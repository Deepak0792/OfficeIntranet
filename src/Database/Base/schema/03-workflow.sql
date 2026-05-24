-- ============================================================
-- WORKFLOW SCHEMA - Approval Workflow Engine (v3)
-- SQL Server Database Schema
-- Schema: workflow
-- Purpose: Configurable multi-step approval workflow engine
-- Dependencies: shared (StatusLookup), employee (Employee), time (ScopeType)
--
-- CHANGELOG
-- v1 → v2:
--   - ScopeType moved from WorkflowAssignment → WorkflowStepApprover
--     (each step resolves approvers from its own scope)
--   - WorkflowTask table added (runtime actionable inbox items)
--   - WorkflowActionHistory: fixed dual FK collision on computed column
--     (split into FromWorkflowStatusGroup / ToWorkflowStatusGroup)
--
-- v2 → v3:
--   - WorkflowStepApprover.ApproverReferenceId REMOVED
--     EMPLOYEE is a first-class ScopeType (HierarchyLevel = 7)
--     Fixed approvers use ScopeTypeId = EMPLOYEE, ScopeReferenceId = employee.Id
--     No separate column needed — same resolution path as all other scope types
--   - Seed inserts: StatusName → Label (matches shared.StatusLookup schema)
--     Inserts moved out of comment block — live executable SQL
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'workflow')
BEGIN
    EXEC('CREATE SCHEMA workflow');
END
GO

-- ============================================================
-- MODULE 1: WORKFLOW CONFIGURATION
-- Design-time entities. Define the template, steps, and
-- approver resolution rules. No runtime data lives here.
-- ============================================================

-- Functional module that owns workflows  e.g. LEAVE, EXPENSE, HIRING
CREATE TABLE workflow.WorkflowModule (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    ModuleCode      NVARCHAR(100)   NOT NULL UNIQUE,
    ModuleName      NVARCHAR(200)   NOT NULL,
    EntityName      NVARCHAR(100)   NOT NULL,   -- Logical entity name tracked by the module
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),    
    LastUpdatedBy   INT             NULL
);
GO

-- Versioned workflow template belonging to a module
CREATE TABLE workflow.WorkflowDefinition (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowModuleId    SMALLINT          NOT NULL,
    WorkflowCode        NVARCHAR(100)   NOT NULL UNIQUE,
    WorkflowName        NVARCHAR(200)   NOT NULL,
    VersionNo           SMALLINT             NOT NULL DEFAULT 1,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_WorkflowDefinition_Module
        FOREIGN KEY (WorkflowModuleId)
        REFERENCES workflow.WorkflowModule(Id)
);
GO

-- Ordered steps within a workflow definition
-- WorkflowStepType values (WORKFLOW_STEP_TYPE): APPROVAL, REVIEW, NOTIFICATION, FYI
CREATE TABLE workflow.WorkflowStep (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    SMALLINT          NOT NULL,
    StepNo                  SMALLINT             NOT NULL,
    StepName                NVARCHAR(200)   NOT NULL,
    WorkflowStepType        NVARCHAR(50)    NOT NULL,
    WorkflowStepTypeGroup   AS CAST('WORKFLOW_STEP_TYPE' AS NVARCHAR(50)) PERSISTED,
    IsFinalStep             BIT             NOT NULL DEFAULT 0,
    AllowDelegation         BIT             NOT NULL DEFAULT 1,
    EscalationAfterHours    INT             NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_WorkflowStep_Definition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_WorkflowStep_WorkflowStepType
        FOREIGN KEY (WorkflowStepType, WorkflowStepTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT UQ_WorkflowStep_Order
        UNIQUE (WorkflowDefinitionId, StepNo)
);
GO

-- ============================================================
-- Approver resolution rule per step.
--
-- Each row defines HOW to resolve the approver for this step
-- using the unified ScopeType hierarchy from time.ScopeType:
--
--   ScopeType   HierarchyLevel   Meaning
--   GLOBAL             1         Anyone in the entire system
--   COUNTRY            2         Scoped to a country
--   LEGAL_ENTITY       3         Scoped to a legal entity
--   OFFICE             4         Scoped to an office
--   DEPARTMENT         5         Scoped to a department
--   TEAM               6         Scoped to a team
--   EMPLOYEE           7         A specific employee (fixed approver)
--
-- Resolution examples:
--   Step 1 → ApproverType=ROLE,              ScopeTypeId=DEPARTMENT, ScopeReferenceId=42
--            "Find the manager-role holder in Dept 42"
--
--   Step 2 → ApproverType=DESIGNATION,       ScopeTypeId=LEGAL_ENTITY, ScopeReferenceId=1
--            "Find HR Head designation in Legal Entity 1"
--
--   Step 3 → ApproverType=EMPLOYEE,          ScopeTypeId=EMPLOYEE, ScopeReferenceId=501
--            "Always assign to Employee 501"
--
--   Step 4 → ApproverType=REPORTING_MANAGER, ScopeTypeId=NULL, ScopeReferenceId=NULL
--            "Resolve from initiator's org hierarchy at runtime"
--
-- ApproverReferenceId intentionally removed (v3):
--   EMPLOYEE is a ScopeType like any other. Fixed approvers are
--   expressed as ScopeTypeId=EMPLOYEE + ScopeReferenceId=employee.Id.
--   A separate column would duplicate this and create two resolution paths.
-- ============================================================
CREATE TABLE workflow.WorkflowStepApprover (
    Id                          SMALLINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowStepId              SMALLINT          NOT NULL,
    WorkflowApproverType        NVARCHAR(50)    NOT NULL,
    WorkflowApproverTypeGroup   AS CAST('WORKFLOW_APPROVER_TYPE' AS NVARCHAR(50)) PERSISTED,
    ScopeTypeId                 SMALLINT          NULL,   -- FK → time.ScopeType
    ScopeReferenceId            SMALLINT          NULL,   -- Entity id within that scope level
    PriorityOrder               SMALLINT             NOT NULL DEFAULT 1,
    IsMandatory                 BIT             NOT NULL DEFAULT 1,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

    CONSTRAINT FK_WorkflowStepApprover_Step
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowStepApprover_WorkflowApproverType
        FOREIGN KEY (WorkflowApproverType, WorkflowApproverTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_WorkflowStepApprover_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES time.ScopeType(Id)
);
GO

-- Declares which designation(s) qualify as the approver for a given step.
-- One WorkflowStepApprover can accept multiple designations
-- (e.g. Step 2 accepts CONSULTANT or SRSURGEON as Department Head)
-- ============================================================
CREATE TABLE workflow.WorkflowStepApproverDesignation (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowStepApproverId  SMALLINT          NOT NULL,
    DesignationId           SMALLINT          NOT NULL,   -- FK → time.Designation
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_WSADesignation_StepApprover
        FOREIGN KEY (WorkflowStepApproverId)
        REFERENCES workflow.WorkflowStepApprover(Id),

    CONSTRAINT FK_WSADesignation_Designation
        FOREIGN KEY (DesignationId)
        REFERENCES time.Designation(Id),

    CONSTRAINT UQ_WSADesignation
        UNIQUE (WorkflowStepApproverId, DesignationId)
);

-- ============================================================
-- MODULE 2: WORKFLOW ASSIGNMENT
-- Routing table: maps a workflow definition to an org scope.
-- Answers: "Which workflow template applies to transaction X?"
--
-- ScopeType here is ROUTING scope (which org unit the workflow
-- is assigned to), distinct from approver resolution scope.
-- Example: Assign LEAVE_WF to DEPARTMENT 42 effective 2025-01-01
-- ============================================================
CREATE TABLE workflow.WorkflowAssignment (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    SMALLINT          NOT NULL,
    ScopeTypeId             SMALLINT          NOT NULL,   -- FK → time.ScopeType (routing scope)
    ScopeReferenceId        SMALLINT          NOT NULL,   -- Entity id at the routing scope
    EffectiveFrom           DATE            NOT NULL,
    EffectiveTo             DATE            NULL,
    PriorityOrder           SMALLINT             NOT NULL DEFAULT 1,  -- Conflict resolution when multiple match
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_WorkflowAssignment_Definition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_WorkflowAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES time.ScopeType(Id)
);
GO

-- ============================================================
-- MODULE 3: WORKFLOW EXECUTION
-- Runtime state tracking for each submitted transaction.
-- ============================================================

-- One instance per submitted transaction.
-- ReferenceTransactionId → PK of the originating record (e.g. LeaveRequest.Id)
CREATE TABLE workflow.WorkflowInstance (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    SMALLINT          NOT NULL,
    WorkflowModuleId        SMALLINT          NOT NULL,
    ReferenceTransactionId  INT          NOT NULL,
    CurrentWorkflowStepId   SMALLINT          NULL,       -- NULL when completed or cancelled
    WorkflowStatus          NVARCHAR(50)    NOT NULL,
    WorkflowStatusGroup     AS CAST('WORKFLOW_STATUS' AS NVARCHAR(50)) PERSISTED,
    CreatedBy               INT             NOT NULL,   -- FK → employee.Employee
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CompletedAt             DATETIME2       NULL,
    CompletedBy             INT             NULL,
    IsActive                BIT             NOT NULL DEFAULT 1

    CONSTRAINT FK_WorkflowInstance_Definition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_WorkflowInstance_Module
        FOREIGN KEY (WorkflowModuleId)
        REFERENCES workflow.WorkflowModule(Id),

    CONSTRAINT FK_WorkflowInstance_CurrentStep
        FOREIGN KEY (CurrentWorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowInstance_WorkflowStatus
        FOREIGN KEY (WorkflowStatus, WorkflowStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================
-- WorkflowTask — Runtime actionable task per resolved approver.
--
-- WorkflowStepApprover = rule ("who should approve step N")
-- WorkflowTask         = instance ("Employee 501 must act on Instance 99, Step 2")
--
-- Lifecycle:
--   1. WorkflowInstance advances to Step N.
--   2. Engine evaluates WorkflowStepApprover rules + scope
--      to resolve actual Employee ids.
--   3. One WorkflowTask row inserted per resolved approver.
--   4. Approver sees PENDING tasks in their inbox.
--   5. On action → TaskStatus updated, WorkflowActionHistory written.
--
-- Delegation chain:
--   Original task → DelegatedFromEmployeeId set, ParentWorkflowTaskId set,
--   new task created for the delegate with ParentWorkflowTaskId pointing back.
--
-- TaskStatus values (WORKFLOW_TASK_STATUS): PENDING, COMPLETED, DELEGATED, CANCELLED, ESCALATED
-- ============================================================
CREATE TABLE workflow.WorkflowTask (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    WorkflowInstanceId          INT          NOT NULL,
    WorkflowStepId              SMALLINT          NOT NULL,
    WorkflowStepApproverId      SMALLINT          NOT NULL,   -- The rule that generated this task
    AssignedToEmployeeId        INT          NOT NULL,   -- FK → employee.Employee (resolved approver)
    DelegatedFromEmployeeId     INT          NULL,       -- FK → employee.Employee (set when delegated)
    TaskStatus                  NVARCHAR(50)    NOT NULL,
    TaskStatusGroup             AS CAST('WORKFLOW_TASK_STATUS' AS NVARCHAR(50)) PERSISTED,
    Remarks                     NVARCHAR(2000)  NULL,
    ParentWorkflowTaskId        INT          NULL,       -- Set when this task is a delegation child
    AssignedAt                  DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    DueAt                       DATETIME2       NULL,       -- Computed from step EscalationAfterHours
    ActionAt                    DATETIME2       NULL,       -- Timestamp when approver acted
    ActionBy                    INT             NOT NULL,       -- Timestamp when approver acted
    IsActive                    BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_WorkflowTask_Instance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_WorkflowTask_Step
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowTask_StepApprover
        FOREIGN KEY (WorkflowStepApproverId)
        REFERENCES workflow.WorkflowStepApprover(Id),

    CONSTRAINT FK_WorkflowTask_TaskStatus
        FOREIGN KEY (TaskStatus, TaskStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_WorkflowTask_Parent
        FOREIGN KEY (ParentWorkflowTaskId)
        REFERENCES workflow.WorkflowTask(Id)
);
GO

-- ============================================================
-- MODULE 4: WORKFLOW AUDIT
-- Immutable log of every state transition and action taken.
--
-- FromWorkflowStatusGroup and ToWorkflowStatusGroup are kept as
-- separate computed columns so each can independently back its
-- own composite FK into shared.StatusLookup (StatusCode, StatusGroup).
-- ============================================================
CREATE TABLE workflow.WorkflowActionHistory (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    WorkflowInstanceId          INT          NOT NULL,
    WorkflowTaskId              INT          NULL,       -- Task that was acted on (NULL for system actions)
    WorkflowStepId              SMALLINT          NULL,
    WorkflowActionType          NVARCHAR(50)    NOT NULL,
    WorkflowActionTypeGroup     AS CAST('WORKFLOW_ACTION_TYPE' AS NVARCHAR(50)) PERSISTED,    
    Remarks                     NVARCHAR(2000)  NULL,
    FromWorkflowStatus          NVARCHAR(50)    NULL,
    FromWorkflowStatusGroup     AS CAST('WORKFLOW_STATUS' AS NVARCHAR(50)) PERSISTED,
    ToWorkflowStatus            NVARCHAR(50)    NULL,
    ToWorkflowStatusGroup       AS CAST('WORKFLOW_STATUS' AS NVARCHAR(50)) PERSISTED,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    ActionBy                    INT          NOT NULL,   -- FK → employee.Employee
    ActionAt                    DATETIME2       NOT NULL,

    CONSTRAINT FK_WorkflowActionHistory_Instance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_WorkflowActionHistory_Task
        FOREIGN KEY (WorkflowTaskId)
        REFERENCES workflow.WorkflowTask(Id),

    CONSTRAINT FK_WorkflowActionHistory_Step
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowActionHistory_WorkflowActionType
        FOREIGN KEY (WorkflowActionType, WorkflowActionTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_WorkflowActionHistory_FromWorkflowStatus
        FOREIGN KEY (FromWorkflowStatus, FromWorkflowStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_WorkflowActionHistory_ToWorkflowStatus
        FOREIGN KEY (ToWorkflowStatus, ToWorkflowStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================
-- INDEXES
-- ============================================================

-- WorkflowAssignment: routing lookup
CREATE INDEX IX_WorkflowAssignment_Scope
    ON workflow.WorkflowAssignment (ScopeTypeId, ScopeReferenceId);

-- WorkflowStepApprover: step-level resolution lookups
CREATE INDEX IX_WorkflowStepApprover_Step
    ON workflow.WorkflowStepApprover (WorkflowStepId);

CREATE INDEX IX_WorkflowStepApprover_Scope
    ON workflow.WorkflowStepApprover (ScopeTypeId, ScopeReferenceId);

-- WorkflowInstance: primary runtime access paths
CREATE INDEX IX_WorkflowInstance_Module_Transaction
    ON workflow.WorkflowInstance (WorkflowModuleId, ReferenceTransactionId);

CREATE INDEX IX_WorkflowInstance_CreatedBy
    ON workflow.WorkflowInstance (CreatedBy);

CREATE INDEX IX_WorkflowInstance_CurrentStep
    ON workflow.WorkflowInstance (CurrentWorkflowStepId);

-- WorkflowTask: approver inbox — highest-frequency runtime query
CREATE INDEX IX_WorkflowTask_AssignedTo_Status
    ON workflow.WorkflowTask (AssignedToEmployeeId, TaskStatus);

CREATE INDEX IX_WorkflowTask_Instance
    ON workflow.WorkflowTask (WorkflowInstanceId);

CREATE INDEX IX_WorkflowTask_Step
    ON workflow.WorkflowTask (WorkflowStepId);

-- WorkflowActionHistory: audit trail lookups
CREATE INDEX IX_WorkflowActionHistory_Instance
    ON workflow.WorkflowActionHistory (WorkflowInstanceId);

CREATE INDEX IX_WorkflowActionHistory_Task
    ON workflow.WorkflowActionHistory (WorkflowTaskId);

-- WorkflowStep: step ordering within a definition
CREATE INDEX IX_WorkflowStep_Definition_StepNo
    ON workflow.WorkflowStep (WorkflowDefinitionId, StepNo);

GO

PRINT 'Workflow schema created successfully';

GO