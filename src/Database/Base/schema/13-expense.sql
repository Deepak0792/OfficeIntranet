-- EXPENSE SCHEMA - Expense & Reimbursement Module
-- SQL Server Database Schema | Schema: expense
-- Dependencies: shared (StatusLookup), workflow (WorkflowInstance, WorkflowStep),
--               employee (Employee), time (ScopeType via workflow.WorkflowAssignment)
-- DESIGN PRINCIPLES--
-- 1. WORKFLOW ENGINE OWNS ALL STATE TRANSITION DATA
--    workflow.WorkflowInstance  → owns CurrentWorkflowStepId, WorkflowStatus
--    workflow.WorkflowActionHistory → owns FromWorkflowStatus, ToWorkflowStatus per action
--    workflow.WorkflowStepApprover  → owns who is the approver and by what resolution strategy
--
--    Expense tables therefore DO NOT store:
--      • CurrentWorkflowStepId   (join: entity → WorkflowInstance)
--      • CurrentApproverId       (join: entity → WorkflowInstance → WorkflowStep → WorkflowStepApprover)
--      • FromStatus / ToStatus   (query: WorkflowActionHistory for the WorkflowInstanceId)
--      • ApproverRole            (join: ExpenseApproval.WorkflowStepId → WorkflowStepApprover.WorkflowApproverType)
--      • StepNo                  (join: ExpenseApproval.WorkflowStepId → WorkflowStep.StepNo)
--      • WorkflowDefinitionId    (join: entity → WorkflowInstance → WorkflowDefinitionId)
--
-- 2. WORKFLOW_APPROVER_TYPE REPLACES APPROVER_ROLE
--    WORKFLOW_APPROVER_TYPE (already seeded) answers "how is the approver resolved?"
--    and "what functional role did the approver hold?" via WorkflowStepApprover.
--    A separate APPROVER_ROLE seed group is redundant — removed entirely.
--
-- 3. SCOPE-BASED WORKFLOW ASSIGNMENT
--    Which WorkflowDefinition applies to a transaction is resolved via
--    workflow.WorkflowAssignment (ScopeTypeId + ScopeReferenceId).
--    Expense tables carry no scope columns — scope lives in WorkflowAssignment.
--
-- 4. AUDIT LOG IS A SNAPSHOT TABLE — NO FKs ON ACTOR COLUMNS
--    ExpenseAuditLog.EventBy is stored as a snapshot Id.
--    A FK to employee.Employee would block deactivation of employees
--    with audit history, destroying compliance record integrity.
--
-- 5. EXPENSEATTACHMENT.UPLOADEDBY — SAME SNAPSHOT PRINCIPLE
--    Attachments are claim artefacts that must outlive the uploader's
--    active status. UploadedBy stored as snapshot Id, no FK.
--
-- 6. EXPENSEREIMBURSEMENT HAS TWO DISTINCT STATUS COLUMNS — BOTH KEPT
--    PaymentStatus  (REIMBURSEMENT_STATUS) = finance-side state (PENDING→PROCESSING→PAID)
--    TransactionStatus (TRANSACTION_STATUS) = bank-wire state   (INITIATED→SUCCESS/FAILED)
--    These are independent layers. A payment can be PROCESSING in finance
--    while the bank transaction is still INITIATED. Not redundant.
--
-- 7. ASSETREIMBURSEMENT IS NOT AN EXPENSECLAIM
--    AssetReimbursement has its own workflow (IT validation gate) and is paid
--    directly via ExpenseReimbursement. It never produces an ExpenseClaim.
--
-- 8. TRAVEL_TYPE COVERS TRANSPORT MODES ONLY
--    HOTEL and MEAL are ExpenseClaimItem subcategories, not transport modes.
--    They are excluded from TRAVEL_TYPE to prevent category confusion on TravelRequest.
--
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'expense')
BEGIN
    EXEC('CREATE SCHEMA expense');
END
GO
-- NOTE: APPROVER_ROLE seed group is intentionally absent.
-- WORKFLOW_APPROVER_TYPE (already seeded in shared) covers both the resolution
-- strategy and the functional role of the approver. Maintaining a second group
-- with overlapping codes (REPORTING_MANAGER, DEPARTMENT_HEAD) creates duplication.
-- The approver role for any action is derivable by joining:
-- ExpenseApproval.WorkflowStepId → WorkflowStepApprover.WorkflowApproverType

-- MODULE 1: EXPENSE LOOKUPS AND POLICIES
CREATE TABLE expense.ExpenseCategory (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode    NVARCHAR(100)   NOT NULL UNIQUE,
    CategoryName    NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);
GO

CREATE TABLE expense.ExpenseSubCategory (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    CategoryId      INT          NOT NULL,
    SubCategoryCode NVARCHAR(100)   NOT NULL,
    SubCategoryName NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ExpenseSubCategory_Category
        FOREIGN KEY (CategoryId)
        REFERENCES expense.ExpenseCategory(Id),

    CONSTRAINT UQ_ExpenseSubCategory_CodePerCategory
        UNIQUE (CategoryId, SubCategoryCode)
);
GO

-- PolicyGroup FK enforces that only seeded EXPENSE_POLICY_GROUP codes are stored.
CREATE TABLE expense.ExpensePolicy (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    PolicyCode          NVARCHAR(100)   NOT NULL UNIQUE,
    PolicyName          NVARCHAR(200)   NOT NULL,
    PolicyGroup         NVARCHAR(50)   NOT NULL,
    PolicyGroupLookup   AS CAST('EXPENSE_POLICY_GROUP' AS NVARCHAR(50)) PERSISTED,
    CategoryId          INT          NULL,
    SubCategoryId       INT          NULL,
    MaximumAmount       DECIMAL(18,2)   NULL,
    FrequencyMonths     INT             NULL,
    ApprovedVendorList  NVARCHAR(2000)  NULL,
    GstInvoiceRequired  BIT             NOT NULL DEFAULT 0,
    TravelClassAllowed  NVARCHAR(200)   NULL,
    DailyAllowanceLimit DECIMAL(18,2)   NULL,
    HotelLimitAmount    DECIMAL(18,2)   NULL,
    Description         NVARCHAR(2000)  NULL,
    EffectiveFrom       DATE            NOT NULL,
    EffectiveTo         DATE            NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ExpensePolicy_PolicyGroup
        FOREIGN KEY (PolicyGroup, PolicyGroupLookup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpensePolicy_Category
        FOREIGN KEY (CategoryId)
        REFERENCES expense.ExpenseCategory(Id),

    CONSTRAINT FK_ExpensePolicy_SubCategory
        FOREIGN KEY (SubCategoryId)
        REFERENCES expense.ExpenseSubCategory(Id)
);
GO

CREATE TABLE expense.ExpensePolicyRule (
    Id          INT          PRIMARY KEY IDENTITY(1,1),
    PolicyId    INT          NOT NULL,
    RuleCode    NVARCHAR(100)   NOT NULL,
    RuleName    NVARCHAR(200)   NOT NULL,
    RuleType    NVARCHAR(100)   NOT NULL,
    RuleValue   NVARCHAR(1000)  NOT NULL,
    IsActive    BIT             NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ExpensePolicyRule_Policy
        FOREIGN KEY (PolicyId)
        REFERENCES expense.ExpensePolicy(Id),

    CONSTRAINT UQ_ExpensePolicyRule_PolicyRule
        UNIQUE (PolicyId, RuleCode)
);
GO

-- MODULE 2: TRAVEL REQUESTS-- Captures pre-trip approval for the primary transport mode.
-- Post-trip itemised costs (accommodation, meals, local cabs) are filed
-- as ExpenseClaimItems on an ExpenseClaim linked to this TravelRequest.
CREATE TABLE expense.TravelRequest (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    TravelRequestNumber     NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId              INT          NOT NULL,
    TravelType              NVARCHAR(50)    NOT NULL,
    TravelTypeGroup         AS CAST('TRAVEL_TYPE' AS NVARCHAR(50)) PERSISTED,
    DepartureCity           NVARCHAR(200)   NULL,
    ArrivalCity             NVARCHAR(200)   NULL,
    DepartureDate           DATE            NOT NULL,
    ReturnDate              DATE            NULL,
    TravelClass             NVARCHAR(50)    NULL,
    EstimatedCost           DECIMAL(18,2)   NULL,
    Purpose                 NVARCHAR(2000)  NULL,
    AdvanceRequestedAmount  DECIMAL(18,2)   NULL,
    TravelRequestStatus     NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    TravelRequestStatusGroup AS CAST('TRAVEL_REQUEST_STATUS' AS NVARCHAR(50)) PERSISTED,
    WorkflowInstanceId      INT          NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_TravelRequest_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_TravelRequest_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_TravelRequest_TravelType
        FOREIGN KEY (TravelType, TravelTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_TravelRequest_Status
        FOREIGN KEY (TravelRequestStatus, TravelRequestStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE 3: EXPENSE ADVANCES
CREATE TABLE expense.ExpenseAdvance (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    AdvanceNumber       NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId          INT          NOT NULL,
    TravelRequestId     INT          NULL,
    AdvanceAmount       DECIMAL(18,2)   NOT NULL,
    Currency            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    Purpose             NVARCHAR(2000)  NULL,
    RequestedOn         DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    ApprovedAmount      DECIMAL(18,2)   NULL,
    PaidAmount          DECIMAL(18,2)   NULL,
    AdjustmentAmount    DECIMAL(18,2)   NULL,
    AdjustmentDate      DATE            NULL,
    AdvanceStatus       NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    AdvanceStatusGroup  AS CAST('ADVANCE_REQUEST_STATUS' AS NVARCHAR(50)) PERSISTED,
    WorkflowInstanceId  INT          NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_ExpenseAdvance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExpenseAdvance_TravelRequest
        FOREIGN KEY (TravelRequestId)
        REFERENCES expense.TravelRequest(Id),

    CONSTRAINT FK_ExpenseAdvance_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExpenseAdvance_Status
        FOREIGN KEY (AdvanceStatus, AdvanceStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE 4: ASSET REIMBURSEMENTS
CREATE TABLE expense.AssetReimbursement (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    AssetRequestNumber          NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId                  INT          NOT NULL,
    AssetType                   NVARCHAR(50)    NOT NULL,
    AssetTypeGroup              AS CAST('ASSET_TYPE' AS NVARCHAR(50)) PERSISTED,
    AssetDescription            NVARCHAR(2000)  NULL,
    InvoiceNumber               NVARCHAR(100)   NOT NULL,
    InvoiceDate                 DATE            NOT NULL,
    RequestedAmount             DECIMAL(18,2)   NOT NULL,
    ApprovedAmount              DECIMAL(18,2)   NULL,
    MaximumAllowedAmount        DECIMAL(18,2)   NULL,
    GstInvoiceProvided          BIT             NOT NULL DEFAULT 0,
    ApprovalComments            NVARCHAR(2000)  NULL,
    ValidationStatus            NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ValidationStatusGroup       AS CAST('POLICY_VALIDATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    AssetReimbursementStatus    NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    AssetReimbursementStatusGroup AS CAST('ASSET_REIMBURSEMENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    WorkflowInstanceId          INT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_AssetReimbursement_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_AssetReimbursement_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_AssetReimbursement_AssetType
        FOREIGN KEY (AssetType, AssetTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_AssetReimbursement_ValidationStatus
        FOREIGN KEY (ValidationStatus, ValidationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_AssetReimbursement_Status
        FOREIGN KEY (AssetReimbursementStatus, AssetReimbursementStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE 5: EXPENSE CLAIMS
CREATE TABLE expense.ExpenseClaim (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    ClaimNumber                 NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId                  INT          NOT NULL,
    CategoryId                  INT          NOT NULL,
    TravelRequestId             INT          NULL,
    AdvanceRequestId            INT          NULL,
    ClaimStatus                 NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    ClaimStatusGroup            AS CAST('EXPENSE_CLAIM_STATUS' AS NVARCHAR(50)) PERSISTED,
    TotalAmount                 DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Currency                    NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    PolicyValidationStatus      NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    PolicyValidationStatusGroup AS CAST('POLICY_VALIDATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    PolicyValidationResult      NVARCHAR(2000)  NULL,
    WorkflowInstanceId          INT          NULL,
    SubmittedAt                 DATETIME2       NULL,
    ApprovedAt                  DATETIME2       NULL,
    PaidAt                      DATETIME2       NULL,
    ClosedAt                    DATETIME2       NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_ExpenseClaim_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExpenseClaim_Category
        FOREIGN KEY (CategoryId)
        REFERENCES expense.ExpenseCategory(Id),

    CONSTRAINT FK_ExpenseClaim_TravelRequest
        FOREIGN KEY (TravelRequestId)
        REFERENCES expense.TravelRequest(Id),

    CONSTRAINT FK_ExpenseClaim_AdvanceRequest
        FOREIGN KEY (AdvanceRequestId)
        REFERENCES expense.ExpenseAdvance(Id),

    CONSTRAINT FK_ExpenseClaim_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExpenseClaim_ClaimStatus
        FOREIGN KEY (ClaimStatus, ClaimStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpenseClaim_PolicyValidationStatus
        FOREIGN KEY (PolicyValidationStatus, PolicyValidationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE expense.ExpenseClaimItem (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    ExpenseClaimId              INT          NOT NULL,
    LineNumber                  INT             NOT NULL,
    SubCategoryId               INT          NULL,
    ExpenseDate                 DATE            NOT NULL,
    Amount                      DECIMAL(18,2)   NOT NULL,
    TaxAmount                   DECIMAL(18,2)   NULL,
    VendorName                  NVARCHAR(200)   NULL,
    VendorGSTIN                 NVARCHAR(50)    NULL,
    InvoiceNumber               NVARCHAR(100)   NULL,
    InvoiceDate                 DATE            NULL,
    Location                    NVARCHAR(200)   NULL,
    Purpose                     NVARCHAR(2000)  NULL,
    IsReceiptProvided           BIT             NOT NULL DEFAULT 0,
    IsPolicyCompliant           BIT             NOT NULL DEFAULT 1,
    PolicyValidationStatus      NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    PolicyValidationStatusGroup AS CAST('POLICY_VALIDATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    PolicyValidationMessage     NVARCHAR(2000)  NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_ExpenseClaimItem_ExpenseClaim
        FOREIGN KEY (ExpenseClaimId)
        REFERENCES expense.ExpenseClaim(Id),

    CONSTRAINT FK_ExpenseClaimItem_SubCategory
        FOREIGN KEY (SubCategoryId)
        REFERENCES expense.ExpenseSubCategory(Id),

    CONSTRAINT FK_ExpenseClaimItem_PolicyValidationStatus
        FOREIGN KEY (PolicyValidationStatus, PolicyValidationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT UQ_ExpenseClaimItem_LineNumber
        UNIQUE (ExpenseClaimId, LineNumber)
);
GO

-- UploadedBy: snapshot Id, no FK — attachments must survive employee deactivation.
CREATE TABLE expense.ExpenseAttachment (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    ExpenseClaimId      INT          NOT NULL,
    ExpenseClaimItemId  INT          NULL,
    FileName            NVARCHAR(500)   NOT NULL,
    FileType            NVARCHAR(100)   NULL,
    FileUrl             NVARCHAR(2000)  NOT NULL,
    DocumentType        NVARCHAR(100)   NULL,
    UploadedBy          INT          NOT NULL,
    UploadedAt          DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsRequired          BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_ExpenseAttachment_ExpenseClaim
        FOREIGN KEY (ExpenseClaimId)
        REFERENCES expense.ExpenseClaim(Id),

    CONSTRAINT FK_ExpenseAttachment_ExpenseClaimItem
        FOREIGN KEY (ExpenseClaimItemId)
        REFERENCES expense.ExpenseClaimItem(Id)
);
GO

-- MODULE 6: PAYMENT SETTLEMENT-- EmployeeId denormalised here for direct payment processing queries —
-- avoids joining through claim/advance/asset to reach the payee.
CREATE TABLE expense.ExpenseReimbursement (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    ReimbursementNumber     NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId              INT          NOT NULL,
    ExpenseClaimId          INT          NULL,
    AdvanceRequestId        INT          NULL,
    AssetReimbursementId    INT          NULL,
    ReimbursementType       NVARCHAR(50)    NOT NULL,
    ReimbursementTypeGroup  AS CAST('REIMBURSEMENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    PaymentMethod           NVARCHAR(50)    NOT NULL,
    PaymentMethodGroup      AS CAST('PAYMENT_MODE_TYPE' AS NVARCHAR(50)) PERSISTED,
    -- Finance-side state: has the payment instruction been issued and processed?
    PaymentStatus           NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    PaymentStatusGroup      AS CAST('REIMBURSEMENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    Amount                  DECIMAL(18,2)   NOT NULL,
    TaxDeducted             DECIMAL(18,2)   NULL,
    NetAmount               DECIMAL(18,2)   NULL,
    BankAccountReference    NVARCHAR(200)   NULL,
    -- Bank-wire state: what did the payment gateway/bank report back?
    -- Distinct from PaymentStatus — finance can mark PROCESSING while the
    -- bank wire is still INITIATED; each layer fails independently.
    TransactionReference    NVARCHAR(200)   NULL,
    TransactionStatus       NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    TransactionStatusGroup  AS CAST('TRANSACTION_STATUS' AS NVARCHAR(50)) PERSISTED,
    ScheduledPaymentDate    DATE            NULL,
    PaidDate                DATE            NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_ExpenseReimbursement_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExpenseReimbursement_ExpenseClaim
        FOREIGN KEY (ExpenseClaimId)
        REFERENCES expense.ExpenseClaim(Id),

    CONSTRAINT FK_ExpenseReimbursement_AdvanceRequest
        FOREIGN KEY (AdvanceRequestId)
        REFERENCES expense.ExpenseAdvance(Id),

    CONSTRAINT FK_ExpenseReimbursement_AssetReimbursement
        FOREIGN KEY (AssetReimbursementId)
        REFERENCES expense.AssetReimbursement(Id),

    CONSTRAINT FK_ExpenseReimbursement_ReimbursementType
        FOREIGN KEY (ReimbursementType, ReimbursementTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpenseReimbursement_PaymentMethod
        FOREIGN KEY (PaymentMethod, PaymentMethodGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpenseReimbursement_PaymentStatus
        FOREIGN KEY (PaymentStatus, PaymentStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpenseReimbursement_TransactionStatus
        FOREIGN KEY (TransactionStatus, TransactionStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE 7: APPROVAL LOG-- Human-readable record of every approval action across all expense entities.
-- Complements workflow.WorkflowActionHistory (which is the engine's own audit)
-- with expense-domain context: which entity was acted on, and by whom.
--
-- Columns removed vs earlier drafts and why:
--   ApproverRole / ApproverRoleGroup
--     → Redundant. Join WorkflowStepId → WorkflowStepApprover.WorkflowApproverType.
--       WORKFLOW_APPROVER_TYPE already captures the functional role.
--   FromStatus / ToStatus / WorkflowStatusGroup
--     → Redundant. workflow.WorkflowActionHistory owns all status transition history
--       for the WorkflowInstance. Duplicating it here creates a second copy that
--       can drift. Query WorkflowActionHistory for transition detail.
CREATE TABLE expense.ExpenseApproval (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    ReferenceType       NVARCHAR(50)    NOT NULL,
    ReferenceTypeGroup  AS CAST('EXPENSE_APPROVAL_REFERENCE' AS NVARCHAR(50)) PERSISTED,
    ReferenceId         INT          NOT NULL,
    WorkflowInstanceId  INT          NULL,
    ApproverId          INT          NULL,
    ActionType          NVARCHAR(50)    NOT NULL,
    ActionTypeGroup     AS CAST('WORKFLOW_ACTION_TYPE' AS NVARCHAR(50)) PERSISTED,
    ActionBy            INT          NOT NULL,
    ActionAt            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    Remarks             NVARCHAR(2000)  NULL,

    CONSTRAINT FK_ExpenseApproval_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExpenseApproval_ReferenceType
        FOREIGN KEY (ReferenceType, ReferenceTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpenseApproval_ActionType
        FOREIGN KEY (ActionType, ActionTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpenseApproval_ApproverId
        FOREIGN KEY (ApproverId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExpenseApproval_ActionBy
        FOREIGN KEY (ActionBy)
        REFERENCES employee.Employee(Id)
);
GO

-- MODULE 8: AUDIT LOG-- Immutable append-only compliance log.
-- EventBy: snapshot Id, no FK — audit records must survive employee deactivation.
-- EventType FK enforces only seeded AUDIT_EVENT_TYPE values are written.

CREATE TABLE expense.ExpenseAuditLog (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    EntityName      NVARCHAR(100)   NOT NULL,
    EntityId        INT          NOT NULL,
    EventType       NVARCHAR(50)   NOT NULL,
    EventTypeGroup  AS CAST('AUDIT_EVENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    EventBy         INT          NOT NULL,
    EventAt         DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    Details         NVARCHAR(MAX)   NULL,
    SourceSystem    NVARCHAR(200)   NULL,

    CONSTRAINT FK_ExpenseAuditLog_EventType
        FOREIGN KEY (EventType, EventTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- INDEXES
CREATE INDEX IX_ExpenseClaim_Employee          ON expense.ExpenseClaim (EmployeeId);
CREATE INDEX IX_ExpenseClaim_Status            ON expense.ExpenseClaim (ClaimStatus);
CREATE INDEX IX_ExpenseClaim_WorkflowInstance  ON expense.ExpenseClaim (WorkflowInstanceId);
CREATE INDEX IX_ExpenseClaim_TravelRequest     ON expense.ExpenseClaim (TravelRequestId);
CREATE INDEX IX_ExpenseClaim_AdvanceRequest    ON expense.ExpenseClaim (AdvanceRequestId);

CREATE INDEX IX_ExpenseClaimItem_Claim         ON expense.ExpenseClaimItem (ExpenseClaimId);

CREATE INDEX IX_ExpenseAttachment_Claim        ON expense.ExpenseAttachment (ExpenseClaimId);

CREATE INDEX IX_TravelRequest_Employee         ON expense.TravelRequest (EmployeeId);
CREATE INDEX IX_TravelRequest_Status           ON expense.TravelRequest (TravelRequestStatus);

CREATE INDEX IX_ExpenseAdvance_Employee        ON expense.ExpenseAdvance (EmployeeId);
CREATE INDEX IX_ExpenseAdvance_TravelRequest   ON expense.ExpenseAdvance (TravelRequestId);

CREATE INDEX IX_AssetReimbursement_Employee    ON expense.AssetReimbursement (EmployeeId);
CREATE INDEX IX_AssetReimbursement_Status      ON expense.AssetReimbursement (AssetReimbursementStatus);

CREATE INDEX IX_ExpenseReimbursement_Employee  ON expense.ExpenseReimbursement (EmployeeId);
CREATE INDEX IX_ExpenseReimbursement_Claim     ON expense.ExpenseReimbursement (ExpenseClaimId);
CREATE INDEX IX_ExpenseReimbursement_Advance   ON expense.ExpenseReimbursement (AdvanceRequestId);
CREATE INDEX IX_ExpenseReimbursement_Asset     ON expense.ExpenseReimbursement (AssetReimbursementId);

CREATE INDEX IX_ExpenseApproval_Reference      ON expense.ExpenseApproval (ReferenceType, ReferenceId);
CREATE INDEX IX_ExpenseApproval_ActionBy       ON expense.ExpenseApproval (ActionBy);

CREATE INDEX IX_ExpenseAuditLog_Entity         ON expense.ExpenseAuditLog (EntityName, EntityId);
CREATE INDEX IX_ExpenseAuditLog_EventAt        ON expense.ExpenseAuditLog (EventAt);
GO

PRINT 'Expense schema created successfully.';
GO