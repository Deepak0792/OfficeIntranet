-- EMPLOYEE SCHEMA - Core Employee Data
-- SQL Server Database Schema
-- Schema: employee
-- Purpose: Employee master data, organizational structure, teams, skills, documents
-- Dependencies: shared (StatusLookup), time (TimeZoneMaster, OfficeLocation, LegalEntity, Department, Designation, DocumentType, RelationshipType)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'employee')
BEGIN
    EXEC('CREATE SCHEMA employee');
END
GO

-- EMPLOYEE - Core employee profile
CREATE TABLE employee.Employee (
    Id                      INT             PRIMARY KEY IDENTITY(1,1),
    EmployeeCode            NVARCHAR(50)    NOT NULL UNIQUE,
    FirstName               NVARCHAR(100)   NOT NULL,
    LastName                NVARCHAR(100)   NULL,
    DisplayName             NVARCHAR(200)   NULL,
    Email                   NVARCHAR(255)   NOT NULL UNIQUE,
    MobileNumber            NVARCHAR(30)    NULL,
    DesignationId           SMALLINT          NULL,
    PreferredLanguage       NVARCHAR(20)    NULL,
    PreferredTimeZoneId     SMALLINT          NULL,
    DateOfJoining           DATE            NULL,
    EmploymentType          NVARCHAR(50)    NOT NULL DEFAULT 'FULL_TIME',
    EmploymentTypeGroup     AS CAST('EMPLOYMENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    AboutMe                 NVARCHAR(MAX)   NULL,
    ProfilePhotoUrl         NVARCHAR(1000)  NULL,
    IsSystemEmployee        BIT             NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_Employee_Designation
        FOREIGN KEY (DesignationId)
        REFERENCES time.Designation(Id),

    CONSTRAINT FK_Employee_TimeZoneMaster
        FOREIGN KEY (PreferredTimeZoneId)
        REFERENCES time.TimeZoneMaster(Id),

    CONSTRAINT FK_Employee_EmploymentType
        FOREIGN KEY (EmploymentType, EmploymentTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- EMPLOYEE LEGAL ENTITY
CREATE TABLE employee.EmployeeLegalEntity (
    Id              INT  PRIMARY KEY IDENTITY(1,1),
    EmployeeId      INT     NOT NULL,
    LegalEntityId   SMALLINT  NOT NULL,
    IsPrimary       BIT     NOT NULL DEFAULT 0,
    StartDate       DATE    NULL,
    EndDate         DATE    NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL,

    CONSTRAINT FK_ELE_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ELE_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES time.LegalEntity(Id)
);
GO

-- EMPLOYEE DEPARTMENT
CREATE TABLE employee.EmployeeDepartment (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT             NOT NULL,
    DepartmentId            SMALLINT          NOT NULL,
    IsPrimaryDepartment     BIT             NOT NULL DEFAULT 0,
    AllocationPercentage    DECIMAL(5,2)    NULL,
    StartDate               DATE            NULL,
    EndDate                 DATE            NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_EmployeeDepartment_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeDepartment_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id)
);
GO

-- EMPLOYEE LOCATION
CREATE TABLE employee.EmployeeLocation (
    Id                  INT  PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT  NOT NULL,
    LocationId          SMALLINT  NOT NULL,
    IsPrimaryLocation   BIT     NOT NULL DEFAULT 1,
    StartDate           DATE    NULL,
    EndDate             DATE    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_EmployeeLocation_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeLocation_Location
        FOREIGN KEY (LocationId)
        REFERENCES time.OfficeLocation(Id)
);
GO

-- EMPLOYEE RELATIONSHIP
CREATE TABLE employee.EmployeeRelationship (
    Id                      INT  PRIMARY KEY IDENTITY(1,1),
    ParentEmployeeId        INT  NOT NULL,
    ChildEmployeeId         INT  NOT NULL,
    RelationshipType        NVARCHAR(50)  NOT NULL,
    RelationshipTypeGroup   AS CAST('RELATIONSHIP_TYPE' AS NVARCHAR(50)) PERSISTED,
    DepartmentId            SMALLINT  NULL,
    IsPrimaryRelationship   BIT     NOT NULL DEFAULT 0,
    EffectiveFrom           DATE    NULL,
    EffectiveTo             DATE    NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_ER_ParentEmployee
        FOREIGN KEY (ParentEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ER_ChildEmployee
        FOREIGN KEY (ChildEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeRelationship_RelationshipType
        FOREIGN KEY (RelationshipType, RelationshipTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ER_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id)
);
GO

-- EMPLOYEE CONTACT
CREATE TABLE employee.EmployeeContact (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT          NOT NULL,
    ContactType         NVARCHAR(50)    NOT NULL,
    ContactTypeGroup    AS CAST('CONTACT_TYPE' AS NVARCHAR(50)) PERSISTED,
    ContactValue        NVARCHAR(500)   NOT NULL,
    IsPrimary           BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_EmployeeContact_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeContact_ContactType
        FOREIGN KEY (ContactType, ContactTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- EMPLOYEE DOCUMENT
CREATE TABLE employee.EmployeeDocument (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT          NOT NULL,
    DocumentTypeId          SMALLINT          NOT NULL,
    FileName                NVARCHAR(500)   NULL,
    OriginalFileName        NVARCHAR(500)   NULL,
    FileExtension           NVARCHAR(20)    NULL,
    MimeType                NVARCHAR(100)   NULL,
    FileSizeInBytes         INT          NULL,
    FileUrl                 NVARCHAR(1000)  NULL,
    DocumentNumber          NVARCHAR(200)   NULL,
    IssuedDate              DATE            NULL,
    ExpiryDate              DATE            NULL,
    Remarks                 NVARCHAR(1000)  NULL,
    UploadedAt              DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsVerified              BIT             NOT NULL DEFAULT 0,
    VerifiedByEmployeeId    INT          NULL,
    VerifiedAt              DATETIME2       NULL,
    WorkflowInstanceId      INT          NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_EmployeeDocument_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeDocument_DocumentType
        FOREIGN KEY (DocumentTypeId)
        REFERENCES time.DocumentType(Id),

    CONSTRAINT FK_EmployeeDocument_VerifiedBy
        FOREIGN KEY (VerifiedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeDocument_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
);
GO

-- SKILL
CREATE TABLE employee.Skill (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    SkillName       NVARCHAR(200)   NOT NULL UNIQUE,
    SkillCategory   NVARCHAR(100)   NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL
);
GO

-- EMPLOYEE SKILL
CREATE TABLE employee.EmployeeSkill (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT          NOT NULL,
    SkillId             SMALLINT          NOT NULL,
    SkillLevel          NVARCHAR(50)    NULL,
    YearsOfExperience   DECIMAL(5,2)    NULL,
    IsPrimarySkill      BIT             NOT NULL DEFAULT 0,
    LastUsedDate        DATE            NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_EmployeeSkill_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeSkill_Skill
        FOREIGN KEY (SkillId)
        REFERENCES employee.Skill(Id)
);
GO

-- TEAM
CREATE TABLE employee.Team (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    TeamCode        NVARCHAR(50)    NOT NULL UNIQUE,
    TeamName        NVARCHAR(200)   NOT NULL,
    TeamType        NVARCHAR(100)   NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL
);
GO

-- EMPLOYEE TEAM
CREATE TABLE employee.EmployeeTeam (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT          NOT NULL,
    TeamId                  SMALLINT          NOT NULL,
    RoleInTeam              NVARCHAR(100)   NULL,
    AllocationPercentage    DECIMAL(5,2)    NULL,
    StartDate               DATE            NULL,
    EndDate                 DATE            NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_EmployeeTeam_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeTeam_Team
        FOREIGN KEY (TeamId)
        REFERENCES employee.Team(Id)
);
GO

-- BIOMETRIC EMPLOYEE MAPPING
CREATE TABLE employee.BiometricEmployeeMapping (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT          NOT NULL,
    BiometricDeviceId   INT          NOT NULL,
    DeviceEmployeeCode  NVARCHAR(100)   NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_BiometricEmployeeMapping_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_BiometricEmployeeMapping_Device
        FOREIGN KEY (BiometricDeviceId)
        REFERENCES time.BiometricDevice(Id)
);
GO

-- EMPLOYEE ADDRESS
-- Purpose: Stores multiple address records per employee (permanent, current, emergency, etc.)
-- Dependencies: employee.Employee, time.Country, time.Region, shared.StatusLookup
-- ADDRESS TYPE must exist in shared.StatusLookup under group 'ADDRESS_TYPE'
-- Expected StatusCodes: PERMANENT, CURRENT, MAILING, EMERGENCY, WORK

CREATE TABLE employee.EmployeeAddress (
    Id                  INT             PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT             NOT NULL,
    AddressType         NVARCHAR(50)    NOT NULL,
    AddressTypeGroup    AS CAST('ADDRESS_TYPE' AS NVARCHAR(50)) PERSISTED,
    AddressLine1        NVARCHAR(500)   NOT NULL,
    AddressLine2        NVARCHAR(500)   NULL,
    Landmark            NVARCHAR(300)   NULL,
    City                NVARCHAR(100)   NOT NULL,
    StateProvince       NVARCHAR(100)   NULL,
    PostalCode          NVARCHAR(20)    NULL,
    CountryId           SMALLINT        NOT NULL,
    RegionId            SMALLINT        NULL,
    IsPrimary           BIT             NOT NULL DEFAULT 0,
    WorkflowInstanceId      INT          NULL,
    IsVerified          BIT             NOT NULL DEFAULT 0,
    VerifiedByEmployeeId INT            NULL,
    VerifiedAt          DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_EmployeeAddress_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeAddress_Country
        FOREIGN KEY (CountryId)
        REFERENCES time.Country(Id),

    CONSTRAINT FK_EmployeeAddress_Region
        FOREIGN KEY (RegionId)
        REFERENCES time.Region(Id),

    CONSTRAINT FK_EmployeeAddress_VerifiedBy
        FOREIGN KEY (VerifiedByEmployeeId)
        REFERENCES employee.Employee(Id),
    
    CONSTRAINT FK_EmployeeAddress_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_EmployeeAddress_AddressType
        FOREIGN KEY (AddressType, AddressTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE employee.OutboxMessages
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
    [CreatedBy] INT NULL,

    [LastUpdatedAt] DATETIME2 NOT NULL
        CONSTRAINT [DF_OutboxMessages_LastUpdatedAt] DEFAULT GETUTCDATE(),

    [LastUpdatedBy] INT NULL,

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

-- INDEXES - employee Schema
CREATE INDEX IX_Employee_Email             ON employee.Employee (Email);
CREATE INDEX IX_Employee_DisplayName       ON employee.Employee (DisplayName);
CREATE INDEX IX_Employee_Designation        ON employee.Employee (DesignationId);
CREATE INDEX IX_Employee_DateOfJoining      ON employee.Employee (DateOfJoining);

CREATE INDEX IX_EmployeeLegalEntity_Employee    ON employee.EmployeeLegalEntity (EmployeeId);
CREATE INDEX IX_EmployeeLegalEntity_LegalEntity ON employee.EmployeeLegalEntity (LegalEntityId);

CREATE INDEX IX_EmployeeDepartment_Employee    ON employee.EmployeeDepartment (EmployeeId);
CREATE INDEX IX_EmployeeDepartment_Department  ON employee.EmployeeDepartment (DepartmentId);

CREATE INDEX IX_EmployeeLocation_Employee      ON employee.EmployeeLocation (EmployeeId);
CREATE INDEX IX_EmployeeLocation_Location      ON employee.EmployeeLocation (LocationId);

CREATE INDEX IX_EmployeeRelationship_Parent    ON employee.EmployeeRelationship (ParentEmployeeId);
CREATE INDEX IX_EmployeeRelationship_Child     ON employee.EmployeeRelationship (ChildEmployeeId);

CREATE INDEX IX_EmployeeContact_Employee       ON employee.EmployeeContact (EmployeeId);
CREATE INDEX IX_EmployeeContact_Type            ON employee.EmployeeContact (ContactType);

CREATE INDEX IX_EmployeeDocument_Employee      ON employee.EmployeeDocument (EmployeeId);
CREATE INDEX IX_EmployeeDocument_DocumentType   ON employee.EmployeeDocument (DocumentTypeId);
CREATE INDEX IX_EmployeeDocument_ExpiryDate     ON employee.EmployeeDocument (ExpiryDate);
CREATE INDEX IX_EmployeeDocument_WorkflowInstance ON employee.EmployeeDocument (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_EmployeeDocument_WorkflowInstance
    ON employee.EmployeeDocument (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

CREATE INDEX IX_EmployeeSkill_Employee      ON employee.EmployeeSkill (EmployeeId);
CREATE INDEX IX_EmployeeSkill_Skill        ON employee.EmployeeSkill (SkillId);

CREATE INDEX IX_EmployeeTeam_Employee      ON employee.EmployeeTeam (EmployeeId);
CREATE INDEX IX_EmployeeTeam_Team          ON employee.EmployeeTeam (TeamId);

CREATE INDEX IX_BiometricEmployeeMapping_Employee ON employee.BiometricEmployeeMapping (EmployeeId, BiometricDeviceId);

CREATE INDEX IX_EmployeeAddress_Employee    ON employee.EmployeeAddress (EmployeeId);
CREATE INDEX IX_EmployeeAddress_Country     ON employee.EmployeeAddress (CountryId);
CREATE INDEX IX_EmployeeAddress_Region      ON employee.EmployeeAddress (RegionId);
CREATE INDEX IX_EmployeeAddress_AddressType ON employee.EmployeeAddress (AddressType);

-- Fast lookup for pending messages to publish
CREATE NONCLUSTERED INDEX [IX_OutboxMessages_Status_CreatedAt] ON [employee].[OutboxMessages] ([Status] ASC, [CreatedAt] ASC) INCLUDE ([Exchange], [RoutingKey], [RetryCount]);
-- Efficient retry processing
CREATE NONCLUSTERED INDEX [IX_OutboxMessages_Status_RetryCount] ON [employee].[OutboxMessages] ([Status] ASC, [RetryCount] ASC) INCLUDE ([CreatedAt]);
-- Query published history efficiently
CREATE NONCLUSTERED INDEX [IX_OutboxMessages_PublishedAt] ON [employee].[OutboxMessages] ([PublishedAt] ASC) WHERE [PublishedAt] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [UX_OutboxMessages_Id_Status] ON [employee].[OutboxMessages] ([Id], [Status]);


GO

-- Partial unique index: only one IsPrimary = 1 per employee
CREATE UNIQUE INDEX UIX_EmployeeAddress_PrimaryPerEmployee
    ON employee.EmployeeAddress (EmployeeId)
    WHERE IsPrimary = 1 AND IsActive = 1;
GO

-- VIEW - Employee Full Profile (for joins)
CREATE OR ALTER VIEW employee.vw_EmployeeFullProfile AS
SELECT
    e.Id                                     AS EmployeeId,
    e.EmployeeCode,
    e.FirstName,
    e.LastName,
    e.DisplayName,
    e.ProfilePhotoUrl,
    e.Email,
    e.MobileNumber,
    e.DateOfJoining,
    e.EmploymentType,
    e.IsActive,
    d.Id                                     AS DepartmentId,
    d.DepartmentName,
    dg.Id                                    AS DesignationId,
    dg.DesignationName,
    dg.Grade,
    loc.Id                                   AS LocationId,
    loc.LocationName,
    loc.City,
    le.LegalEntityId                         AS PrimaryLegalEntityId,
    ler.EntityName                           AS PrimaryLegalEntityName,
    mgr.Id                                   AS ManagerId,
    mgr.DisplayName                          AS ManagerName
FROM employee.Employee e
LEFT JOIN employee.EmployeeDepartment ed ON ed.EmployeeId = e.Id AND ed.IsPrimaryDepartment = 1 AND ed.IsActive = 1
LEFT JOIN time.Department d ON d.Id = ed.DepartmentId
LEFT JOIN time.Designation dg ON dg.Id = e.DesignationId
LEFT JOIN employee.EmployeeLocation el ON el.EmployeeId = e.Id AND el.IsPrimaryLocation = 1 AND el.IsActive = 1
LEFT JOIN time.OfficeLocation loc ON loc.Id = el.LocationId
LEFT JOIN employee.EmployeeLegalEntity le ON le.EmployeeId = e.Id AND le.IsPrimary = 1 AND le.IsActive = 1
LEFT JOIN time.LegalEntity ler ON ler.Id = le.LegalEntityId
LEFT JOIN employee.EmployeeRelationship er ON er.ChildEmployeeId = e.Id AND er.RelationshipType = 'DIRECT_MANAGER' AND er.IsPrimaryRelationship = 1 AND er.IsActive = 1
LEFT JOIN employee.Employee mgr ON mgr.Id = er.ParentEmployeeId;
GO

PRINT 'Employee schema created successfully';
GO