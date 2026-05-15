-- =============================================================================================================
-- AUDIT LOGS SCHEMA - System-wide Audit Trail and Activity Logging
-- SQL Server Database Schema
-- Schema: audit
-- Purpose: Track all system activities, user actions, data changes for compliance and security
-- Dependencies: shared (StatusLookup), employee (Employee)
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'audit')
BEGIN
    EXEC('CREATE SCHEMA audit');
END
GO


-- =============================================================================================================
-- SEED STATUS CODES - Audit-specific status groups
-- =============================================================================

-- Audit Action Type
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'CREATE' AND StatusGroup = 'AUDIT_ACTION')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('CREATE', 'AUDIT_ACTION', 'Create', 'New record created', 1, 0),
    ('READ', 'AUDIT_ACTION', 'Read', 'Record accessed/viewed', 2, 0),
    ('UPDATE', 'AUDIT_ACTION', 'Update', 'Record modified', 3, 0),
    ('DELETE', 'AUDIT_ACTION', 'Delete', 'Record deleted', 4, 0),
    ('LOGIN', 'AUDIT_ACTION', 'Login', 'User logged in', 5, 0),
    ('LOGOUT', 'AUDIT_ACTION', 'Logout', 'User logged out', 6, 0),
    ('EXPORT', 'AUDIT_ACTION', 'Export', 'Data exported', 7, 0),
    ('IMPORT', 'AUDIT_ACTION', 'Import', 'Data imported', 8, 0),
    ('DOWNLOAD', 'AUDIT_ACTION', 'Download', 'File downloaded', 9, 0),
    ('UPLOAD', 'AUDIT_ACTION', 'Upload', 'File uploaded', 10, 0),
    ('APPROVE', 'AUDIT_ACTION', 'Approve', 'Record approved', 11, 0),
    ('REJECT', 'AUDIT_ACTION', 'Reject', 'Record rejected', 12, 0),
    ('SUBMIT', 'AUDIT_ACTION', 'Submit', 'Form submitted', 13, 0),
    ('CANCEL', 'AUDIT_ACTION', 'Cancel', 'Action cancelled', 14, 0),
    ('SHARE', 'AUDIT_ACTION', 'Share', 'Record shared', 15, 0),
    ('PERMISSION_CHANGE', 'AUDIT_ACTION', 'Permission Change', 'Permissions modified', 16, 0),
    ('PASSWORD_CHANGE', 'AUDIT_ACTION', 'Password Change', 'Password modified', 17, 0),
    ('CONFIG_CHANGE', 'AUDIT_ACTION', 'Config Change', 'Configuration modified', 18, 0);
END
GO

-- Audit Entity Type
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'USER' AND StatusGroup = 'AUDIT_ENTITY_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('USER', 'AUDIT_ENTITY_TYPE', 'User', 'User/Employee entity', 1, 0),
    ('ROLE', 'AUDIT_ENTITY_TYPE', 'Role', 'Role entity', 2, 0),
    ('PERMISSION', 'AUDIT_ENTITY_TYPE', 'Permission', 'Permission entity', 3, 0),
    ('DOCUMENT', 'AUDIT_ENTITY_TYPE', 'Document', 'Document entity', 4, 0),
    ('EVENT', 'AUDIT_ENTITY_TYPE', 'Event', 'Event entity', 5, 0),
    ('SURVEY', 'AUDIT_ENTITY_TYPE', 'Survey', 'Survey entity', 6, 0),
    ('FEEDBACK', 'AUDIT_ENTITY_TYPE', 'Feedback', 'Feedback entity', 7, 0),
    ('ANNOUNCEMENT', 'AUDIT_ENTITY_TYPE', 'Announcement', 'Announcement entity', 8, 0),
    ('TICKET', 'AUDIT_ENTITY_TYPE', 'Ticket', 'Helpdesk ticket entity', 9, 0),
    ('LEAVE', 'AUDIT_ENTITY_TYPE', 'Leave', 'Leave request entity', 10, 0),
    ('ASSET', 'AUDIT_ENTITY_TYPE', 'Asset', 'Asset entity', 11, 0),
    ('CONFIG', 'AUDIT_ENTITY_TYPE', 'Config', 'Configuration entity', 12, 0),
    ('LOG', 'AUDIT_ENTITY_TYPE', 'Log', 'System log entry', 13, 0),
    ('AUTH', 'AUDIT_ENTITY_TYPE', 'Auth', 'Authentication event', 14, 0);
END
GO

-- Audit Severity
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'INFO' AND StatusGroup = 'AUDIT_SEVERITY')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('INFO', 'AUDIT_SEVERITY', 'Information', 'Informational log', 1, 0),
    ('DEBUG', 'AUDIT_SEVERITY', 'Debug', 'Debug information', 2, 0),
    ('WARNING', 'AUDIT_SEVERITY', 'Warning', 'Warning event', 3, 0),
    ('ERROR', 'AUDIT_SEVERITY', 'Error', 'Error event', 4, 1),
    ('CRITICAL', 'AUDIT_SEVERITY', 'Critical', 'Critical security event', 5, 1);
END
GO

-- Audit Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'SUCCESS' AND StatusGroup = 'AUDIT_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('SUCCESS', 'AUDIT_STATUS', 'Success', 'Action completed successfully', 1, 0),
    ('FAILED', 'AUDIT_STATUS', 'Failed', 'Action failed', 2, 1),
    ('PARTIAL', 'AUDIT_STATUS', 'Partial', 'Action partially completed', 3, 0),
    ('ROLLED_BACK', 'AUDIT_STATUS', 'Rolled Back', 'Action was rolled back', 4, 1),
    ('PENDING', 'AUDIT_STATUS', 'Pending', 'Action pending', 5, 0);
END
GO


-- =============================================================================================================
-- AUDIT LOG - Main audit trail table
-- =============================================================================
CREATE TABLE audit.AuditLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    ActionCode          NVARCHAR(50)    NOT NULL,
    ActionCodeGroup     AS CAST('AUDIT_ACTION' AS NVARCHAR(50)) PERSISTED,
    EntityType          NVARCHAR(50)   NOT NULL,
    EntityTypeGroup     AS CAST('AUDIT_ENTITY_TYPE' AS NVARCHAR(50)) PERSISTED,
    EntityId            BIGINT          NULL,
    EntityCode          NVARCHAR(100)  NULL,
    SchemaName          NVARCHAR(100)  NULL,
    TableName           NVARCHAR(200)  NULL,
    SeverityCode        NVARCHAR(50)   NOT NULL DEFAULT 'INFO',
    SeverityCodeGroup   AS CAST('AUDIT_SEVERITY' AS NVARCHAR(50)) PERSISTED,
    StatusCode          NVARCHAR(50)   NOT NULL DEFAULT 'SUCCESS',
    StatusCodeGroup     AS CAST('AUDIT_STATUS' AS NVARCHAR(50)) PERSISTED,
    UserId              BIGINT          NULL,
    UserName            NVARCHAR(200)  NULL,
    SessionId           NVARCHAR(100)  NULL,
    IPAddress           NVARCHAR(50)   NULL,
    UserAgent           NVARCHAR(500)  NULL,
    DeviceInfo          NVARCHAR(200)  NULL,
    Location            NVARCHAR(200)  NULL,
    ModuleName          NVARCHAR(100)  NULL,
    FeatureName         NVARCHAR(100)  NULL,
    Description         NVARCHAR(MAX)  NULL,
    OldValues           NVARCHAR(MAX)  NULL,
    NewValues           NVARCHAR(MAX)  NULL,
    ChangedFields       NVARCHAR(MAX)  NULL,
    ErrorMessage        NVARCHAR(MAX)  NULL,
    StackTrace          NVARCHAR(MAX)  NULL,
    RequestUrl          NVARCHAR(500)  NULL,
    RequestMethod       NVARCHAR(20)   NULL,
    ResponseCode        INT             NULL,
    ExecutionTimeMs     INT             NULL,
    CorrelationId       UNIQUEIDENTIFIER NULL,
    ParentEventId       UNIQUEIDENTIFIER NULL,
    AdditionalData      NVARCHAR(MAX)  NULL,
    IsSuspicious        BIT             NOT NULL DEFAULT 0,
    SuspiciousReason    NVARCHAR(500)  NULL,
    RetentionUntil      DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AuditLog_Action
        FOREIGN KEY (ActionCode, ActionCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AuditLog_EntityType
        FOREIGN KEY (EntityType, EntityTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AuditLog_Severity
        FOREIGN KEY (SeverityCode, SeverityCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AuditLog_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AuditLog_User
        FOREIGN KEY (UserId)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- AUDIT CONFIGURATION - Configure audit settings per entity
-- =============================================================================
CREATE TABLE audit.AuditConfiguration (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    SchemaName          NVARCHAR(100)   NOT NULL,
    TableName           NVARCHAR(200)   NOT NULL,
    EntityType          NVARCHAR(50)   NOT NULL,
    EntityTypeGroup     AS CAST('AUDIT_ENTITY_TYPE' AS NVARCHAR(50)) PERSISTED,
    IsAuditEnabled      BIT             NOT NULL DEFAULT 1,
    LogReads            BIT             NOT NULL DEFAULT 0,
    LogCreates          BIT             NOT NULL DEFAULT 1,
    LogUpdates          BIT             NOT NULL DEFAULT 1,
    LogDeletes          BIT             NOT NULL DEFAULT 1,
    LogFieldChanges     BIT             NOT NULL DEFAULT 1,
    ExcludedColumns     NVARCHAR(MAX)  NULL,
    SensitiveColumns    NVARCHAR(MAX)  NULL,
    RetentionDays       INT             NOT NULL DEFAULT 365,
    AlertOnChanges      BIT             NOT NULL DEFAULT 0,
    AlertThreshold      INT             NULL,
    CreatedById         BIGINT          NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_AuditConfiguration_EntityType
        FOREIGN KEY (EntityType, EntityTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AuditConfiguration_CreatedBy
        FOREIGN KEY (CreatedById)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_AuditConfiguration_Table UNIQUE (SchemaName, TableName)
);
GO


-- =============================================================================================================
-- AUDIT RETENTION POLICY - Retention rules for audit data
-- =============================================================================
CREATE TABLE audit.AuditRetentionPolicy (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyName          NVARCHAR(100)   NOT NULL UNIQUE,
    Description         NVARCHAR(500)   NULL,
    RetentionDays       INT             NOT NULL,
    ArchiveBeforeDelete BIT             NOT NULL DEFAULT 1,
    ArchiveLocation     NVARCHAR(500)   NULL,
    SeverityFilter      NVARCHAR(50)   NULL,
    ActionFilter        NVARCHAR(50)   NULL,
    EntityTypeFilter    NVARCHAR(50)   NULL,
    UserFilter          NVARCHAR(500)  NULL,
    ScheduleCron       NVARCHAR(100)   NULL,
    LastRunAt          DATETIME2       NULL,
    NextRunAt          DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedById         BIGINT          NOT NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AuditRetentionPolicy_CreatedBy
        FOREIGN KEY (CreatedById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- AUDIT SUSPICIOUS ACTIVITY - Flagged suspicious activities
-- =============================================================================
CREATE TABLE audit.SuspiciousActivity (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    AuditLogId          BIGINT          NOT NULL,
    SuspiciousType      NVARCHAR(50)   NOT NULL,
    RiskScore           INT             NOT NULL DEFAULT 0,
    RiskFactors         NVARCHAR(MAX)  NULL,
    DetectionRule       NVARCHAR(200)  NULL,
    RecommendedAction   NVARCHAR(500)  NULL,
    IsReviewed          BIT             NOT NULL DEFAULT 0,
    ReviewedById        BIGINT          NULL,
    ReviewedAt          DATETIME2       NULL,
    ReviewNotes         NVARCHAR(MAX)  NULL,
    IsConfirmed         BIT             NULL,
    FalsePositive       BIT             NOT NULL DEFAULT 0,
    AlertSent           BIT             NOT NULL DEFAULT 0,
    AlertRecipient      NVARCHAR(255)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SuspiciousActivity_AuditLog
        FOREIGN KEY (AuditLogId)
        REFERENCES audit.AuditLog(Id),

    CONSTRAINT FK_SuspiciousActivity_ReviewedBy
        FOREIGN KEY (ReviewedById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- AUDIT ARCHIVE - Archived audit logs
-- =============================================================================
CREATE TABLE audit.AuditArchive (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    ArchiveBatch        NVARCHAR(50)   NOT NULL,
    ArchiveDate         DATETIME2       NOT NULL,
    ArchivedFrom        DATETIME2       NOT NULL,
    ArchivedTo          DATETIME2       NOT NULL,
    RecordCount         INT             NOT NULL DEFAULT 0,
    ArchiveLocation     NVARCHAR(500)  NOT NULL,
    CompressedSize      BIGINT          NULL,
    OriginalSize        BIGINT          NULL,
    IsEncrypted         BIT             NOT NULL DEFAULT 1,
    ArchiveKeyId        NVARCHAR(100)  NULL,
    ArchivedById        BIGINT          NOT NULL,
    VerificationHash    NVARCHAR(64)   NULL,
    IsVerified          BIT             NOT NULL DEFAULT 0,
    VerifiedAt          DATETIME2       NULL,
    RestoredAt          DATETIME2       NULL,
    RestoredById        BIGINT          NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AuditArchive_ArchivedBy
        FOREIGN KEY (ArchivedById)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_AuditArchive_RestoredBy
        FOREIGN KEY (RestoredById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- USER SESSION LOG - Track user login/logout sessions
-- =============================================================================
CREATE TABLE audit.UserSessionLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    SessionId           NVARCHAR(100)  NOT NULL UNIQUE,
    UserId              BIGINT          NOT NULL,
    LoginType           NVARCHAR(50)   NOT NULL,
    IPAddress           NVARCHAR(50)   NULL,
    UserAgent           NVARCHAR(500)  NULL,
    DeviceInfo          NVARCHAR(200)  NULL,
    BrowserInfo         NVARCHAR(200)  NULL,
    OSInfo              NVARCHAR(200)  NULL,
    Location            NVARCHAR(200)  NULL,
    LoginTime           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LogoutTime          DATETIME2       NULL,
    LogoutType          NVARCHAR(50)   NULL,
    SessionDuration     INT             NULL,
    LastActivityAt      DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    RefreshToken        NVARCHAR(MAX)  NULL,
    AccessToken         NVARCHAR(MAX)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_UserSessionLog_User
        FOREIGN KEY (UserId)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- DATA CHANGE LOG - Track specific field-level changes
-- =============================================================================
CREATE TABLE audit.DataChangeLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    AuditLogId          BIGINT          NOT NULL,
    EntityType          NVARCHAR(50)   NOT NULL,
    EntityTypeGroup     AS CAST('AUDIT_ENTITY_TYPE' AS NVARCHAR(50)) PERSISTED,
    EntityId            BIGINT          NOT NULL,
    FieldName           NVARCHAR(200)  NOT NULL,
    FieldLabel          NVARCHAR(200)  NULL,
    OldValue            NVARCHAR(MAX)  NULL,
    NewValue            NVARCHAR(MAX)  NULL,
    IsSensitive         BIT             NOT NULL DEFAULT 0,
    IsEncrypted         BIT             NOT NULL DEFAULT 0,
    ChangeReason        NVARCHAR(500)  NULL,
    ChangedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_DataChangeLog_AuditLog
        FOREIGN KEY (AuditLogId)
        REFERENCES audit.AuditLog(Id),

    CONSTRAINT FK_DataChangeLog_EntityType
        FOREIGN KEY (EntityType, EntityTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
);
GO


-- =============================================================================================================
-- LOGIN ATTEMPT LOG - Track authentication attempts
-- =============================================================================
CREATE TABLE audit.LoginAttemptLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    UserId              BIGINT          NULL,
    UserName            NVARCHAR(200)  NULL,
    Email               NVARCHAR(255)  NULL,
    AttemptType         NVARCHAR(50)   NOT NULL,
    LoginMethod         NVARCHAR(50)   NULL,
    IPAddress           NVARCHAR(50)   NULL,
    UserAgent           NVARCHAR(500)  NULL,
    DeviceInfo          NVARCHAR(200)  NULL,
    Location            NVARCHAR(200)  NULL,
    Success             BIT             NOT NULL DEFAULT 0,
    FailureReason       NVARCHAR(200)  NULL,
    ErrorCode           NVARCHAR(50)   NULL,
    SessionId           NVARCHAR(100)  NULL,
    MfaRequired         BIT             NOT NULL DEFAULT 0,
    MfaVerified         BIT             NOT NULL DEFAULT 0,
    SuspiciousActivity  BIT             NOT NULL DEFAULT 0,
    AttemptCount        INT             NOT NULL DEFAULT 1,
    LockedUntil         DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_LoginAttemptLog_User
        FOREIGN KEY (UserId)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- CONSENT LOG - Track user consent for data processing
-- =============================================================================
CREATE TABLE audit.ConsentLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    UserId              BIGINT          NOT NULL,
    ConsentType         NVARCHAR(100)  NOT NULL,
    ConsentVersion      NVARCHAR(50)   NOT NULL,
    ConsentGiven        BIT             NOT NULL DEFAULT 0,
    ConsentMethod       NVARCHAR(50)   NOT NULL,
    IPAddress           NVARCHAR(50)   NULL,
    UserAgent           NVARCHAR(500)  NULL,
    WithdrawalReason    NVARCHAR(500)  NULL,
    ConsentText         NVARCHAR(MAX)  NULL,
    EffectiveFrom       DATETIME2       NOT NULL,
    EffectiveTo         DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ConsentLog_User
        FOREIGN KEY (UserId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_ConsentLog_UserType UNIQUE (UserId, ConsentType, ConsentVersion)
);
GO


-- =============================================================================================================
-- DATA EXPORT LOG - Track data export activities
-- =============================================================================
CREATE TABLE audit.DataExportLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    ExportId            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    UserId              BIGINT          NOT NULL,
    ExportType          NVARCHAR(50)   NOT NULL,
    EntityTypes         NVARCHAR(MAX)  NULL,
    Filters             NVARCHAR(MAX)  NULL,
    Format              NVARCHAR(50)   NOT NULL,
    FileName            NVARCHAR(255)  NULL,
    FileSize            BIGINT          NULL,
    RecordCount         INT             NOT NULL DEFAULT 0,
    IPAddress           NVARCHAR(50)   NULL,
    Destination          NVARCHAR(500)  NULL,
    IsAutomated         BIT             NOT NULL DEFAULT 0,
    ScheduleId          NVARCHAR(100)  NULL,
    Status              NVARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    ErrorMessage        NVARCHAR(MAX)  NULL,
    CompletedAt         DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_DataExportLog_User
        FOREIGN KEY (UserId)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- ACCESS VIOLATION LOG - Track security policy violations
-- =============================================================================
CREATE TABLE audit.AccessViolationLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    ViolationId         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    UserId              BIGINT          NULL,
    UserName            NVARCHAR(200)  NULL,
    ViolationType       NVARCHAR(50)   NOT NULL,
    SeverityCode        NVARCHAR(50)   NOT NULL DEFAULT 'WARNING',
    SeverityCodeGroup   AS CAST('AUDIT_SEVERITY' AS NVARCHAR(50)) PERSISTED,
    ResourceType        NVARCHAR(50)   NOT NULL,
    ResourceId          BIGINT          NULL,
    ResourceName        NVARCHAR(200)  NULL,
    RequestUrl          NVARCHAR(500)  NULL,
    RequestMethod       NVARCHAR(20)   NULL,
    IPAddress           NVARCHAR(50)   NULL,
    UserAgent           NVARCHAR(500)  NULL,
    Description         NVARCHAR(MAX)  NULL,
    PolicyViolated      NVARCHAR(200)  NULL,
    MitigationAction    NVARCHAR(500)  NULL,
    IsResolved          BIT             NOT NULL DEFAULT 0,
    ResolvedById        BIGINT          NULL,
    ResolvedAt          DATETIME2       NULL,
    ResolutionNotes     NVARCHAR(MAX)  NULL,
    AlertSent           BIT             NOT NULL DEFAULT 0,
    AlertRecipient      NVARCHAR(255)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AccessViolationLog_User
        FOREIGN KEY (UserId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_AccessViolationLog_Severity
        FOREIGN KEY (SeverityCode, SeverityCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AccessViolationLog_ResolvedBy
        FOREIGN KEY (ResolvedById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- COMPLIANCE REPORT - Compliance tracking reports
-- =============================================================================
CREATE TABLE audit.ComplianceReport (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    ReportCode          NVARCHAR(50)    NOT NULL UNIQUE,
    ReportName          NVARCHAR(200)   NOT NULL,
    ReportType          NVARCHAR(100)  NOT NULL,
    Description         NVARCHAR(500)  NULL,
    GeneratedById       BIGINT          NOT NULL,
    PeriodStart         DATE            NOT NULL,
    PeriodEnd           DATE            NOT NULL,
    Parameters          NVARCHAR(MAX)  NULL,
    Findings            NVARCHAR(MAX)  NULL,
    Recommendations     NVARCHAR(MAX)  NULL,
    Status              NVARCHAR(50)   NOT NULL DEFAULT 'DRAFT',
    ApprovedById        BIGINT          NULL,
    ApprovedAt          DATETIME2       NULL,
    PublishedAt         DATETIME2       NULL,
    FileUrl             NVARCHAR(1000)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ComplianceReport_GeneratedBy
        FOREIGN KEY (GeneratedById)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ComplianceReport_ApprovedBy
        FOREIGN KEY (ApprovedById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- INDEXES - For performance optimization
-- =============================================================================

-- AuditLog indexes
CREATE INDEX IX_AuditLog_EventId ON audit.AuditLog(EventId);
CREATE INDEX IX_AuditLog_Action ON audit.AuditLog(ActionCode, ActionCodeGroup);
CREATE INDEX IX_AuditLog_EntityType ON audit.AuditLog(EntityType, EntityTypeGroup);
CREATE INDEX IX_AuditLog_EntityId ON audit.AuditLog(EntityId);
CREATE INDEX IX_AuditLog_User ON audit.AuditLog(UserId);
CREATE INDEX IX_AuditLog_Severity ON audit.AuditLog(SeverityCode, SeverityCodeGroup);
CREATE INDEX IX_AuditLog_Status ON audit.AuditLog(StatusCode, StatusCodeGroup);
CREATE INDEX IX_AuditLog_CreatedAt ON audit.AuditLog(CreatedAt);
CREATE INDEX IX_AuditLog_ModuleFeature ON audit.AuditLog(ModuleName, FeatureName);
CREATE INDEX IX_AuditLog_IPAddress ON audit.AuditLog(IPAddress);
CREATE INDEX IX_AuditLog_Suspicious ON audit.AuditLog(IsSuspicious, CreatedAt);
CREATE INDEX IX_AuditLog_CorrelationId ON audit.AuditLog(CorrelationId);
CREATE INDEX IX_AuditLog_Retention ON audit.AuditLog(RetentionUntil);

-- AuditConfiguration indexes
CREATE INDEX IX_AuditConfiguration_Table ON audit.AuditConfiguration(SchemaName, TableName);
CREATE INDEX IX_AuditConfiguration_EntityType ON audit.AuditConfiguration(EntityType);

-- AuditRetentionPolicy indexes
CREATE INDEX IX_AuditRetentionPolicy_Schedule ON audit.AuditRetentionPolicy(NextRunAt, IsActive);

-- SuspiciousActivity indexes
CREATE INDEX IX_SuspiciousActivity_AuditLog ON audit.SuspiciousActivity(AuditLogId);
CREATE INDEX IX_SuspiciousActivity_RiskScore ON audit.SuspiciousActivity(RiskScore, IsReviewed);
CREATE INDEX IX_SuspiciousActivity_ReviewedBy ON audit.SuspiciousActivity(ReviewedById);

-- AuditArchive indexes
CREATE INDEX IX_AuditArchive_Date ON audit.AuditArchive(ArchiveDate);
CREATE INDEX IX_AuditArchive_Batch ON audit.AuditArchive(ArchiveBatch);

-- UserSessionLog indexes
CREATE INDEX IX_UserSessionLog_User ON audit.UserSessionLog(UserId);
CREATE INDEX IX_UserSessionLog_SessionId ON audit.UserSessionLog(SessionId);
CREATE INDEX IX_UserSessionLog_LoginTime ON audit.UserSessionLog(LoginTime);
CREATE INDEX IX_UserSessionLog_Active ON audit.UserSessionLog(IsActive, LogoutTime);

-- DataChangeLog indexes
CREATE INDEX IX_DataChangeLog_AuditLog ON audit.DataChangeLog(AuditLogId);
CREATE INDEX IX_DataChangeLog_Entity ON audit.DataChangeLog(EntityType, EntityId);
CREATE INDEX IX_DataChangeLog_Field ON audit.DataChangeLog(FieldName);

-- LoginAttemptLog indexes
CREATE INDEX IX_LoginAttemptLog_User ON audit.LoginAttemptLog(UserId);
CREATE INDEX IX_LoginAttemptLog_CreatedAt ON audit.LoginAttemptLog(CreatedAt);
CREATE INDEX IX_LoginAttemptLog_Success ON audit.LoginAttemptLog(Success, CreatedAt);
CREATE INDEX IX_LoginAttemptLog_IPAddress ON audit.LoginAttemptLog(IPAddress);
CREATE INDEX IX_LoginAttemptLog_Suspicious ON audit.LoginAttemptLog(SuspiciousActivity);

-- ConsentLog indexes
CREATE INDEX IX_ConsentLog_User ON audit.ConsentLog(UserId);
CREATE INDEX IX_ConsentLog_Type ON audit.ConsentLog(ConsentType);

-- DataExportLog indexes
CREATE INDEX IX_DataExportLog_ExportId ON audit.DataExportLog(ExportId);
CREATE INDEX IX_DataExportLog_User ON audit.DataExportLog(UserId);
CREATE INDEX IX_DataExportLog_CreatedAt ON audit.DataExportLog(CreatedAt);

-- AccessViolationLog indexes
CREATE INDEX IX_AccessViolationLog_ViolationId ON audit.AccessViolationLog(ViolationId);
CREATE INDEX IX_AccessViolationLog_User ON audit.AccessViolationLog(UserId);
CREATE INDEX IX_AccessViolationLog_Type ON audit.AccessViolationLog(ViolationType);
CREATE INDEX IX_AccessViolationLog_Resolved ON audit.AccessViolationLog(IsResolved);
CREATE INDEX IX_AccessViolationLog_CreatedAt ON audit.AccessViolationLog(CreatedAt);

-- ComplianceReport indexes
CREATE INDEX IX_ComplianceReport_Code ON audit.ComplianceReport(ReportCode);
CREATE INDEX IX_ComplianceReport_GeneratedBy ON audit.ComplianceReport(GeneratedById);
CREATE INDEX IX_ComplianceReport_Period ON audit.ComplianceReport(PeriodStart, PeriodEnd);
GO


-- =============================================================================================================
-- DEFAULT AUDIT CONFIGURATION - Enable audit for main tables
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM audit.AuditConfiguration)
BEGIN
    INSERT INTO audit.AuditConfiguration (SchemaName, TableName, EntityType, LogReads, LogCreates, LogUpdates, LogDeletes, RetentionDays)
    VALUES
    ('employee', 'Employee', 'USER', 0, 1, 1, 1, 730),
    ('auth', 'UserRole', 'ROLE', 0, 1, 1, 1, 365),
    ('events', 'Event', 'EVENT', 0, 1, 1, 1, 365),
    ('surveys', 'Survey', 'SURVEY', 0, 1, 1, 1, 365),
    ('surveys', 'AnonymousFeedback', 'FEEDBACK', 0, 1, 1, 0, 730);
END
GO


PRINT 'Audit Logs schema created successfully';
GO