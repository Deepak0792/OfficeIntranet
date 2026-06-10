-- TIME SCHEMA - Time Zones, Locations & Infrastructure
-- SQL Server Database Schema
-- Schema: time
-- Purpose: Time zones, countries, regions, office locations, legal entities, departments, scope tyepe, geo fence, biometric device
-- Dependencies: shared (StatusLookup)


IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'time')
BEGIN
    EXEC('CREATE SCHEMA time');
END
GO

-- TIME ZONE MASTER
CREATE TABLE time.TimeZoneMaster (
    Id                      UNIQUEIDENTIFIER PRIMARY KEY,
    TimeZoneCode            NVARCHAR(100)   NOT NULL UNIQUE,
    TimeZoneName            NVARCHAR(200)   NOT NULL,
    UtcOffset               NVARCHAR(20)    NOT NULL,
    OffsetMinutes           SMALLINT        NOT NULL,
    SupportsDaylightSaving  BIT             NOT NULL DEFAULT 0,
    WindowsTimeZoneId       NVARCHAR(200)   NULL,
    IanaTimeZoneId          NVARCHAR(200)   NULL,
    CountryCode             NVARCHAR(10)    NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL
);
GO

-- COUNTRY
CREATE TABLE time.Country (
    Id              UNIQUEIDENTIFIER PRIMARY KEY,
    CountryCode     NVARCHAR(10)    NOT NULL UNIQUE,
    CountryName     NVARCHAR(200)   NOT NULL,
    CurrencyCode    NVARCHAR(10)    NULL,
    TimeZoneId      UNIQUEIDENTIFIER        NULL,
    DisplayOrder    SMALLINT        NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_Country_TimeZone
        FOREIGN KEY (TimeZoneId)
        REFERENCES time.TimeZoneMaster(Id)
);
GO

-- REGION
CREATE TABLE time.Region (
    Id              UNIQUEIDENTIFIER          PRIMARY KEY,
    CountryId       UNIQUEIDENTIFIER          NOT NULL,
    RegionName      NVARCHAR(200)   NOT NULL,
    RegionType      NVARCHAR(50)    NULL,
    ParentRegionId  UNIQUEIDENTIFIER          NULL,
    DisplayOrder    SMALLINT             NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_Region_Country
        FOREIGN KEY (CountryId)
        REFERENCES time.Country(Id),

    CONSTRAINT FK_Region_Parent
        FOREIGN KEY (ParentRegionId)
        REFERENCES time.Region(Id)
);
GO

-- LEGAL ENTITY
CREATE TABLE time.LegalEntity (
    Id                          UNIQUEIDENTIFIER PRIMARY KEY,
    EntityCode                  NVARCHAR(50)    NOT NULL UNIQUE,
    EntityName                  NVARCHAR(300)   NOT NULL,
    CountryId                   UNIQUEIDENTIFIER          NOT NULL,
    TaxIdentificationNumber     NVARCHAR(100)   NULL,
    RegistrationNumber          NVARCHAR(100)   NULL,
    CurrencyCode                NVARCHAR(10)    NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_LegalEntity_Country
        FOREIGN KEY (CountryId)
        REFERENCES time.Country(Id)
);
GO

-- OFFICE LOCATION
CREATE TABLE time.OfficeLocation (
    Id              UNIQUEIDENTIFIER PRIMARY KEY,
    LegalEntityId   UNIQUEIDENTIFIER          NOT NULL,
    CountryId       UNIQUEIDENTIFIER          NOT NULL,
    RegionId        UNIQUEIDENTIFIER          NULL,
    LocationCode    NVARCHAR(50)    NOT NULL UNIQUE,
    LocationName    NVARCHAR(200)   NOT NULL,
    BuildingName    NVARCHAR(200)   NULL,
    AddressLine1    NVARCHAR(500)   NULL,
    AddressLine2    NVARCHAR(500)   NULL,
    City            NVARCHAR(100)   NULL,
    StateProvince   NVARCHAR(100)   NULL,
    PostalCode      NVARCHAR(20)    NULL,
    Latitude        DECIMAL(10,7)   NULL,
    Longitude       DECIMAL(10,7)   NULL,
    TimeZoneId      UNIQUEIDENTIFIER          NULL,
    IsHeadOffice    BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_OfficeLocation_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES time.LegalEntity(Id),

    CONSTRAINT FK_OfficeLocation_Country
        FOREIGN KEY (CountryId)
        REFERENCES time.Country(Id),

    CONSTRAINT FK_OfficeLocation_Region
        FOREIGN KEY (RegionId)
        REFERENCES time.Region(Id),

    CONSTRAINT FK_OfficeLocation_TimeZone
        FOREIGN KEY (TimeZoneId)
        REFERENCES time.TimeZoneMaster(Id)
);
GO

-- DEPARTMENT
CREATE TABLE time.Department (
    Id                  UNIQUEIDENTIFIER PRIMARY KEY,
    DepartmentCode      NVARCHAR(50)    NOT NULL UNIQUE,
    DepartmentName      NVARCHAR(200)   NOT NULL,
    ParentDepartmentId  UNIQUEIDENTIFIER          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_Department_Parent
        FOREIGN KEY (ParentDepartmentId)
        REFERENCES time.Department(Id)
);
GO

-- SCOPE TYPE - Organizational hierarchy levels
CREATE TABLE time.ScopeType (
    Id              UNIQUEIDENTIFIER PRIMARY KEY,
    ScopeCode       NVARCHAR(100)   NOT NULL UNIQUE,
    ScopeName       NVARCHAR(200)   NOT NULL,
    HierarchyLevel  SMALLINT             NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL
);
GO

-- DESIGNATION
CREATE TABLE time.Designation (
    Id                  UNIQUEIDENTIFIER PRIMARY KEY,
    DesignationCode     NVARCHAR(50)    NOT NULL UNIQUE,
    DesignationName     NVARCHAR(200)   NOT NULL,
    Grade               NVARCHAR(50)    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL
);
GO

-- DOCUMENT TYPE
CREATE TABLE time.DocumentType (
    Id                  UNIQUEIDENTIFIER PRIMARY KEY,
    DocumentTypeCode    NVARCHAR(50)    NOT NULL UNIQUE,
    DocumentTypeName    NVARCHAR(200)   NOT NULL,
    Category            NVARCHAR(100)   NULL,
    Description         NVARCHAR(1000)  NULL,
    IsMandatory         BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL
);
GO

-- GEO FENCE
CREATE TABLE time.GeoFence (
    Id              UNIQUEIDENTIFIER PRIMARY KEY,
    GeoFenceCode    NVARCHAR(100)   NOT NULL UNIQUE,
    GeoFenceName    NVARCHAR(200)   NOT NULL,
    Latitude        DECIMAL(18,8)   NOT NULL,
    Longitude       DECIMAL(18,8)   NOT NULL,
    RadiusMeters    DECIMAL(18,2)   NOT NULL,
    OfficeId        UNIQUEIDENTIFIER          NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_GeoFence_Office
        FOREIGN KEY (OfficeId)
        REFERENCES time.OfficeLocation(Id)
);
GO

-- BIOMETRIC DEVICE
CREATE TABLE time.BiometricDevice (
    Id              UNIQUEIDENTIFIER PRIMARY KEY,
    DeviceCode      NVARCHAR(100)   NOT NULL UNIQUE,
    DeviceName      NVARCHAR(200)   NOT NULL,
    SerialNumber    NVARCHAR(200)   NULL,
    OfficeId        UNIQUEIDENTIFIER          NULL,
    IpAddress       NVARCHAR(100)   NULL,    
    LastSyncAt      DATETIME2       NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_BiometricDevice_Office
        FOREIGN KEY (OfficeId)
        REFERENCES time.OfficeLocation(Id)
);
GO
CREATE TABLE time.OutboxMessages
(
    [Id] UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT [DF_OutboxMessages_Id] DEFAULT NEWSEQUENTIALID(),
    [EventType] NVARCHAR(500) NOT NULL,
    [Payload] NVARCHAR(MAX) NOT NULL,
    [Exchange] NVARCHAR(200) NOT NULL,
    [RoutingKey] NVARCHAR(200) NOT NULL,
    -- Lookup-based status
    [Status] NVARCHAR(50) NOT NULL,
    [StatusGroup] NVARCHAR(50) NOT NULL
        CONSTRAINT [DF_OutboxMessages_StatusGroup] DEFAULT ('OUTBOX_STATUS'),
    [IsActive] BIT NOT NULL
        CONSTRAINT [DF_OutboxMessages_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2 NOT NULL
        CONSTRAINT [DF_OutboxMessages_CreatedAt] DEFAULT GETUTCDATE(),
    [CreatedBy] UNIQUEIDENTIFIER NULL,

    [LastUpdatedAt] DATETIME2 NOT NULL
        CONSTRAINT [DF_OutboxMessages_LastUpdatedAt] DEFAULT GETUTCDATE(),

    [LastUpdatedBy] UNIQUEIDENTIFIER NULL,

    [PublishedAt] DATETIME2 NULL,

    [RetryCount] INT NOT NULL
        CONSTRAINT [DF_OutboxMessages_RetryCount] DEFAULT (0),

    [ErrorMessage] NVARCHAR(MAX) NULL,

    CONSTRAINT [PK_OutboxMessages]
        PRIMARY KEY CLUSTERED ([Id] ASC),

    CONSTRAINT FK_OutboxMessages_Status
        FOREIGN KEY (Status, StatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- INDEXES - time Schema
CREATE INDEX IX_TimeZoneMaster_TimeZoneCode      ON time.TimeZoneMaster (TimeZoneCode);
CREATE INDEX IX_TimeZoneMaster_IanaTimeZoneId    ON time.TimeZoneMaster (IanaTimeZoneId);
CREATE INDEX IX_TimeZoneMaster_WindowsTimeZoneId ON time.TimeZoneMaster (WindowsTimeZoneId);
CREATE INDEX IX_Country_CountryCode              ON time.Country (CountryCode);
CREATE INDEX IX_Region_Country                   ON time.Region (CountryId);
CREATE INDEX IX_Region_Parent                    ON time.Region (ParentRegionId);
CREATE INDEX IX_LegalEntity_Country              ON time.LegalEntity (CountryId);
CREATE INDEX IX_OfficeLocation_LegalEntity       ON time.OfficeLocation (LegalEntityId);
CREATE INDEX IX_OfficeLocation_Country           ON time.OfficeLocation (CountryId);
CREATE INDEX IX_OfficeLocation_Region            ON time.OfficeLocation (RegionId);
CREATE INDEX IX_Department_Parent                ON time.Department (ParentDepartmentId);
CREATE INDEX IX_ScopeType_HierarchyLevel         ON time.ScopeType (HierarchyLevel);
CREATE INDEX IX_BiometricDevice_Office           ON time.BiometricDevice (OfficeId);
CREATE INDEX IX_GeoFence_Office                  ON time.GeoFence (OfficeId);
-- Fast lookup for pending messages to publish
CREATE NONCLUSTERED INDEX [IX_OutboxMessages_Status_CreatedAt] ON [time].[OutboxMessages] ([Status] ASC, [CreatedAt] ASC) INCLUDE ([Exchange], [RoutingKey], [RetryCount]);
-- Efficient retry processing
CREATE NONCLUSTERED INDEX [IX_OutboxMessages_Status_RetryCount] ON [time].[OutboxMessages] ([Status] ASC, [RetryCount] ASC) INCLUDE ([CreatedAt]);
-- Query published history efficiently
CREATE NONCLUSTERED INDEX [IX_OutboxMessages_PublishedAt] ON [time].[OutboxMessages] ([PublishedAt] ASC) WHERE [PublishedAt] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [UX_OutboxMessages_Id_Status] ON [time].[OutboxMessages] ([Id], [Status]);

GO

PRINT 'Time schema created successfully';
GO