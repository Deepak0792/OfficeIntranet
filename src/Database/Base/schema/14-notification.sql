-- NOTIFICATION SCHEMA
-- SQL Server Database Schema
-- Schema: notification

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'notification')
BEGIN
    EXEC('CREATE SCHEMA notification');
END
GO

CREATE TABLE notification.NotificationTemplate (
    Id                  INT             PRIMARY KEY IDENTITY(1,1),
    EventName           NVARCHAR(200)   NOT NULL,
    Channel             NVARCHAR(50)    NOT NULL DEFAULT 'EMAIL',
    SubjectTemplate     NVARCHAR(500)   NOT NULL,
    BodyTemplate        NVARCHAR(MAX)   NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

CREATE TABLE notification.NotificationLog (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    NotificationTemplateId  INT             NULL,
    RecipientEmployeeId     INT             NOT NULL,
    RecipientAddress        NVARCHAR(200)   NOT NULL,
    Channel                 NVARCHAR(50)    NOT NULL,
    Subject                 NVARCHAR(500)   NOT NULL,
    Body                    NVARCHAR(MAX)   NOT NULL,
    Status                  NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    SentAt                  DATETIME2       NULL,
    ErrorMessage            NVARCHAR(MAX)   NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_NotificationLog_Template
        FOREIGN KEY (NotificationTemplateId)
        REFERENCES notification.NotificationTemplate(Id)
);
GO
