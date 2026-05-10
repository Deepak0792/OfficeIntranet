-- =============================================================================================================
-- ENTERPRISE HRMS / PAYROLL EXTENSION
-- SQL SERVER DATABASE SCHEMA
-- Schema: payroll
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
--   - Foreign keys reference dbo.Employee, dbo.PayrollComponent, and dbo.LegalEntity
--   - Computed columns are used for derived financial figures (NetPayable, TotalDeduction)
--   - Audit columns (CreatedAt, UpdatedAt) on every table for change tracking
--   - No free-text status fields; all statuses are lookup/master-driven
--
-- MODULES:
--   1. Salary & Compensation  : SalaryGrade, SalaryStructure, SalaryStructureComponent,
--                               EmployeeSalary, EmployeeSalaryComponent, SalaryRevision
--   2. Bank Credit            : BankMaster, EmployeeBankAccount, PayrollDisbursement,
--                               PayrollDisbursementTransaction
--   3. Tax Deductions         : TaxRegime, TaxSlab, EmployeeTaxDeclaration,
--                               TaxDeclarationProof, EmployeeTaxDeduction,
--                               TaxDeductionBreakdown
-- =============================================================================================================


-- =============================================================================================================
-- SCHEMA CREATION
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'payroll')
BEGIN
    EXEC('CREATE SCHEMA payroll');
END;
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
    LegalEntityId   BIGINT          NOT NULL,       -- references dbo.LegalEntity(Id)
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


-- -------------------------------------------------------
-- SALARY STRUCTURE COMPONENT
-- Maps payroll components (earnings/deductions) to a salary
-- structure and defines how each component is calculated.
-- CalculationType: FIXED | PERCENTAGE | FORMULA
-- BaseComponentId: used when CalculationType = PERCENTAGE,
--   allowing one component to be derived as a % of another
--   (e.g. HRA = 40% of Basic).
-- SortOrder controls the display sequence on payslips.
-- -------------------------------------------------------
CREATE TABLE payroll.SalaryStructureComponent (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    SalaryStructureId   BIGINT          NOT NULL,
    PayrollComponentId  BIGINT          NOT NULL,   -- references dbo.PayrollComponent(Id)
    CalculationType     NVARCHAR(20)    NOT NULL    -- FIXED | PERCENTAGE | FORMULA
        CONSTRAINT CK_SSC_CalcType CHECK (CalculationType IN ('FIXED','PERCENTAGE','FORMULA')),
    PercentageValue     DECIMAL(10,4)   NULL,       -- used when CalculationType = PERCENTAGE
    BaseComponentId     BIGINT          NULL,       -- references payroll.SalaryStructureComponent(Id)
    FormulaExpression   NVARCHAR(2000)  NULL,       -- used when CalculationType = FORMULA
    IsStatutory         BIT             NOT NULL DEFAULT 0,  -- e.g. PF, ESI, Gratuity
    IsActive            BIT             NOT NULL DEFAULT 1,
    SortOrder           INT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SSC_SalaryStructure
        FOREIGN KEY (SalaryStructureId)
        REFERENCES payroll.SalaryStructure(Id),

    CONSTRAINT FK_SSC_PayrollComponent
        FOREIGN KEY (PayrollComponentId)
        REFERENCES dbo.PayrollComponent(Id),

    CONSTRAINT FK_SSC_BaseComponent
        FOREIGN KEY (BaseComponentId)
        REFERENCES payroll.SalaryStructureComponent(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE SALARY
-- Master salary record for each employee capturing the
-- overall CTC, gross, and net salary figures for a given
-- effective period. Supports time-bound salary assignments
-- (EffectiveFrom / EffectiveTo) so historical records
-- are retained. IsActive = 1 identifies the current record.
-- CurrencyCode allows multi-currency payroll.
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeSalary (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,   -- references dbo.Employee(Id)
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
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeSalaryId        BIGINT          NOT NULL,
    SalaryStructureComponentId BIGINT       NOT NULL,
    PayrollMonth            INT             NOT NULL,
    PayrollYear             INT             NOT NULL,
    ComputedAmount          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    OverrideAmount          DECIMAL(18,2)   NULL,
    FinalAmount             AS (COALESCE(OverrideAmount, ComputedAmount)),
    OverrideReason          NVARCHAR(500)   NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

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
-- RevisionType: ANNUAL_INCREMENT | PROMOTION | CORRECTION |
--               JOINING | MARKET_CORRECTION | OTHER
-- This provides a complete audit trail of all salary changes.
-- -------------------------------------------------------
CREATE TABLE payroll.SalaryRevision (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    OldEmployeeSalaryId BIGINT          NULL,       -- NULL for the very first salary record
    NewEmployeeSalaryId BIGINT          NOT NULL,
    RevisionType        NVARCHAR(50)    NOT NULL
        CONSTRAINT CK_SalaryRevision_Type CHECK (RevisionType IN (
            'ANNUAL_INCREMENT','PROMOTION','CORRECTION',
            'JOINING','MARKET_CORRECTION','OTHER')),
    RevisionDate        DATE            NOT NULL,
    OldAnnualCTC        DECIMAL(18,2)   NULL,
    NewAnnualCTC        DECIMAL(18,2)   NOT NULL,
    IncrementAmount     AS (NewAnnualCTC - ISNULL(OldAnnualCTC, 0)),
    IncrementPercentage DECIMAL(10,4)   NULL,
    Reason              NVARCHAR(2000)  NULL,
    ApprovedBy          BIGINT          NULL,       -- references dbo.Employee(Id)
    ApprovedAt          DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

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
        REFERENCES dbo.Employee(Id)
);


-- =============================================================================================================
-- MODULE 2: BANK CREDIT & TRANSACTIONS
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
    IfscPrefix      NVARCHAR(10)    NULL,       -- First 4 chars of IFSC (India)
    SwiftCode       NVARCHAR(20)    NULL,       -- BIC/SWIFT for international
    CountryCode     NVARCHAR(10)    NOT NULL DEFAULT 'IN',
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- EMPLOYEE BANK ACCOUNT
-- Stores an employee's bank account details for salary
-- credit. Supports multiple accounts per employee;
-- IsPrimary identifies the default disbursement account.
-- AccountType: SAVINGS | CURRENT | SALARY
-- IsVerified indicates whether the account has been
-- validated by HR/Finance before a salary transfer is made.
-- Sensitive fields (AccountNumber) should be encrypted at
-- the application layer before persistence.
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeBankAccount (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    BankMasterId        BIGINT          NOT NULL,
    AccountHolderName   NVARCHAR(300)   NOT NULL,
    AccountNumber       NVARCHAR(100)   NOT NULL,   -- store encrypted at app layer
    AccountType         NVARCHAR(20)    NOT NULL DEFAULT 'SAVINGS'
        CONSTRAINT CK_EBA_AccountType CHECK (AccountType IN ('SAVINGS','CURRENT','SALARY')),
    IfscCode            NVARCHAR(20)    NULL,       -- full IFSC (India)
    SwiftCode           NVARCHAR(20)    NULL,       -- BIC for international transfers
    BranchName          NVARCHAR(300)   NULL,
    BankAddress         NVARCHAR(500)   NULL,
    CurrencyCode        NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    IsPrimary           BIT             NOT NULL DEFAULT 0,
    IsVerified          BIT             NOT NULL DEFAULT 0,
    VerifiedBy          BIGINT          NULL,       -- references dbo.Employee(Id)
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
        REFERENCES dbo.Employee(Id)
);


-- -------------------------------------------------------
-- PAYROLL DISBURSEMENT
-- Represents a payroll run (salary credit batch) for a
-- specific payroll month and year within a legal entity.
-- One disbursement record covers all employees processed
-- in that run. DisbursementStatus tracks the lifecycle:
--   DRAFT -> APPROVED -> PROCESSING -> COMPLETED | FAILED
-- TotalNetPayable is the aggregate amount to be transferred
-- in the batch. BankBatchReferenceNo is the batch ID
-- returned by the bank or payment gateway.
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
    DisbursementStatus      NVARCHAR(20)    NOT NULL DEFAULT 'DRAFT'
        CONSTRAINT CK_PD_Status CHECK (DisbursementStatus IN (
            'DRAFT','APPROVED','PROCESSING','COMPLETED','FAILED','CANCELLED')),
    BankBatchReferenceNo    NVARCHAR(200)   NULL,   -- batch ref from bank/payment gateway
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

    CONSTRAINT UQ_PayrollDisbursement
        UNIQUE (LegalEntityId, PayrollMonth, PayrollYear)
);


-- -------------------------------------------------------
-- PAYROLL DISBURSEMENT TRANSACTION
-- Individual salary credit transaction for each employee
-- within a payroll disbursement batch. Captures the exact
-- gross pay, deductions, and net amount credited, along
-- with the bank transaction reference.
-- TransactionStatus:
--   PENDING -> INITIATED -> SUCCESS | FAILED | REVERSED
-- BankTransactionId is the unique reference returned by
-- the bank or payment rail (NEFT/RTGS/IMPS/SWIFT) upon
-- successful credit confirmation.
-- FailureReason stores the bank-returned error description
-- when a credit fails, enabling retry or manual resolution.
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
    TransactionStatus       NVARCHAR(20)    NOT NULL DEFAULT 'PENDING'
        CONSTRAINT CK_PDT_Status CHECK (TransactionStatus IN (
            'PENDING','INITIATED','SUCCESS','FAILED','REVERSED')),
    BankTransactionId       NVARCHAR(300)   NULL,   -- UTR / NEFT ref / SWIFT ref from bank
    PaymentMode             NVARCHAR(50)    NULL,   -- NEFT | RTGS | IMPS | SWIFT | CHEQUE
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

    CONSTRAINT UQ_DisbursementTransaction
        UNIQUE (PayrollDisbursementId, EmployeeId)
);


-- =============================================================================================================
-- MODULE 3: TAX DEDUCTIONS
-- =============================================================================================================


-- -------------------------------------------------------
-- TAX REGIME
-- Defines tax regimes applicable to employees
-- (e.g. India Old Regime, India New Regime, UAE, US Federal).
-- RegimeCode is jurisdiction-specific and maps to the
-- tax computation rules implemented in the payroll engine.
-- -------------------------------------------------------
CREATE TABLE payroll.TaxRegime (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    RegimeCode      NVARCHAR(100)   NOT NULL UNIQUE,
    RegimeName      NVARCHAR(300)   NOT NULL,
    CountryCode     NVARCHAR(10)    NOT NULL,
    FiscalYearStart NVARCHAR(10)    NULL,   -- e.g. "04-01" for India (April 1)
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- TAX SLAB
-- Stores income tax slab brackets for a given tax regime
-- and fiscal year. MinIncome / MaxIncome define the bracket;
-- MaxIncome NULL implies the top slab with no upper bound.
-- TaxRate is expressed as a percentage (e.g. 30.00 = 30%).
-- SurchargeRate and CessRate capture additional levies
-- (e.g. India's 4% Health & Education Cess).
-- -------------------------------------------------------
CREATE TABLE payroll.TaxSlab (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    TaxRegimeId     BIGINT          NOT NULL,
    FiscalYear      INT             NOT NULL,   -- e.g. 2024 for FY 2024-25
    SlabOrder       INT             NOT NULL,
    MinIncome       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    MaxIncome       DECIMAL(18,2)   NULL,       -- NULL = no upper cap (top slab)
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
-- (Form 12BB equivalent) for a fiscal year. Employees submit
-- planned investments and exemptions at year start; these
-- are used for provisional TDS computation throughout the year.
-- DeclarationStatus:
--   DRAFT -> SUBMITTED -> VERIFIED | REJECTED
-- TaxRegimeId records which regime the employee opted for,
-- which is critical in jurisdictions offering multiple regimes.
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeTaxDeclaration (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    TaxRegimeId             BIGINT          NOT NULL,
    FiscalYear              INT             NOT NULL,
    DeclaredTotalIncome     DECIMAL(18,2)   NOT NULL DEFAULT 0,
    DeclaredExemptions      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    DeclaredDeductions      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    EstimatedTaxableIncome  AS (DeclaredTotalIncome - DeclaredExemptions - DeclaredDeductions),
    DeclarationStatus       NVARCHAR(20)    NOT NULL DEFAULT 'DRAFT'
        CONSTRAINT CK_ETD_Status CHECK (DeclarationStatus IN (
            'DRAFT','SUBMITTED','VERIFIED','REJECTED')),
    SubmittedAt             DATETIME2       NULL,
    VerifiedBy              BIGINT          NULL,
    VerifiedAt              DATETIME2       NULL,
    Remarks                 NVARCHAR(2000)  NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_ETD_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ETD_TaxRegime
        FOREIGN KEY (TaxRegimeId)
        REFERENCES payroll.TaxRegime(Id),

    CONSTRAINT FK_ETD_VerifiedBy
        FOREIGN KEY (VerifiedBy)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT UQ_EmployeeTaxDeclaration
        UNIQUE (EmployeeId, FiscalYear)
);


-- -------------------------------------------------------
-- TAX DECLARATION PROOF
-- Stores actual investment/exemption proof documents
-- submitted by employees against their declarations.
-- One declaration can have multiple proof documents
-- (e.g. HRA rent receipts, LIC premium certificates).
-- ProofCategory maps to a declaration section
-- (e.g. 80C, 80D, HRA, LTA).
-- ApprovedAmount may differ from DeclaredAmount when
-- the Finance team partially accepts the claim.
-- -------------------------------------------------------
CREATE TABLE payroll.TaxDeclarationProof (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeTaxDeclarationId    BIGINT          NOT NULL,
    ProofCategory               NVARCHAR(100)   NOT NULL,  -- e.g. 80C, 80D, HRA, LTA, NPS
    Description                 NVARCHAR(500)   NULL,
    DeclaredAmount              DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ApprovedAmount              DECIMAL(18,2)   NULL,
    DocumentFileUrl             NVARCHAR(1000)  NULL,
    OriginalFileName            NVARCHAR(500)   NULL,
    UploadedAt                  DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    ReviewedBy                  BIGINT          NULL,
    ReviewedAt                  DATETIME2       NULL,
    ReviewStatus                NVARCHAR(20)    NULL
        CONSTRAINT CK_TDP_ReviewStatus CHECK (ReviewStatus IN (
            'PENDING','APPROVED','REJECTED',NULL)),
    RejectionReason             NVARCHAR(500)   NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TDP_Declaration
        FOREIGN KEY (EmployeeTaxDeclarationId)
        REFERENCES payroll.EmployeeTaxDeclaration(Id),

    CONSTRAINT FK_TDP_ReviewedBy
        FOREIGN KEY (ReviewedBy)
        REFERENCES dbo.Employee(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE TAX DEDUCTION
-- Stores the total tax deducted at source (TDS) for each
-- employee per payroll month. This is the header-level TDS
-- record; the detailed component breakdown is in
-- TaxDeductionBreakdown.
-- TaxableIncome is the income figure after all exemptions
-- and deductions used to arrive at TDSAmount.
-- CumulativeTDSYTD is the running year-to-date TDS deducted,
-- useful for Form 16 / year-end reconciliation.
-- IsAdjustment flags months where TDS was retrospectively
-- corrected (e.g. due to arrears or declaration change).
-- -------------------------------------------------------
CREATE TABLE payroll.EmployeeTaxDeduction (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL,
    EmployeeTaxDeclarationId    BIGINT          NULL,   -- NULL if no declaration on file
    TaxRegimeId                 BIGINT          NOT NULL,
    PayrollMonth                INT             NOT NULL,
    PayrollYear                 INT             NOT NULL,
    FiscalYear                  INT             NOT NULL,
    GrossIncome                 DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalExemptions             DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalDeductions             DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TaxableIncome               AS (GrossIncome - TotalExemptions - TotalDeductions),
    TDSAmount                   DECIMAL(18,2)   NOT NULL DEFAULT 0,  -- tax deducted this month
    SurchargeAmount             DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CessAmount                  DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalTaxDeducted            AS (TDSAmount + SurchargeAmount + CessAmount),
    CumulativeTDSYTD            DECIMAL(18,2)   NOT NULL DEFAULT 0,  -- running total YTD
    IsAdjustment                BIT             NOT NULL DEFAULT 0,
    AdjustmentReason            NVARCHAR(500)   NULL,
    PayrollDisbursementTransactionId BIGINT     NULL,   -- links to the credit transaction
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

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
        REFERENCES payroll.PayrollDisbursementTransaction(Id),

    CONSTRAINT UQ_EmployeeTaxDeduction
        UNIQUE (EmployeeId, PayrollMonth, PayrollYear)
);


-- -------------------------------------------------------
-- TAX DEDUCTION BREAKDOWN
-- Stores the line-item breakdown of tax deductions per
-- employee per payroll month. Each row represents a
-- specific section or head under which tax has been
-- computed or relief has been applied.
-- DeductionHead examples:
--   STANDARD_DEDUCTION, HRA_EXEMPTION, SECTION_80C,
--   SECTION_80D, LTA_EXEMPTION, SURCHARGE, CESS,
--   PROFESSIONAL_TAX, REBATE_87A
-- This granular table supports Form 16 Part-B generation
-- and allows auditors to trace exactly how tax was computed.
-- -------------------------------------------------------
CREATE TABLE payroll.TaxDeductionBreakdown (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeTaxDeductionId  BIGINT          NOT NULL,
    DeductionHead           NVARCHAR(200)   NOT NULL,   -- e.g. Section 80C, HRA Exemption
    DeductionCategory       NVARCHAR(100)   NULL,       -- EXEMPTION | DEDUCTION | TAX | CESS | REBATE
    DeclaredAmount          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ApprovedAmount          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ActualDeductionAmount   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Remarks                 NVARCHAR(500)   NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TaxBreakdown_TaxDeduction
        FOREIGN KEY (EmployeeTaxDeductionId)
        REFERENCES payroll.EmployeeTaxDeduction(Id)
);


-- =============================================================================================================
-- INDEXES
-- =============================================================================================================

-- Salary Structure
CREATE INDEX IX_SalaryStructure_LegalEntity
    ON payroll.SalaryStructure (LegalEntityId);

-- Employee Salary
CREATE INDEX IX_EmployeeSalary_Employee
    ON payroll.EmployeeSalary (EmployeeId, EffectiveFrom, EffectiveTo);

CREATE INDEX IX_EmployeeSalary_Structure
    ON payroll.EmployeeSalary (SalaryStructureId);

-- Employee Salary Component
CREATE INDEX IX_ESC_EmployeeSalary_Month
    ON payroll.EmployeeSalaryComponent (EmployeeSalaryId, PayrollYear, PayrollMonth);

-- Salary Revision
CREATE INDEX IX_SalaryRevision_Employee
    ON payroll.SalaryRevision (EmployeeId, RevisionDate);

-- Employee Bank Account
CREATE INDEX IX_EBA_Employee
    ON payroll.EmployeeBankAccount (EmployeeId);

-- Payroll Disbursement
CREATE INDEX IX_PayrollDisbursement_LegalEntity_Period
    ON payroll.PayrollDisbursement (LegalEntityId, PayrollYear, PayrollMonth);

CREATE INDEX IX_PayrollDisbursement_Status
    ON payroll.PayrollDisbursement (DisbursementStatus);

-- Payroll Disbursement Transaction
CREATE INDEX IX_PDT_Disbursement_Employee
    ON payroll.PayrollDisbursementTransaction (PayrollDisbursementId, EmployeeId);

CREATE INDEX IX_PDT_BankTransactionId
    ON payroll.PayrollDisbursementTransaction (BankTransactionId)
    WHERE BankTransactionId IS NOT NULL;

CREATE INDEX IX_PDT_Status
    ON payroll.PayrollDisbursementTransaction (TransactionStatus);

-- Employee Tax Declaration
CREATE INDEX IX_ETD_Employee_FiscalYear
    ON payroll.EmployeeTaxDeclaration (EmployeeId, FiscalYear);

-- Tax Declaration Proof
CREATE INDEX IX_TDP_Declaration
    ON payroll.TaxDeclarationProof (EmployeeTaxDeclarationId);

-- Employee Tax Deduction
CREATE INDEX IX_ETaxDed_Employee_Period
    ON payroll.EmployeeTaxDeduction (EmployeeId, PayrollYear, PayrollMonth);

CREATE INDEX IX_ETaxDed_FiscalYear
    ON payroll.EmployeeTaxDeduction (EmployeeId, FiscalYear);

-- Tax Deduction Breakdown
CREATE INDEX IX_TaxBreakdown_Deduction
    ON payroll.TaxDeductionBreakdown (EmployeeTaxDeductionId);

-- =============================================================================================================
-- END OF SCHEMA: payroll
-- =============================================================================================================