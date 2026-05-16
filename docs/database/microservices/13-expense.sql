-- =============================================================================================================
-- EXPENSE SCHEMA - Expense & Reimbursement Module
-- SQL Server Database Schema
-- Schema: expense
-- Purpose: Manage expense claims, travel requests, asset reimbursement, advances, policy validation, finance settlement, and audit logging
-- Dependencies: shared (StatusLookup), workflow (WorkflowModule, WorkflowDefinition, WorkflowInstance, WorkflowStep), employee (Employee), time (Department, OfficeLocation)
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'expense')
BEGIN
    EXEC('CREATE SCHEMA expense');
END
GO

-- =============================================================================================================
-- SEED LOOKUP VALUES FOR EXPENSE MODULE
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM workflow.WorkflowModule WHERE ModuleCode = 'EXPENSE_REIMBURSEMENT')
BEGIN
    INSERT INTO workflow.WorkflowModule (ModuleCode, ModuleName, EntityName, IsActive, CreatedAt)
    VALUES ('EXPENSE_REIMBURSEMENT', 'Expense & Reimbursement', 'ExpenseClaim', 1, GETUTCDATE());
END
GO

-- =============================================================================================================
-- EXPENSE CLAIM STATUS
-- Purpose: Tracks lifecycle of expense claims in ExpenseClaim table
-- Usage: ClaimStatus field in expense.ExpenseClaim
-- Flow: DRAFT -> SUBMITTED -> MANAGER_APPROVED -> FINANCE_APPROVED -> PAID -> CLOSED
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'DRAFT' AND StatusGroup = 'EXPENSE_CLAIM_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('DRAFT', 'EXPENSE_CLAIM_STATUS', 'Draft', 'Initial state - employee creating expense claim. Not yet submitted for approval.', 1, 0),
    ('SUBMITTED', 'EXPENSE_CLAIM_STATUS', 'Submitted', 'Claim submitted to workflow for approval. Pending manager review.', 2, 0),
    ('MANAGER_APPROVED', 'EXPENSE_CLAIM_STATUS', 'Manager Approved', 'Approved by direct manager. Now pending finance review.', 3, 0),
    ('FINANCE_APPROVED', 'EXPENSE_CLAIM_STATUS', 'Finance Approved', 'Approved by finance team. Eligible for reimbursement payment.', 4, 0),
    ('REJECTED', 'EXPENSE_CLAIM_STATUS', 'Rejected', 'Claim rejected by approver. Employee can edit and resubmit.', 5, 1),
    ('PAID', 'EXPENSE_CLAIM_STATUS', 'Paid', 'Reimbursement amount disbursed to employee bank account.', 6, 1),
    ('CLOSED', 'EXPENSE_CLAIM_STATUS', 'Closed', 'Claim finalized with no further actions possible. Archive state.', 7, 1);
END
GO

-- =============================================================================================================
-- TRAVEL REQUEST STATUS
-- Purpose: Tracks pre-approval status for business travel in TravelRequest table
-- Usage: TravelRequestStatus field in expense.TravelRequest
-- Flow: DRAFT -> SUBMITTED -> APPROVED -> COMPLETED
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'DRAFT' AND StatusGroup = 'TRAVEL_REQUEST_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('DRAFT', 'TRAVEL_REQUEST_STATUS', 'Draft', 'Initial draft - employee planning trip details.', 1, 0),
    ('SUBMITTED', 'TRAVEL_REQUEST_STATUS', 'Submitted', 'Travel request submitted for approval.', 2, 0),
    ('APPROVED', 'TRAVEL_REQUEST_STATUS', 'Approved', 'Travel plan approved. Employee can proceed with booking.', 3, 0),
    ('REJECTED', 'TRAVEL_REQUEST_STATUS', 'Rejected', 'Travel request denied. Can be edited and resubmitted.', 4, 1),
    ('COMPLETED', 'TRAVEL_REQUEST_STATUS', 'Completed', 'Travel completed. Expense claims can now be filed.', 5, 1),
    ('CANCELLED', 'TRAVEL_REQUEST_STATUS', 'Cancelled', 'Employee cancelled the travel request before trip.', 6, 1);
END
GO

-- =============================================================================================================
-- ADVANCE REQUEST STATUS
-- Purpose: Tracks monetary advance requests in ExpenseAdvance table
-- Usage: AdvanceStatus field in expense.ExpenseAdvance
-- Flow: DRAFT -> SUBMITTED -> APPROVED -> PAID -> ADJUSTED
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'DRAFT' AND StatusGroup = 'ADVANCE_REQUEST_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('DRAFT', 'ADVANCE_REQUEST_STATUS', 'Draft', 'Draft advance request being prepared by employee.', 1, 0),
    ('SUBMITTED', 'ADVANCE_REQUEST_STATUS', 'Submitted', 'Advance request submitted for manager approval.', 2, 0),
    ('APPROVED', 'ADVANCE_REQUEST_STATUS', 'Approved', 'Advance approved. Ready for disbursement.', 3, 0),
    ('REJECTED', 'ADVANCE_REQUEST_STATUS', 'Rejected', 'Advance request denied by approver.', 4, 1),
    ('PAID', 'ADVANCE_REQUEST_STATUS', 'Paid', 'Advance amount disbursed to employee account.', 5, 0),
    ('ADJUSTED', 'ADVANCE_REQUEST_STATUS', 'Adjusted', 'Advance settled against submitted expense claim.', 6, 1),
    ('CANCELLED', 'ADVANCE_REQUEST_STATUS', 'Cancelled', 'Employee cancelled advance request before payment.', 7, 1);
END
GO

-- =============================================================================================================
-- ASSET REIMBURSEMENT STATUS
-- Purpose: Tracks employee asset purchase reimbursements in AssetReimbursement table
-- Usage: AssetReimbursementStatus field in expense.AssetReimbursement
-- Flow: DRAFT -> SUBMITTED -> IT_VALIDATED -> MANAGER_APPROVED -> FINANCE_APPROVED -> PAID
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'DRAFT' AND StatusGroup = 'ASSET_REIMBURSEMENT_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('DRAFT', 'ASSET_REIMBURSEMENT_STATUS', 'Draft', 'Draft asset reimbursement request being prepared.', 1, 0),
    ('SUBMITTED', 'ASSET_REIMBURSEMENT_STATUS', 'Submitted', 'Asset reimbursement submitted. Awaiting IT validation.', 2, 0),
    ('IT_VALIDATED', 'ASSET_REIMBURSEMENT_STATUS', 'IT Validated', 'IT confirmed asset is on approved list. Pending manager approval.', 3, 0),
    ('MANAGER_APPROVED', 'ASSET_REIMBURSEMENT_STATUS', 'Manager Approved', 'Manager approved. Pending finance review.', 4, 0),
    ('FINANCE_APPROVED', 'ASSET_REIMBURSEMENT_STATUS', 'Finance Approved', 'Finance approved for reimbursement payment.', 5, 0),
    ('REJECTED', 'ASSET_REIMBURSEMENT_STATUS', 'Rejected', 'Asset reimbursement rejected at any stage.', 6, 1),
    ('PAID', 'ASSET_REIMBURSEMENT_STATUS', 'Paid', 'Reimbursement amount transferred to employee.', 7, 1);
END
GO

-- =============================================================================================================
-- POLICY VALIDATION STATUS
-- Purpose: Result of expense policy rule validation against ExpenseClaim/ClaimItem
-- Usage: PolicyValidationStatus in expense.ExpenseClaim, ExpenseClaimItem, AssetReimbursement
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'PENDING' AND StatusGroup = 'POLICY_VALIDATION_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('PENDING', 'POLICY_VALIDATION_STATUS', 'Pending', 'Policy validation not yet executed. Happens on claim submission.', 1, 0),
    ('PASS', 'POLICY_VALIDATION_STATUS', 'Pass', 'Expense item complies with all policy rules. Approved for reimbursement.', 2, 0),
    ('FAIL', 'POLICY_VALIDATION_STATUS', 'Fail', 'Expense violates policy rules. Requires approver override or claim edit.', 3, 1);
END
GO

-- =============================================================================================================
-- REIMBURSEMENT STATUS (Payment Settlement)
-- Purpose: Tracks payment processing for approved reimbursements in ExpenseReimbursement
-- Usage: PaymentStatus field in expense.ExpenseReimbursement
-- Flow: PENDING -> PROCESSING -> PAID
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'PENDING' AND StatusGroup = 'REIMBURSEMENT_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('PENDING', 'REIMBURSEMENT_STATUS', 'Pending', 'Awaiting payment processing. Finance has approved the claim.', 1, 0),
    ('PROCESSING', 'REIMBURSEMENT_STATUS', 'Processing', 'Payment being processed through bank/finance system.', 2, 0),
    ('PAID', 'REIMBURSEMENT_STATUS', 'Paid', 'Payment successfully disbursed to employee bank account.', 3, 1),
    ('FAILED', 'REIMBURSEMENT_STATUS', 'Failed', 'Payment failed. Can be retried or manually processed.', 4, 1),
    ('CANCELLED', 'REIMBURSEMENT_STATUS', 'Cancelled', 'Payment cancelled by finance. Claim may need reprocessing.', 5, 1);
END
GO

-- =============================================================================================================
-- EXPENSE APPROVAL REFERENCE TYPES
-- Purpose: Identifies which expense entity type is being approved in workflow
-- Usage: ReferenceType field in expense.ExpenseApproval to link to correct entity
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'EXPENSE_CLAIM' AND StatusGroup = 'EXPENSE_APPROVAL_REFERENCE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('EXPENSE_CLAIM', 'EXPENSE_APPROVAL_REFERENCE', 'Expense Claim', 'Approval reference for expense.ExpenseClaim records.', 1, 0),
    ('TRAVEL_REQUEST', 'EXPENSE_APPROVAL_REFERENCE', 'Travel Request', 'Approval reference for expense.TravelRequest records.', 2, 0),
    ('ASSET_REIMBURSEMENT', 'EXPENSE_APPROVAL_REFERENCE', 'Asset Reimbursement', 'Approval reference for expense.AssetReimbursement records.', 3, 0),
    ('ADVANCE_REQUEST', 'EXPENSE_APPROVAL_REFERENCE', 'Advance Request', 'Approval reference for expense.ExpenseAdvance records.', 4, 0);
END
GO

-- =============================================================================================================
-- APPROVER ROLES
-- Purpose: Defines who can approve expense requests at each workflow step
-- Usage: ApproverRole in expense.ExpenseApproval determines approval authority
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'REPORTING_MANAGER' AND StatusGroup = 'APPROVER_ROLE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('REPORTING_MANAGER', 'APPROVER_ROLE', 'Reporting Manager', 'First-level approval by employee''s direct manager.', 1, 0),
    ('DEPARTMENT_HEAD', 'APPROVER_ROLE', 'Department Head', 'Second-level approval by department head.', 2, 0),
    ('FINANCE', 'APPROVER_ROLE', 'Finance', 'Finance team approval for payment release.', 3, 0),
    ('HR', 'APPROVER_ROLE', 'HR', 'HR approval for policy exceptions or special cases.', 4, 0),
    ('IT', 'APPROVER_ROLE', 'IT', 'IT validation for asset reimbursement eligibility.', 5, 0),
    ('PAYROLL', 'APPROVER_ROLE', 'Payroll', 'Payroll final review before disbursement.', 6, 0);
END
GO

-- =============================================================================================================
-- EXPENSE POLICY GROUPS
-- Purpose: Groups expense policies by category for organization and reporting
-- Usage: PolicyGroup in expense.ExpensePolicy determines which policy rules apply
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'TRAVEL' AND StatusGroup = 'EXPENSE_POLICY_GROUP')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('TRAVEL', 'EXPENSE_POLICY_GROUP', 'Travel', 'Policies for travel expenses (flights, hotels, transport).', 1, 0),
    ('ASSET', 'EXPENSE_POLICY_GROUP', 'Asset', 'Policies for office asset purchases (laptops, equipment).', 2, 0),
    ('WFH', 'EXPENSE_POLICY_GROUP', 'WFH', 'Work from home allowances (internet, phone, electricity).', 3, 0),
    ('MEDICAL', 'EXPENSE_POLICY_GROUP', 'Medical', 'Medical reimbursement policies and limits.', 4, 0),
    ('ADVANCE', 'EXPENSE_POLICY_GROUP', 'Advance', 'Advance request limits and recovery rules.', 5, 0),
    ('GENERAL', 'EXPENSE_POLICY_GROUP', 'General', 'General office and misc expense policies.', 6, 0);
END
GO

-- =============================================================================================================
-- REIMBURSEMENT TYPES
-- Purpose: Categorizes the type of reimbursement being processed
-- Usage: ReimbursementType in expense.ExpenseReimbursement
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'CLAIM' AND StatusGroup = 'REIMBURSEMENT_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('CLAIM', 'REIMBURSEMENT_TYPE', 'Claim', 'Reimbursement for submitted expense claim after approval.', 1, 0),
    ('ADVANCE', 'REIMBURSEMENT_TYPE', 'Advance', 'Settlement of advance against related expense claim.', 2, 0),
    ('ASSET', 'REIMBURSEMENT_TYPE', 'Asset', 'Reimbursement for approved asset purchase.', 3, 0);
END
GO

-- =============================================================================================================
-- AUDIT EVENT TYPES
-- Purpose: Captures all action events for compliance tracking in ExpenseAuditLog
-- Usage: EventType field in expense.ExpenseAuditLog records every state change
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'CLAIM_CREATED' AND StatusGroup = 'AUDIT_EVENT_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('CLAIM_CREATED', 'AUDIT_EVENT_TYPE', 'Claim Created', 'New expense claim created by employee.', 1, 0),
    ('CLAIM_SUBMITTED', 'AUDIT_EVENT_TYPE', 'Claim Submitted', 'Expense claim submitted for approval workflow.', 2, 0),
    ('CLAIM_APPROVED', 'AUDIT_EVENT_TYPE', 'Claim Approved', 'Claim approved at some workflow stage.', 3, 0),
    ('CLAIM_REJECTED', 'AUDIT_EVENT_TYPE', 'Claim Rejected', 'Claim rejected by approver.', 4, 0),
    ('PAYMENT_PROCESSED', 'AUDIT_EVENT_TYPE', 'Payment Processed', 'Reimbursement payment initiated or completed.', 5, 0),
    ('POLICY_VALIDATED', 'AUDIT_EVENT_TYPE', 'Policy Validated', 'Automated policy validation executed on claim.', 6, 0);
END
GO

-- =============================================================================================================
-- ASSET TYPES
-- Purpose: Categories of office assets eligible for employee reimbursement
-- Usage: AssetType in expense.AssetReimbursement determines eligibility and limits
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'LAPTOP' AND StatusGroup = 'ASSET_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('LAPTOP', 'ASSET_TYPE', 'Laptop', 'Personal laptop purchase reimbursement (requires IT validation).', 1, 0),
    ('MONITOR', 'ASSET_TYPE', 'Monitor', 'External monitor for home office setup.', 2, 0),
    ('KEYBOARD', 'ASSET_TYPE', 'Keyboard', 'Keyboard and input devices.', 3, 0),
    ('MOUSE', 'ASSET_TYPE', 'Mouse', 'Mouse and pointing devices.', 4, 0),
    ('HEADPHONES', 'ASSET_TYPE', 'Headphones', 'Headphones for calls and meetings.', 5, 0),
    ('CHAIR', 'ASSET_TYPE', 'Office Chair', 'Ergonomic office chair for WFH setup.', 6, 0);
END
GO

-- =============================================================================================================
-- TRAVEL TYPES
-- Purpose: Classifies travel expenses for policy and reporting
-- Usage: TravelType in expense.TravelRequest and related claim items
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'FLIGHT' AND StatusGroup = 'TRAVEL_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('FLIGHT', 'TRAVEL_TYPE', 'Flight', 'Domestic or international flight tickets.', 1, 0),
    ('TRAIN', 'TRAVEL_TYPE', 'Train', 'Train travel (AC class depends on policy).', 2, 0),
    ('CAB', 'TRAVEL_TYPE', 'Cab', 'Taxi, cab, ride-share for business travel.', 3, 0),
    ('FUEL', 'TRAVEL_TYPE', 'Fuel', 'Vehicle fuel for company car or mileage reimbursement.', 4, 0),
    ('HOTEL', 'TRAVEL_TYPE', 'Hotel', 'Hotel accommodation during business travel.', 5, 0),
    ('MEAL', 'TRAVEL_TYPE', 'Meal', 'Daily allowance for meals during travel.', 6, 0);
END
GO

-- =============================================================================================================
-- WORKFLOW ACTION TYPES
-- Purpose: Actions taken by approvers during expense approval workflow
-- Usage: ActionType in expense.ExpenseApproval records approver decisions
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'APPROVED' AND StatusGroup = 'WORKFLOW_ACTION_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('APPROVED', 'WORKFLOW_ACTION_TYPE', 'Approved', 'Approver accepted the request and approved it.', 1, 0),
    ('REJECTED', 'WORKFLOW_ACTION_TYPE', 'Rejected', 'Approver rejected the request. Requires employee action.', 2, 1),
    ('ESCALATED', 'WORKFLOW_ACTION_TYPE', 'Escalated', 'Request escalated to higher-level approver.', 3, 0),
    ('COMMENTED', 'WORKFLOW_ACTION_TYPE', 'Commented', 'Approver added comment without changing status.', 4, 0);
END
GO

-- Payment Methods are already seeded in shared.StatusLookup under PAYMENT_MODE_TYPE
-- Transaction statuses are already seeded under TRANSACTION_STATUS
-- Existing shared.StatusLookup groups can support this module without duplicate data
GO

-- =============================================================================================================
-- MODULE 1: EXPENSE LOOKUPS AND POLICIES
-- =============================================================================================================

CREATE TABLE expense.ExpenseCategory (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode        NVARCHAR(100)   NOT NULL UNIQUE,
    CategoryName        NVARCHAR(200)   NOT NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Master table for expense categories (e.g., Travel, Food, Medical). Used to classify expense claims and determine applicable policies.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseCategory';
GO

-- =============================================================================================================
-- EXPENSE CATEGORIES (Master Data)
-- Purpose: Classifies expense claims by business category
-- Usage: CategoryId in expense.ExpenseClaim determines applicable policy
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM expense.ExpenseCategory WHERE CategoryCode = 'TRAVEL')
BEGIN
    INSERT INTO expense.ExpenseCategory (CategoryCode, CategoryName, Description)
    VALUES
    ('TRAVEL', 'Travel', 'Business travel: flights, trains, cabs, fuel, parking.'),
    ('FOOD', 'Food', 'Client meals, business dinners, daily allowances.'),
    ('ACCOMMODATION', 'Accommodation', 'Hotel stays, lodging during business travel.'),
    ('INTERNET', 'Internet', 'Work from home internet reimbursement (WFH policy).'),
    ('MOBILE', 'Mobile', 'Mobile phone bills, SIM card costs.'),
    ('LAPTOP', 'Laptop', 'Laptop purchases and repairs (asset reimbursement).'),
    ('OFFICE_SUPPLIES', 'Office Supplies', 'Stationery, printer supplies, misc office items.'),
    ('MEDICAL', 'Medical', 'Medical reimbursements, health checkups, insurance.'),
    ('TRAINING', 'Training', 'Courses, certifications, conference fees.'),
    ('RELOCATION', 'Relocation', 'Moving expenses, relocation allowances.');
END
GO

CREATE TABLE expense.ExpenseSubCategory (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    CategoryId          BIGINT          NOT NULL,
    SubCategoryCode     NVARCHAR(100)   NOT NULL,
    SubCategoryName     NVARCHAR(200)   NOT NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ExpenseSubCategory_Category
        FOREIGN KEY (CategoryId)
        REFERENCES expense.ExpenseCategory(Id),

    CONSTRAINT UQ_ExpenseSubCategory_CodePerCategory
        UNIQUE (CategoryId, SubCategoryCode)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Sub-categories under each expense category for granular classification. Example: Travel category has Flight, Train, Cab sub-categories.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseSubCategory';
GO

CREATE TABLE expense.ExpensePolicy (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyCode              NVARCHAR(100)   NOT NULL UNIQUE,
    PolicyName              NVARCHAR(200)   NOT NULL,
    PolicyGroup             NVARCHAR(100)   NOT NULL,
    CategoryId              BIGINT          NULL,
    SubCategoryId           BIGINT          NULL,
    MaximumAmount           DECIMAL(18,2)   NULL,
    FrequencyMonths         INT             NULL,
    ApprovedVendorList      NVARCHAR(2000)  NULL,
    GstInvoiceRequired      BIT             NOT NULL DEFAULT 0,
    TravelClassAllowed      NVARCHAR(200)   NULL,
    DailyAllowanceLimit     DECIMAL(18,2)   NULL,
    HotelLimitAmount        DECIMAL(18,2)   NULL,
    Description             NVARCHAR(2000)  NULL,
    EffectiveFrom           DATE            NOT NULL,
    EffectiveTo             DATE            NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ExpensePolicy_Category
        FOREIGN KEY (CategoryId)
        REFERENCES expense.ExpenseCategory(Id),

    CONSTRAINT FK_ExpensePolicy_SubCategory
        FOREIGN KEY (SubCategoryId)
        REFERENCES expense.ExpenseSubCategory(Id)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Defines expense policies with limits, rules, and validation criteria. Each policy applies to specific expense categories and has effective date ranges.', 'SCHEMA', 'expense', 'TABLE', 'ExpensePolicy';
GO

CREATE TABLE expense.ExpensePolicyRule (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyId                BIGINT          NOT NULL,
    RuleCode                NVARCHAR(100)   NOT NULL,
    RuleName                NVARCHAR(200)   NOT NULL,
    RuleType                NVARCHAR(100)   NOT NULL,
    RuleValue               NVARCHAR(1000)  NOT NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ExpensePolicyRule_Policy
        FOREIGN KEY (PolicyId)
        REFERENCES expense.ExpensePolicy(Id),

    CONSTRAINT UQ_ExpensePolicyRule_PolicyRule
        UNIQUE (PolicyId, RuleCode)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Individual validation rules attached to an expense policy. Rules define conditions like max amount per day, required GST invoice, approved vendors, etc.', 'SCHEMA', 'expense', 'TABLE', 'ExpensePolicyRule';
GO

-- =============================================================================================================
-- MODULE 2: TRAVEL, ASSET AND ADVANCES
-- =============================================================================================================

CREATE TABLE expense.TravelRequest (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    TravelRequestNumber         NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId                  BIGINT          NOT NULL,
    TravelType                  NVARCHAR(50)    NOT NULL,
    TravelTypeGroup             AS CAST('TRAVEL_TYPE' AS NVARCHAR(50)) PERSISTED,
    DepartureCity               NVARCHAR(200)   NULL,
    ArrivalCity                 NVARCHAR(200)   NULL,
    DepartureDate               DATE            NOT NULL,
    ReturnDate                  DATE            NULL,
    TravelClass                 NVARCHAR(50)    NULL,
    EstimatedCost               DECIMAL(18,2)   NULL,
    Purpose                     NVARCHAR(2000)  NULL,
    AdvanceRequestedAmount      DECIMAL(18,2)   NULL,
    TravelRequestStatus         NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    TravelRequestStatusGroup    AS CAST('TRAVEL_REQUEST_STATUS' AS NVARCHAR(50)) PERSISTED,
    WorkflowDefinitionId        BIGINT          NULL,
    WorkflowInstanceId          BIGINT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_TravelRequest_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_TravelRequest_WorkflowDefinition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_TravelRequest_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_TravelRequest_Status
        FOREIGN KEY (TravelRequestStatus, TravelRequestStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Pre-travel request records for employee business trips. Used to approve travel plans and optionally request advances before the trip.', 'SCHEMA', 'expense', 'TABLE', 'TravelRequest';
GO

CREATE TABLE expense.ExpenseAdvance (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    AdvanceNumber               NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId                  BIGINT          NOT NULL,
    TravelRequestId             BIGINT          NULL,
    AdvanceAmount               DECIMAL(18,2)   NOT NULL,
    Currency                    NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    Purpose                     NVARCHAR(2000)  NULL,
    RequestedOn                 DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    ApprovedAmount              DECIMAL(18,2)   NULL,
    PaidAmount                  DECIMAL(18,2)   NULL,
    AdjustmentAmount            DECIMAL(18,2)   NULL,
    AdjustmentDate              DATE            NULL,
    AdvanceStatus               NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    AdvanceStatusGroup          AS CAST('ADVANCE_REQUEST_STATUS' AS NVARCHAR(50)) PERSISTED,
    WorkflowDefinitionId        BIGINT          NULL,
    WorkflowInstanceId          BIGINT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_ExpenseAdvance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExpenseAdvance_TravelRequest
        FOREIGN KEY (TravelRequestId)
        REFERENCES expense.TravelRequest(Id),

    CONSTRAINT FK_ExpenseAdvance_WorkflowDefinition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_ExpenseAdvance_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExpenseAdvance_Status
        FOREIGN KEY (AdvanceStatus, AdvanceStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Tracks monetary advances paid to employees before expense submission. Advances are later adjusted against actual expense claims or recovered if unused.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseAdvance';
GO

CREATE TABLE expense.AssetReimbursement (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    AssetRequestNumber          NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId                  BIGINT          NOT NULL,
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
    WorkflowDefinitionId        BIGINT          NULL,
    WorkflowInstanceId          BIGINT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_AssetReimbursement_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_AssetReimbursement_WorkflowDefinition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_AssetReimbursement_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_AssetReimbursement_ValidationStatus
        FOREIGN KEY (ValidationStatus, ValidationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_AssetReimbursement_Status
        FOREIGN KEY (AssetReimbursementStatus, AssetReimbursementStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Tracks employee requests for reimbursement of office assets (laptops, monitors, chairs). Requires IT validation and invoice verification before approval.', 'SCHEMA', 'expense', 'TABLE', 'AssetReimbursement';
GO

-- =============================================================================================================
-- MODULE 3: CLAIMS
-- =============================================================================================================

CREATE TABLE expense.ExpenseClaim (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ClaimNumber                 NVARCHAR(100)   NOT NULL UNIQUE,
    EmployeeId                  BIGINT          NOT NULL,
    CategoryId                  BIGINT          NOT NULL,
    TravelRequestId             BIGINT          NULL,
    AdvanceRequestId            BIGINT          NULL,
    AssetReimbursementId        BIGINT          NULL,
    ClaimStatus                 NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    ClaimStatusGroup            AS CAST('EXPENSE_CLAIM_STATUS' AS NVARCHAR(50)) PERSISTED,
    TotalAmount                 DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Currency                    NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    PolicyValidationStatus      NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    PolicyValidationStatusGroup AS CAST('POLICY_VALIDATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    PolicyValidationResult      NVARCHAR(2000)  NULL,
    WorkflowDefinitionId        BIGINT          NULL,
    WorkflowInstanceId          BIGINT          NULL,
    CurrentWorkflowStepId       BIGINT          NULL,
    CurrentApproverId           BIGINT          NULL,
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

    CONSTRAINT FK_ExpenseClaim_AssetReimbursement
        FOREIGN KEY (AssetReimbursementId)
        REFERENCES expense.AssetReimbursement(Id),

    CONSTRAINT FK_ExpenseClaim_WorkflowDefinition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_ExpenseClaim_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExpenseClaim_CurrentWorkflowStep
        FOREIGN KEY (CurrentWorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_ExpenseClaim_ClaimStatus
        FOREIGN KEY (ClaimStatus, ClaimStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExpenseClaim_PolicyValidationStatus
        FOREIGN KEY (PolicyValidationStatus, PolicyValidationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Main expense claim record. Links to category, travel/advance/asset requests. Tracks workflow status from submission through approval to payment.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseClaim';
GO

CREATE TABLE expense.ExpenseClaimItem (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ExpenseClaimId              BIGINT          NOT NULL,
    LineNumber                  INT             NOT NULL,
    SubCategoryId               BIGINT          NULL,
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
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Individual line items within an expense claim. Each item has its own date, amount, vendor details, and policy validation status.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseClaimItem';
GO

CREATE TABLE expense.ExpenseAttachment (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    ExpenseClaimId          BIGINT          NOT NULL,
    ExpenseClaimItemId      BIGINT          NULL,
    FileName                NVARCHAR(500)   NOT NULL,
    FileType                NVARCHAR(100)   NULL,
    FileUrl                 NVARCHAR(2000)  NOT NULL,
    DocumentType            NVARCHAR(100)   NULL,
    UploadedBy              BIGINT          NOT NULL,
    UploadedAt              DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsRequired              BIT             NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_ExpenseAttachment_ExpenseClaim
        FOREIGN KEY (ExpenseClaimId)
        REFERENCES expense.ExpenseClaim(Id),

    CONSTRAINT FK_ExpenseAttachment_ExpenseClaimItem
        FOREIGN KEY (ExpenseClaimItemId)
        REFERENCES expense.ExpenseClaimItem(Id)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Supporting documents (invoices, receipts) attached to expense claims or individual line items. Required for GST and audit compliance.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseAttachment';
GO

-- =============================================================================================================
-- MODULE 3: PAYMENT SETTLEMENT AND AUDIT
-- =============================================================================================================

CREATE TABLE expense.ExpenseReimbursement (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ReimbursementNumber         NVARCHAR(100)   NOT NULL UNIQUE,
    ExpenseClaimId              BIGINT          NULL,
    AdvanceRequestId            BIGINT          NULL,
    AssetReimbursementId        BIGINT          NULL,
    ReimbursementType           NVARCHAR(50)    NOT NULL,
    ReimbursementTypeGroup      AS CAST('REIMBURSEMENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    PaymentMethod               NVARCHAR(50)    NOT NULL,
    PaymentMethodGroup          AS CAST('PAYMENT_MODE_TYPE' AS NVARCHAR(50)) PERSISTED,
    PaymentStatus               NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    PaymentStatusGroup          AS CAST('REIMBURSEMENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    Amount                      DECIMAL(18,2)   NOT NULL,
    TaxDeducted                 DECIMAL(18,2)   NULL,
    NetAmount                   DECIMAL(18,2)   NULL,
    BankAccountReference        NVARCHAR(200)   NULL,
    TransactionReference        NVARCHAR(200)   NULL,
    TransactionStatus           NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    TransactionStatusGroup      AS CAST('TRANSACTION_STATUS' AS NVARCHAR(50)) PERSISTED,
    ScheduledPaymentDate        DATE            NULL,
    PaidDate                    DATE            NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_ExpenseReimbursement_ExpenseClaim
        FOREIGN KEY (ExpenseClaimId)
        REFERENCES expense.ExpenseClaim(Id),

    CONSTRAINT FK_ExpenseReimbursement_AdvanceRequest
        FOREIGN KEY (AdvanceRequestId)
        REFERENCES expense.ExpenseAdvance(Id),

    CONSTRAINT FK_ExpenseReimbursement_AssetReimbursement
        FOREIGN KEY (AssetReimbursementId)
        REFERENCES expense.AssetReimbursement(Id),

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
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Tracks reimbursement payments for approved expense claims. Handles payment processing, transaction status, and settlement details.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseReimbursement';
GO

CREATE TABLE expense.ExpenseApproval (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ReferenceType               NVARCHAR(50)    NOT NULL,
    ReferenceTypeGroup          AS CAST('EXPENSE_APPROVAL_REFERENCE' AS NVARCHAR(50)) PERSISTED,
    ReferenceId                 BIGINT          NOT NULL,
    WorkflowInstanceId          BIGINT          NULL,
    WorkflowStepId              BIGINT          NULL,
    StepNo                      INT             NULL,
    ApproverId                  BIGINT          NULL,
    ApproverRole                NVARCHAR(50)    NULL,
    ApproverRoleGroup           AS CAST('APPROVER_ROLE' AS NVARCHAR(50)) PERSISTED,
    ActionType                  NVARCHAR(50)    NOT NULL,
    ActionTypeGroup             AS CAST('WORKFLOW_ACTION_TYPE' AS NVARCHAR(50)) PERSISTED,
    FromStatus                  NVARCHAR(50)    NULL,
    ToStatus                    NVARCHAR(50)    NULL,
    WorkflowStatusGroup         AS CAST('EXPENSE_CLAIM_STATUS' AS NVARCHAR(50)) PERSISTED,
    ActionBy                    BIGINT          NOT NULL,
    ActionAt                    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    Remarks                     NVARCHAR(2000)  NULL,

    CONSTRAINT FK_ExpenseApproval_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExpenseApproval_WorkflowStep
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id)
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Stores approval history for expense requests. Records each approver action (approved/rejected/escalated) with timestamps and remarks.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseApproval';
GO

CREATE TABLE expense.ExpenseAuditLog (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EntityName                  NVARCHAR(100)   NOT NULL,
    EntityId                    BIGINT          NOT NULL,
    EventType                   NVARCHAR(100)   NOT NULL,
    EventTypeGroup              AS CAST('AUDIT_EVENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    EventBy                     BIGINT          NOT NULL,
    EventAt                     DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    Details                     NVARCHAR(MAX)   NULL,
    SourceSystem                NVARCHAR(200)   NULL
);
-- Comments for table purpose
EXEC sp_addextendedproperty 'MS_Description', 'Immutable audit trail for all expense-related actions. Captures create, submit, approve, reject, payment events for compliance and investigation.', 'SCHEMA', 'expense', 'TABLE', 'ExpenseAuditLog';
GO

-- =============================================================================================================
-- INDEXES - expense Schema
-- =============================================================================================================

CREATE INDEX IX_ExpenseClaim_Employee ON expense.ExpenseClaim (EmployeeId);
CREATE INDEX IX_ExpenseClaim_Status ON expense.ExpenseClaim (ClaimStatus);
CREATE INDEX IX_ExpenseClaim_WorkflowInstance ON expense.ExpenseClaim (WorkflowInstanceId);
CREATE INDEX IX_ExpenseClaimItem_ExpenseClaim ON expense.ExpenseClaimItem (ExpenseClaimId);
CREATE INDEX IX_ExpenseAttachment_ExpenseClaim ON expense.ExpenseAttachment (ExpenseClaimId);
CREATE INDEX IX_TravelRequest_Employee ON expense.TravelRequest (EmployeeId);
CREATE INDEX IX_ExpenseAdvance_Employee ON expense.ExpenseAdvance (EmployeeId);
CREATE INDEX IX_ExpenseReimbursement_Claim ON expense.ExpenseReimbursement (ExpenseClaimId);
CREATE INDEX IX_ExpenseReimbursement_Advance ON expense.ExpenseReimbursement (AdvanceRequestId);
CREATE INDEX IX_ExpenseApproval_Reference ON expense.ExpenseApproval (ReferenceType, ReferenceId);
CREATE INDEX IX_ExpenseAuditLog_Entity ON expense.ExpenseAuditLog (EntityName, EntityId);
GO
