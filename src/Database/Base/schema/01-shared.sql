-- SHARED SCHEMA - Cross-Cutting Lookup Tables
-- SQL Server Database Schema
-- Schema: shared
-- Purpose: Universal status codes used by ALL microservices for domain isolation
-- Dependencies: None (foundational)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'shared')
BEGIN
    EXEC('CREATE SCHEMA shared');
END
GO

-- STATUS LOOKUP - Universal status codes with domain isolation
CREATE TABLE shared.StatusLookup (
    StatusCode      NVARCHAR(50)    NOT NULL,
    StatusGroup     NVARCHAR(50)    NOT NULL,
    Label           NVARCHAR(100)  NOT NULL,
    Description     NVARCHAR(500)  NULL,
    DisplayOrder    TINYINT         NOT NULL DEFAULT 0,
    IsTerminal      BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_StatusLookup PRIMARY KEY (StatusCode, StatusGroup)
);
GO

PRINT 'Shared schema created successfully';