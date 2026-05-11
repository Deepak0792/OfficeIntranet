-- =============================================================================================================
-- ENTERPRISE HRMS / PAYROLL EXTENSION
-- SQL SERVER DATABASE SCHEMA
-- Schema: payroll  |  Shared lookup: dbo
-- Compatible: SQL Server 2016+
-- =============================================================================================================
-- PURPOSE:
--   Extends the core HRMS platform with dedicated payroll processing capabilities covering:
--     1. Salary & Compensation     : Employee salary structures, component breakdowns,
--                                    revision history, and effective-date-driven salary records
--     2. Bank Credit & Transactions: Employee bank account details and disbursement
--                                    transaction ledger with bank reference/transaction IDs
--     3. Tax Deductions            : Period-wise statutory and non-statutory tax deduction
--                                    records per employee, including TDS declarations and
--                                    proof submission tracking
--
-- DESIGN PRINCIPLES:
--   - All tables reside in the [payroll] schema to isolate payroll concerns from core HRMS (dbo)
--   - dbo.StatusLookup is the single cross-schema master for ALL workflow status codes.
--     Individual tables carry FK references to it instead of inline CHECK constraints,
--     making status governance centralized and extensible to any future schema (leave,
--     recruitment, appraisal, etc.) without schema-coupling.
--   - Foreign keys reference dbo.Employee, payroll.PayrollComponent, and dbo.LegalEntity
--   - Computed columns are used for derived financial figures (NetPayable, TotalDeduction)
--   - Audit columns (CreatedAt, UpdatedAt) on every table for change tracking
--
-- TABLE CREATION ORDER (respects FK dependencies):
--   0.  dbo.StatusLookup                  <- shared across ALL schemas
--   1.  payroll.TaxProofCategory
--   2.  payroll.SalaryGrade
--   3.  payroll.SalaryStructure
--   4.  payroll.PayrollComponent
--   5.  payroll.SalaryStructureComponent
--   6.  payroll.PayrollAttendanceSummary
--   7.  payroll.EmployeeSalary
--   8.  payroll.EmployeeSalaryComponent
--   9.  payroll.SalaryRevision
--   10. payroll.BankMaster
--   11. payroll.EmployeeBankAccount
--   12. payroll.PayrollDisbursement
--   13. payroll.PayrollDisbursementTransaction
--   14. payroll.TaxRegime
--   15. payroll.TaxSlab
--   16. payroll.EmployeeTaxDeclaration
--   17. payroll.TaxDeclarationItem
--   18. payroll.TaxDeclarationProof
--   19. payroll.EmployeeTaxDeduction
--   20. payroll.TaxDeductionBreakdown
--   21. INDEXES
--   22. VIEWS
-- =============================================================================================================


-- =============================================================================================================
-- SCHEMA CREATION
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'payroll')
    EXEC('CREATE SCHEMA payroll');
GO


-- =============================================================================================================
-- MODULE 0: SHARED LOOKUP  —  dbo.StatusLookup
-- =============================================================================================================
-- Owned by dbo so it is accessible to ALL schemas (payroll, leave, recruitment, appraisal, etc.)
-- without cross-schema coupling.
--
-- StatusGroup partitions codes by domain. Current groups seeded below:
--   DECLARATION_STATUS   -> DRAFT | SUBMITTED | VERIFIED | REJECTED
--   PROOF_REVIEW_STATUS  -> PENDING | APPROVED | REJECTED
--   DISBURSEMENT_STATUS  -> DRAFT | APPROVED | PROCESSING | COMPLETED | FAILED | CANCELLED
--   TRANSACTION_STATUS   -> PENDING | INITIATED | SUCCESS | FAILED | REVERSED
--   SALARY_REVISION_TYPE -> ANNUAL_INCREMENT | PROMOTION | CORRECTION |
--                           JOINING | MARKET_CORRECTION | OTHER
--   BANK_ACCOUNT_TYPE    -> SAVINGS | CURRENT | SALARY
--   CALC_TYPE            -> FIXED | PERCENTAGE | FORMULA
--   DEDUCTION_CATEGORY   -> EXEMPTION | DEDUCTION | TAX | CESS | REBATE
--
-- IsTerminal = 1 signals the application layer that no further transitions are allowed on
-- a record in that status (e.g. a VERIFIED declaration should be locked from edits).
--
-- HOW TO REFERENCE FROM ANY TABLE:
--   Add the status column + a persisted group column, then FK both into dbo.StatusLookup.
--   The composite FK ensures a payroll table accepting ('PENDING','PROOF_REVIEW_STATUS')
--   cannot accidentally accept ('PENDING','TRANSACTION_STATUS') — domain isolation is
--   enforced at the database level, not only at the application layer.
--
--   Example:
--     MyStatus      NVARCHAR(50) NOT NULL DEFAULT 'PENDING',
--     MyStatusGroup AS CAST('PROOF_REVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
--     CONSTRAINT FK_MyTable_MyStatus
--         FOREIGN KEY (MyStatus, MyStatusGroup)
--         REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
-- =============================================================================================================

CREATE TABLE dbo.StatusLookup (
    StatusCode      NVARCHAR(50)    NOT NULL,
    StatusGroup     NVARCHAR(50)    NOT NULL,
    Label           NVARCHAR(100)   NOT NULL,
    Description     NVARCHAR(500)   NULL,
    DisplayOrder    TINYINT         NOT NULL DEFAULT 0,
    IsTerminal      BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_StatusLookup PRIMARY KEY (StatusCode, StatusGroup)
);
GO


-- =============================================================================================================
-- MODULE 0 (continued): payroll.TaxProofCategory
-- =============================================================================================================
-- Master list of income tax declaration sections/categories as defined under the Income Tax Act.
-- Drives form sections, UI visibility per regime, and statutory limit enforcement during proof review.
-- IsApplicableOldRegime / IsApplicableNewRegime controls which categories appear
-- based on the employee's chosen regime.
-- StatutoryMaxLimit: NULL = no statutory cap.
-- RequiresDocument: some categories (e.g. Standard Deduction) are auto-applied
-- and need no proof upload.
-- =============================================================================================================

CREATE TABLE payroll.TaxProofCategory (
    Id                      INT             PRIMARY KEY IDENTITY(1,1),
    CategoryCode            NVARCHAR(20)    NOT NULL
        CONSTRAINT UQ_TPC_CategoryCode UNIQUE,
    CategoryName            NVARCHAR(200)   NOT NULL,
    Section                 NVARCHAR(100)   NULL,
    StatutoryMaxLimit       DECIMAL(18,2)   NULL,
    IsApplicableOldRegime   BIT             NOT NULL DEFAULT 1,
    IsApplicableNewRegime   BIT             NOT NULL DEFAULT 0,
    RequiresDocument        BIT             NOT NULL DEFAULT 1,
    DisplayOrder            TINYINT         NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL
);
GO


-- =============================================================================================================
-- MODULE 1: SALARY & COMPENSATION
-- =============================================================================================================


-- -------------------------------------------------------
-- SALARY GRADE
-- Defines pay bands or grade levels (e.g. L1, L2, Band A).
-- Each grade carries a minimum and maximum CTC boundary
-- to enforce compensation governance across the organization.
-- -------------------------------------------------------
CREATE TABLE payroll.SalaryGrade (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    GradeCode       NVARCHAR(50)    NOT NULL UNIQUE,
    GradeName       NVARCHAR(200)   NOT NULL,
    MinCTC          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    MaxCTC          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CurrencyCode    NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt       DATETIME2       NULL
);


-- -------------------------------------------------------
-- SALARY STRUCTURE
-- A named template that groups salary components and their
-- computation rules (e.g. "Standard Monthly - India",
-- "Contractual - UAE"). Structures are versioned and tied
-- to a legal entity to support multi-country payroll.
-- Multiple structures can coexist; IsDefault flags the
-- fallback structure when no explicit assignment is found.
-- -------------------------------------------------------
CREATE TABLE payroll.SalaryStructure (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    StructureCode   NVARCHAR(100)   NOT NULL UNIQUE,
    StructureName   NVARCHAR(200)   NOT NULL,
    LegalEntityId   BIGINT          NOT NULL,
    CurrencyCode    NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    VersionNo       INT             NOT NULL DEFAULT 1,
    IsDefault       BIT             NOT NULL DEFAULT 0,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt       DATETIME2       NULL,

    CONSTRAINT FK_SalaryStructure_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES dbo.LegalEntity(Id)
);


-- =============================================================================================================
-- MODULE 2: PAYROLL COMPONENTS & ATTENDANCE
-- =============================================================================================================


-- -------------------------------------------------------
-- PAYROLL COMPONENT
-- Defines payroll earning and deduction heads
-- (e.g. Basic, HRA, PF). IsEarning and IsDeduction are
-- non-exclusive — a component may appear on both sides
-- (e.g. PF_ER is an employer earning/CTC head but not a
-- deduction; PF_EMP is a deduction from gross).
-- -------------------------------------------------------
CREATE TABLE payroll.PayrollComponent (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    ComponentCode   NVARCHAR(100)   NOT NULL UNIQUE,
    ComponentName   NVARCHAR(200)   NOT NULL,
    IsEarning       BIT             NOT NULL DEFAULT 1,
    IsDeduction     BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- SALARY STRUCTURE COMPONENT
-- Maps payroll components (earnings/deductions) to a salary
-- structure and defines how each component is calculated.
-- CalculationType references dbo.StatusLookup (CALC_TYPE):
--   FIXED | PERCENTAGE | FORMULA
-- BaseComponentId: used when CalculationType = PERCENTAGE,
--   allowing one component to be derived as a % of another
--   (e.g. HRA = 40% of Basic).
-- SortOrder controls the display sequence on payslips.
-- -------------------------------------------------------
CREATE TABLE payroll.SalaryStructureComponent (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    SalaryStructureId   BIGINT          NOT NULL,
    PayrollComponentId  BIGINT          NOT NULL,
    CalculationType     NVARCHAR(50)    NOT NULL DEFAULT 'FIXED',
    CalculationTypeGroup AS CAST('CALC_TYPE' AS NVARCHAR(50)) PERSISTED,
    PercentageValue     DECIMAL(10,4)   NULL,
    BaseComponentId     BIGINT          NULL,
    FormulaExpression   NVARCHAR(2000)  NULL,
    IsStatutory         BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    SortOrder           INT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SSC_SalaryStructure
        FOREIGN KEY (SalaryStructureId)
        REFERENCES payroll.SalaryStructure(Id),

    CONSTRAINT FK_SSC_PayrollComponent
        FOREIGN KEY (PayrollComponentId)
        REFERENCES payroll.PayrollComponent(Id),

    CONSTRAINT FK_SSC_BaseComponent
        FOREIGN KEY (BaseComponentId)
        REFERENCES payroll.SalaryStructureComponent(Id),

    CONSTRAINT FK_SSC_CalcType
        FOREIGN KEY (CalculationType, CalculationTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- PAYROLL ATTENDANCE SUMMARY
-- Aggregated monthly attendance figures used by payroll
-- processing; one record per employee per payroll month/year.
-- -------------------------------------------------------
CREATE TABLE payroll.PayrollAttendanceSummary (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    PayrollMonth        INT             NOT NULL,
    PayrollYear         INT             NOT NULL,
    TotalWorkingDays    DECIMAL(10,2)   NOT NULL,
    PresentDays         DECIMAL(10,2)   NOT NULL,
    LeaveDays           DECIMAL(10,2)   NOT NULL DEFAULT 0,
    AbsentDays          DECIMAL(10,2)   NOT NULL DEFAULT 0,
    OvertimeMinutes     INT             NOT NULL DEFAULT 0,
    ProcessedAt         DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_PayrollAttendanceSummary
        UNIQUE (EmployeeId, PayrollMonth, PayrollYear),

    CONSTRAINT FK_PayrollAttendanceSummary_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE SALARY
-- Master salary record for each employee capturing the
-- overall CTC, gross, and net salary figures for a given
-- effective period. Supports time-bound salary assignments
-- (EffectiveFrom / EffectiveTo) so historical records
-- are retained. IsActive = 1 identifies the current record.
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeSalary (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    SalaryStructureId   BIGINT          NOT NULL,
    SalaryGradeId       BIGINT          NULL,
    AnnualCTC           DECIMAL(18,2)   NOT NULL,
    MonthlyCTC          DECIMAL(18,2)   NOT NULL,
    MonthlyGross        DECIMAL(18,2)   NOT NULL,
    MonthlyNet          DECIMAL(18,2)   NOT NULL,
    CurrencyCode        NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    EffectiveFrom       DATE            NOT NULL,
    EffectiveTo         DATE            NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    Remarks             NVARCHAR(1000)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_EmployeeSalary_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeSalary_Structure
        FOREIGN KEY (SalaryStructureId)
        REFERENCES payroll.SalaryStructure(Id),

    CONSTRAINT FK_EmployeeSalary_Grade
        FOREIGN KEY (SalaryGradeId)
        REFERENCES payroll.SalaryGrade(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE SALARY COMPONENT
-- Stores the computed/actual monetary value of each salary
-- component for a given EmployeeSalary record and payroll
-- month. One row per component per month per employee.
-- This table serves as the detailed payslip line-item source.
-- ComputedAmount is the system-calculated value;
-- OverrideAmount allows HR to manually override for a month.
-- FinalAmount = COALESCE(OverrideAmount, ComputedAmount).
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeSalaryComponent (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeSalaryId            BIGINT          NOT NULL,
    SalaryStructureComponentId  BIGINT          NOT NULL,
    PayrollMonth                INT             NOT NULL,
    PayrollYear                 INT             NOT NULL,
    ComputedAmount              DECIMAL(18,2)   NOT NULL DEFAULT 0,
    OverrideAmount              DECIMAL(18,2)   NULL,
    FinalAmount                 AS (COALESCE(OverrideAmount, ComputedAmount)),
    OverrideReason              NVARCHAR(500)   NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ESC_EmployeeSalary
        FOREIGN KEY (EmployeeSalaryId) 
        REFERENCES payroll.EmployeeSalary(Id),

    CONSTRAINT FK_ESC_StructureComponent
        FOREIGN KEY (SalaryStructureComponentId) 
        REFERENCES payroll.SalaryStructureComponent(Id),

    CONSTRAINT UQ_EmployeeSalaryComponent
        UNIQUE (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear)
);


-- -------------------------------------------------------
-- SALARY REVISION
-- Tracks every compensation change event for an employee,
-- capturing the before and after CTC values, the reason
-- for the revision, and who approved it.
-- RevisionType references dbo.StatusLookup (SALARY_REVISION_TYPE).
-- -------------------------------------------------------
CREATE TABLE payroll.SalaryRevision (
    Id                   BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId           BIGINT          NOT NULL,
    OldEmployeeSalaryId  BIGINT          NULL,
    NewEmployeeSalaryId  BIGINT          NOT NULL,
    RevisionType         NVARCHAR(50)    NOT NULL,
    RevisionTypeGroup    AS CAST('SALARY_REVISION_TYPE' AS NVARCHAR(50)) PERSISTED,
    RevisionDate         DATE            NOT NULL,
    OldAnnualCTC         DECIMAL(18,2)   NULL,
    NewAnnualCTC         DECIMAL(18,2)   NOT NULL,
    IncrementAmount      AS (NewAnnualCTC - ISNULL(OldAnnualCTC, 0)),
    IncrementPercentage  DECIMAL(10,4)   NULL,
    Reason               NVARCHAR(2000)  NULL,
    ApprovedBy           BIGINT          NULL,
    ApprovedAt           DATETIME2       NULL,
    CreatedAt            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SalaryRevision_Employee
        FOREIGN KEY (EmployeeId)
         REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_SalaryRevision_OldSalary
        FOREIGN KEY (OldEmployeeSalaryId) 
        REFERENCES payroll.EmployeeSalary(Id),

    CONSTRAINT FK_SalaryRevision_NewSalary
        FOREIGN KEY (NewEmployeeSalaryId) 
        REFERENCES payroll.EmployeeSalary(Id),

    CONSTRAINT FK_SalaryRevision_ApprovedBy
        FOREIGN KEY (ApprovedBy) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_SalaryRevision_RevisionType
        FOREIGN KEY (RevisionType, RevisionTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- MODULE 3: BANK CREDIT & TRANSACTIONS
-- =============================================================================================================


-- -------------------------------------------------------
-- BANK MASTER
-- Reference table of banks supported for payroll credit.
-- Stores IFSC prefix, SWIFT code, and routing identifiers
-- for both domestic (NEFT/RTGS) and international wires.
-- -------------------------------------------------------
CREATE TABLE payroll.BankMaster (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    BankCode        NVARCHAR(50)    NOT NULL UNIQUE,
    BankName        NVARCHAR(300)   NOT NULL,
    IfscPrefix      NVARCHAR(10)    NULL,
    SwiftCode       NVARCHAR(20)    NULL,
    CountryCode     NVARCHAR(10)    NOT NULL DEFAULT 'IN',
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- EMPLOYEE BANK ACCOUNT
-- Stores an employee's bank account details for salary
-- credit. Supports multiple accounts per employee;
-- IsPrimary identifies the default disbursement account.
-- AccountType references dbo.StatusLookup (BANK_ACCOUNT_TYPE):
--   SAVINGS | CURRENT | SALARY
-- IsVerified indicates Finance sign-off before disbursement.
-- Sensitive fields (AccountNumber) should be encrypted at
-- the application layer before persistence.
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeBankAccount (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    BankMasterId        BIGINT          NOT NULL,
    AccountHolderName   NVARCHAR(300)   NOT NULL,
    AccountNumber       NVARCHAR(100)   NOT NULL,
    AccountType         NVARCHAR(50)    NOT NULL DEFAULT 'SAVINGS',
    AccountTypeGroup    AS CAST('BANK_ACCOUNT_TYPE' AS NVARCHAR(50)) PERSISTED,
    IfscCode            NVARCHAR(20)    NULL,
    SwiftCode           NVARCHAR(20)    NULL,
    BranchName          NVARCHAR(300)   NULL,
    BankAddress         NVARCHAR(500)   NULL,
    CurrencyCode        NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    IsPrimary           BIT             NOT NULL DEFAULT 0,
    IsVerified          BIT             NOT NULL DEFAULT 0,
    VerifiedBy          BIGINT          NULL,
    VerifiedAt          DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_EBA_Employee
        FOREIGN KEY (EmployeeId) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EBA_BankMaster
        FOREIGN KEY (BankMasterId) 
        REFERENCES payroll.BankMaster(Id),

    CONSTRAINT FK_EBA_VerifiedBy
        FOREIGN KEY (VerifiedBy) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EBA_AccountType
        FOREIGN KEY (AccountType, AccountTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- PAYROLL DISBURSEMENT
-- Represents a payroll run (salary credit batch) for a
-- specific payroll month and year within a legal entity.
-- DisbursementStatus references dbo.StatusLookup (DISBURSEMENT_STATUS):
--   DRAFT -> APPROVED -> PROCESSING -> COMPLETED | FAILED | CANCELLED
-- BankBatchReferenceNo is the batch ID returned by the bank
-- or payment gateway upon successful submission.
-- -------------------------------------------------------
CREATE TABLE payroll.PayrollDisbursement (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    LegalEntityId           BIGINT          NOT NULL,
    PayrollMonth            INT             NOT NULL,
    PayrollYear             INT             NOT NULL,
    DisbursementDate        DATE            NULL,
    TotalEmployeeCount      INT             NOT NULL DEFAULT 0,
    TotalNetPayable         DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    DisbursementStatus      NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    DisbursementStatusGroup AS CAST('DISBURSEMENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    BankBatchReferenceNo    NVARCHAR(200)   NULL,
    InitiatedBy             BIGINT          NOT NULL,
    ApprovedBy              BIGINT          NULL,
    ApprovedAt              DATETIME2       NULL,
    ProcessedAt             DATETIME2       NULL,
    Remarks                 NVARCHAR(1000)  NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_PD_LegalEntity
        FOREIGN KEY (LegalEntityId) 
        REFERENCES dbo.LegalEntity(Id),

    CONSTRAINT FK_PD_InitiatedBy
        FOREIGN KEY (InitiatedBy) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PD_ApprovedBy
        FOREIGN KEY (ApprovedBy) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PD_DisbursementStatus
        FOREIGN KEY (DisbursementStatus, DisbursementStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT UQ_PayrollDisbursement
        UNIQUE (LegalEntityId, PayrollMonth, PayrollYear)
);


-- -------------------------------------------------------
-- PAYROLL DISBURSEMENT TRANSACTION
-- Individual salary credit transaction for each employee
-- within a payroll disbursement batch.
-- TransactionStatus references dbo.StatusLookup (TRANSACTION_STATUS):
--   PENDING -> INITIATED -> SUCCESS | FAILED | REVERSED
-- BankTransactionId is the unique reference returned by
-- the bank or payment rail (NEFT/RTGS/IMPS/SWIFT).
-- FailureReason stores the bank-returned error for retry/resolution.
-- -------------------------------------------------------
CREATE TABLE payroll.PayrollDisbursementTransaction (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    PayrollDisbursementId   BIGINT          NOT NULL,
    EmployeeId              BIGINT          NOT NULL,
    EmployeeBankAccountId   BIGINT          NOT NULL,
    PayrollMonth            INT             NOT NULL,
    PayrollYear             INT             NOT NULL,
    GrossAmount             DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalDeductions         DECIMAL(18,2)   NOT NULL DEFAULT 0,
    NetAmountCredited       AS (GrossAmount - TotalDeductions),
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    TransactionStatus       NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    TransactionStatusGroup  AS CAST('TRANSACTION_STATUS' AS NVARCHAR(50)) PERSISTED,
    BankTransactionId       NVARCHAR(300)   NULL,
    PaymentMode             NVARCHAR(50)    NULL,
    InitiatedAt             DATETIME2       NULL,
    ConfirmedAt             DATETIME2       NULL,
    FailureReason           NVARCHAR(1000)  NULL,
    RetryCount              INT             NOT NULL DEFAULT 0,
    IsManualCredit          BIT             NOT NULL DEFAULT 0,
    Remarks                 NVARCHAR(1000)  NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_PDT_Disbursement
        FOREIGN KEY (PayrollDisbursementId) 
        REFERENCES payroll.PayrollDisbursement(Id),

    CONSTRAINT FK_PDT_Employee
        FOREIGN KEY (EmployeeId) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PDT_BankAccount
        FOREIGN KEY (EmployeeBankAccountId) 
        REFERENCES payroll.EmployeeBankAccount(Id),

    CONSTRAINT FK_PDT_TransactionStatus
        FOREIGN KEY (TransactionStatus, TransactionStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT UQ_DisbursementTransaction
        UNIQUE (PayrollDisbursementId, EmployeeId)
);


-- =============================================================================================================
-- MODULE 4: TAX DEDUCTIONS
-- =============================================================================================================


-- -------------------------------------------------------
-- TAX REGIME
-- Defines tax regimes applicable to employees
-- (e.g. India Old Regime, India New Regime, UAE, US Federal).
-- -------------------------------------------------------
CREATE TABLE payroll.TaxRegime (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    RegimeCode      NVARCHAR(100)   NOT NULL UNIQUE,
    RegimeName      NVARCHAR(300)   NOT NULL,
    CountryCode     NVARCHAR(10)    NOT NULL,
    FiscalYearStart NVARCHAR(10)    NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- TAX SLAB
-- Stores income tax slab brackets for a given tax regime
-- and fiscal year. MinIncome / MaxIncome define the bracket;
-- MaxIncome NULL implies the top slab with no upper bound.
-- TaxRate expressed as a percentage (e.g. 30.00 = 30%).
-- SurchargeRate and CessRate capture additional levies
-- (e.g. India's 4% Health & Education Cess).
-- -------------------------------------------------------
CREATE TABLE payroll.TaxSlab (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    TaxRegimeId     BIGINT          NOT NULL,
    FiscalYear      INT             NOT NULL,
    SlabOrder       INT             NOT NULL,
    MinIncome       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    MaxIncome       DECIMAL(18,2)   NULL,
    TaxRate         DECIMAL(10,4)   NOT NULL DEFAULT 0,
    SurchargeRate   DECIMAL(10,4)   NOT NULL DEFAULT 0,
    CessRate        DECIMAL(10,4)   NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TaxSlab_TaxRegime
        FOREIGN KEY (TaxRegimeId) 
        REFERENCES payroll.TaxRegime(Id),

    CONSTRAINT UQ_TaxSlab
        UNIQUE (TaxRegimeId, FiscalYear, SlabOrder)
);


-- -------------------------------------------------------
-- EMPLOYEE TAX DECLARATION
-- Captures an employee's income tax investment declaration
-- (Form 12BB equivalent) for a fiscal year.
-- DeclarationStatus references dbo.StatusLookup (DECLARATION_STATUS):
--   DRAFT -> SUBMITTED -> VERIFIED | REJECTED
-- EstimatedTaxableIncome is PERSISTED to allow indexing.
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeTaxDeclaration (
    Id                       BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId               BIGINT          NOT NULL,
    TaxRegimeId              BIGINT          NOT NULL,
    FiscalYear               INT             NOT NULL
        CONSTRAINT CK_ETD_FiscalYear CHECK (FiscalYear BETWEEN 2000 AND 2099),
    DeclaredTotalIncome      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    DeclaredExemptions       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    DeclaredDeductions       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    EstimatedTaxableIncome   AS (DeclaredTotalIncome - DeclaredExemptions - DeclaredDeductions) PERSISTED,
    DeclarationStatus        NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    DeclarationStatusGroup   AS CAST('DECLARATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    SubmittedAt              DATETIME2       NULL,
    VerifiedBy               BIGINT          NULL,
    VerifiedAt               DATETIME2       NULL,
    Remarks                  NVARCHAR(2000)  NULL,
    CreatedAt                DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                DATETIME2       NULL,

    CONSTRAINT UQ_EmployeeTaxDeclaration
        UNIQUE (EmployeeId, FiscalYear),

    CONSTRAINT FK_ETD_Employee
        FOREIGN KEY (EmployeeId) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ETD_TaxRegime
        FOREIGN KEY (TaxRegimeId) 
        REFERENCES payroll.TaxRegime(Id),

    CONSTRAINT FK_ETD_VerifiedBy
        FOREIGN KEY (VerifiedBy) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ETD_DeclarationStatus
        FOREIGN KEY (DeclarationStatus, DeclarationStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- TAX DECLARATION ITEM
-- Line-item breakdown of a declaration — one row per
-- IT section claimed by the employee.
-- e.g. Rs 1,50,000 under 80C; Rs 24,000 under 80D.
-- DeclaredAmount:  What the employee claims at declaration time.
-- ApprovedAmount:  Finalised by Finance after proof review;
--                  may be less than declared if proof is partial.
-- Source of truth for TDS computation; header-level
-- aggregates in EmployeeTaxDeclaration are recomputed
-- from this table on SUBMIT.
-- -------------------------------------------------------
CREATE TABLE payroll.TaxDeclarationItem (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeTaxDeclarationId    BIGINT          NOT NULL,
    TaxProofCategoryId          INT             NOT NULL,
    DeclaredAmount              DECIMAL(18,2)   NOT NULL DEFAULT 0
        CONSTRAINT CK_TDI_DeclaredAmount CHECK (DeclaredAmount >= 0),
    ApprovedAmount              DECIMAL(18,2)   NULL
        CONSTRAINT CK_TDI_ApprovedAmount CHECK (ApprovedAmount IS NULL OR ApprovedAmount >= 0),
    Remarks                     NVARCHAR(500)   NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT UQ_TDI_DeclarationCategory
        UNIQUE (EmployeeTaxDeclarationId, TaxProofCategoryId),

    CONSTRAINT FK_TDI_Declaration
        FOREIGN KEY (EmployeeTaxDeclarationId) 
        REFERENCES payroll.EmployeeTaxDeclaration(Id),

    CONSTRAINT FK_TDI_Category
        FOREIGN KEY (TaxProofCategoryId) 
        REFERENCES payroll.TaxProofCategory(Id)
);


-- -------------------------------------------------------
-- TAX DECLARATION PROOF
-- Stores uploaded proof documents submitted by employees
-- against a specific declaration line item.
-- One item can have multiple proof documents
-- (e.g. 12 monthly rent receipts for HRA).
-- ReviewStatus references dbo.StatusLookup (PROOF_REVIEW_STATUS):
--   PENDING -> APPROVED | REJECTED
-- DocumentFileUrl should point to secure blob/S3 storage;
-- never store file binaries in the database.
-- -------------------------------------------------------
CREATE TABLE payroll.TaxDeclarationProof (
    Id                   BIGINT          PRIMARY KEY IDENTITY(1,1),
    TaxDeclarationItemId BIGINT          NOT NULL,
    Description          NVARCHAR(500)   NULL,
    DeclaredAmount       DECIMAL(18,2)   NOT NULL DEFAULT 0
        CONSTRAINT CK_TDP_DeclaredAmount CHECK (DeclaredAmount >= 0),
    ApprovedAmount       DECIMAL(18,2)   NULL
        CONSTRAINT CK_TDP_ApprovedAmount CHECK (ApprovedAmount IS NULL OR ApprovedAmount >= 0),
    DocumentFileUrl      NVARCHAR(1000)  NULL,
    OriginalFileName     NVARCHAR(500)   NULL,
    UploadedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    ReviewStatus         NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ReviewStatusGroup    AS CAST('PROOF_REVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
    ReviewedBy           BIGINT          NULL,
    ReviewedAt           DATETIME2       NULL,
    RejectionReason      NVARCHAR(500)   NULL,
    CreatedAt            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TDP_DeclarationItem
        FOREIGN KEY (TaxDeclarationItemId) 
        REFERENCES payroll.TaxDeclarationItem(Id),

    CONSTRAINT FK_TDP_ReviewedBy
        FOREIGN KEY (ReviewedBy) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_TDP_ReviewStatus
        FOREIGN KEY (ReviewStatus, ReviewStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- EMPLOYEE TAX DEDUCTION
-- Stores the total TDS for each employee per payroll month.
-- Header-level record; detailed breakdown in TaxDeductionBreakdown.
-- CumulativeTDSYTD = running year-to-date TDS (Form 16 / year-end).
-- IsAdjustment flags retrospective TDS corrections.
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeTaxDeduction (
    Id                               BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                       BIGINT          NOT NULL,
    EmployeeTaxDeclarationId         BIGINT          NULL,
    TaxRegimeId                      BIGINT          NOT NULL,
    PayrollMonth                     INT             NOT NULL,
    PayrollYear                      INT             NOT NULL,
    FiscalYear                       INT             NOT NULL,
    GrossIncome                      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalExemptions                  DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalDeductions                  DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TaxableIncome                    AS (GrossIncome - TotalExemptions - TotalDeductions),
    TDSAmount                        DECIMAL(18,2)   NOT NULL DEFAULT 0,
    SurchargeAmount                  DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CessAmount                       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalTaxDeducted                 AS (TDSAmount + SurchargeAmount + CessAmount),
    CumulativeTDSYTD                 DECIMAL(18,2)   NOT NULL DEFAULT 0,
    IsAdjustment                     BIT             NOT NULL DEFAULT 0,
    AdjustmentReason                 NVARCHAR(500)   NULL,
    PayrollDisbursementTransactionId BIGINT          NULL,
    CreatedAt                        DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                        DATETIME2       NULL,

    CONSTRAINT UQ_EmployeeTaxDeduction
        UNIQUE (EmployeeId, PayrollMonth, PayrollYear),

    CONSTRAINT FK_ETaxDed_Employee
        FOREIGN KEY (EmployeeId) 
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ETaxDed_Declaration
        FOREIGN KEY (EmployeeTaxDeclarationId) 
        REFERENCES payroll.EmployeeTaxDeclaration(Id),

    CONSTRAINT FK_ETaxDed_TaxRegime
        FOREIGN KEY (TaxRegimeId) 
        REFERENCES payroll.TaxRegime(Id),

    CONSTRAINT FK_ETaxDed_DisbursementTransaction
        FOREIGN KEY (PayrollDisbursementTransactionId)
        REFERENCES payroll.PayrollDisbursementTransaction(Id)
);


-- -------------------------------------------------------
-- TAX DEDUCTION BREAKDOWN
-- Line-item breakdown of tax deductions per employee per
-- payroll month. Each row = one section or deduction head.
-- DeductionHead examples:
--   STANDARD_DEDUCTION, HRA_EXEMPTION, SECTION_80C,
--   SECTION_80D, LTA_EXEMPTION, SURCHARGE, CESS,
--   PROFESSIONAL_TAX, REBATE_87A
-- DeductionCategory references dbo.StatusLookup (DEDUCTION_CATEGORY):
--   EXEMPTION | DEDUCTION | TAX | CESS | REBATE
-- Supports Form 16 Part-B generation and audit trails.
-- -------------------------------------------------------
CREATE TABLE payroll.TaxDeductionBreakdown (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeTaxDeductionId  BIGINT          NOT NULL,
    DeductionHead           NVARCHAR(200)   NOT NULL,
    DeductionCategory       NVARCHAR(50)    NULL,
    DeductionCategoryGroup  AS CAST('DEDUCTION_CATEGORY' AS NVARCHAR(50)) PERSISTED,
    DeclaredAmount          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ApprovedAmount          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ActualDeductionAmount   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Remarks                 NVARCHAR(500)   NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TaxBreakdown_TaxDeduction
        FOREIGN KEY (EmployeeTaxDeductionId)
         REFERENCES payroll.EmployeeTaxDeduction(Id),

    CONSTRAINT FK_TaxBreakdown_DeductionCategory
        FOREIGN KEY (DeductionCategory, DeductionCategoryGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- INDEXES
-- =============================================================================================================

-- Status Lookup  (speeds up UI dropdowns filtered by StatusGroup)
CREATE NONCLUSTERED INDEX IX_StatusLookup_Group
    ON dbo.StatusLookup (StatusGroup, IsActive)
    INCLUDE (StatusCode, Label, DisplayOrder, IsTerminal);

-- Salary Structure
CREATE NONCLUSTERED INDEX IX_SalaryStructure_LegalEntity
    ON payroll.SalaryStructure (LegalEntityId);

-- Employee Salary
CREATE NONCLUSTERED INDEX IX_EmployeeSalary_Employee
    ON payroll.EmployeeSalary (EmployeeId, EffectiveFrom, EffectiveTo);

CREATE NONCLUSTERED INDEX IX_EmployeeSalary_Structure
    ON payroll.EmployeeSalary (SalaryStructureId);

-- Payroll Attendance Summary
CREATE NONCLUSTERED INDEX IX_PayrollAttendanceSummary_Employee
    ON payroll.PayrollAttendanceSummary (EmployeeId, PayrollMonth, PayrollYear);

-- Employee Salary Component
CREATE NONCLUSTERED INDEX IX_ESC_EmployeeSalary_Month
    ON payroll.EmployeeSalaryComponent (EmployeeSalaryId, PayrollYear, PayrollMonth);

-- Salary Revision
CREATE NONCLUSTERED INDEX IX_SalaryRevision_Employee
    ON payroll.SalaryRevision (EmployeeId, RevisionDate);

-- Employee Bank Account
CREATE NONCLUSTERED INDEX IX_EBA_Employee
    ON payroll.EmployeeBankAccount (EmployeeId);

-- Payroll Disbursement
CREATE NONCLUSTERED INDEX IX_PayrollDisbursement_LegalEntity_Period
    ON payroll.PayrollDisbursement (LegalEntityId, PayrollYear, PayrollMonth);

CREATE NONCLUSTERED INDEX IX_PayrollDisbursement_Status
    ON payroll.PayrollDisbursement (DisbursementStatus);

-- Payroll Disbursement Transaction
CREATE NONCLUSTERED INDEX IX_PDT_Disbursement_Employee
    ON payroll.PayrollDisbursementTransaction (PayrollDisbursementId, EmployeeId);

CREATE NONCLUSTERED INDEX IX_PDT_BankTransactionId
    ON payroll.PayrollDisbursementTransaction (BankTransactionId)
    WHERE BankTransactionId IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_PDT_Status
    ON payroll.PayrollDisbursementTransaction (TransactionStatus);

-- Employee Tax Declaration
CREATE NONCLUSTERED INDEX IX_ETD_Employee_FiscalYear
    ON payroll.EmployeeTaxDeclaration (EmployeeId, FiscalYear)
    INCLUDE (DeclarationStatus, EstimatedTaxableIncome);

CREATE NONCLUSTERED INDEX IX_ETD_FiscalYear_Status
    ON payroll.EmployeeTaxDeclaration (FiscalYear, DeclarationStatus);

-- Tax Declaration Item
CREATE NONCLUSTERED INDEX IX_TDI_DeclarationId
    ON payroll.TaxDeclarationItem (EmployeeTaxDeclarationId)
    INCLUDE (TaxProofCategoryId, DeclaredAmount, ApprovedAmount);

-- Tax Declaration Proof
CREATE NONCLUSTERED INDEX IX_TDP_ItemId
    ON payroll.TaxDeclarationProof (TaxDeclarationItemId)
    INCLUDE (ReviewStatus, DeclaredAmount, ApprovedAmount);

CREATE NONCLUSTERED INDEX IX_TDP_ReviewStatus_Pending
    ON payroll.TaxDeclarationProof (ReviewStatus)
    WHERE ReviewStatus = 'PENDING';

-- Employee Tax Deduction
CREATE NONCLUSTERED INDEX IX_ETaxDed_Employee_Period
    ON payroll.EmployeeTaxDeduction (EmployeeId, PayrollYear, PayrollMonth);

CREATE NONCLUSTERED INDEX IX_ETaxDed_FiscalYear
    ON payroll.EmployeeTaxDeduction (EmployeeId, FiscalYear);

-- Tax Deduction Breakdown
CREATE NONCLUSTERED INDEX IX_TaxBreakdown_Deduction
    ON payroll.TaxDeductionBreakdown (EmployeeTaxDeductionId);


-- =============================================================================================================
-- VIEWS
-- =============================================================================================================

-- Full declaration summary with item-level rollup.
-- Joins dbo.StatusLookup to surface Label and IsTerminal (lock flag) directly.
GO
CREATE OR ALTER VIEW payroll.vw_EmployeeDeclarationSummary AS
SELECT
    etd.Id                          AS DeclarationId,
    etd.EmployeeId,
    etd.FiscalYear,
    etd.DeclarationStatus,
    sl.Label                        AS DeclarationStatusLabel,
    sl.IsTerminal                   AS IsDeclarationLocked,
    etd.TaxRegimeId,
    etd.DeclaredTotalIncome,
    etd.DeclaredExemptions,
    etd.DeclaredDeductions,
    etd.EstimatedTaxableIncome,
    COUNT(tdi.Id)                   AS TotalLineItems,
    SUM(tdi.DeclaredAmount)         AS TotalItemsDeclared,
    SUM(tdi.ApprovedAmount)         AS TotalItemsApproved,
    etd.SubmittedAt,
    etd.VerifiedAt,
    etd.CreatedAt
FROM payroll.EmployeeTaxDeclaration etd
INNER JOIN dbo.StatusLookup sl
    ON  sl.StatusCode  = etd.DeclarationStatus
    AND sl.StatusGroup = 'DECLARATION_STATUS'
LEFT JOIN payroll.TaxDeclarationItem tdi
    ON tdi.EmployeeTaxDeclarationId = etd.Id
GROUP BY
    etd.Id, etd.EmployeeId, etd.FiscalYear, etd.DeclarationStatus,
    sl.Label, sl.IsTerminal, etd.TaxRegimeId,
    etd.DeclaredTotalIncome, etd.DeclaredExemptions,
    etd.DeclaredDeductions, etd.EstimatedTaxableIncome,
    etd.SubmittedAt, etd.VerifiedAt, etd.CreatedAt;
GO

-- Finance team pending proof review queue.
CREATE OR ALTER VIEW payroll.vw_PendingProofReview AS
SELECT
    tdp.Id                          AS ProofId,
    etd.EmployeeId,
    etd.FiscalYear,
    tpc.CategoryCode,
    tpc.CategoryName,
    tpc.StatutoryMaxLimit,
    tdi.DeclaredAmount              AS ItemDeclaredAmount,
    tdp.DeclaredAmount              AS ProofDeclaredAmount,
    tdp.Description,
    tdp.DocumentFileUrl,
    tdp.OriginalFileName,
    tdp.UploadedAt,
    tdp.ReviewStatus,
    sl.Label                        AS ReviewStatusLabel
FROM payroll.TaxDeclarationProof tdp
INNER JOIN dbo.StatusLookup sl
    ON  sl.StatusCode  = tdp.ReviewStatus
    AND sl.StatusGroup = 'PROOF_REVIEW_STATUS'
INNER JOIN payroll.TaxDeclarationItem tdi
    ON tdi.Id = tdp.TaxDeclarationItemId
INNER JOIN payroll.EmployeeTaxDeclaration etd
    ON etd.Id = tdi.EmployeeTaxDeclarationId
INNER JOIN payroll.TaxProofCategory tpc
    ON tpc.Id = tdi.TaxProofCategoryId
WHERE tdp.ReviewStatus = 'PENDING';
GO


-- =============================================================================================================
-- END OF SCHEMA: payroll  |  Shared: dbo.StatusLookup
-- =============================================================================================================