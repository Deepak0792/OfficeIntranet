-- ============================================================================================================================
-- AUDIT SCHEMA  —  Enterprise Audit Logging Framework
-- SQL Server  |  Schema: audit
-- ----------------------------------------------------------------------------------------------------------------------------
-- Purpose   : Centralised, tamper-evident audit log for all microservices in the enterprise platform.
--             Covers data changes, API activity, workflow decisions, bulk operations, configuration
--             changes, scheduled jobs, and system-level notifications.
--             Optimised for compliance reporting, forensic investigation, and event replay.
--
-- Design principles
--   • Immutable by convention  — no UPDATE/DELETE on audit rows; soft-state tracked in AuditEventStatus.
--   • Microservice-aware       — every row carries ServiceName + CorrelationId for distributed tracing.
--   • Before/After capture     — FieldAuditLog stores old and new values at field level for full diff.
--   • JSON payloads            — NVARCHAR(MAX) with CHECK IS JSON for flexible, schema-free detail capture.
--   • Retention-ready          — RetentionPolicyCode on core tables drives archival jobs.
--   • No auth overlap          — login, session, and token tables are maintained in a separate schema.
--
-- Module map
--   MODULE 1   CORE REGISTRY           AuditEvent · AuditEventTag
--   MODULE 2   DATA CHANGE AUDIT       EntityChangeLog · FieldAuditLog
--   MODULE 3   API & INTEGRATION       ApiRequestLog · ApiResponseLog · IntegrationMessageLog
--   MODULE 4   WORKFLOW & APPROVAL     WorkflowAuditLog · ApprovalDecisionLog
--   MODULE 5   BULK OPERATIONS         BulkOperationLog · BulkOperationItemLog
--   MODULE 6   CONFIGURATION CHANGE    ConfigChangeLog
--   MODULE 7   SCHEDULED JOB           ScheduledJobLog
--   MODULE 8   NOTIFICATION & ALERT    NotificationLog
--   MODULE 9   DATA EXPORT & DOWNLOAD  DataExportLog
--   MODULE 10  QUERY / SEARCH ACCESS   SensitiveDataAccessLog
--   MODULE 11  DELEGATION & IMPERSONATION  ImpersonationLog
--   MODULE 12  POLICY & CONSENT        ConsentAuditLog
-- ============================================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'audit')
    EXEC('CREATE SCHEMA audit');
GO

-- ============================================================================================================================
-- MODULE 1  —  CORE REGISTRY
-- The AuditEvent table is the central spine.  Every row from every other module
-- links back to AuditEvent so cross-module investigation works from a single join.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 1.1  AuditEvent
--      Top-level record for every auditable action in the platform.
--      One row per logical event.  All other audit tables are children of this table
--      via AuditEventId (FK).  Stores the "who / what / where / when" envelope;
--      module tables store the payload detail.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.AuditEvent (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),

    -- Identity of the actor
    ActorUserId             NVARCHAR(100)   NOT NULL,               -- internal user / service-account id
    ActorUserName           NVARCHAR(300)   NULL,                   -- display name at time of event
    ActorEmail              NVARCHAR(300)   NULL,
    ActorRoles              NVARCHAR(1000)  NULL,                   -- comma-separated roles held at event time
    ActorIpAddress          NVARCHAR(100)   NULL,
    ActorUserAgent          NVARCHAR(500)   NULL,
    ImpersonatedByUserId    NVARCHAR(100)   NULL,                   -- set when actor is acting on behalf of another

    -- Microservice origin
    ServiceName             NVARCHAR(200)   NOT NULL,               -- e.g. "PayrollService", "HRService"
    ServiceVersion          NVARCHAR(50)    NULL,                   -- semver of the service at event time
    HostName                NVARCHAR(200)   NULL,                   -- pod / server hostname
    Environment             NVARCHAR(50)    NULL,                   -- PRODUCTION | STAGING | UAT | DEV

    -- Distributed tracing
    CorrelationId           NVARCHAR(100)   NULL,                   -- propagated request correlation id
    CausationId             NVARCHAR(100)   NULL,                   -- id of the event that caused this one
    TraceId                 NVARCHAR(100)   NULL,                   -- OpenTelemetry / Jaeger trace id
    SpanId                  NVARCHAR(100)   NULL,                   -- OpenTelemetry span id

    -- Event classification
    EventCategory           NVARCHAR(100)   NOT NULL,               -- DATA_CHANGE | API_CALL | WORKFLOW | BULK | CONFIG | JOB | NOTIFICATION | EXPORT | DATA_ACCESS | IMPERSONATION | CONSENT
    EventAction             NVARCHAR(200)   NOT NULL,               -- verb, e.g. CREATE, UPDATE, DELETE, APPROVE, EXPORT
    EventOutcome            NVARCHAR(50)    NOT NULL,               -- SUCCESS | FAILURE | PARTIAL | SKIPPED
    EventDescription        NVARCHAR(2000)  NULL,                   -- human-readable summary

    -- Temporal
    EventTimestampUtc       DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    EventTimestampOffset    NVARCHAR(10)    NULL,                   -- actor's UTC offset, e.g. '+05:30'

    -- Retention
    RetentionPolicyCode     NVARCHAR(50)    NOT NULL DEFAULT 'STANDARD',  -- drives archival; STANDARD | LONG_TERM | PERMANENT | GDPR_RESTRICTED
    IsArchived              BIT             NOT NULL DEFAULT 0,
    ArchivedAt              DATETIME2       NULL,

    -- Checksum for tamper detection (populated by the audit service, not the application)
    RowChecksum             NVARCHAR(64)    NULL,                   -- SHA-256 of canonical row fields

    CONSTRAINT PK_AuditEvent PRIMARY KEY (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 1.2  AuditEventTag
--      Free-form key-value tags attached to an AuditEvent for flexible querying and grouping.
--      Examples: Department=HR, LegalEntity=MEDCARE-IN, TicketId=TKT-001, Module=Payroll.
--      Kept separate to avoid sparse columns on AuditEvent and to allow multi-value tags.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.AuditEventTag (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId    BIGINT          NOT NULL,
    TagKey          NVARCHAR(200)   NOT NULL,
    TagValue        NVARCHAR(1000)  NULL,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_AuditEventTag PRIMARY KEY (Id),

    CONSTRAINT FK_AuditEventTag_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 2  —  DATA CHANGE AUDIT
-- Records CREATE / UPDATE / DELETE operations on every authorised business entity.
-- EntityChangeLog captures the row-level summary; FieldAuditLog captures each changed field.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 2.1  EntityChangeLog
--      One row per entity instance that was created, modified, or deleted in a single event.
--      Stores the full before/after JSON snapshot of the entity alongside structured metadata.
--      Links to AuditEvent for actor and service context.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.EntityChangeLog (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId        BIGINT          NOT NULL,

    -- Entity identity
    EntityName          NVARCHAR(200)   NOT NULL,               -- logical entity, e.g. "Employee", "LeaveRequest"
    EntitySchema        NVARCHAR(100)   NULL,                   -- physical schema, e.g. "employee"
    EntityTable         NVARCHAR(200)   NULL,                   -- physical table name (optional; for DB-level audit)
    EntityId            NVARCHAR(200)   NOT NULL,               -- PK value of the affected row (cast to NVARCHAR)
    EntityDisplayName   NVARCHAR(500)   NULL,                   -- human label at time of change, e.g. "Rajesh Sharma"

    -- Change type
    ChangeType          NVARCHAR(50)    NOT NULL,               -- CREATE | UPDATE | DELETE | RESTORE | MERGE

    -- Snapshots (JSON)
    BeforeJson          NVARCHAR(MAX)   NULL                    CONSTRAINT CK_ECL_BeforeJson   CHECK (BeforeJson  IS NULL OR ISJSON(BeforeJson)  = 1),
    AfterJson           NVARCHAR(MAX)   NULL                    CONSTRAINT CK_ECL_AfterJson    CHECK (AfterJson   IS NULL OR ISJSON(AfterJson)   = 1),

    -- Change reason / justification
    ChangeReason        NVARCHAR(2000)  NULL,
    ChangeSource        NVARCHAR(100)   NULL,                   -- UI | API | IMPORT | SYSTEM | MIGRATION

    -- Temporal
    ChangedAt           DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_EntityChangeLog PRIMARY KEY (Id),

    CONSTRAINT FK_ECL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 2.2  FieldAuditLog
--      Granular, field-level diff for every changed column within an EntityChangeLog row.
--      Supports forensic investigation and field-level rollback/replay.
--      Each row represents one field that changed value.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.FieldAuditLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    EntityChangeLogId       BIGINT          NOT NULL,

    -- Field identity
    FieldName               NVARCHAR(200)   NOT NULL,           -- logical field name, e.g. "AnnualCTC"
    FieldLabel              NVARCHAR(300)   NULL,               -- display label, e.g. "Annual CTC"
    FieldDataType           NVARCHAR(100)   NULL,               -- NVARCHAR | DECIMAL | DATE | BIT | etc.

    -- Values
    OldValue                NVARCHAR(MAX)   NULL,               -- serialised as string regardless of type
    NewValue                NVARCHAR(MAX)   NULL,

    -- Masking (for confidential fields)
    IsMaskedInLog           BIT             NOT NULL DEFAULT 0, -- when 1, OldValue/NewValue are replaced with [MASKED]

    CONSTRAINT PK_FieldAuditLog PRIMARY KEY (Id),

    CONSTRAINT FK_FAL_EntityChangeLog
        FOREIGN KEY (EntityChangeLogId)
        REFERENCES audit.EntityChangeLog (Id)
);
GO


-- ============================================================================================================================
-- MODULE 3  —  API & INTEGRATION AUDIT
-- Full request/response envelope logging for REST APIs and inter-service messages.
-- Supports SLA analysis, debugging, and security investigation.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 3.1  ApiRequestLog
--      Records every inbound API call received by any microservice.
--      Includes HTTP metadata, route, query/body payload, and performance metrics.
--      Paired 1-to-1 with ApiResponseLog.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.ApiRequestLog (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId        BIGINT          NOT NULL,

    -- HTTP context
    HttpMethod          NVARCHAR(10)    NOT NULL,               -- GET | POST | PUT | PATCH | DELETE
    RequestUri          NVARCHAR(2000)  NOT NULL,
    RoutePath           NVARCHAR(500)   NULL,                   -- normalised route, e.g. /api/employees/{id}
    QueryString         NVARCHAR(2000)  NULL,
    ContentType         NVARCHAR(200)   NULL,
    RequestSizeBytes    BIGINT          NULL,

    -- Payload (can be redacted for sensitive endpoints)
    RequestBodyJson     NVARCHAR(MAX)   NULL                    CONSTRAINT CK_ARL_RequestBodyJson CHECK (RequestBodyJson IS NULL OR ISJSON(RequestBodyJson) = 1),
    RequestHeadersJson  NVARCHAR(MAX)   NULL                    CONSTRAINT CK_ARL_RequestHeadersJson CHECK (RequestHeadersJson IS NULL OR ISJSON(RequestHeadersJson) = 1),
    IsBodyRedacted      BIT             NOT NULL DEFAULT 0,

    -- Timing
    ReceivedAt          DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_ApiRequestLog PRIMARY KEY (Id),

    CONSTRAINT FK_ARL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 3.2  ApiResponseLog
--      Records the outbound response for every logged API request (linked 1-to-1 with ApiRequestLog).
--      Stores HTTP status, response size, error detail, and end-to-end latency.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.ApiResponseLog (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    ApiRequestLogId     BIGINT          NOT NULL,

    -- Response metadata
    HttpStatusCode      INT             NOT NULL,
    ResponseSizeBytes   BIGINT          NULL,
    ContentType         NVARCHAR(200)   NULL,

    -- Payload
    ResponseBodyJson    NVARCHAR(MAX)   NULL                    CONSTRAINT CK_ARLO_ResponseBodyJson CHECK (ResponseBodyJson IS NULL OR ISJSON(ResponseBodyJson) = 1),
    IsBodyRedacted      BIT             NOT NULL DEFAULT 0,

    -- Error detail
    ErrorCode           NVARCHAR(100)   NULL,
    ErrorMessage        NVARCHAR(2000)  NULL,
    ExceptionType       NVARCHAR(500)   NULL,
    StackTrace          NVARCHAR(MAX)   NULL,

    -- Timing
    RespondedAt         DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    DurationMs          INT             NULL,                   -- total request-to-response milliseconds

    CONSTRAINT PK_ApiResponseLog PRIMARY KEY (Id),

    CONSTRAINT UQ_ApiResponseLog_Request UNIQUE (ApiRequestLogId),

    CONSTRAINT FK_ARLO_ApiRequestLog
        FOREIGN KEY (ApiRequestLogId)
        REFERENCES audit.ApiRequestLog (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 3.3  IntegrationMessageLog
--      Tracks messages produced and consumed on message brokers (Kafka, RabbitMQ, Azure Service Bus, etc.)
--      and calls to external third-party APIs (payment gateways, SMS, email providers, etc.).
--      Supports end-to-end message tracing and retry/failure forensics.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.IntegrationMessageLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId            BIGINT          NOT NULL,

    -- Direction
    Direction               NVARCHAR(20)    NOT NULL,           -- OUTBOUND | INBOUND

    -- Transport metadata
    IntegrationType         NVARCHAR(100)   NOT NULL,           -- MESSAGE_BROKER | EXTERNAL_API | WEBHOOK | FILE_TRANSFER
    ProviderName            NVARCHAR(200)   NULL,               -- e.g. "Kafka", "SendGrid", "Razorpay"
    TopicOrEndpoint         NVARCHAR(500)   NULL,               -- topic name, queue, or external URL
    MessageId               NVARCHAR(200)   NULL,               -- broker-assigned or service-assigned id
    MessageType             NVARCHAR(200)   NULL,               -- event type / message name

    -- Payload
    PayloadJson             NVARCHAR(MAX)   NULL                CONSTRAINT CK_IML_PayloadJson CHECK (PayloadJson IS NULL OR ISJSON(PayloadJson) = 1),
    PayloadSizeBytes        BIGINT          NULL,
    IsPayloadRedacted       BIT             NOT NULL DEFAULT 0,

    -- Outcome
    OutcomeStatus           NVARCHAR(50)    NOT NULL,           -- SENT | RECEIVED | FAILED | RETRIED | DEAD_LETTERED
    HttpStatusCode          INT             NULL,               -- for external API calls
    ErrorDetail             NVARCHAR(2000)  NULL,
    RetryCount              INT             NOT NULL DEFAULT 0,

    -- Timing
    MessageTimestampUtc     DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    DurationMs              INT             NULL,

    CONSTRAINT PK_IntegrationMessageLog PRIMARY KEY (Id),

    CONSTRAINT FK_IML_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 4  —  WORKFLOW & APPROVAL AUDIT
-- Captures every state transition and human decision in approval workflows.
-- Provides an immutable, ordered history for compliance and dispute resolution.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 4.1  WorkflowAuditLog
--      Records each state transition of a workflow instance (e.g. Leave Request, Payroll Disbursement).
--      One row per transition.  Does not replace the operational workflow tables;
--      provides a separate, append-only audit trail.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.WorkflowAuditLog (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId                BIGINT          NOT NULL,

    -- Workflow identity
    WorkflowDefinitionCode      NVARCHAR(100)   NOT NULL,       -- e.g. "LEAVE_APPROVAL", "PAYROLL_DISBURSEMENT"
    WorkflowInstanceId          NVARCHAR(200)   NOT NULL,       -- PK of the operational WorkflowInstance
    EntityName                  NVARCHAR(200)   NULL,           -- subject entity, e.g. "LeaveRequest"
    EntityId                    NVARCHAR(200)   NULL,           -- PK of the subject record

    -- State transition
    StepCode                    NVARCHAR(100)   NOT NULL,       -- e.g. "MANAGER_APPROVAL"
    StepLabel                   NVARCHAR(300)   NULL,
    FromStatus                  NVARCHAR(100)   NOT NULL,
    ToStatus                    NVARCHAR(100)   NOT NULL,
    ActionTaken                 NVARCHAR(100)   NOT NULL,       -- SUBMIT | APPROVE | REJECT | RETURN | ESCALATE | CANCEL
    ActionComment               NVARCHAR(2000)  NULL,

    -- Actor (may differ from AuditEvent.ActorUserId for system-triggered transitions)
    ActorUserId                 NVARCHAR(100)   NULL,
    ActorUserName               NVARCHAR(300)   NULL,
    ActorRoleAtDecision         NVARCHAR(300)   NULL,

    -- Delegation context
    IsDelegated                 BIT             NOT NULL DEFAULT 0,
    DelegatedByUserId           NVARCHAR(100)   NULL,

    -- Timing
    TransitionTimestampUtc      DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    TimeSpentInPreviousStepMs   BIGINT          NULL,

    CONSTRAINT PK_WorkflowAuditLog PRIMARY KEY (Id),

    CONSTRAINT FK_WAL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 4.2  ApprovalDecisionLog
--      Records each individual approver's decision within a multi-approver step.
--      Supports scenarios where a single step requires consensus from multiple roles.
--      Links to WorkflowAuditLog for the parent transition context.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.ApprovalDecisionLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    WorkflowAuditLogId      BIGINT          NOT NULL,

    -- Approver identity
    ApproverUserId          NVARCHAR(100)   NOT NULL,
    ApproverUserName        NVARCHAR(300)   NULL,
    ApproverRole            NVARCHAR(300)   NULL,

    -- Decision
    Decision                NVARCHAR(50)    NOT NULL,           -- APPROVED | REJECTED | RETURNED | ABSTAINED
    DecisionComment         NVARCHAR(2000)  NULL,
    ConditionsJson          NVARCHAR(MAX)   NULL                CONSTRAINT CK_ADL_ConditionsJson CHECK (ConditionsJson IS NULL OR ISJSON(ConditionsJson) = 1),

    -- Timing
    DecisionTimestampUtc    DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    TimeToDecideMs          BIGINT          NULL,               -- time from step assignment to decision

    CONSTRAINT PK_ApprovalDecisionLog PRIMARY KEY (Id),

    CONSTRAINT FK_ADL_WorkflowAuditLog
        FOREIGN KEY (WorkflowAuditLogId)
        REFERENCES audit.WorkflowAuditLog (Id)
);
GO


-- ============================================================================================================================
-- MODULE 5  —  BULK OPERATIONS
-- Tracks mass-update, mass-import, and mass-delete operations with row-level outcome detail.
-- Essential for post-import forensics and partial-failure investigations.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 5.1  BulkOperationLog
--      Header record for a single bulk operation (e.g. payroll import, employee mass-update).
--      Captures totals, outcome summary, and source file metadata.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.BulkOperationLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId            BIGINT          NOT NULL,

    -- Operation identity
    OperationType           NVARCHAR(200)   NOT NULL,           -- e.g. "PAYROLL_IMPORT", "EMPLOYEE_BULK_UPDATE"
    OperationDescription    NVARCHAR(1000)  NULL,
    EntityName              NVARCHAR(200)   NOT NULL,           -- target entity

    -- Source
    SourceFileName          NVARCHAR(500)   NULL,
    SourceFileHash          NVARCHAR(128)   NULL,               -- SHA-256 of uploaded file
    SourceSystem            NVARCHAR(200)   NULL,

    -- Totals
    TotalRecordsSubmitted   INT             NOT NULL DEFAULT 0,
    TotalRecordsSucceeded   INT             NOT NULL DEFAULT 0,
    TotalRecordsFailed      INT             NOT NULL DEFAULT 0,
    TotalRecordsSkipped     INT             NOT NULL DEFAULT 0,

    -- Outcome
    OperationStatus         NVARCHAR(50)    NOT NULL,           -- COMPLETED | PARTIAL | FAILED | ROLLED_BACK
    ErrorSummary            NVARCHAR(2000)  NULL,

    -- Timing
    StartedAt               DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    CompletedAt             DATETIME2(7)    NULL,
    DurationMs              BIGINT          NULL,

    CONSTRAINT PK_BulkOperationLog PRIMARY KEY (Id),

    CONSTRAINT FK_BOL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 5.2  BulkOperationItemLog
--      Row-level outcome record for each item processed within a BulkOperationLog.
--      Links to EntityChangeLog when a change was persisted, allowing full diff tracing per item.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.BulkOperationItemLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    BulkOperationLogId      BIGINT          NOT NULL,

    -- Item identity
    RowSequence             INT             NOT NULL,           -- position in the source file / batch
    EntityId                NVARCHAR(200)   NULL,               -- PK of the target record (if resolved)
    EntityDisplayName       NVARCHAR(500)   NULL,

    -- Source row data
    SourceRowJson           NVARCHAR(MAX)   NULL                CONSTRAINT CK_BOIL_SourceRowJson CHECK (SourceRowJson IS NULL OR ISJSON(SourceRowJson) = 1),

    -- Outcome
    ItemStatus              NVARCHAR(50)    NOT NULL,           -- SUCCESS | FAILED | SKIPPED | DUPLICATE
    ErrorCode               NVARCHAR(100)   NULL,
    ErrorMessage            NVARCHAR(2000)  NULL,

    -- Change linkage (set when ItemStatus = SUCCESS and a change was persisted)
    EntityChangeLogId       BIGINT          NULL,

    CONSTRAINT PK_BulkOperationItemLog PRIMARY KEY (Id),

    CONSTRAINT FK_BOIL_BulkOperationLog
        FOREIGN KEY (BulkOperationLogId)
        REFERENCES audit.BulkOperationLog (Id),

    CONSTRAINT FK_BOIL_EntityChangeLog
        FOREIGN KEY (EntityChangeLogId)
        REFERENCES audit.EntityChangeLog (Id)
);
GO


-- ============================================================================================================================
-- MODULE 6  —  CONFIGURATION CHANGE AUDIT
-- Records changes to system configuration, feature flags, role/permission mappings,
-- lookup values, and any other system-level setting.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 6.1  ConfigChangeLog
--      Captures before/after state of any configuration item across all services.
--      Supports rollback analysis and root-cause investigation for incidents triggered
--      by configuration drift.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.ConfigChangeLog (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId        BIGINT          NOT NULL,

    -- Config identity
    ConfigScope         NVARCHAR(100)   NOT NULL,               -- GLOBAL | SERVICE | TENANT | FEATURE_FLAG | ROLE_PERMISSION | LOOKUP
    ConfigKey           NVARCHAR(500)   NOT NULL,               -- dot-delimited key, e.g. "payroll.taxRegime.defaultFY"
    ConfigNamespace     NVARCHAR(200)   NULL,                   -- optional grouping / namespace
    ConfigDescription   NVARCHAR(1000)  NULL,

    -- Values
    OldValueJson        NVARCHAR(MAX)   NULL                    CONSTRAINT CK_CCL_OldValueJson CHECK (OldValueJson IS NULL OR ISJSON(OldValueJson) = 1),
    NewValueJson        NVARCHAR(MAX)   NULL                    CONSTRAINT CK_CCL_NewValueJson CHECK (NewValueJson IS NULL OR ISJSON(NewValueJson) = 1),

    -- Change context
    ChangeReason        NVARCHAR(2000)  NULL,
    TicketReference     NVARCHAR(200)   NULL,                   -- change-management ticket (e.g. Jira ID)
    EffectiveFrom       DATETIME2       NULL,

    -- Timing
    ChangedAt           DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_ConfigChangeLog PRIMARY KEY (Id),

    CONSTRAINT FK_CCL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 7  —  SCHEDULED JOB AUDIT
-- Records execution history, status, and performance metrics for all scheduled
-- and background jobs across every microservice.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 7.1  ScheduledJobLog
--      One row per execution of a scheduled or background job (cron, message-driven, or manual trigger).
--      Stores run outcome, affected record counts, and any error detail for SLA and incident tracking.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.ScheduledJobLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId            BIGINT          NOT NULL,

    -- Job identity
    JobCode                 NVARCHAR(200)   NOT NULL,           -- unique code for the job, e.g. "PAYROLL_PROCESS_MAR25"
    JobName                 NVARCHAR(300)   NOT NULL,
    JobGroup                NVARCHAR(200)   NULL,               -- logical grouping, e.g. "PayrollJobs"
    TriggerType             NVARCHAR(50)    NOT NULL,           -- SCHEDULED | MANUAL | EVENT_DRIVEN | RETRY
    ScheduledAt             DATETIME2(7)    NULL,               -- when the job was supposed to run

    -- Execution
    StartedAt               DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    CompletedAt             DATETIME2(7)    NULL,
    DurationMs              BIGINT          NULL,

    -- Outcome
    ExecutionStatus         NVARCHAR(50)    NOT NULL,           -- RUNNING | COMPLETED | FAILED | TIMED_OUT | CANCELLED | SKIPPED
    RecordsProcessed        INT             NULL,
    RecordsFailed           INT             NULL,
    OutputSummaryJson       NVARCHAR(MAX)   NULL                CONSTRAINT CK_SJL_OutputSummaryJson CHECK (OutputSummaryJson IS NULL OR ISJSON(OutputSummaryJson) = 1),

    -- Error
    ErrorCode               NVARCHAR(100)   NULL,
    ErrorMessage            NVARCHAR(2000)  NULL,
    ExceptionType           NVARCHAR(500)   NULL,
    StackTrace              NVARCHAR(MAX)   NULL,

    -- Retry context
    RetryAttempt            INT             NOT NULL DEFAULT 0,
    MaxRetries              INT             NULL,
    NextRetryAt             DATETIME2(7)    NULL,

    CONSTRAINT PK_ScheduledJobLog PRIMARY KEY (Id),

    CONSTRAINT FK_SJL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 8  —  NOTIFICATION & ALERT AUDIT
-- Tracks every notification dispatched to users (email, SMS, in-app, push) and
-- every system alert raised.  Supports delivery verification and escalation tracing.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 8.1  NotificationLog
--      Records each notification or alert generated and dispatched by the platform.
--      Captures channel, template, delivery status, and retry history.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.NotificationLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId            BIGINT          NOT NULL,

    -- Notification identity
    NotificationType        NVARCHAR(100)   NOT NULL,           -- EMAIL | SMS | IN_APP | PUSH | WEBHOOK_ALERT | ESCALATION
    TemplateCode            NVARCHAR(200)   NULL,               -- template identifier used
    Subject                 NVARCHAR(500)   NULL,

    -- Recipient
    RecipientUserId         NVARCHAR(100)   NULL,
    RecipientAddress        NVARCHAR(500)   NULL,               -- email address, phone number, device token, etc.

    -- Trigger context
    TriggerEntityName       NVARCHAR(200)   NULL,               -- entity that triggered this notification
    TriggerEntityId         NVARCHAR(200)   NULL,
    TriggerEventCode        NVARCHAR(200)   NULL,               -- e.g. "LEAVE_APPROVED", "PAYROLL_PUBLISHED"

    -- Payload
    NotificationBodyJson    NVARCHAR(MAX)   NULL                CONSTRAINT CK_NL_NotificationBodyJson CHECK (NotificationBodyJson IS NULL OR ISJSON(NotificationBodyJson) = 1),

    -- Delivery
    DeliveryStatus          NVARCHAR(50)    NOT NULL,           -- QUEUED | SENT | DELIVERED | FAILED | BOUNCED | UNSUBSCRIBED
    ProviderName            NVARCHAR(200)   NULL,               -- e.g. "SendGrid", "Twilio", "Firebase"
    ProviderMessageId       NVARCHAR(300)   NULL,               -- provider's own message reference
    ErrorDetail             NVARCHAR(1000)  NULL,

    -- Timing & retry
    ScheduledAt             DATETIME2(7)    NULL,
    SentAt                  DATETIME2(7)    NULL,
    DeliveredAt             DATETIME2(7)    NULL,
    RetryCount              INT             NOT NULL DEFAULT 0,

    CONSTRAINT PK_NotificationLog PRIMARY KEY (Id),

    CONSTRAINT FK_NL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 9  —  DATA EXPORT & DOWNLOAD AUDIT
-- Records every export, report generation, and bulk download of business data.
-- Supports GDPR data-subject access reviews and DLP (data loss prevention) investigations.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 9.1  DataExportLog
--      One row per export or report download request.
--      Captures the filter criteria, output format, file metadata, and delivery method.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.DataExportLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId            BIGINT          NOT NULL,

    -- Export identity
    ExportType              NVARCHAR(200)   NOT NULL,           -- REPORT | DATA_DUMP | SALARY_SLIP | TAX_STATEMENT | CUSTOM
    EntityName              NVARCHAR(200)   NULL,               -- primary entity exported, e.g. "Employee"
    ReportCode              NVARCHAR(200)   NULL,               -- report identifier where applicable

    -- Filter criteria (JSON so any shape of filter is captured)
    FilterCriteriaJson      NVARCHAR(MAX)   NULL                CONSTRAINT CK_DEL_FilterCriteriaJson CHECK (FilterCriteriaJson IS NULL OR ISJSON(FilterCriteriaJson) = 1),

    -- Output
    OutputFormat            NVARCHAR(50)    NULL,               -- CSV | XLSX | PDF | JSON | XML
    TotalRecordsExported    INT             NULL,
    FileSizeBytes           BIGINT          NULL,
    FileHash                NVARCHAR(128)   NULL,               -- SHA-256 of the output file
    StorageLocation         NVARCHAR(1000)  NULL,               -- cloud blob path / download URL

    -- Delivery
    DeliveryMethod          NVARCHAR(100)   NULL,               -- DOWNLOAD | EMAIL | SFTP | API_RESPONSE
    RecipientUserId         NVARCHAR(100)   NULL,
    RecipientAddress        NVARCHAR(500)   NULL,

    -- Timing
    RequestedAt             DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    GeneratedAt             DATETIME2(7)    NULL,
    DownloadedAt            DATETIME2(7)    NULL,

    CONSTRAINT PK_DataExportLog PRIMARY KEY (Id),

    CONSTRAINT FK_DEL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 10  —  SENSITIVE DATA ACCESS AUDIT
-- Tracks read access to fields classified as confidential or sensitive (PAN, Aadhaar, salary, bank
-- account numbers, etc.).  Does not log every read — only access that bypasses standard masking.
-- Supports GDPR Article 30 processing records and financial data access audits.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 10.1  SensitiveDataAccessLog
--       One row for each time a user or service reads unmasked confidential data.
--       Captures entity, field, access justification, and the policy that permitted the access.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.SensitiveDataAccessLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId            BIGINT          NOT NULL,

    -- Subject (whose data was accessed)
    SubjectUserId           NVARCHAR(100)   NULL,               -- data subject; may differ from actor
    SubjectEntityName       NVARCHAR(200)   NOT NULL,           -- e.g. "Employee", "BankAccount"
    SubjectEntityId         NVARCHAR(200)   NOT NULL,

    -- Fields accessed
    FieldsAccessedJson      NVARCHAR(MAX)   NOT NULL            CONSTRAINT CK_SDAL_FieldsAccessedJson CHECK (ISJSON(FieldsAccessedJson) = 1),
    -- e.g. [{"fieldName":"PANNumber","sensitivityLevel":4},{"fieldName":"AadhaarNumber","sensitivityLevel":5}]

    -- Access justification
    AccessJustification     NVARCHAR(2000)  NULL,               -- e.g. "Payroll verification for March 2025"
    PermittingPolicyCode    NVARCHAR(200)   NULL,               -- auth policy that granted unmasked access
    AccessChannel           NVARCHAR(100)   NULL,               -- WEB_UI | API | REPORT | EXPORT | ADMIN_CONSOLE

    -- Timing
    AccessedAt              DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_SensitiveDataAccessLog PRIMARY KEY (Id),

    CONSTRAINT FK_SDAL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 11  —  DELEGATION & IMPERSONATION AUDIT
-- Tracks every instance where a user acts on behalf of another (delegated access)
-- or where an admin impersonates a user for support/investigation purposes.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 11.1  ImpersonationLog
--       Records the start and end of impersonation and delegation sessions, and every
--       action taken during the session (linked via AuditEvent.ImpersonatedByUserId).
--       Provides the complete audit trail for privileged user access.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.ImpersonationLog (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId                BIGINT          NOT NULL,

    -- Who is doing the impersonating / delegating
    ActorUserId                 NVARCHAR(100)   NOT NULL,
    ActorUserName               NVARCHAR(300)   NULL,
    ActorRole                   NVARCHAR(300)   NULL,

    -- Who is being impersonated / delegated
    TargetUserId                NVARCHAR(100)   NOT NULL,
    TargetUserName              NVARCHAR(300)   NULL,

    -- Session
    SessionType                 NVARCHAR(50)    NOT NULL,       -- IMPERSONATION | DELEGATION
    SessionReferenceId          NVARCHAR(200)   NULL,           -- e.g. DelegatedAccess.Id from auth schema
    Reason                      NVARCHAR(2000)  NULL,
    ScopeDescription            NVARCHAR(1000)  NULL,           -- what permissions/scope the session covers

    -- Lifecycle
    SessionStatus               NVARCHAR(50)    NOT NULL,       -- STARTED | ENDED | REVOKED | EXPIRED
    StartedAt                   DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    EndedAt                     DATETIME2(7)    NULL,
    DurationSeconds             AS (DATEDIFF(SECOND, StartedAt, EndedAt)),

    CONSTRAINT PK_ImpersonationLog PRIMARY KEY (Id),

    CONSTRAINT FK_IL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- MODULE 12  —  POLICY, CONSENT & ACKNOWLEDGEMENT AUDIT
-- Records policy acknowledgements, consent grants/revocations, and data processing
-- agreement events.  Required for GDPR, DPDPA, and ISO 27001 compliance.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 12.1  ConsentAuditLog
--       Immutable record of every consent or policy acknowledgement given, updated, or
--       revoked by a data subject (employee, candidate, etc.).
--       Each row is a point-in-time snapshot of the consent state.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE audit.ConsentAuditLog (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    AuditEventId            BIGINT          NOT NULL,

    -- Subject
    SubjectUserId           NVARCHAR(100)   NOT NULL,
    SubjectUserName         NVARCHAR(300)   NULL,

    -- Policy / consent document
    PolicyCode              NVARCHAR(200)   NOT NULL,           -- e.g. "PRIVACY_POLICY", "DATA_PROCESSING_AGREEMENT"
    PolicyVersionId         NVARCHAR(100)   NULL,               -- version of the policy document
    PolicyName              NVARCHAR(500)   NULL,

    -- Decision
    ConsentAction           NVARCHAR(50)    NOT NULL,           -- GRANTED | REVOKED | UPDATED | ACKNOWLEDGED | DECLINED
    ConsentChannel          NVARCHAR(100)   NULL,               -- WEB_UI | EMAIL_LINK | PAPER | API
    ConsentProofJson        NVARCHAR(MAX)   NULL                CONSTRAINT CK_CAL_ConsentProofJson CHECK (ConsentProofJson IS NULL OR ISJSON(ConsentProofJson) = 1),
    -- e.g. {"checkboxChecked":true,"uiScreen":"OnboardingStep3","ipAddress":"10.0.0.1"}

    -- Jurisdiction / lawful basis
    JurisdictionCode        NVARCHAR(50)    NULL,               -- IN | EU | UK
    LawfulBasis             NVARCHAR(200)   NULL,               -- e.g. "Contract", "LegalObligation", "Consent"

    -- Timing
    ConsentTimestampUtc     DATETIME2(7)    NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt               DATETIME2(7)    NULL,

    CONSTRAINT PK_ConsentAuditLog PRIMARY KEY (Id),

    CONSTRAINT FK_CAL_AuditEvent
        FOREIGN KEY (AuditEventId)
        REFERENCES audit.AuditEvent (Id)
);
GO


-- ============================================================================================================================
-- INDEXES
-- Grouped by access pattern:
--   • Hot-path queries  — service/correlation/actor lookups on AuditEvent
--   • Entity lookups    — EntityChangeLog and FieldAuditLog by entity + id
--   • Time-range scans  — timestamp indexes on all major tables for reporting windows
--   • FK traversal      — all foreign key columns indexed for join performance
-- ============================================================================================================================

-- ── AuditEvent ──────────────────────────────────────────────────────────────────────────────────────
-- Actor lookup (WHO did what)
CREATE INDEX IX_AuditEvent_Actor          ON audit.AuditEvent (ActorUserId, EventTimestampUtc DESC);
-- Distributed-trace lookup (find all events in a request chain)
CREATE INDEX IX_AuditEvent_Correlation    ON audit.AuditEvent (CorrelationId) WHERE CorrelationId IS NOT NULL;
CREATE INDEX IX_AuditEvent_Trace          ON audit.AuditEvent (TraceId)       WHERE TraceId       IS NOT NULL;
-- Service + time (WHAT service, WHEN — used by compliance reports)
CREATE INDEX IX_AuditEvent_Service_Time   ON audit.AuditEvent (ServiceName, EventTimestampUtc DESC);
-- Category + outcome (event-type dashboards)
CREATE INDEX IX_AuditEvent_Category       ON audit.AuditEvent (EventCategory, EventAction, EventOutcome, EventTimestampUtc DESC);
-- Retention management
CREATE INDEX IX_AuditEvent_Retention      ON audit.AuditEvent (RetentionPolicyCode, IsArchived, EventTimestampUtc);
-- Impersonation flag (privileged-access reports)
CREATE INDEX IX_AuditEvent_Impersonated   ON audit.AuditEvent (ImpersonatedByUserId) WHERE ImpersonatedByUserId IS NOT NULL;

-- ── AuditEventTag ────────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_AuditEventTag_Event       ON audit.AuditEventTag (AuditEventId);
CREATE INDEX IX_AuditEventTag_KeyValue    ON audit.AuditEventTag (TagKey, TagValue);

-- ── EntityChangeLog ──────────────────────────────────────────────────────────────────────────────────
-- Entity-instance history (e.g. "show me all changes to Employee EMP001")
CREATE INDEX IX_ECL_Entity_Id             ON audit.EntityChangeLog (EntityName, EntityId, ChangedAt DESC);
-- Time-range change reports
CREATE INDEX IX_ECL_ChangedAt             ON audit.EntityChangeLog (ChangedAt DESC);
-- FK
CREATE INDEX IX_ECL_AuditEvent            ON audit.EntityChangeLog (AuditEventId);
CREATE INDEX IX_ECL_ChangeType            ON audit.EntityChangeLog (ChangeType, EntityName, ChangedAt DESC);

-- ── FieldAuditLog ────────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_FAL_EntityChangeLog       ON audit.FieldAuditLog (EntityChangeLogId);
CREATE INDEX IX_FAL_FieldName             ON audit.FieldAuditLog (FieldName, EntityChangeLogId);

-- ── ApiRequestLog ────────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_ARL_AuditEvent            ON audit.ApiRequestLog (AuditEventId);
CREATE INDEX IX_ARL_RoutePath_Time        ON audit.ApiRequestLog (RoutePath, ReceivedAt DESC);
CREATE INDEX IX_ARL_ReceivedAt            ON audit.ApiRequestLog (ReceivedAt DESC);

-- ── ApiResponseLog ───────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_ARLO_Request              ON audit.ApiResponseLog (ApiRequestLogId);
CREATE INDEX IX_ARLO_StatusCode           ON audit.ApiResponseLog (HttpStatusCode, RespondedAt DESC);

-- ── IntegrationMessageLog ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_IML_AuditEvent            ON audit.IntegrationMessageLog (AuditEventId);
CREATE INDEX IX_IML_MessageId             ON audit.IntegrationMessageLog (MessageId) WHERE MessageId IS NOT NULL;
CREATE INDEX IX_IML_Topic_Time            ON audit.IntegrationMessageLog (TopicOrEndpoint, MessageTimestampUtc DESC);
CREATE INDEX IX_IML_OutcomeStatus         ON audit.IntegrationMessageLog (OutcomeStatus, MessageTimestampUtc DESC);

-- ── WorkflowAuditLog ─────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_WAL_AuditEvent            ON audit.WorkflowAuditLog (AuditEventId);
CREATE INDEX IX_WAL_Instance              ON audit.WorkflowAuditLog (WorkflowInstanceId, TransitionTimestampUtc DESC);
CREATE INDEX IX_WAL_Entity                ON audit.WorkflowAuditLog (EntityName, EntityId, TransitionTimestampUtc DESC);
CREATE INDEX IX_WAL_Actor_Time            ON audit.WorkflowAuditLog (ActorUserId, TransitionTimestampUtc DESC);

-- ── ApprovalDecisionLog ──────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_ADL_WorkflowAuditLog      ON audit.ApprovalDecisionLog (WorkflowAuditLogId);
CREATE INDEX IX_ADL_Approver              ON audit.ApprovalDecisionLog (ApproverUserId, DecisionTimestampUtc DESC);

-- ── BulkOperationLog ─────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_BOL_AuditEvent            ON audit.BulkOperationLog (AuditEventId);
CREATE INDEX IX_BOL_OperationType_Time    ON audit.BulkOperationLog (OperationType, StartedAt DESC);
CREATE INDEX IX_BOL_Status                ON audit.BulkOperationLog (OperationStatus, StartedAt DESC);

-- ── BulkOperationItemLog ─────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_BOIL_BulkOperation        ON audit.BulkOperationItemLog (BulkOperationLogId, ItemStatus);
CREATE INDEX IX_BOIL_EntityId             ON audit.BulkOperationItemLog (EntityId) WHERE EntityId IS NOT NULL;
CREATE INDEX IX_BOIL_EntityChangeLog      ON audit.BulkOperationItemLog (EntityChangeLogId) WHERE EntityChangeLogId IS NOT NULL;

-- ── ConfigChangeLog ──────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_CCL_AuditEvent            ON audit.ConfigChangeLog (AuditEventId);
CREATE INDEX IX_CCL_ConfigKey_Time        ON audit.ConfigChangeLog (ConfigKey, ChangedAt DESC);
CREATE INDEX IX_CCL_Scope_Time            ON audit.ConfigChangeLog (ConfigScope, ChangedAt DESC);

-- ── ScheduledJobLog ──────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_SJL_AuditEvent            ON audit.ScheduledJobLog (AuditEventId);
CREATE INDEX IX_SJL_JobCode_Time          ON audit.ScheduledJobLog (JobCode, StartedAt DESC);
CREATE INDEX IX_SJL_Status_Time           ON audit.ScheduledJobLog (ExecutionStatus, StartedAt DESC);

-- ── NotificationLog ──────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_NL_AuditEvent             ON audit.NotificationLog (AuditEventId);
CREATE INDEX IX_NL_Recipient_Time         ON audit.NotificationLog (RecipientUserId, SentAt DESC);
CREATE INDEX IX_NL_TriggerEntity          ON audit.NotificationLog (TriggerEntityName, TriggerEntityId);
CREATE INDEX IX_NL_DeliveryStatus         ON audit.NotificationLog (DeliveryStatus, SentAt DESC);

-- ── DataExportLog ────────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_DEL_AuditEvent            ON audit.DataExportLog (AuditEventId);
CREATE INDEX IX_DEL_Actor_Time            ON audit.DataExportLog (AuditEventId, RequestedAt DESC);
CREATE INDEX IX_DEL_ExportType_Time       ON audit.DataExportLog (ExportType, RequestedAt DESC);

-- ── SensitiveDataAccessLog ───────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_SDAL_AuditEvent           ON audit.SensitiveDataAccessLog (AuditEventId);
CREATE INDEX IX_SDAL_Subject_Time         ON audit.SensitiveDataAccessLog (SubjectUserId, AccessedAt DESC);
CREATE INDEX IX_SDAL_Entity               ON audit.SensitiveDataAccessLog (SubjectEntityName, SubjectEntityId, AccessedAt DESC);

-- ── ImpersonationLog ─────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_IL_AuditEvent             ON audit.ImpersonationLog (AuditEventId);
CREATE INDEX IX_IL_Actor_Time             ON audit.ImpersonationLog (ActorUserId, StartedAt DESC);
CREATE INDEX IX_IL_Target_Time            ON audit.ImpersonationLog (TargetUserId, StartedAt DESC);
CREATE INDEX IX_IL_SessionStatus          ON audit.ImpersonationLog (SessionStatus, StartedAt DESC);

-- ── ConsentAuditLog ──────────────────────────────────────────────────────────────────────────────────
CREATE INDEX IX_CAL_AuditEvent            ON audit.ConsentAuditLog (AuditEventId);
CREATE INDEX IX_CAL_Subject_Policy_Time   ON audit.ConsentAuditLog (SubjectUserId, PolicyCode, ConsentTimestampUtc DESC);
CREATE INDEX IX_CAL_PolicyCode_Time       ON audit.ConsentAuditLog (PolicyCode, ConsentTimestampUtc DESC);
CREATE INDEX IX_CAL_ConsentAction         ON audit.ConsentAuditLog (ConsentAction, ConsentTimestampUtc DESC);

GO
PRINT 'audit schema created successfully.';
GO