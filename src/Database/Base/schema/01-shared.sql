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

CREATE TABLE shared.LookupDefinition
(
    LookupDefinitionId     BIGINT IDENTITY(1,1) NOT NULL,
    LookupCode             NVARCHAR(100) NOT NULL,
    LookupName             NVARCHAR(200) NOT NULL,
    -- STATIC_SQL | TABLE | PROCEDURE
    LookupSourceType       NVARCHAR(30) NOT NULL,
    SourceObjectName       NVARCHAR(300) NULL,
    SqlStatement           NVARCHAR(MAX) NULL,
    ProcedureName          NVARCHAR(300) NULL,
    ParentLookupDefinitionId BIGINT NULL,
    -- UI Metadata
    ValueField             NVARCHAR(100) NOT NULL DEFAULT 'Id',
    TextField              NVARCHAR(100) NOT NULL DEFAULT 'Name',
    ParentValueField       NVARCHAR(100) NULL,
    -- Dynamic filtering support
    SupportsParentFilter   BIT NOT NULL DEFAULT 0,
    -- System
    IsSystem               BIT NOT NULL DEFAULT 0,
    IsActive               BIT NOT NULL DEFAULT 1,
    CreatedAt              DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_LookupDefinition
        PRIMARY KEY (LookupDefinitionId),

    CONSTRAINT UQ_LookupDefinition_Code
        UNIQUE (LookupCode),

    CONSTRAINT FK_LookupDefinition_Parent
        FOREIGN KEY (ParentLookupDefinitionId)
        REFERENCES shared.LookupDefinition(LookupDefinitionId)
);
GO

-- ============================================================
-- LOOKUP DEFINITIONS : FEEDBACK_STATUS
--shared.GetLookup  'FEEDBACK_STATUS'
--shared.GetLookup  'STATE' , 1
-- ============================================================

CREATE OR ALTER PROCEDURE shared.GetLookup 
(
    @LookupCode NVARCHAR(100),
    @ParentId NVARCHAR(100) = NULL
)
AS
BEGIN

    DECLARE @Sql NVARCHAR(MAX);

    SELECT @Sql = SqlStatement
    FROM shared.LookupDefinition
    WHERE LookupCode = @LookupCode
      AND IsActive = 1;

    IF @Sql IS NULL
    BEGIN
        RAISERROR('Lookup not found.',16,1);
        RETURN;
    END

    EXEC sp_executesql
    @Sql,
    N'@ParentId NVARCHAR(100)',
    @ParentId;

END
GO
PRINT 'Shared schema created successfully';