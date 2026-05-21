-- HELPDESK SCHEMA - IT Support & Asset Management
-- SQL Server Database Schema
-- Schema: helpdesk
-- Purpose: Ticket management, SLA tracking, asset inventory, software licensing
-- Dependencies: shared (StatusLookup), employee (Employee), time (OfficeLocation, ScopeType)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'helpdesk')
BEGIN
    EXEC('CREATE SCHEMA helpdesk');
END
GO

-- MODULE 1: MASTER TABLES
CREATE TABLE helpdesk.TicketCategory (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode        NVARCHAR(100)   NOT NULL UNIQUE,
    CategoryName        NVARCHAR(200)   NOT NULL,
    ParentCategoryId    SMALLINT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TicketCategory_Parent
        FOREIGN KEY (ParentCategoryId)
        REFERENCES helpdesk.TicketCategory(Id)
);
GO

CREATE TABLE helpdesk.SupportGroup (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    SupportGroupCode    NVARCHAR(100)   NOT NULL UNIQUE,
    SupportGroupName    NVARCHAR(200)   NOT NULL,
    DepartmentId        SMALLINT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SupportGroup_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id)
);
GO

CREATE TABLE helpdesk.AssetCategory (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode        NVARCHAR(100)   NOT NULL UNIQUE,
    CategoryName        NVARCHAR(200)   NOT NULL,
    ParentCategoryId    SMALLINT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsTrackable         BIT             NOT NULL DEFAULT 1,
    IsConsumable        BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_AssetCategory_Parent
        FOREIGN KEY (ParentCategoryId)
        REFERENCES helpdesk.AssetCategory(Id)
);
GO

CREATE TABLE helpdesk.Vendor (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    VendorCode          NVARCHAR(100)   NOT NULL UNIQUE,
    VendorName          NVARCHAR(300)   NOT NULL,
    ContactPerson       NVARCHAR(200)   NULL,
    Email               NVARCHAR(255)   NULL,
    MobileNumber        NVARCHAR(50)    NULL,
    WebsiteUrl          NVARCHAR(500)   NULL,
    Address             NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);
GO

-- MODULE 2: TICKET MANAGEMENT
CREATE TABLE helpdesk.Ticket (
    Id                              INT          PRIMARY KEY IDENTITY(1,1),
    TicketNumber                    NVARCHAR(50)    NOT NULL UNIQUE,
    RequesterEmployeeId             INT          NOT NULL,
    RequestedForEmployeeId          INT          NULL,
    TicketCategoryId                SMALLINT          NOT NULL,
    TicketPriorityCode              NVARCHAR(50)    NOT NULL,
    TicketPriorityGroup             AS CAST('HELPDESK_TICKET_PRIORITY' AS NVARCHAR(50)) PERSISTED,
    TicketStatusCode                NVARCHAR(50)    NOT NULL,
    TicketStatusGroup               AS CAST('HELPDESK_TICKET_STATUS' AS NVARCHAR(50)) PERSISTED,
    SupportGroupId                  SMALLINT          NULL,
    AssignedToEmployeeId            INT          NULL,
    AssetId                         INT          NULL,
    OfficeLocationId                SMALLINT          NULL,
    Subject                         NVARCHAR(300)   NOT NULL,
    Description                     NVARCHAR(MAX)  NULL,
    OpenedAt                        DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    AssignedAt                      DATETIME2       NULL,
    ResolvedAt                      DATETIME2       NULL,
    ClosedAt                        DATETIME2       NULL,
    WorkflowInstanceId              INT          NULL,
    IsReopened                      BIT             NOT NULL DEFAULT 0,
    ReopenedCount                   SMALLINT             NOT NULL DEFAULT 0,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                       DATETIME2       NULL,

    CONSTRAINT FK_Ticket_Requester
        FOREIGN KEY (RequesterEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Ticket_RequestedFor
        FOREIGN KEY (RequestedForEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Ticket_Category
        FOREIGN KEY (TicketCategoryId)
        REFERENCES helpdesk.TicketCategory(Id),

    CONSTRAINT FK_Ticket_SupportGroup
        FOREIGN KEY (SupportGroupId)
        REFERENCES helpdesk.SupportGroup(Id),

    CONSTRAINT FK_Ticket_AssignedTo
        FOREIGN KEY (AssignedToEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Ticket_OfficeLocation
        FOREIGN KEY (OfficeLocationId)
        REFERENCES time.OfficeLocation(Id),

    CONSTRAINT FK_Ticket_Priority
        FOREIGN KEY (TicketPriorityCode, TicketPriorityGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_Ticket_Status
        FOREIGN KEY (TicketStatusCode, TicketStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE helpdesk.TicketComment (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    TicketId            INT          NOT NULL,
    CommentedBy         INT          NOT NULL,
    CommentText         NVARCHAR(MAX)   NOT NULL,
    IsInternalComment   BIT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TicketComment_Ticket
        FOREIGN KEY (TicketId)
        REFERENCES helpdesk.Ticket(Id),

    CONSTRAINT FK_TicketComment_Employee
        FOREIGN KEY (CommentedBy)
        REFERENCES employee.Employee(Id)
);
GO

CREATE TABLE helpdesk.TicketAttachment (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    TicketId            INT          NOT NULL,
    UploadedBy          INT          NOT NULL,
    FileName            NVARCHAR(500)   NOT NULL,
    OriginalFileName    NVARCHAR(500)   NULL,
    FileExtension       NVARCHAR(20)    NULL,
    MimeType            NVARCHAR(100)   NULL,
    FileSizeInBytes     INT          NULL,
    FileUrl             NVARCHAR(1000)  NOT NULL,
    UploadedAt          DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TicketAttachment_Ticket
        FOREIGN KEY (TicketId)
        REFERENCES helpdesk.Ticket(Id),

    CONSTRAINT FK_TicketAttachment_Employee
        FOREIGN KEY (UploadedBy)
        REFERENCES employee.Employee(Id)
);
GO

-- MODULE 3: SLA MANAGEMENT
CREATE TABLE helpdesk.SlaPolicy (
    Id                              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    PolicyCode                      NVARCHAR(100)   NOT NULL UNIQUE,
    PolicyName                      NVARCHAR(200)   NOT NULL,
    TicketPriorityCode              NVARCHAR(50)    NOT NULL,
    TicketPriorityGroup             AS CAST('HELPDESK_TICKET_PRIORITY' AS NVARCHAR(50)) PERSISTED,
    ResponseTimeMinutes             SMALLINT             NOT NULL,
    ResolutionTimeMinutes           SMALLINT             NOT NULL,
    EscalationTimeMinutes           SMALLINT             NULL,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SlaPolicy_Priority
        FOREIGN KEY (TicketPriorityCode, TicketPriorityGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE helpdesk.TicketSlaTracking (
    Id                              INT          PRIMARY KEY IDENTITY(1,1),
    TicketId                        INT          NOT NULL,
    SlaPolicyId                     SMALLINT          NOT NULL,
    ResponseDueAt                   DATETIME2       NULL,
    ResolutionDueAt                 DATETIME2       NULL,
    FirstResponseAt                 DATETIME2       NULL,
    ResolvedAt                      DATETIME2       NULL,
    IsResponseBreached              BIT             NOT NULL DEFAULT 0,
    IsResolutionBreached            BIT             NOT NULL DEFAULT 0,
    BreachRemarks                   NVARCHAR(1000)  NULL,
    LastEvaluatedAt                 DATETIME2       NULL,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TicketSlaTracking_Ticket
        FOREIGN KEY (TicketId)
        REFERENCES helpdesk.Ticket(Id),

    CONSTRAINT FK_TicketSlaTracking_Policy
        FOREIGN KEY (SlaPolicyId)
        REFERENCES helpdesk.SlaPolicy(Id),

    CONSTRAINT UQ_TicketSlaTracking_Ticket
        UNIQUE (TicketId)
);
GO

-- MODULE 4: ASSET & DEVICE MANAGEMENT
CREATE TABLE helpdesk.Asset (
    Id                              INT          PRIMARY KEY IDENTITY(1,1),
    AssetCode                       NVARCHAR(100)   NOT NULL UNIQUE,
    AssetTag                        NVARCHAR(100)   NULL UNIQUE,
    AssetName                       NVARCHAR(300)   NOT NULL,
    AssetCategoryId                 SMALLINT          NOT NULL,
    AssetStatusCode                 NVARCHAR(50)    NOT NULL,
    AssetStatusGroup                AS CAST('HELPDESK_ASSET_STATUS' AS NVARCHAR(50)) PERSISTED,
    VendorId                        SMALLINT          NULL,
    SerialNumber                    NVARCHAR(200)   NULL,
    ModelNumber                     NVARCHAR(200)   NULL,
    Manufacturer                    NVARCHAR(200)   NULL,
    OperatingSystem                 NVARCHAR(200)   NULL,
    MacAddress                      NVARCHAR(100)   NULL,
    IpAddress                       NVARCHAR(100)   NULL,
    HostName                        NVARCHAR(200)   NULL,
    PurchaseDate                    DATE            NULL,
    WarrantyExpiryDate              DATE            NULL,
    PurchaseCost                    DECIMAL(18,2)   NULL,
    CurrentBookValue                DECIMAL(18,2)   NULL,
    OfficeLocationId                SMALLINT          NULL,
    CurrentEmployeeId               INT          NULL,
    Description                     NVARCHAR(1000)  NULL,
    LastAuditDate                   DATE            NULL,
    NextAuditDate                   DATE            NULL,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                       DATETIME2       NULL,

    CONSTRAINT FK_Asset_Category
        FOREIGN KEY (AssetCategoryId)
        REFERENCES helpdesk.AssetCategory(Id),

    CONSTRAINT FK_Asset_Status
        FOREIGN KEY (AssetStatusCode, AssetStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_Asset_Vendor
        FOREIGN KEY (VendorId)
        REFERENCES helpdesk.Vendor(Id),

    CONSTRAINT FK_Asset_OfficeLocation
        FOREIGN KEY (OfficeLocationId)
        REFERENCES time.OfficeLocation(Id),

    CONSTRAINT FK_Asset_CurrentEmployee
        FOREIGN KEY (CurrentEmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

CREATE TABLE helpdesk.AssetAssignment (
    Id                              INT          PRIMARY KEY IDENTITY(1,1),
    AssetId                         INT          NOT NULL,
    EmployeeId                      INT          NOT NULL,
    AssignedByEmployeeId            INT          NOT NULL,
    AssignedDate                    DATETIME2       NOT NULL,
    ExpectedReturnDate              DATE            NULL,
    ReturnedDate                    DATETIME2       NULL,
    ReturnCondition                 NVARCHAR(500)   NULL,
    Remarks                         NVARCHAR(1000)  NULL,
    IsActiveAssignment              BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AssetAssignment_Asset
        FOREIGN KEY (AssetId)
        REFERENCES helpdesk.Asset(Id),

    CONSTRAINT FK_AssetAssignment_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_AssetAssignment_AssignedBy
        FOREIGN KEY (AssignedByEmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

CREATE TABLE helpdesk.AssetMaintenance (
    Id                              INT          PRIMARY KEY IDENTITY(1,1),
    AssetId                         INT          NOT NULL,
    VendorId                        SMALLINT          NULL,
    MaintenanceDate                 DATE            NOT NULL,
    MaintenanceType                 NVARCHAR(100)   NULL,
    CostAmount                      DECIMAL(18,2)   NULL,
    Description                     NVARCHAR(1000)  NULL,
    NextMaintenanceDate             DATE            NULL,
    CreatedByEmployeeId             INT          NULL,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AssetMaintenance_Asset
        FOREIGN KEY (AssetId)
        REFERENCES helpdesk.Asset(Id),

    CONSTRAINT FK_AssetMaintenance_Vendor
        FOREIGN KEY (VendorId)
        REFERENCES helpdesk.Vendor(Id),

    CONSTRAINT FK_AssetMaintenance_Employee
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

-- MODULE 5: SOFTWARE LICENSE MANAGEMENT
CREATE TABLE helpdesk.SoftwareProduct (
    Id                                  INT          PRIMARY KEY IDENTITY(1,1),
    SoftwareCode                        NVARCHAR(100)   NOT NULL UNIQUE,
    SoftwareName                        NVARCHAR(300)   NOT NULL,
    VersionNumber                       NVARCHAR(100)   NULL,
    VendorId                            SMALLINT          NULL,
    LicenseTypeCode                     NVARCHAR(50)    NOT NULL,
    LicenseTypeGroup                    AS CAST('HELPDESK_LICENSE_TYPE' AS NVARCHAR(50)) PERSISTED,
    Description                         NVARCHAR(1000)  NULL,
    IsActive                            BIT             NOT NULL DEFAULT 1,
    CreatedAt                           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SoftwareProduct_Vendor
        FOREIGN KEY (VendorId)
        REFERENCES helpdesk.Vendor(Id),

    CONSTRAINT FK_SoftwareProduct_LicenseType
        FOREIGN KEY (LicenseTypeCode, LicenseTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE helpdesk.SoftwareLicense (
    Id                              INT          PRIMARY KEY IDENTITY(1,1),
    SoftwareProductId               INT          NOT NULL,
    LicenseKey                      NVARCHAR(500)   NULL,
    LicenseCount                    SMALLINT             NOT NULL DEFAULT 1,
    UsedLicenseCount                SMALLINT             NOT NULL DEFAULT 0,
    PurchaseDate                    DATE            NULL,
    ExpiryDate                      DATE            NULL,
    PurchaseCost                    DECIMAL(18,2)   NULL,
    IsSubscription                  BIT             NOT NULL DEFAULT 0,
    AutoRenewalEnabled              BIT             NOT NULL DEFAULT 0,
    Remarks                         NVARCHAR(1000)  NULL,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SoftwareLicense_Product
        FOREIGN KEY (SoftwareProductId)
        REFERENCES helpdesk.SoftwareProduct(Id),

    CONSTRAINT CK_SoftwareLicense_Count
        CHECK (UsedLicenseCount <= LicenseCount)
);
GO

CREATE TABLE helpdesk.SoftwareInstallation (
    Id                              INT          PRIMARY KEY IDENTITY(1,1),
    SoftwareLicenseId               INT          NOT NULL,
    AssetId                         INT          NOT NULL,
    InstalledForEmployeeId          INT          NULL,
    InstalledByEmployeeId          INT          NULL,
    InstalledDate                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UninstalledDate                 DATETIME2       NULL,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    Remarks                         NVARCHAR(1000)  NULL,

    CONSTRAINT FK_SoftwareInstallation_License
        FOREIGN KEY (SoftwareLicenseId)
        REFERENCES helpdesk.SoftwareLicense(Id),

    CONSTRAINT FK_SoftwareInstallation_Asset
        FOREIGN KEY (AssetId)
        REFERENCES helpdesk.Asset(Id),

    CONSTRAINT FK_SoftwareInstallation_Employee
        FOREIGN KEY (InstalledForEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_SoftwareInstallation_InstalledBy
        FOREIGN KEY (InstalledByEmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

-- INDEXES - helpdesk Schema
CREATE INDEX IX_Ticket_Requester         ON helpdesk.Ticket (RequesterEmployeeId);
CREATE INDEX IX_Ticket_AssignedTo        ON helpdesk.Ticket (AssignedToEmployeeId);
CREATE INDEX IX_Ticket_Status            ON helpdesk.Ticket (TicketStatusCode);
CREATE INDEX IX_Ticket_Category          ON helpdesk.Ticket (TicketCategoryId);
CREATE INDEX IX_Ticket_Priority          ON helpdesk.Ticket (TicketPriorityCode);
CREATE INDEX IX_Ticket_OpenedAt           ON helpdesk.Ticket (OpenedAt);

CREATE INDEX IX_TicketComment_Ticket      ON helpdesk.TicketComment (TicketId, CreatedAt);

CREATE INDEX IX_TicketSlaTracking_Ticket  ON helpdesk.TicketSlaTracking (TicketId);
CREATE INDEX IX_TicketSlaTracking_ResponseDue ON helpdesk.TicketSlaTracking (ResponseDueAt);
CREATE INDEX IX_TicketSlaTracking_ResolutionDue ON helpdesk.TicketSlaTracking (ResolutionDueAt);

CREATE INDEX IX_Asset_Category            ON helpdesk.Asset (AssetCategoryId);
CREATE INDEX IX_Asset_Status             ON helpdesk.Asset (AssetStatusCode);
CREATE INDEX IX_Asset_CurrentEmployee    ON helpdesk.Asset (CurrentEmployeeId);
CREATE INDEX IX_Asset_OfficeLocation     ON helpdesk.Asset (OfficeLocationId);
CREATE INDEX IX_Asset_SerialNumber        ON helpdesk.Asset (SerialNumber);
CREATE INDEX IX_Asset_HostName            ON helpdesk.Asset (HostName);

CREATE INDEX IX_AssetAssignment_Employee  ON helpdesk.AssetAssignment (EmployeeId);
CREATE INDEX IX_AssetAssignment_Asset     ON helpdesk.AssetAssignment (AssetId);
CREATE INDEX IX_AssetAssignment_Active    ON helpdesk.AssetAssignment (IsActiveAssignment);

CREATE INDEX IX_AssetMaintenance_Asset    ON helpdesk.AssetMaintenance (AssetId);

CREATE INDEX IX_SoftwareProduct_Name      ON helpdesk.SoftwareProduct (SoftwareName);
CREATE INDEX IX_SoftwareLicense_Product   ON helpdesk.SoftwareLicense (SoftwareProductId);
CREATE INDEX IX_SoftwareLicense_Expiry    ON helpdesk.SoftwareLicense (ExpiryDate);

CREATE INDEX IX_SoftwareInstallation_Asset    ON helpdesk.SoftwareInstallation (AssetId);
CREATE INDEX IX_SoftwareInstallation_Employee ON helpdesk.SoftwareInstallation (InstalledForEmployeeId);
GO

PRINT 'Helpdesk schema created successfully';
GO