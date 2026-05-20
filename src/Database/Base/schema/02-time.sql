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
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    TimeZoneCode            NVARCHAR(100)   NOT NULL UNIQUE,
    TimeZoneName            NVARCHAR(200)   NOT NULL,
    UtcOffset               NVARCHAR(20)    NOT NULL,
    OffsetMinutes           INT             NOT NULL,
    SupportsDaylightSaving  BIT             NOT NULL DEFAULT 0,
    WindowsTimeZoneId       NVARCHAR(200)   NULL,
    IanaTimeZoneId          NVARCHAR(200)   NULL,
    CountryCode             NVARCHAR(10)    NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL
);
GO

-- COUNTRY
CREATE TABLE time.Country (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    CountryCode     NVARCHAR(10)    NOT NULL UNIQUE,
    CountryName     NVARCHAR(200)   NOT NULL,
    CurrencyCode    NVARCHAR(10)    NULL,
    TimeZoneId      INT          NULL,
    DisplayOrder    INT             NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL,

    CONSTRAINT FK_Country_TimeZone
        FOREIGN KEY (TimeZoneId)
        REFERENCES time.TimeZoneMaster(Id)
);
GO

-- REGION
CREATE TABLE time.Region (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    CountryId       INT          NOT NULL,
    RegionName      NVARCHAR(200)   NOT NULL,
    RegionType      NVARCHAR(50)    NULL,
    ParentRegionId  INT          NULL,
    DisplayOrder    INT             NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL,

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
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    EntityCode                  NVARCHAR(50)    NOT NULL UNIQUE,
    EntityName                  NVARCHAR(300)   NOT NULL,
    CountryId                   INT          NOT NULL,
    TaxIdentificationNumber     NVARCHAR(100)   NULL,
    RegistrationNumber          NVARCHAR(100)   NULL,
    CurrencyCode                NVARCHAR(10)    NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

    CONSTRAINT FK_LegalEntity_Country
        FOREIGN KEY (CountryId)
        REFERENCES time.Country(Id)
);
GO

-- OFFICE LOCATION
CREATE TABLE time.OfficeLocation (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    LegalEntityId   INT          NOT NULL,
    CountryId       INT          NOT NULL,
    RegionId        INT          NULL,
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
    TimeZoneId      INT          NULL,
    IsHeadOffice    BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL,

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
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    DepartmentCode      NVARCHAR(50)    NOT NULL UNIQUE,
    DepartmentName      NVARCHAR(200)   NOT NULL,
    ParentDepartmentId  INT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_Department_Parent
        FOREIGN KEY (ParentDepartmentId)
        REFERENCES time.Department(Id)
);
GO

-- SCOPE TYPE - Organizational hierarchy levels
CREATE TABLE time.ScopeType (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    ScopeCode       NVARCHAR(100)   NOT NULL UNIQUE,
    ScopeName       NVARCHAR(200)   NOT NULL,
    HierarchyLevel  INT             NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL
);
GO

-- DESIGNATION
CREATE TABLE time.Designation (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    DesignationCode     NVARCHAR(50)    NOT NULL UNIQUE,
    DesignationName     NVARCHAR(200)   NOT NULL,
    Grade               NVARCHAR(50)    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- DOCUMENT TYPE
CREATE TABLE time.DocumentType (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    DocumentTypeCode    NVARCHAR(50)    NOT NULL UNIQUE,
    DocumentTypeName    NVARCHAR(200)   NOT NULL,
    Category            NVARCHAR(100)   NULL,
    Description         NVARCHAR(1000)  NULL,
    IsMandatory         BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- GEO FENCE
CREATE TABLE time.GeoFence (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    GeoFenceCode    NVARCHAR(100)   NOT NULL UNIQUE,
    GeoFenceName    NVARCHAR(200)   NOT NULL,
    Latitude        DECIMAL(18,8)   NOT NULL,
    Longitude       DECIMAL(18,8)   NOT NULL,
    RadiusMeters    DECIMAL(18,2)   NOT NULL,
    OfficeId        INT          NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL,

    CONSTRAINT FK_GeoFence_Office
        FOREIGN KEY (OfficeId)
        REFERENCES time.OfficeLocation(Id)
);
GO

-- BIOMETRIC DEVICE
CREATE TABLE time.BiometricDevice (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    DeviceCode      NVARCHAR(100)   NOT NULL UNIQUE,
    DeviceName      NVARCHAR(200)   NOT NULL,
    SerialNumber    NVARCHAR(200)   NULL,
    OfficeId        INT          NULL,
    IpAddress       NVARCHAR(100)   NULL,    
    LastSyncAt      DATETIME2       NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL,

    CONSTRAINT FK_BiometricDevice_Office
        FOREIGN KEY (OfficeId)
        REFERENCES time.OfficeLocation(Id)
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

GO

PRINT 'Time schema created successfully';
GO