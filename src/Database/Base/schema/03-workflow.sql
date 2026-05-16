-- WORKFLOW SCHEMA - Approval Workflow Engine
-- SQL Server Database Schema
-- Schema: workflow
-- Purpose: Configurable multi-step approval workflow engine
-- Dependencies: shared (StatusLookup), employee (Employee), time (ScopeType)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'workflow')
BEGIN
    EXEC('CREATE SCHEMA workflow');
END
GO

-- MODULE 1: WORKFLOW CONFIGURATION
CREATE TABLE workflow.WorkflowModule (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    ModuleCode      NVARCHAR(100)   NOT NULL UNIQUE,
    ModuleName      NVARCHAR(200)   NOT NULL,
    EntityName      NVARCHAR(100)   NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);
GO

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
GO

CREATE TABLE workflow.WorkflowStep (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    BIGINT          NOT NULL,
    StepNo                  INT             NOT NULL,
    StepName                NVARCHAR(200)   NOT NULL,
    WorkflowStepType        NVARCHAR(50 )   NOT NULL,
    WorkflowStepTypeGroup   AS CAST('WORKFLOW_STEP_TYPE' AS NVARCHAR(50)) PERSISTED,
    IsFinalStep             BIT             NOT NULL DEFAULT 0,
    AllowDelegation         BIT             NOT NULL DEFAULT 1,
    EscalationAfterHours    INT             NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

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

CREATE TABLE workflow.WorkflowStepApprover (
    Id                          BIGINT  PRIMARY KEY IDENTITY(1,1),
    WorkflowStepId              BIGINT  NOT NULL,
    WorkflowApproverType        NVARCHAR(50 )   NOT NULL,
    WorkflowApproverTypeGroup   AS CAST('WORKFLOW_APPROVER_TYPE' AS NVARCHAR(50)) PERSISTED,
    ApproverReferenceId         BIGINT  NULL,
    PriorityOrder               INT     NOT NULL DEFAULT 1,
    IsMandatory                 BIT     NOT NULL DEFAULT 1,
    IsActive                    BIT     NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_WorkflowStepApprover_Step
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowStepApprover_WorkflowApproverType
        FOREIGN KEY (WorkflowApproverType, WorkflowApproverTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE 2: WORKFLOW ASSIGNMENT
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
GO

-- MODULE 3: WORKFLOW EXECUTION
CREATE TABLE workflow.WorkflowInstance (
    Id                      BIGINT      PRIMARY KEY IDENTITY(1,1),
    WorkflowDefinitionId    BIGINT      NOT NULL,
    WorkflowModuleId        BIGINT      NOT NULL,
    ReferenceTransactionId  BIGINT      NOT NULL,
    CurrentWorkflowStepId   BIGINT      NULL,
    WorkflowStatus          NVARCHAR(50 )   NOT NULL,
    WorkflowStatusGroup     AS CAST('WORKFLOW_STATUS' AS NVARCHAR(50)) PERSISTED,
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

    CONSTRAINT FK_WorkflowInstance_WorkflowStatus
        FOREIGN KEY (WorkflowStatus, WorkflowStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE 4: WORKFLOW AUDIT
CREATE TABLE workflow.WorkflowActionHistory (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    WorkflowInstanceId          BIGINT          NOT NULL,
    WorkflowStepId              BIGINT          NULL,
    WorkflowActionType          NVARCHAR(50 )   NOT NULL,
    WorkflowActionTypeGroup     AS CAST('WORKFLOW_ACTION_TYPE' AS NVARCHAR(50)) PERSISTED,
    ActionBy                    BIGINT          NOT NULL,
    ActionAt                    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    Remarks                     NVARCHAR(2000)  NULL,
    FromWorkflowStatus          NVARCHAR(50 )   NULL,
    ToWorkflowStatus            NVARCHAR(50 )   NULL,
    WorkflowStatusGroup         AS CAST('WORKFLOW_STATUS' AS NVARCHAR(50)) PERSISTED,

    CONSTRAINT FK_WorkflowActionHistory_Instance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_WorkflowActionHistory_Step
        FOREIGN KEY (WorkflowStepId)
        REFERENCES workflow.WorkflowStep(Id),

    CONSTRAINT FK_WorkflowActionHistory_WorkflowActionType
        FOREIGN KEY (WorkflowActionType, WorkflowActionTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_WorkflowActionHistory_FromWorkflowStatus
        FOREIGN KEY (FromWorkflowStatus, WorkflowStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),
    
    CONSTRAINT FK_WorkflowActionHistory_ToWorkflowStatus
        FOREIGN KEY (ToWorkflowStatus, WorkflowStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- INDEXES - workflow Schema
CREATE INDEX IX_WorkflowAssignment_Scope
    ON workflow.WorkflowAssignment (ScopeTypeId, ScopeReferenceId);

CREATE INDEX IX_WorkflowInstance_Module_Transaction
    ON workflow.WorkflowInstance (WorkflowModuleId, ReferenceTransactionId);

CREATE INDEX IX_WorkflowInstance_InitiatedBy
    ON workflow.WorkflowInstance (InitiatedBy);

CREATE INDEX IX_WorkflowInstance_CurrentStep
    ON workflow.WorkflowInstance (CurrentWorkflowStepId);

CREATE INDEX IX_WorkflowActionHistory_Instance
    ON workflow.WorkflowActionHistory (WorkflowInstanceId);

CREATE INDEX IX_WorkflowStep_Definition_StepNo
    ON workflow.WorkflowStep (WorkflowDefinitionId, StepNo);

CREATE INDEX IX_WorkflowStepApprover_Step
    ON workflow.WorkflowStepApprover (WorkflowStepId);

GO

PRINT 'Workflow schema created successfully';
GO