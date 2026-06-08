-- PAYROLL SCHEMA - Payroll Processing
-- SQL Server Database Schema
-- Schema: payroll
-- Purpose: Salary structures, compensation, tax deductions, bank disbursement
-- Dependencies: shared (StatusLookup), employee (Employee), time (LegalEntity, BankMaster)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'payroll')
BEGIN
    EXEC('CREATE SCHEMA payroll');
END
GO

-- TAX PROOF CATEGORY - IT Declaration Sections
CREATE TABLE payroll.TaxProofCategory (
    Id                      UNIQUEIDENTIFIER             PRIMARY KEY,
    CategoryCode            NVARCHAR(50)    NOT NULL UNIQUE,
    CategoryName            NVARCHAR(200)   NOT NULL,
    Section                 NVARCHAR(100)   NULL,
    StatutoryMaxLimit       DECIMAL(18,2)   NULL,
    IsApplicableOldRegime   BIT             NOT NULL DEFAULT 1,
    IsApplicableNewRegime   BIT             NOT NULL DEFAULT 0,
    RequiresDocument        BIT             NOT NULL DEFAULT 1,
    DisplayOrder            SMALLINT         NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL
);
GO

-- SALARY GRADE
CREATE TABLE payroll.SalaryGrade (
    Id              UNIQUEIDENTIFIER          PRIMARY KEY,
    GradeCode       NVARCHAR(50)    NOT NULL UNIQUE,
    GradeName       NVARCHAR(200)   NOT NULL,
    MinCTC          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    MaxCTC          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CurrencyCode    NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL
);
GO

-- SALARY STRUCTURE
CREATE TABLE payroll.SalaryStructure (
    Id              UNIQUEIDENTIFIER          PRIMARY KEY,
    StructureCode   NVARCHAR(100)   NOT NULL UNIQUE,
    StructureName   NVARCHAR(200)   NOT NULL,
    LegalEntityId   UNIQUEIDENTIFIER          NOT NULL,
    CurrencyCode    NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    VersionNo       SMALLINT             NOT NULL DEFAULT 1,
    IsDefault       BIT             NOT NULL DEFAULT 0,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SalaryStructure_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES time.LegalEntity(Id)
);
GO

-- PAYROLL COMPONENT
CREATE TABLE payroll.PayrollComponent (
    Id              UNIQUEIDENTIFIER          PRIMARY KEY,
    ComponentCode   NVARCHAR(100)   NOT NULL UNIQUE,
    ComponentName   NVARCHAR(200)   NOT NULL,
    IsEarning       BIT             NOT NULL DEFAULT 1,
    IsDeduction     BIT             NOT NULL DEFAULT 0, 
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,
);
GO

-- SALARY STRUCTURE COMPONENT
CREATE TABLE payroll.SalaryStructureComponent (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    SalaryStructureId   UNIQUEIDENTIFIER          NOT NULL,
    PayrollComponentId  UNIQUEIDENTIFIER          NOT NULL,
    CalculationType     NVARCHAR(50)    NOT NULL DEFAULT 'FIXED',
    CalculationTypeGroup AS CAST('CALC_TYPE' AS NVARCHAR(50)) PERSISTED,
    PercentageValue     DECIMAL(10,4)   NULL,
    BaseComponentId     UNIQUEIDENTIFIER          NULL,
    FormulaExpression   NVARCHAR(2000)  NULL,
    IsStatutory         BIT             NOT NULL DEFAULT 0,
    DisplayOrder        SMALLINT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

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
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- PAYROLL ATTENDANCE SUMMARY
CREATE TABLE payroll.PayrollAttendanceSummary (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    PayrollMonth        SMALLINT             NOT NULL,
    PayrollYear         SMALLINT             NOT NULL,
    TotalWorkingDays    DECIMAL(10,2)   NOT NULL,
    PresentDays         DECIMAL(10,2)   NOT NULL,
    LeaveDays           DECIMAL(10,2)   NOT NULL DEFAULT 0,
    AbsentDays          DECIMAL(10,2)   NOT NULL DEFAULT 0,
    OvertimeMinutes     SMALLINT             NOT NULL DEFAULT 0,
    ProcessedAt         DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT UQ_PayrollAttendanceSummary
        UNIQUE (EmployeeId, PayrollMonth, PayrollYear),

    CONSTRAINT FK_PayrollAttendanceSummary_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

-- EMPLOYEE SALARY
CREATE TABLE payroll.EmployeeSalary (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    SalaryStructureId   UNIQUEIDENTIFIER          NOT NULL,
    SalaryGradeId       UNIQUEIDENTIFIER          NULL,
    AnnualCTC           DECIMAL(18,2)   NOT NULL,
    MonthlyCTC          DECIMAL(18,2)   NOT NULL,
    MonthlyGross        DECIMAL(18,2)   NOT NULL,
    MonthlyNet          DECIMAL(18,2)   NOT NULL,
    CurrencyCode        NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    EffectiveFrom       DATE            NOT NULL,
    EffectiveTo         DATE            NULL,
    Remarks             NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EmployeeSalary_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeSalary_Structure
        FOREIGN KEY (SalaryStructureId)
        REFERENCES payroll.SalaryStructure(Id),

    CONSTRAINT FK_EmployeeSalary_Grade
        FOREIGN KEY (SalaryGradeId)
        REFERENCES payroll.SalaryGrade(Id)
);
GO

-- EMPLOYEE SALARY COMPONENT
CREATE TABLE payroll.EmployeeSalaryComponent (
    Id                          UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeSalaryId            UNIQUEIDENTIFIER          NOT NULL,
    SalaryStructureComponentId  UNIQUEIDENTIFIER          NOT NULL,
    PayrollMonth                SMALLINT             NOT NULL,
    PayrollYear                 SMALLINT             NOT NULL,
    ComputedAmount              DECIMAL(18,2)   NOT NULL DEFAULT 0,
    OverrideAmount              DECIMAL(18,2)   NULL,
    FinalAmount                 AS (COALESCE(OverrideAmount, ComputedAmount)),
    OverrideReason              NVARCHAR(500)   NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_ESC_EmployeeSalary
        FOREIGN KEY (EmployeeSalaryId)
        REFERENCES payroll.EmployeeSalary(Id),

    CONSTRAINT FK_ESC_StructureComponent
        FOREIGN KEY (SalaryStructureComponentId)
        REFERENCES payroll.SalaryStructureComponent(Id),

    CONSTRAINT UQ_EmployeeSalaryComponent
        UNIQUE (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear)
);
GO

-- SALARY REVISION
CREATE TABLE payroll.SalaryRevision (
    Id                   UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId           UNIQUEIDENTIFIER          NOT NULL,
    OldEmployeeSalaryId  UNIQUEIDENTIFIER          NULL,
    NewEmployeeSalaryId  UNIQUEIDENTIFIER          NOT NULL,
    RevisionType         NVARCHAR(50)    NOT NULL,
    RevisionTypeGroup    AS CAST('SALARY_REVISION_TYPE' AS NVARCHAR(50)) PERSISTED,
    RevisionDate         DATE            NOT NULL,
    OldAnnualCTC         DECIMAL(18,2)   NULL,
    NewAnnualCTC         DECIMAL(18,2)   NOT NULL,
    IncrementAmount      AS (NewAnnualCTC - ISNULL(OldAnnualCTC, 0)),
    IncrementPercentage  DECIMAL(10,4)   NULL,
    Reason               NVARCHAR(2000)  NULL,
    ApprovedBy           UNIQUEIDENTIFIER          NULL,
    ApprovedAt           DATETIME2       NULL,
    IsActive             BIT             NOT NULL DEFAULT 1,
    LastUpdatedAt        DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy        UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SalaryRevision_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_SalaryRevision_OldSalary
        FOREIGN KEY (OldEmployeeSalaryId)
        REFERENCES payroll.EmployeeSalary(Id),

    CONSTRAINT FK_SalaryRevision_NewSalary
        FOREIGN KEY (NewEmployeeSalaryId)
        REFERENCES payroll.EmployeeSalary(Id),

    CONSTRAINT FK_SalaryRevision_ApprovedBy
        FOREIGN KEY (ApprovedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_SalaryRevision_RevisionType
        FOREIGN KEY (RevisionType, RevisionTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- BANK MASTER
CREATE TABLE payroll.BankMaster (
    Id              UNIQUEIDENTIFIER          PRIMARY KEY,
    BankCode        NVARCHAR(50)    NOT NULL UNIQUE,
    BankName        NVARCHAR(300)   NOT NULL,
    IfscPrefix      NVARCHAR(10)    NULL,
    SwiftCode       NVARCHAR(20)    NULL,
    CountryCode     NVARCHAR(10)    NOT NULL DEFAULT 'IN',
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL
);
GO

-- EMPLOYEE BANK ACCOUNT
CREATE TABLE payroll.EmployeeBankAccount (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    BankMasterId        UNIQUEIDENTIFIER          NOT NULL,
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
    VerifiedBy          UNIQUEIDENTIFIER          NULL,
    VerifiedAt          DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EBA_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EBA_BankMaster
        FOREIGN KEY (BankMasterId)
        REFERENCES payroll.BankMaster(Id),

    CONSTRAINT FK_EBA_VerifiedBy
        FOREIGN KEY (VerifiedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EBA_AccountType
        FOREIGN KEY (AccountType, AccountTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- PAYROLL DISBURSEMENT
CREATE TABLE payroll.PayrollDisbursement (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    LegalEntityId           UNIQUEIDENTIFIER          NOT NULL,
    PayrollMonth            SMALLINT             NOT NULL,
    PayrollYear             SMALLINT             NOT NULL,
    DisbursementDate        DATE            NULL,
    TotalEmployeeCount      SMALLINT             NOT NULL DEFAULT 0,
    TotalNetPayable         DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    DisbursementStatus      NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    DisbursementStatusGroup AS CAST('DISBURSEMENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    BankBatchReferenceNo    NVARCHAR(200)   NULL,
    InitiatedBy             UNIQUEIDENTIFIER          NOT NULL,
    ApprovedBy              UNIQUEIDENTIFIER          NULL,
    ApprovedAt              DATETIME2       NULL,
    ProcessedAt             DATETIME2       NULL,
    Remarks                 NVARCHAR(1000)  NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_PD_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES time.LegalEntity(Id),

    CONSTRAINT FK_PD_InitiatedBy
        FOREIGN KEY (InitiatedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PD_ApprovedBy
        FOREIGN KEY (ApprovedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PD_DisbursementStatus
        FOREIGN KEY (DisbursementStatus, DisbursementStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT UQ_PayrollDisbursement
        UNIQUE (LegalEntityId, PayrollMonth, PayrollYear)
);
GO

-- PAYROLL DISBURSEMENT TRANSACTION
CREATE TABLE payroll.PayrollDisbursementTransaction (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    PayrollDisbursementId   UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId              UNIQUEIDENTIFIER          NOT NULL,
    EmployeeBankAccountId   UNIQUEIDENTIFIER          NOT NULL,
    PayrollMonth            SMALLINT             NOT NULL,
    PayrollYear             SMALLINT             NOT NULL,
    GrossAmount             DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalDeductions         DECIMAL(18,2)   NOT NULL DEFAULT 0,
    NetAmountCredited       AS (GrossAmount - TotalDeductions),
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    TransactionStatus       NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    TransactionStatusGroup  AS CAST('TRANSACTION_STATUS' AS NVARCHAR(50)) PERSISTED,
    BankTransactionId       NVARCHAR(300)   NULL,
    PaymentMode             NVARCHAR(50)    NULL,
    PaymentModeType         AS CAST('PAYMENT_MODE_TYPE' AS NVARCHAR(50)) PERSISTED,
    InitiatedAt             DATETIME2       NULL,
    ConfirmedAt             DATETIME2       NULL,
    FailureReason           NVARCHAR(1000)  NULL,
    RetryCount              INT             NOT NULL DEFAULT 0,
    IsManualCredit          BIT             NOT NULL DEFAULT 0,
    Remarks                 NVARCHAR(1000)  NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_PDT_Disbursement
        FOREIGN KEY (PayrollDisbursementId)
        REFERENCES payroll.PayrollDisbursement(Id),

    CONSTRAINT FK_PDT_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PDT_BankAccount
        FOREIGN KEY (EmployeeBankAccountId)
        REFERENCES payroll.EmployeeBankAccount(Id),

    CONSTRAINT FK_PDT_TransactionStatus
        FOREIGN KEY (TransactionStatus, TransactionStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_PDT_PaymentMode
        FOREIGN KEY (PaymentMode, PaymentModeType)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT UQ_DisbursementTransaction
        UNIQUE (PayrollDisbursementId, EmployeeId)
);
GO

-- TAX REGIME
CREATE TABLE payroll.TaxRegime (
    Id              UNIQUEIDENTIFIER          PRIMARY KEY,
    RegimeCode      NVARCHAR(100)   NOT NULL UNIQUE,
    RegimeName      NVARCHAR(300)   NOT NULL,
    CountryCode     NVARCHAR(10)    NOT NULL,
    FiscalYearStart NVARCHAR(10)    NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL
);
GO

-- TAX SLAB
CREATE TABLE payroll.TaxSlab (
    Id              UNIQUEIDENTIFIER          PRIMARY KEY,
    TaxRegimeId     UNIQUEIDENTIFIER          NOT NULL,
    FiscalYear      SMALLINT             NOT NULL,
    SlabOrder       SMALLINT             NOT NULL,
    MinIncome       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    MaxIncome       DECIMAL(18,2)   NULL,
    TaxRate         DECIMAL(10,4)   NOT NULL DEFAULT 0,
    SurchargeRate   DECIMAL(10,4)   NOT NULL DEFAULT 0,
    CessRate        DECIMAL(10,4)   NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_TaxSlab_TaxRegime
        FOREIGN KEY (TaxRegimeId)
        REFERENCES payroll.TaxRegime(Id),

    CONSTRAINT UQ_TaxSlab
        UNIQUE (TaxRegimeId, FiscalYear, SlabOrder)
);
GO

-- EMPLOYEE TAX DECLARATION
CREATE TABLE payroll.EmployeeTaxDeclaration (
    Id                       UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId               UNIQUEIDENTIFIER          NOT NULL,
    TaxRegimeId              UNIQUEIDENTIFIER          NOT NULL,
    FiscalYear               SMALLINT             NOT NULL
        CONSTRAINT CK_ETD_FiscalYear CHECK (FiscalYear BETWEEN 2000 AND 2099),
    DeclaredTotalIncome      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    DeclaredExemptions       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    DeclaredDeductions       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    EstimatedTaxableIncome   AS (DeclaredTotalIncome - DeclaredExemptions - DeclaredDeductions) PERSISTED,
    DeclarationStatus        NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    DeclarationStatusGroup   AS CAST('DECLARATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    SubmittedAt              DATETIME2       NULL,
    VerifiedBy               UNIQUEIDENTIFIER          NULL,
    VerifiedAt               DATETIME2       NULL,
    Remarks                  NVARCHAR(2000)  NULL,
    IsActive                 BIT             NOT NULL DEFAULT 1,
    CreatedAt                DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy            UNIQUEIDENTIFIER             NULL,

    CONSTRAINT UQ_EmployeeTaxDeclaration
        UNIQUE (EmployeeId, FiscalYear),

    CONSTRAINT FK_ETD_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ETD_TaxRegime
        FOREIGN KEY (TaxRegimeId)
        REFERENCES payroll.TaxRegime(Id),

    CONSTRAINT FK_ETD_VerifiedBy
        FOREIGN KEY (VerifiedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ETD_DeclarationStatus
        FOREIGN KEY (DeclarationStatus, DeclarationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- TAX DECLARATION ITEM
CREATE TABLE payroll.TaxDeclarationItem (
    Id                          UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeTaxDeclarationId    UNIQUEIDENTIFIER          NOT NULL,
    TaxProofCategoryId          UNIQUEIDENTIFIER             NOT NULL,
    DeclaredAmount              DECIMAL(18,2)   NOT NULL DEFAULT 0
        CONSTRAINT CK_TDI_DeclaredAmount CHECK (DeclaredAmount >= 0),
    ApprovedAmount              DECIMAL(18,2)   NULL
        CONSTRAINT CK_TDI_ApprovedAmount CHECK (ApprovedAmount IS NULL OR ApprovedAmount >= 0),
    Remarks                     NVARCHAR(500)   NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy                UNIQUEIDENTIFIER             NULL,

    CONSTRAINT UQ_TDI_DeclarationCategory
        UNIQUE (EmployeeTaxDeclarationId, TaxProofCategoryId),

    CONSTRAINT FK_TDI_Declaration
        FOREIGN KEY (EmployeeTaxDeclarationId)
        REFERENCES payroll.EmployeeTaxDeclaration(Id),

    CONSTRAINT FK_TDI_Category
        FOREIGN KEY (TaxProofCategoryId)
        REFERENCES payroll.TaxProofCategory(Id)
);
GO

-- TAX DECLARATION PROOF
CREATE TABLE payroll.TaxDeclarationProof (
    Id                   UNIQUEIDENTIFIER          PRIMARY KEY,
    TaxDeclarationItemId UNIQUEIDENTIFIER          NOT NULL,
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
    ReviewedBy           UNIQUEIDENTIFIER          NULL,
    ReviewedAt           DATETIME2       NULL,
    RejectionReason      NVARCHAR(500)   NULL,
    IsActive             BIT             NOT NULL DEFAULT 1,
    CreatedAt            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy            UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt        DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy        UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_TDP_DeclarationItem
        FOREIGN KEY (TaxDeclarationItemId)
        REFERENCES payroll.TaxDeclarationItem(Id),

    CONSTRAINT FK_TDP_ReviewedBy
        FOREIGN KEY (ReviewedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_TDP_ReviewStatus
        FOREIGN KEY (ReviewStatus, ReviewStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- EMPLOYEE TAX DEDUCTION
CREATE TABLE payroll.EmployeeTaxDeduction (
    Id                               UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId                       UNIQUEIDENTIFIER          NOT NULL,
    EmployeeTaxDeclarationId         UNIQUEIDENTIFIER          NULL,
    TaxRegimeId                      UNIQUEIDENTIFIER          NOT NULL,
    PayrollMonth                     SMALLINT             NOT NULL,
    PayrollYear                      SMALLINT             NOT NULL,
    FiscalYear                       SMALLINT             NOT NULL,
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
    PayrollDisbursementTransactionId UNIQUEIDENTIFIER          NULL,
    IsActive                         BIT             NOT NULL DEFAULT 1,
    CreatedAt                        DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                        UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt                    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
LastUpdatedBy                        UNIQUEIDENTIFIER             NULL,

    CONSTRAINT UQ_EmployeeTaxDeduction
        UNIQUE (EmployeeId, PayrollMonth, PayrollYear),

    CONSTRAINT FK_ETaxDed_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

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
GO

-- TAX DEDUCTION BREAKDOWN
CREATE TABLE payroll.TaxDeductionBreakdown (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeTaxDeductionId  UNIQUEIDENTIFIER          NOT NULL,
    DeductionHead           NVARCHAR(200)   NOT NULL,
    DeductionCategory       NVARCHAR(50)    NULL,
    DeductionCategoryGroup  AS CAST('DEDUCTION_CATEGORY' AS NVARCHAR(50)) PERSISTED,
    DeclaredAmount          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ApprovedAmount          DECIMAL(18,2)   NOT NULL DEFAULT 0,
    ActualDeductionAmount   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Remarks                 NVARCHAR(500)   NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_TaxBreakdown_TaxDeduction
        FOREIGN KEY (EmployeeTaxDeductionId)
        REFERENCES payroll.EmployeeTaxDeduction(Id),

    CONSTRAINT FK_TaxBreakdown_DeductionCategory
        FOREIGN KEY (DeductionCategory, DeductionCategoryGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- SALARY SLIP PUBLICATION
CREATE TABLE payroll.SalarySlipPublication (
    Id                              UNIQUEIDENTIFIER          PRIMARY KEY,
    DisbursementTransactionId       UNIQUEIDENTIFIER          NOT NULL UNIQUE,
    SlipStatus                      NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    SlipStatusGroup                 AS CAST('SALARY_SLIP_STATUS' AS NVARCHAR(50)) PERSISTED,
    FileUrl                         NVARCHAR(1000)  NULL,
    IsPasswordProtected             BIT             NOT NULL DEFAULT 1,
    GeneratedAt                     DATETIME2       NULL,
    PublishedAt                     DATETIME2       NULL,
    FirstDownloadedAt               DATETIME2       NULL,
    Remarks                         NVARCHAR(1000)  NULL,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy                   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SalarySlipPub_DisbursementTransaction
        FOREIGN KEY (DisbursementTransactionId)
        REFERENCES payroll.PayrollDisbursementTransaction(Id),

    CONSTRAINT FK_SalarySlipPub_Status
        FOREIGN KEY (SlipStatus, SlipStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- INDEXES - payroll Schema
CREATE INDEX IX_SalaryStructure_LegalEntity ON payroll.SalaryStructure (LegalEntityId);
CREATE INDEX IX_EmployeeSalary_Employee    ON payroll.EmployeeSalary (EmployeeId, EffectiveFrom, EffectiveTo);
CREATE INDEX IX_EmployeeSalary_Structure     ON payroll.EmployeeSalary (SalaryStructureId);
CREATE INDEX IX_EmployeeSalaryComponent_EmployeeSalary_Month ON payroll.EmployeeSalaryComponent (EmployeeSalaryId, PayrollYear, PayrollMonth);
CREATE INDEX IX_SalaryRevision_Employee      ON payroll.SalaryRevision (EmployeeId, RevisionDate);
CREATE INDEX IX_EBA_Employee                  ON payroll.EmployeeBankAccount (EmployeeId);
CREATE INDEX IX_PayrollDisbursement_LegalEntity_Period ON payroll.PayrollDisbursement (LegalEntityId, PayrollYear, PayrollMonth);
CREATE INDEX IX_PayrollDisbursement_Status   ON payroll.PayrollDisbursement (DisbursementStatus);
CREATE INDEX IX_PDT_Disbursement_Employee    ON payroll.PayrollDisbursementTransaction (PayrollDisbursementId, EmployeeId);
CREATE INDEX IX_PDT_BankTransactionId        ON payroll.PayrollDisbursementTransaction (BankTransactionId) WHERE BankTransactionId IS NOT NULL;
CREATE INDEX IX_PDT_Status                   ON payroll.PayrollDisbursementTransaction (TransactionStatus);
CREATE INDEX IX_ETD_Employee_FiscalYear     ON payroll.EmployeeTaxDeclaration (EmployeeId, FiscalYear);
CREATE INDEX IX_ETD_FiscalYear_Status       ON payroll.EmployeeTaxDeclaration (FiscalYear, DeclarationStatus);
CREATE INDEX IX_TDI_DeclarationId            ON payroll.TaxDeclarationItem (EmployeeTaxDeclarationId);
CREATE INDEX IX_TDP_ItemId                   ON payroll.TaxDeclarationProof (TaxDeclarationItemId);
CREATE INDEX IX_ETaxDed_Employee_Period      ON payroll.EmployeeTaxDeduction (EmployeeId, PayrollYear, PayrollMonth);
CREATE INDEX IX_SalarySlipPub_Status         ON payroll.SalarySlipPublication (SlipStatus);
GO

PRINT 'Payroll schema created successfully';
GO