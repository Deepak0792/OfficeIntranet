-- =============================================================================================================
-- ENTERPRISE DYNAMIC APPROVAL WORKFLOW ENGINE
-- SQL SERVER DATABASE SCHEMA
-- Schema: workflow
-- =============================================================================================================
-- PURPOSE:
--   Reusable, configuration-driven approval workflow engine that operates across all business modules.
--   Supports multi-level approvals, dynamic approver resolution, scope-based workflow assignment,
--   escalation, delegation, and a full audit trail — with no hardcoded approval logic.
--
-- DESIGN PRINCIPLES:
--   - No free-text statuses; all states are master-driven
--   - Workflows are reusable templates assigned via organizational scope
--   - Approver resolution is dynamic (reporting manager, role, specific user, etc.)
--   - Every approval action is recorded for audit purposes
--
-- MODULES:
--   1. Workflow Configuration  : WorkflowModule, WorkflowDefinition, WorkflowStepType,
--                                WorkflowStep, WorkflowApproverType, WorkflowStepApprover
--   2. Workflow Assignment     : WorkflowAssignment
--   3. Workflow Execution      : WorkflowStatus, WorkflowInstance
--   4. Workflow Audit          : WorkflowActionType, WorkflowActionHistory
--   5. Seed Data               : WorkflowStepType, WorkflowApproverType,
--                                WorkflowStatus, WorkflowActionType
-- =============================================================================================================


-- =============================================================================================================
-- SCHEMA CREATION
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'workflow')
BEGIN
    EXEC('CREATE SCHEMA workflow');
END;
GO


-- =============================================================================================================
-- MODULE 1: WORKFLOW CONFIGURATION
-- Defines the structural blueprint of workflows — modules, definitions, steps, and approvers.
-- =============================================================================================================


-- -------------------------------------------------------
-- WORKFLOW MODULE
-- Registers business modules that consume the workflow engine
-- (e.g. Leave, Attendance Regularization, Shift Swap).
-- EntityName maps to the source database entity/table name.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowModule (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    ModuleCode      NVARCHAR(100)   NOT NULL UNIQUE,
    ModuleName      NVARCHAR(200)   NOT NULL,
    EntityName      NVARCHAR(100)   NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- WORKFLOW DEFINITION
-- A named, versioned workflow template associated with a
-- business module. Multiple versions can coexist;
-- VersionNo differentiates them. WorkflowCode is globally unique.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowDefinition (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowModuleId    BIGINT          NOT NULL,
    WorkflowCode        NVARCHAR(100)   NOT NULL UNIQUE,
    WorkflowName        NVARCHAR(200)   NOT NULL,
    VersionNo           INT             NOT NULL DEFAULT 1,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_WorkflowDefinition_Module
        FOREIGN KEY (WorkflowModuleId)
        REFERENCES workflow.WorkflowModule(Id)
);


-- -------------------------------------------------------
-- WORKFLOW STEP TYPE
-- Lookup table defining the behavioral category of a step.
-- Examples: Approval, Review, Notification, Auto Approval.
-- Drives application-layer handling logic per step.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowStepType (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    StepTypeCode    NVARCHAR(100)   NOT NULL UNIQUE,
    StepTypeName    NVARCHAR(200)   NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- WORKFLOW STEP
-- Defines the ordered sequence of steps within a workflow
-- definition. StepNo drives execution order.
-- EscalationAfterHours triggers auto-escalation if the step
-- is not acted upon within the defined window.
-- Unique constraint on (WorkflowDefinitionId, StepNo) prevents
-- duplicate step ordering within a workflow.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowStep (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    BIGINT          NOT NULL,
    StepNo                  INT             NOT NULL,
    StepName                NVARCHAR(200)   NOT NULL,
    WorkflowStepTypeId      BIGINT          NOT NULL,
    IsFinalStep             BIT             NOT NULL DEFAULT 0,
    AllowDelegation         BIT             NOT NULL DEFAULT 1,
    EscalationAfterHours    INT             NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_WorkflowStep_Definition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_WorkflowStep_StepType
        FOREIGN KEY (WorkflowStepTypeId)
        REFERENCES workflow.WorkflowStepType(Id),

    CONSTRAINT UQ_WorkflowStep_Order
        UNIQUE (WorkflowDefinitionId, StepNo)
);


-- -------------------------------------------------------
-- WORKFLOW APPROVER TYPE
-- Lookup table defining how approvers are resolved at runtime.
-- Examples: Reporting Manager (dynamic), Role-based, Specific User,
-- Department Head, HR Manager.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowApproverType (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    ApproverTypeCode    NVARCHAR(100)   NOT NULL UNIQUE,
    ApproverTypeName    NVARCHAR(200)   NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- WORKFLOW STEP APPROVER
-- Configures who approves a given step and in what order.
-- ApproverReferenceId is nullable — used only when the
-- ApproverType points to a specific user or role (not a
-- dynamic resolver like Reporting Manager).
-- PriorityOrder supports parallel approvers on the same step.
-- IsMandatory distinguishes required from optional approvers.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowStepApprover (
    Id                      BIGINT  PRIMARY KEY IDENTITY(1,1),
    WorkflowStepId          BIGINT  NOT NULL,
    WorkflowApproverTypeId  BIGINT  NOT NULL,
    ApproverReferenceId     BIGINT  NULL,
    PriorityOrder           INT     NOT NULL DEFAULT 1,
    IsMandatory             BIT     NOT NULL DEFAULT 1,
    IsActive                BIT     NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_WorkflowStepApprover_Step
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowStepApprover_ApproverType
        FOREIGN KEY (WorkflowApproverTypeId)
        REFERENCES workflow.WorkflowApproverType(Id)
);



-- =============================================================================================================
-- MODULE 2: WORKFLOW ASSIGNMENT
-- Dynamically assigns workflow definitions to organizational scope levels.
-- =============================================================================================================


-- -------------------------------------------------------
-- WORKFLOW ASSIGNMENT
-- Binds a workflow definition to an organizational scope
-- (Global, Country, Legal Entity, Office, Department, Team,
-- or Employee) via ScopeTypeId + ScopeReferenceId.
-- PriorityOrder resolves conflicts when multiple assignments
-- apply to the same employee. EffectiveFrom / EffectiveTo
-- supports advance-scheduled workflow changes.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowAssignment (
    Id                      BIGINT  PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    BIGINT  NOT NULL,
    ScopeTypeId             BIGINT  NOT NULL,
    ScopeReferenceId        BIGINT  NOT NULL,
    EffectiveFrom           DATE    NOT NULL,
    EffectiveTo             DATE    NULL,
    PriorityOrder           INT     NOT NULL DEFAULT 1,
    IsActive                BIT     NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_WorkflowAssignment_Definition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id)
);



-- =============================================================================================================
-- MODULE 3: WORKFLOW EXECUTION
-- Runtime state of workflow instances triggered by business transactions.
-- =============================================================================================================


-- -------------------------------------------------------
-- WORKFLOW STATUS
-- Lookup table for all possible states of a workflow instance.
-- IsFinalStatus flags terminal states (Approved, Rejected, Cancelled)
-- after which no further actions are permitted.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowStatus (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    StatusCode      NVARCHAR(100)   NOT NULL UNIQUE,
    StatusName      NVARCHAR(200)   NOT NULL,
    IsFinalStatus   BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- WORKFLOW INSTANCE
-- Represents a single runtime execution of a workflow,
-- triggered by a business transaction (e.g. a leave request,
-- regularization request, or shift swap).
-- ReferenceTransactionId links back to the source record
-- in the originating module's table.
-- CurrentWorkflowStepId tracks the active step awaiting action.
-- CompletedAt is populated when the instance reaches a final status.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowInstance (
    Id                      BIGINT      PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    BIGINT      NOT NULL,
    WorkflowModuleId        BIGINT      NOT NULL,
    ReferenceTransactionId  BIGINT      NOT NULL,
    CurrentWorkflowStepId   BIGINT      NULL,
    WorkflowStatusId        BIGINT      NOT NULL,
    InitiatedBy             BIGINT      NOT NULL,
    InitiatedAt             DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    CompletedAt             DATETIME2   NULL,

    CONSTRAINT FK_WorkflowInstance_Definition
        FOREIGN KEY (WorkflowDefinitionId)
        REFERENCES workflow.WorkflowDefinition(Id),

    CONSTRAINT FK_WorkflowInstance_Module
        FOREIGN KEY (WorkflowModuleId)
        REFERENCES workflow.WorkflowModule(Id),

    CONSTRAINT FK_WorkflowInstance_CurrentStep
        FOREIGN KEY (CurrentWorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowInstance_Status
        FOREIGN KEY (WorkflowStatusId)
        REFERENCES workflow.WorkflowStatus(Id)
);



-- =============================================================================================================
-- MODULE 4: WORKFLOW AUDIT
-- Immutable action history for every user and system interaction on a workflow instance.
-- =============================================================================================================


-- -------------------------------------------------------
-- WORKFLOW ACTION TYPE
-- Lookup table defining all possible actions a user or the
-- system can perform on a workflow instance.
-- Examples: Submit, Approve, Reject, Return, Escalate, Cancel.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowActionType (
    Id          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ActionCode  NVARCHAR(100)   NOT NULL UNIQUE,
    ActionName  NVARCHAR(200)   NOT NULL,
    IsActive    BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- WORKFLOW ACTION HISTORY
-- Append-only audit trail recording every action taken on a
-- workflow instance. Captures the before/after status transition
-- (FromWorkflowStatusId → ToWorkflowStatusId), the acting user,
-- the step at the time of action, and optional remarks.
-- WorkflowStepId is nullable to support instance-level actions
-- (e.g. Cancel) that are not tied to a specific step.
-- -------------------------------------------------------
CREATE TABLE workflow.WorkflowActionHistory (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowInstanceId      BIGINT          NOT NULL,
    WorkflowStepId          BIGINT          NULL,
    WorkflowActionTypeId    BIGINT          NOT NULL,
    ActionBy                BIGINT          NOT NULL,
    ActionAt                DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    Remarks                 NVARCHAR(2000)  NULL,
    FromWorkflowStatusId    BIGINT          NULL,
    ToWorkflowStatusId      BIGINT          NULL,

    CONSTRAINT FK_WorkflowActionHistory_Instance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_WorkflowActionHistory_Step
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowActionHistory_ActionType
        FOREIGN KEY (WorkflowActionTypeId)
        REFERENCES workflow.WorkflowActionType(Id),

    CONSTRAINT FK_WorkflowActionHistory_FromStatus
        FOREIGN KEY (FromWorkflowStatusId)
        REFERENCES workflow.WorkflowStatus(Id),

    CONSTRAINT FK_WorkflowActionHistory_ToStatus
        FOREIGN KEY (ToWorkflowStatusId)
        REFERENCES workflow.WorkflowStatus(Id)
);




-- =============================================================================================================
-- INDEXES
-- =============================================================================================================

-- Workflow Assignment: scope-based lookup (primary query path for resolving active workflow)
CREATE INDEX IX_WorkflowAssignment_Scope
ON workflow.WorkflowAssignment (ScopeTypeId, ScopeReferenceId);

-- Workflow Instance: lookup by module and source transaction
CREATE INDEX IX_WorkflowInstance_Module_Transaction
ON workflow.WorkflowInstance (WorkflowModuleId, ReferenceTransactionId);

-- Workflow Instance: filter by current status (e.g. all pending instances)
CREATE INDEX IX_WorkflowInstance_Status
ON workflow.WorkflowInstance (WorkflowStatusId);

-- Workflow Action History: all actions for a given instance
CREATE INDEX IX_WorkflowActionHistory_Instance
ON workflow.WorkflowActionHistory (WorkflowInstanceId);

-- Workflow Step: ordered step resolution within a workflow definition
CREATE INDEX IX_WorkflowStep_Definition_StepNo
ON workflow.WorkflowStep (WorkflowDefinitionId, StepNo);

-- Workflow Step Approver: approver lookup for a given step
CREATE INDEX IX_WorkflowStepApprover_Step
ON workflow.WorkflowStepApprover (WorkflowStepId);

-- Supports lookups of all workflow instances initiated by
-- a specific employee (e.g. My Pending Approvals dashboard)
CREATE INDEX IX_WorkflowInstance_InitiatedBy
    ON workflow.WorkflowInstance (InitiatedBy);

-- Supports lookups of all instances awaiting action on a
-- specific workflow step (e.g. approver inbox resolution)
CREATE INDEX IX_WorkflowInstance_CurrentStep
    ON workflow.WorkflowInstance (CurrentWorkflowStepId);

-- Supports bulk status queries per workflow definition
-- (e.g. all pending leave workflow instances)
CREATE INDEX IX_WorkflowInstance_Definition_Status
    ON workflow.WorkflowInstance (WorkflowDefinitionId, WorkflowStatusId);