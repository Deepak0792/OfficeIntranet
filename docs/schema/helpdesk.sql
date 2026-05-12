-- =============================================================================================================
-- HELPDESK / IT SUPPORT MANAGEMENT
-- SQL SERVER DATABASE SCHEMA
-- Schema: helpdesk
-- =============================================================================================================
-- PURPOSE:
--   Enterprise-grade Helpdesk and IT Support module for office intranet systems.
--
--   Supports:
--      - Ticket lifecycle management
--      - SLA tracking and escalation
--      - IT asset & inventory management
--      - Laptop/device allocation
--      - Device lifecycle tracking
--      - Software license management
--      - Employee asset assignment
--      - Vendor management
--      - Audit and operational reporting
--
-- DESIGN PRINCIPLES:
--   - Reuses existing enterprise master tables
--   - Uses centralized dbo.StatusLookup table
--   - Fully normalized and scalable
--   - Enterprise auditability and reporting ready
--   - Supports lifecycle history tracking
--   - SQL Server optimized design
-- =============================================================================================================

-- =============================================================================================================
-- CREATE SCHEMA
-- =============================================================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'helpdesk'
)
BEGIN
    EXEC('CREATE SCHEMA helpdesk');
END
GO

-- =============================================================================================================
-- STATUS LOOKUP SEEDING
-- Centralized statuses replacing module-specific status tables
-- =============================================================================================================

PRINT 'Seeding Helpdesk StatusLookup values...';
GO

INSERT INTO dbo.StatusLookup
(
    StatusCode,
    StatusGroup,
    Label,
    Description,
    DisplayOrder,
    IsTerminal
)
VALUES

-- =====================================================================================
-- TICKET STATUS
-- =====================================================================================
('OPEN',               'HELPDESK_TICKET_STATUS',      'Open',                 'Newly created ticket',                         1, 0),
('ASSIGNED',           'HELPDESK_TICKET_STATUS',      'Assigned',             'Ticket assigned to support staff',             2, 0),
('IN_PROGRESS',        'HELPDESK_TICKET_STATUS',      'In Progress',          'Work is in progress',                          3, 0),
('ON_HOLD',            'HELPDESK_TICKET_STATUS',      'On Hold',              'Waiting for dependency or requester',          4, 0),
('RESOLVED',           'HELPDESK_TICKET_STATUS',      'Resolved',             'Issue resolved awaiting closure',              5, 0),
('CLOSED',             'HELPDESK_TICKET_STATUS',      'Closed',               'Ticket fully closed',                          6, 1),
('CANCELLED',          'HELPDESK_TICKET_STATUS',      'Cancelled',            'Ticket cancelled',                             7, 1),
('REOPENED',           'HELPDESK_TICKET_STATUS',      'Reopened',             'Previously closed ticket reopened',            8, 0),

-- =====================================================================================
-- TICKET PRIORITY
-- =====================================================================================
('LOW',                'HELPDESK_TICKET_PRIORITY',    'Low',                  'Low impact issue',                             1, 0),
('MEDIUM',             'HELPDESK_TICKET_PRIORITY',    'Medium',               'Moderate impact issue',                        2, 0),
('HIGH',               'HELPDESK_TICKET_PRIORITY',    'High',                 'High impact issue',                            3, 0),
('CRITICAL',           'HELPDESK_TICKET_PRIORITY',    'Critical',             'Business critical issue',                      4, 0),

-- =====================================================================================
-- ASSET STATUS
-- =====================================================================================
('AVAILABLE',          'HELPDESK_ASSET_STATUS',       'Available',            'Available for assignment',                     1, 0),
('ASSIGNED',           'HELPDESK_ASSET_STATUS',       'Assigned',             'Assigned to employee',                         2, 0),
('IN_REPAIR',          'HELPDESK_ASSET_STATUS',       'In Repair',            'Under maintenance or repair',                  3, 0),
('DAMAGED',            'HELPDESK_ASSET_STATUS',       'Damaged',              'Damaged asset',                                4, 0),
('LOST',               'HELPDESK_ASSET_STATUS',       'Lost',                 'Lost asset',                                   5, 1),
('DISPOSED',           'HELPDESK_ASSET_STATUS',       'Disposed',             'Disposed or retired asset',                    6, 1),

-- =====================================================================================
-- SOFTWARE LICENSE TYPE
-- =====================================================================================
('PER_USER',           'HELPDESK_LICENSE_TYPE',       'Per User',             'License allocated per user',                   1, 0),
('PER_DEVICE',         'HELPDESK_LICENSE_TYPE',       'Per Device',           'License allocated per device',                 2, 0),
('SITE_LICENSE',       'HELPDESK_LICENSE_TYPE',       'Site License',         'Organization wide license',                    3, 0),
('SUBSCRIPTION',       'HELPDESK_LICENSE_TYPE',       'Subscription',         'Recurring subscription license',               4, 0),
('TRIAL',              'HELPDESK_LICENSE_TYPE',       'Trial',                'Trial or evaluation license',                  5, 0);
GO

-- =============================================================================================================
-- MODULE 1: MASTER TABLES
-- =============================================================================================================

-- -------------------------------------------------------
-- TICKET CATEGORY
-- Defines hierarchical classifications for IT support
-- tickets such as Hardware, Software, Network, Access,
-- Security, Email, VPN, etc.
-- Supports parent-child category relationships.
-- -------------------------------------------------------
CREATE TABLE helpdesk.TicketCategory (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode        NVARCHAR(100)   NOT NULL UNIQUE,
    CategoryName        NVARCHAR(200)   NOT NULL,
    ParentCategoryId    BIGINT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TicketCategory_Parent
        FOREIGN KEY (ParentCategoryId)
        REFERENCES helpdesk.TicketCategory(Id)
);
GO

-- -------------------------------------------------------
-- SUPPORT GROUP
-- Defines internal IT support teams responsible for
-- handling tickets and operational ownership.
-- Examples:
--   - IT Infrastructure
--   - Application Support
--   - Network Team
--   - Security Operations
-- -------------------------------------------------------
CREATE TABLE helpdesk.SupportGroup (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    SupportGroupCode    NVARCHAR(100)   NOT NULL UNIQUE,
    SupportGroupName    NVARCHAR(200)   NOT NULL,
    DepartmentId        BIGINT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SupportGroup_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES Department(Id)
);
GO

-- -------------------------------------------------------
-- ASSET CATEGORY
-- Defines enterprise asset classifications used for
-- inventory and lifecycle management.
-- Examples:
--   - Laptop
--   - Desktop
--   - Monitor
--   - Mobile Device
--   - Printer
-- -------------------------------------------------------
CREATE TABLE helpdesk.AssetCategory (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode        NVARCHAR(100)   NOT NULL UNIQUE,
    CategoryName        NVARCHAR(200)   NOT NULL,
    ParentCategoryId    BIGINT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsTrackable         BIT             NOT NULL DEFAULT 1,
    IsConsumable        BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_AssetCategory_Parent
        FOREIGN KEY (ParentCategoryId)
        REFERENCES helpdesk.AssetCategory(Id)
);
GO

-- -------------------------------------------------------
-- VENDOR
-- Stores vendors and suppliers associated with IT assets,
-- hardware procurement, AMC providers, and software
-- licensing partners.
-- -------------------------------------------------------
CREATE TABLE helpdesk.Vendor (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
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

-- =============================================================================================================
-- MODULE 2: TICKET MANAGEMENT
-- =============================================================================================================

-- -------------------------------------------------------
-- TICKET
-- Core helpdesk support ticket entity representing issues,
-- service requests, incidents, and operational support
-- requests raised by employees.
--
-- TicketStatus references dbo.StatusLookup
-- (HELPDESK_TICKET_STATUS).
--
-- TicketPriority references dbo.StatusLookup
-- (HELPDESK_TICKET_PRIORITY).
-- -------------------------------------------------------
CREATE TABLE helpdesk.Ticket (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    TicketNumber                    NVARCHAR(50)    NOT NULL UNIQUE,
    RequesterEmployeeId             BIGINT          NOT NULL,
    RequestedForEmployeeId          BIGINT          NULL,
    TicketCategoryId                BIGINT          NOT NULL,
    TicketPriorityCode              NVARCHAR(50)    NOT NULL,
    TicketPriorityGroup AS CAST('HELPDESK_TICKET_PRIORITY' AS NVARCHAR(50)) PERSISTED,
    TicketStatusCode                NVARCHAR(50)    NOT NULL,
    TicketStatusGroup AS CAST('HELPDESK_TICKET_STATUS' AS NVARCHAR(50)) PERSISTED,
    SupportGroupId                  BIGINT          NULL,
    AssignedToEmployeeId            BIGINT          NULL,
    AssetId                         BIGINT          NULL,
    OfficeLocationId                BIGINT          NULL,
    Subject                         NVARCHAR(300)   NOT NULL,
    Description                     NVARCHAR(MAX)   NULL,
    OpenedAt                        DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    AssignedAt                      DATETIME2       NULL,
    ResolvedAt                      DATETIME2       NULL,
    ClosedAt                        DATETIME2       NULL,
    WorkflowInstanceId              BIGINT          NULL,
    IsReopened                      BIT             NOT NULL DEFAULT 0,
    ReopenedCount                   INT             NOT NULL DEFAULT 0,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                       DATETIME2       NULL,

    CONSTRAINT FK_Ticket_Requester
        FOREIGN KEY (RequesterEmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_Ticket_RequestedFor
        FOREIGN KEY (RequestedForEmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_Ticket_Category
        FOREIGN KEY (TicketCategoryId)
        REFERENCES helpdesk.TicketCategory(Id),

    CONSTRAINT FK_Ticket_SupportGroup
        FOREIGN KEY (SupportGroupId)
        REFERENCES helpdesk.SupportGroup(Id),

    CONSTRAINT FK_Ticket_AssignedTo
        FOREIGN KEY (AssignedToEmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_Ticket_OfficeLocation
        FOREIGN KEY (OfficeLocationId)
        REFERENCES OfficeLocation(Id),

    CONSTRAINT FK_Ticket_Priority
        FOREIGN KEY (TicketPriorityCode, TicketPriorityGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_Ticket_Status
        FOREIGN KEY (TicketStatusCode, TicketStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);
GO

-- -------------------------------------------------------
-- TICKET COMMENT
-- Stores ticket communication history, troubleshooting
-- discussions, updates, and internal support notes.
--
-- Internal comments are visible only to support teams.
-- -------------------------------------------------------
CREATE TABLE helpdesk.TicketComment (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    TicketId            BIGINT          NOT NULL,
    CommentedBy         BIGINT          NOT NULL,
    CommentText         NVARCHAR(MAX)   NOT NULL,
    IsInternalComment   BIT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TicketComment_Ticket
        FOREIGN KEY (TicketId)
        REFERENCES helpdesk.Ticket(Id),

    CONSTRAINT FK_TicketComment_Employee
        FOREIGN KEY (CommentedBy)
        REFERENCES Employee(Id)
);
GO

-- -------------------------------------------------------
-- TICKET ATTACHMENT
-- Stores documents, screenshots, logs, and evidence files
-- uploaded as part of ticket troubleshooting and support
-- communication.
-- -------------------------------------------------------
CREATE TABLE helpdesk.TicketAttachment (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    TicketId            BIGINT          NOT NULL,
    UploadedBy          BIGINT          NOT NULL,
    FileName            NVARCHAR(500)   NOT NULL,
    OriginalFileName    NVARCHAR(500)   NULL,
    FileExtension       NVARCHAR(20)    NULL,
    MimeType            NVARCHAR(100)   NULL,
    FileSizeInBytes     BIGINT          NULL,
    FileUrl             NVARCHAR(1000)  NOT NULL,
    UploadedAt          DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_TicketAttachment_Ticket
        FOREIGN KEY (TicketId)
        REFERENCES helpdesk.Ticket(Id),

    CONSTRAINT FK_TicketAttachment_Employee
        FOREIGN KEY (UploadedBy)
        REFERENCES Employee(Id)
);
GO

-- =============================================================================================================
-- MODULE 3: SLA MANAGEMENT
-- =============================================================================================================

-- -------------------------------------------------------
-- SLA POLICY
-- Defines SLA timelines and escalation thresholds used
-- for support ticket response and resolution tracking.
--
-- TicketPriority references dbo.StatusLookup
-- (HELPDESK_TICKET_PRIORITY).
-- -------------------------------------------------------
CREATE TABLE helpdesk.SlaPolicy (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyCode                      NVARCHAR(100)   NOT NULL UNIQUE,
    PolicyName                      NVARCHAR(200)   NOT NULL,
    TicketPriorityCode              NVARCHAR(50)    NOT NULL,
    TicketPriorityGroup AS CAST('HELPDESK_TICKET_PRIORITY' AS NVARCHAR(50)) PERSISTED,
    ResponseTimeMinutes             INT             NOT NULL,
    ResolutionTimeMinutes           INT             NOT NULL,
    EscalationTimeMinutes           INT             NULL,
    IsActive                        BIT             NOT NULL DEFAULT 1,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SlaPolicy_Priority
        FOREIGN KEY (TicketPriorityCode, TicketPriorityGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);
GO

-- -------------------------------------------------------
-- TICKET SLA TRACKING
-- Tracks SLA compliance and breach calculations for
-- support tickets including response and resolution
-- deadlines.
-- -------------------------------------------------------
CREATE TABLE helpdesk.TicketSlaTracking (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    TicketId                        BIGINT          NOT NULL,
    SlaPolicyId                     BIGINT          NOT NULL,
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

-- =============================================================================================================
-- MODULE 4: ASSET & DEVICE MANAGEMENT
-- =============================================================================================================

-- -------------------------------------------------------
-- ASSET
-- Central inventory table storing enterprise IT assets,
-- hardware devices, and trackable infrastructure items.
--
-- AssetStatus references dbo.StatusLookup
-- (HELPDESK_ASSET_STATUS).
-- -------------------------------------------------------
CREATE TABLE helpdesk.Asset (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    AssetCode                       NVARCHAR(100)   NOT NULL UNIQUE,
    AssetTag                        NVARCHAR(100)   NULL UNIQUE,
    AssetName                       NVARCHAR(300)   NOT NULL,
    AssetCategoryId                 BIGINT          NOT NULL,
    AssetStatusCode                 NVARCHAR(50)    NOT NULL,
    AssetStatusGroup AS CAST('HELPDESK_ASSET_STATUS' AS NVARCHAR(50)) PERSISTED,
    VendorId                        BIGINT          NULL,
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
    OfficeLocationId                BIGINT          NULL,
    CurrentEmployeeId               BIGINT          NULL,
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
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_Asset_Vendor
        FOREIGN KEY (VendorId)
        REFERENCES helpdesk.Vendor(Id),

    CONSTRAINT FK_Asset_OfficeLocation
        FOREIGN KEY (OfficeLocationId)
        REFERENCES OfficeLocation(Id),

    CONSTRAINT FK_Asset_CurrentEmployee
        FOREIGN KEY (CurrentEmployeeId)
        REFERENCES Employee(Id)
);
GO

-- -------------------------------------------------------
-- ASSET ASSIGNMENT
-- Tracks employee-wise asset allocation history including
-- issue date, return date, and return condition for
-- laptops, monitors, and devices.
-- -------------------------------------------------------
CREATE TABLE helpdesk.AssetAssignment (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    AssetId                         BIGINT          NOT NULL,
    EmployeeId                      BIGINT          NOT NULL,
    AssignedByEmployeeId            BIGINT          NOT NULL,
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
        REFERENCES Employee(Id),

    CONSTRAINT FK_AssetAssignment_AssignedBy
        FOREIGN KEY (AssignedByEmployeeId)
        REFERENCES Employee(Id)
);
GO

-- -------------------------------------------------------
-- ASSET MAINTENANCE
-- Stores repair, AMC, preventive maintenance, servicing,
-- and operational maintenance records for enterprise
-- hardware assets and devices.
-- -------------------------------------------------------
CREATE TABLE helpdesk.AssetMaintenance (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    AssetId                         BIGINT          NOT NULL,
    VendorId                        BIGINT          NULL,
    MaintenanceDate                 DATE            NOT NULL,
    MaintenanceType                 NVARCHAR(100)   NULL,
    CostAmount                      DECIMAL(18,2)   NULL,
    Description                     NVARCHAR(1000)  NULL,
    NextMaintenanceDate             DATE            NULL,
    CreatedByEmployeeId             BIGINT          NULL,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AssetMaintenance_Asset
        FOREIGN KEY (AssetId)
        REFERENCES helpdesk.Asset(Id),

    CONSTRAINT FK_AssetMaintenance_Vendor
        FOREIGN KEY (VendorId)
        REFERENCES helpdesk.Vendor(Id),

    CONSTRAINT FK_AssetMaintenance_Employee
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES Employee(Id)
);
GO

-- =============================================================================================================
-- MODULE 5: SOFTWARE LICENSE MANAGEMENT
-- =============================================================================================================

-- -------------------------------------------------------
-- SOFTWARE PRODUCT
-- Stores enterprise software catalog including operating
-- systems, licensed applications, productivity tools,
-- antivirus solutions, and SaaS subscriptions.
--
-- LicenseType references dbo.StatusLookup
-- (HELPDESK_LICENSE_TYPE).
-- -------------------------------------------------------
CREATE TABLE helpdesk.SoftwareProduct (
    Id                                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    SoftwareCode                        NVARCHAR(100)   NOT NULL UNIQUE,
    SoftwareName                        NVARCHAR(300)   NOT NULL,
    VersionNumber                       NVARCHAR(100)   NULL,
    VendorId                            BIGINT          NULL,
    LicenseTypeCode                     NVARCHAR(50)    NOT NULL,
    LicenseTypeGroup AS CAST('HELPDESK_LICENSE_TYPE' AS NVARCHAR(50)) PERSISTED,
    Description                         NVARCHAR(1000)  NULL,
    IsActive                            BIT             NOT NULL DEFAULT 1,
    CreatedAt                           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_SoftwareProduct_Vendor
        FOREIGN KEY (VendorId)
        REFERENCES helpdesk.Vendor(Id),

    CONSTRAINT FK_SoftwareProduct_LicenseType
        FOREIGN KEY (LicenseTypeCode, LicenseTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);
GO

-- -------------------------------------------------------
-- SOFTWARE LICENSE
-- Stores purchased software licenses including license
-- keys, subscription details, renewal configuration,
-- utilization count, and validity tracking.
-- -------------------------------------------------------
CREATE TABLE helpdesk.SoftwareLicense (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    SoftwareProductId               BIGINT          NOT NULL,
    LicenseKey                      NVARCHAR(500)   NULL,
    LicenseCount                    INT             NOT NULL DEFAULT 1,
    UsedLicenseCount                INT             NOT NULL DEFAULT 0,
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

-- -------------------------------------------------------
-- SOFTWARE INSTALLATION
-- Tracks software deployment and installation history on
-- enterprise assets and devices along with employee usage
-- allocation and uninstall lifecycle.
-- -------------------------------------------------------
CREATE TABLE helpdesk.SoftwareInstallation (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    SoftwareLicenseId               BIGINT          NOT NULL,
    AssetId                         BIGINT          NOT NULL,
    InstalledForEmployeeId          BIGINT          NULL,
    InstalledByEmployeeId           BIGINT          NULL,
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
        REFERENCES Employee(Id),

    CONSTRAINT FK_SoftwareInstallation_InstalledBy
        FOREIGN KEY (InstalledByEmployeeId)
        REFERENCES Employee(Id)
);
GO

-- =============================================================================================================
-- INDEXES
-- =============================================================================================================

-- =====================================================================================
-- TICKET
-- =====================================================================================

CREATE INDEX IX_Ticket_Requester
    ON helpdesk.Ticket (RequesterEmployeeId);

CREATE INDEX IX_Ticket_AssignedTo
    ON helpdesk.Ticket (AssignedToEmployeeId);

CREATE INDEX IX_Ticket_Status
    ON helpdesk.Ticket (TicketStatusCode);

CREATE INDEX IX_Ticket_Category
    ON helpdesk.Ticket (TicketCategoryId);

CREATE INDEX IX_Ticket_Priority
    ON helpdesk.Ticket (TicketPriorityCode);

CREATE INDEX IX_Ticket_OpenedAt
    ON helpdesk.Ticket (OpenedAt);

-- =====================================================================================
-- TICKET COMMENT
-- =====================================================================================

CREATE INDEX IX_TicketComment_Ticket
    ON helpdesk.TicketComment (TicketId, CreatedAt);

-- =====================================================================================
-- SLA
-- =====================================================================================

CREATE INDEX IX_TicketSlaTracking_Ticket
    ON helpdesk.TicketSlaTracking (TicketId);

CREATE INDEX IX_TicketSlaTracking_ResponseDue
    ON helpdesk.TicketSlaTracking (ResponseDueAt);

CREATE INDEX IX_TicketSlaTracking_ResolutionDue
    ON helpdesk.TicketSlaTracking (ResolutionDueAt);

-- =====================================================================================
-- ASSET
-- =====================================================================================

CREATE INDEX IX_Asset_Category
    ON helpdesk.Asset (AssetCategoryId);

CREATE INDEX IX_Asset_Status
    ON helpdesk.Asset (AssetStatusCode);

CREATE INDEX IX_Asset_CurrentEmployee
    ON helpdesk.Asset (CurrentEmployeeId);

CREATE INDEX IX_Asset_OfficeLocation
    ON helpdesk.Asset (OfficeLocationId);

CREATE INDEX IX_Asset_SerialNumber
    ON helpdesk.Asset (SerialNumber);

CREATE INDEX IX_Asset_HostName
    ON helpdesk.Asset (HostName);

-- =====================================================================================
-- ASSET ASSIGNMENT
-- =====================================================================================

CREATE INDEX IX_AssetAssignment_Employee
    ON helpdesk.AssetAssignment (EmployeeId);

CREATE INDEX IX_AssetAssignment_Asset
    ON helpdesk.AssetAssignment (AssetId);

CREATE INDEX IX_AssetAssignment_Active
    ON helpdesk.AssetAssignment (IsActiveAssignment);

-- =====================================================================================
-- ASSET MAINTENANCE
-- =====================================================================================

CREATE INDEX IX_AssetMaintenance_Asset
    ON helpdesk.AssetMaintenance (AssetId);

-- =====================================================================================
-- SOFTWARE
-- =====================================================================================

CREATE INDEX IX_SoftwareProduct_Name
    ON helpdesk.SoftwareProduct (SoftwareName);

CREATE INDEX IX_SoftwareLicense_Product
    ON helpdesk.SoftwareLicense (SoftwareProductId);

CREATE INDEX IX_SoftwareLicense_Expiry
    ON helpdesk.SoftwareLicense (ExpiryDate);

CREATE INDEX IX_SoftwareInstallation_Asset
    ON helpdesk.SoftwareInstallation (AssetId);

CREATE INDEX IX_SoftwareInstallation_Employee
    ON helpdesk.SoftwareInstallation (InstalledForEmployeeId);

GO