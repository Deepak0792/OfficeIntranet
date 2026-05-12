=============================================================================================================
-- ENTERPRISE HRMS / EMPLOYEE DIRECTORY - GLOBAL HR PLATFORM
-- ENTERPRISE DYNAMIC APPROVAL WORKFLOW ENGINE
-- SQL SERVER DATABASE SCHEMA — COMPLETE MERGED OUTPUT
-- =============================================================================================================
-- MODULES:
--   ── dbo SCHEMA ──────────────────────────────────────────────────────────────────────────────────────────
--    1. Master Data         : StatusLookup, Designation, TimeZoneMaster, Country, LegalEntity, Region,
--                             OfficeLocation, Department, RelationshipType, DocumentType
--    2. Employee Core       : Employee, EmployeeLegalEntity, EmployeeDepartment, EmployeeLocation,
--                             EmployeeRelationship, EmployeeContact, EmployeeSkill, EmployeeDocument
--    3. Team & Skill        : Team, EmployeeTeam, Skill
--    4. Organization Scope  : ScopeType
--    5. Work Week Policy    : WorkWeekPolicy, WorkWeekPolicyDay, WorkWeekPolicyAssignment
--    6. Shift Management    : Shift, ShiftAssignment, ShiftSwapStatus, ShiftSwapRequest
--    7. Rotation Shift      : RotationShift, RotationShiftDetail, RotationShiftAssignment
--    8. Employee Roster     : EmployeeShiftRoster
--    9. Holiday Management  : HolidayCalendar, HolidayType, Holiday, HolidayCalendarAssignment
--   10. Attendance          : AttendanceStatus, AttendanceRecord, AttendanceLog,
--                             AttendanceRegularizationStatus, AttendanceRegularization,
--                             MobileAttendanceLog
--   11. Leave Management    : LeaveType, LeaveStatus, LeaveRequest, LeaveBalance
--   12. Comp-Off            : CompOffType, CompOffBalance
--   13. Payroll             : PayrollComponent, PayrollAttendanceSummary
--   14. Biometric           : BiometricDevice, BiometricEmployeeMapping, GeoFence
--   ── workflow SCHEMA ─────────────────────────────────────────────────────────────────────────────────────
--   15. Workflow Config     : WorkflowModule, WorkflowDefinition, WorkflowStepType,
--                             WorkflowStep, WorkflowApproverType, WorkflowStepApprover
--   16. Workflow Assignment : WorkflowAssignment
--   17. Workflow Execution  : WorkflowStatus, WorkflowInstance
--   18. Workflow Audit      : WorkflowActionType, WorkflowActionHistory
-- =============================================================================================================
-- WORKFLOW INTEGRATION NOTES:
--   WorkflowInstanceId has been added to all workflow-driven transactional tables:
--     - dbo.AttendanceRegularization  (regularization approval)
--     - dbo.LeaveRequest              (leave approval)
--     - dbo.ShiftSwapRequest          (shift swap approval)
--     - dbo.CompOffBalance            (comp-off redemption approval)
--     - dbo.EmployeeDocument          (document verification approval)
--   Column is nullable on all tables to preserve compatibility with manual / system entries.
--   A filtered unique index enforces one workflow instance per transaction where linked.
-- =============================================================================================================


-- =============================================================================================================
-- CREATE DATABASE
-- =============================================================================================================

CREATE DATABASE OfficeDB;
GO
USE OfficeDB;
GO

-- -------------------------------------------------------
-- STATUS LOOKUP
-- Stores statuses across the schema tables
-- STATUS GROUPS SEEDED INTO dbo.StatusLookup FOR SCHEMAS:
-- -------------------------------------------------------
CREATE TABLE dbo.StatusLookup (
    StatusCode      NVARCHAR(50)    NOT NULL,
    StatusGroup     NVARCHAR(50)    NOT NULL,
    Label           NVARCHAR(100)   NOT NULL,
    Description     NVARCHAR(500)   NULL,
    DisplayOrder    TINYINT         NOT NULL DEFAULT 0,
    IsTerminal      BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_StatusLookup PRIMARY KEY (StatusCode, StatusGroup)
);

-- -------------------------------------------------------
-- DESIGNATION
-- Stores job designations/titles and grade levels
-- -------------------------------------------------------
CREATE TABLE dbo.Designation (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    DesignationCode     NVARCHAR(50)    NOT NULL UNIQUE,
    DesignationName     NVARCHAR(200)   NOT NULL,
    Grade               NVARCHAR(50)    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- TIME ZONE MASTER
-- Stores global time zone definitions including Windows
-- and IANA zone IDs, UTC offsets, and DST support flags
-- -------------------------------------------------------
CREATE TABLE dbo.TimeZoneMaster (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    TimeZoneCode            NVARCHAR(100)   NOT NULL UNIQUE,
    TimeZoneName            NVARCHAR(200)   NOT NULL,
    UtcOffset               NVARCHAR(20)    NOT NULL,
    OffsetMinutes           INT             NOT NULL,
    SupportsDaylightSaving  BIT             NOT NULL DEFAULT 0,
    WindowsTimeZoneId       NVARCHAR(200)   NULL,
    IanaTimeZoneId          NVARCHAR(200)   NULL,
    CountryCode             NVARCHAR(10)    NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- COUNTRY
-- Stores country codes, names, currency, and default time zone
-- -------------------------------------------------------
CREATE TABLE dbo.Country (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    CountryCode     NVARCHAR(10)    NOT NULL UNIQUE,
    CountryName     NVARCHAR(200)   NOT NULL,
    CurrencyCode    NVARCHAR(10)    NULL,
    TimeZoneId      BIGINT          NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_Country_TimeZone
        FOREIGN KEY (TimeZoneId)
        REFERENCES dbo.TimeZoneMaster(Id)
);


-- -------------------------------------------------------
-- LEGAL ENTITY
-- Stores company subsidiaries and legal entities per country
-- -------------------------------------------------------
CREATE TABLE dbo.LegalEntity (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EntityCode                  NVARCHAR(50)    NOT NULL UNIQUE,
    EntityName                  NVARCHAR(300)   NOT NULL,
    CountryId                   BIGINT          NOT NULL,
    TaxIdentificationNumber     NVARCHAR(100)   NULL,
    RegistrationNumber          NVARCHAR(100)   NULL,
    CurrencyCode                NVARCHAR(10)    NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_LegalEntity_Country
        FOREIGN KEY (CountryId)
        REFERENCES dbo.Country(Id)
);


-- -------------------------------------------------------
-- REGION
-- Stores hierarchical region/state/city structure per country
-- -------------------------------------------------------
CREATE TABLE dbo.Region (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    CountryId       BIGINT          NOT NULL,
    RegionName      NVARCHAR(200)   NOT NULL,
    RegionType      NVARCHAR(50)    NULL,
    ParentRegionId  BIGINT          NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_Region_Country
        FOREIGN KEY (CountryId)
        REFERENCES dbo.Country(Id),

    CONSTRAINT FK_Region_Parent
        FOREIGN KEY (ParentRegionId)
        REFERENCES dbo.Region(Id)
);


-- -------------------------------------------------------
-- OFFICE LOCATION
-- Stores global office locations with address, geo-coordinates,
-- and associations to legal entity, country, and region
-- -------------------------------------------------------
CREATE TABLE dbo.OfficeLocation (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    LegalEntityId   BIGINT          NOT NULL,
    CountryId       BIGINT          NOT NULL,
    RegionId        BIGINT          NULL,
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
    TimeZoneId      BIGINT          NULL,
    IsHeadOffice    BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_OfficeLocation_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES dbo.LegalEntity(Id),

    CONSTRAINT FK_OfficeLocation_Country
        FOREIGN KEY (CountryId)
        REFERENCES dbo.Country(Id),

    CONSTRAINT FK_OfficeLocation_Region
        FOREIGN KEY (RegionId)
        REFERENCES dbo.Region(Id),

    CONSTRAINT FK_OfficeLocation_TimeZone
        FOREIGN KEY (TimeZoneId)
        REFERENCES dbo.TimeZoneMaster(Id)
);


-- -------------------------------------------------------
-- DEPARTMENT
-- Stores organizational departments with optional parent
-- for hierarchical (nested) department structures
-- -------------------------------------------------------
CREATE TABLE dbo.Department (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    DepartmentCode      NVARCHAR(50)    NOT NULL UNIQUE,
    DepartmentName      NVARCHAR(200)   NOT NULL,
    ParentDepartmentId  BIGINT          NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_Department_Parent
        FOREIGN KEY (ParentDepartmentId)
        REFERENCES dbo.Department(Id)
);


-- -------------------------------------------------------
-- RELATIONSHIP TYPE
-- Defines types of inter-employee relationships
-- e.g. Direct Manager, Dotted-Line Manager, Mentor
-- -------------------------------------------------------
CREATE TABLE dbo.RelationshipType (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    RelationshipName    NVARCHAR(100)   NOT NULL UNIQUE,
    Description         NVARCHAR(500)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- DOCUMENT TYPE
-- Defines categories of employee documents
-- e.g. Passport, Offer Letter, ID Proof
-- -------------------------------------------------------
CREATE TABLE dbo.DocumentType (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    DocumentTypeCode    NVARCHAR(50)    NOT NULL UNIQUE,
    DocumentTypeName    NVARCHAR(200)   NOT NULL,
    Category            NVARCHAR(100)   NULL,
    Description         NVARCHAR(1000)  NULL,
    IsMandatory         BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);



-- =============================================================================================================
-- MODULE 2: EMPLOYEE CORE
-- =============================================================================================================


-- -------------------------------------------------------
-- EMPLOYEE
-- Core employee profile: identity, contact, designation,
-- employment type, preferred locale, and photo
-- -------------------------------------------------------
CREATE TABLE dbo.Employee (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeCode            NVARCHAR(50)    NOT NULL UNIQUE,
    FirstName               NVARCHAR(100)   NOT NULL,
    LastName                NVARCHAR(100)   NULL,
    DisplayName             NVARCHAR(200)   NULL,
    Email                   NVARCHAR(255)   NOT NULL UNIQUE,
    MobileNumber            NVARCHAR(30)    NULL,
    DesignationId           BIGINT          NULL,
    PreferredLanguage       NVARCHAR(20)    NULL,
    PreferredTimeZoneId     BIGINT          NULL,
    DateOfJoining           DATE            NULL,
    EmploymentType          NVARCHAR(50)    NOT NULL DEFAULT 'FULL_TIME',
    EmploymentTypeGroup AS CAST('EMPLOYMENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    AboutMe                 NVARCHAR(MAX)   NULL,
    ProfilePhotoUrl         NVARCHAR(1000)  NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_Employee_Designation
        FOREIGN KEY (DesignationId)
        REFERENCES dbo.Designation(Id),

    CONSTRAINT FK_Employee_TimeZoneMaster
        FOREIGN KEY (PreferredTimeZoneId)
        REFERENCES dbo.TimeZoneMaster(Id),

    CONSTRAINT FK_Employee_EmploymentType
        FOREIGN KEY (EmploymentType, EmploymentTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- EMPLOYEE LEGAL ENTITY
-- Maps employees to one or more legal entities over time;
-- IsPrimary identifies the primary entity
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeLegalEntity (
    Id              BIGINT  PRIMARY KEY IDENTITY(1,1),
    EmployeeId      BIGINT  NOT NULL,
    LegalEntityId   BIGINT  NOT NULL,
    IsPrimary       BIT     NOT NULL DEFAULT 0,
    StartDate       DATE    NULL,
    EndDate         DATE    NULL,
    IsActive        BIT     NOT NULL DEFAULT 1,

    CONSTRAINT FK_ELE_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ELE_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES dbo.LegalEntity(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE DEPARTMENT
-- Maps employees to departments; supports split allocation
-- via AllocationPercentage and tracks primary department
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeDepartment (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    DepartmentId            BIGINT          NOT NULL,
    IsPrimaryDepartment     BIT             NOT NULL DEFAULT 0,
    AllocationPercentage    DECIMAL(5,2)    NULL,
    StartDate               DATE            NULL,
    EndDate                 DATE            NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_EmployeeDepartment_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeDepartment_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES dbo.Department(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE LOCATION
-- Maps employees to office locations with effective date range
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeLocation (
    Id                  BIGINT  PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT  NOT NULL,
    LocationId          BIGINT  NOT NULL,
    IsPrimaryLocation   BIT     NOT NULL DEFAULT 1,
    StartDate           DATE    NULL,
    EndDate             DATE    NULL,
    IsActive            BIT     NOT NULL DEFAULT 1,

    CONSTRAINT FK_EmployeeLocation_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeLocation_Location
        FOREIGN KEY (LocationId)
        REFERENCES dbo.OfficeLocation(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE RELATIONSHIP
-- Stores reporting and matrix hierarchy between employees;
-- supports direct and dotted-line relationships per department
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeRelationship (
    Id                      BIGINT  PRIMARY KEY IDENTITY(1,1),
    ParentEmployeeId        BIGINT  NOT NULL,
    ChildEmployeeId         BIGINT  NOT NULL,
    RelationshipTypeId      BIGINT  NOT NULL,
    DepartmentId            BIGINT  NULL,
    IsPrimaryRelationship   BIT     NOT NULL DEFAULT 0,
    EffectiveFrom           DATE    NULL,
    EffectiveTo             DATE    NULL,
    IsActive                BIT     NOT NULL DEFAULT 1,

    CONSTRAINT FK_ER_ParentEmployee
        FOREIGN KEY (ParentEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ER_ChildEmployee
        FOREIGN KEY (ChildEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ER_RelationshipType
        FOREIGN KEY (RelationshipTypeId)
        REFERENCES dbo.RelationshipType(Id),

    CONSTRAINT FK_ER_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES dbo.Department(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE CONTACT
-- Stores additional contact methods per employee
-- e.g. work phone, personal email, Slack handle
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeContact (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    ContactType         NVARCHAR(50)    NOT NULL,
    ContactTypeGroup AS CAST('CONTACT_TYPE' AS NVARCHAR(50)) PERSISTED,
    ContactValue        NVARCHAR(500)   NOT NULL,
    IsPrimary           BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_EmployeeContact_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeContact_ContactType
        FOREIGN KEY (ContactType, ContactTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);

-- -------------------------------------------------------
-- EMPLOYEE DOCUMENT
-- Stores employee uploaded documents with metadata,
-- verification status, expiry tracking, and workflow linkage.
-- WorkflowInstanceId links to the document verification
-- approval workflow instance where applicable.
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeDocument (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    DocumentTypeId          BIGINT          NOT NULL,
    FileName                NVARCHAR(500)   NULL,
    OriginalFileName        NVARCHAR(500)   NULL,
    FileExtension           NVARCHAR(20)    NULL,
    MimeType                NVARCHAR(100)   NULL,
    FileSizeInBytes         BIGINT          NULL,
    FileUrl                 NVARCHAR(1000)  NULL,
    DocumentNumber          NVARCHAR(200)   NULL,
    IssuedDate              DATE            NULL,
    ExpiryDate              DATE            NULL,
    Remarks                 NVARCHAR(1000)  NULL,
    UploadedAt              DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsVerified              BIT             NOT NULL DEFAULT 0,
    VerifiedByEmployeeId    BIGINT          NULL,
    VerifiedAt              DATETIME2       NULL,
    WorkflowInstanceId      BIGINT          NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_EmployeeDocument_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeDocument_DocumentType
        FOREIGN KEY (DocumentTypeId)
        REFERENCES dbo.DocumentType(Id),

    CONSTRAINT FK_EmployeeDocument_VerifiedBy
        FOREIGN KEY (VerifiedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeDocument_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
);


-- =============================================================================================================
-- MODULE 3: TEAM & SKILL
-- =============================================================================================================


-- -------------------------------------------------------
-- SKILL
-- Catalog of skills that can be mapped to employees
-- -------------------------------------------------------
CREATE TABLE dbo.Skill (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    SkillName       NVARCHAR(200)   NOT NULL UNIQUE,
    SkillCategory   NVARCHAR(100)   NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- TEAM
-- Stores cross-functional teams, squads, or pods
-- -------------------------------------------------------
CREATE TABLE dbo.Team (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    TeamCode        NVARCHAR(50)    NOT NULL UNIQUE,
    TeamName        NVARCHAR(200)   NOT NULL,
    TeamType        NVARCHAR(100)   NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- EMPLOYEE TEAM
-- Maps employees to teams with role and allocation percentage
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeTeam (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    TeamId                  BIGINT          NOT NULL,
    RoleInTeam              NVARCHAR(100)   NULL,
    AllocationPercentage    DECIMAL(5,2)    NULL,
    StartDate               DATE            NULL,
    EndDate                 DATE            NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_EmployeeTeam_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeTeam_Team
        FOREIGN KEY (TeamId)
        REFERENCES dbo.Team(Id)
);


-- -------------------------------------------------------
-- EMPLOYEE SKILL
-- Maps employees to skills with proficiency level,
-- years of experience, and last usage date
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeSkill (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    SkillId             BIGINT          NOT NULL,
    SkillLevel          NVARCHAR(50)    NULL,
    YearsOfExperience   DECIMAL(5,2)    NULL,
    IsPrimarySkill      BIT             NOT NULL DEFAULT 0,
    LastUsedDate        DATE            NULL,

    CONSTRAINT FK_EmployeeSkill_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmployeeSkill_Skill
        FOREIGN KEY (SkillId)
        REFERENCES dbo.Skill(Id)
);



-- =============================================================================================================
-- MODULE 4: ORGANIZATION SCOPE
-- =============================================================================================================


-- -------------------------------------------------------
-- SCOPE TYPE
-- Defines organizational hierarchy levels used for
-- dynamic policy and calendar assignments across entities
-- -------------------------------------------------------
CREATE TABLE dbo.ScopeType (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    ScopeCode       NVARCHAR(100)   NOT NULL UNIQUE,
    ScopeName       NVARCHAR(200)   NOT NULL,
    HierarchyLevel  INT             NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);



-- =============================================================================================================
-- MODULE 5: WORK WEEK POLICY
-- =============================================================================================================


-- -------------------------------------------------------
-- WORK WEEK POLICY
-- Defines named work week templates (e.g. Mon–Fri, Sun–Thu)
-- -------------------------------------------------------
CREATE TABLE dbo.WorkWeekPolicy (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyCode      NVARCHAR(100)   NOT NULL UNIQUE,
    PolicyName      NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsDefault       BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt       DATETIME2       NULL
);


-- -------------------------------------------------------
-- WORK WEEK POLICY DAY
-- Defines per-day working rules for a work week policy;
-- DayOfWeek: 0=Sunday … 6=Saturday
-- -------------------------------------------------------
CREATE TABLE dbo.WorkWeekPolicyDay (
    Id                      BIGINT  PRIMARY KEY IDENTITY(1,1),
    WorkWeekPolicyId        BIGINT  NOT NULL,
    DayOfWeek               TINYINT NOT NULL,
    IsWorkingDay            BIT     NOT NULL,
    StandardWorkingMinutes  INT     NULL,
    IsHalfDay               BIT     NOT NULL DEFAULT 0,

    CONSTRAINT FK_WorkWeekPolicyDay_Policy
        FOREIGN KEY (WorkWeekPolicyId)
        REFERENCES dbo.WorkWeekPolicy(Id),

    CONSTRAINT UQ_WorkWeekPolicyDay
        UNIQUE (WorkWeekPolicyId, DayOfWeek)
);


-- -------------------------------------------------------
-- WORK WEEK POLICY ASSIGNMENT
-- Dynamically assigns work week policies to any scope level;
-- PriorityOrder resolves conflicts when multiple policies apply
-- -------------------------------------------------------
CREATE TABLE dbo.WorkWeekPolicyAssignment (
    Id                  BIGINT  PRIMARY KEY IDENTITY(1,1),
    WorkWeekPolicyId    BIGINT  NOT NULL,
    ScopeTypeId         BIGINT  NOT NULL,
    ScopeReferenceId    BIGINT  NOT NULL,
    EffectiveFrom       DATE    NOT NULL,
    EffectiveTo         DATE    NULL,
    PriorityOrder       INT     NOT NULL DEFAULT 1,
    IsActive            BIT     NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_WorkWeekAssignment_Policy
        FOREIGN KEY (WorkWeekPolicyId)
        REFERENCES dbo.WorkWeekPolicy(Id),

    CONSTRAINT FK_WorkWeekAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES dbo.ScopeType(Id)
);



-- =============================================================================================================
-- MODULE 6: SHIFT MANAGEMENT
-- =============================================================================================================


-- -------------------------------------------------------
-- SHIFT
-- Defines shift timing configuration including grace windows,
-- overnight flags, flexible mode, and overtime allowance
-- -------------------------------------------------------
CREATE TABLE dbo.Shift (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    ShiftCode               NVARCHAR(100)   NOT NULL UNIQUE,
    ShiftName               NVARCHAR(200)   NOT NULL,
    StartTime               TIME            NOT NULL,
    EndTime                 TIME            NOT NULL,
    BreakDurationMinutes    INT             NOT NULL DEFAULT 0,
    GraceInMinutes          INT             NOT NULL DEFAULT 0,
    GraceOutMinutes         INT             NOT NULL DEFAULT 0,
    MinimumWorkingMinutes   INT             NULL,
    MaximumWorkingMinutes   INT             NULL,
    IsNightShift            BIT             NOT NULL DEFAULT 0,
    CrossesMidnight         BIT             NOT NULL DEFAULT 0,
    IsFlexible              BIT             NOT NULL DEFAULT 0,
    AllowOvertime           BIT             NOT NULL DEFAULT 1,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- SHIFT ASSIGNMENT
-- Dynamically assigns shifts to any scope level;
-- PriorityOrder resolves conflicts when multiple apply
-- -------------------------------------------------------
CREATE TABLE dbo.ShiftAssignment (
    Id                  BIGINT  PRIMARY KEY IDENTITY(1,1),
    ShiftId             BIGINT  NOT NULL,
    ScopeTypeId         BIGINT  NOT NULL,
    ScopeReferenceId    BIGINT  NOT NULL,
    EffectiveFrom       DATE    NOT NULL,
    EffectiveTo         DATE    NULL,
    PriorityOrder       INT     NOT NULL DEFAULT 1,
    IsPrimaryShift      BIT     NOT NULL DEFAULT 1,
    IsActive            BIT     NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_ShiftAssignment_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES dbo.Shift(Id),

    CONSTRAINT FK_ShiftAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES dbo.ScopeType(Id)
);


-- -------------------------------------------------------
-- SHIFT SWAP STATUS
-- Lookup table for shift swap request workflow statuses
-- e.g. Pending, Approved, Rejected
-- -------------------------------------------------------
CREATE TABLE dbo.ShiftSwapStatus (
    Id          BIGINT          PRIMARY KEY IDENTITY(1,1),
    StatusCode  NVARCHAR(100)   NOT NULL UNIQUE,
    StatusName  NVARCHAR(200)   NOT NULL
);


-- -------------------------------------------------------
-- SHIFT SWAP REQUEST
-- Stores shift swap requests between two employees,
-- referencing their respective roster entries.
-- WorkflowInstanceId links to the approval workflow
-- instance driving the swap approval process.
-- -------------------------------------------------------
CREATE TABLE dbo.ShiftSwapRequest (
    Id                      BIGINT      PRIMARY KEY IDENTITY(1,1),
    RequesterEmployeeId     BIGINT      NOT NULL,
    TargetEmployeeId        BIGINT      NOT NULL,
    RequesterRosterId       BIGINT      NOT NULL,
    TargetRosterId          BIGINT      NOT NULL,
    ShiftSwapStatusId       BIGINT      NOT NULL,
    WorkflowInstanceId      BIGINT      NULL,
    RequestedAt             DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    ApprovedBy              BIGINT      NULL,
    ApprovedAt              DATETIME2   NULL,
    Remarks                 NVARCHAR(1000) NULL,

    CONSTRAINT FK_ShiftSwapRequest_Status
        FOREIGN KEY (ShiftSwapStatusId)
        REFERENCES dbo.ShiftSwapStatus(Id),

    CONSTRAINT FK_ShiftSwapRequest_RequesterEmployee
        FOREIGN KEY (RequesterEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ShiftSwapRequest_TargetEmployee
        FOREIGN KEY (TargetEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ShiftSwapRequest_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
);



-- =============================================================================================================
-- MODULE 7: ROTATION SHIFT
-- =============================================================================================================


-- -------------------------------------------------------
-- ROTATION SHIFT
-- Defines reusable cyclic rotation schedules
-- CycleLengthDays determines the total days in one cycle
-- -------------------------------------------------------
CREATE TABLE dbo.RotationShift (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    RotationCode    NVARCHAR(100)   NOT NULL UNIQUE,
    RotationName    NVARCHAR(200)   NOT NULL,
    CycleLengthDays INT             NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- ROTATION SHIFT DETAIL
-- Defines the ordered sequence of shifts (or off-days)
-- within a rotation cycle
-- -------------------------------------------------------
CREATE TABLE dbo.RotationShiftDetail (
    Id              BIGINT  PRIMARY KEY IDENTITY(1,1),
    RotationShiftId BIGINT  NOT NULL,
    SequenceNo      INT     NOT NULL,
    ShiftId         BIGINT  NULL,
    DurationDays    INT     NOT NULL,
    IsOffDay        BIT     NOT NULL DEFAULT 0,

    CONSTRAINT FK_RotationDetail_Rotation
        FOREIGN KEY (RotationShiftId)
        REFERENCES dbo.RotationShift(Id),

    CONSTRAINT FK_RotationDetail_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES dbo.Shift(Id)
);


-- -------------------------------------------------------
-- ROTATION SHIFT ASSIGNMENT
-- Assigns rotation schedules to any scope level;
-- RotationStartDate anchors the cycle start
-- -------------------------------------------------------
CREATE TABLE dbo.RotationShiftAssignment (
    Id                  BIGINT  PRIMARY KEY IDENTITY(1,1),
    RotationShiftId     BIGINT  NOT NULL,
    ScopeTypeId         BIGINT  NOT NULL,
    ScopeReferenceId    BIGINT  NOT NULL,
    RotationStartDate   DATE    NOT NULL,
    EffectiveFrom       DATE    NOT NULL,
    EffectiveTo         DATE    NULL,
    IsActive            BIT     NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_RotationAssignment_Rotation
        FOREIGN KEY (RotationShiftId)
        REFERENCES dbo.RotationShift(Id),

    CONSTRAINT FK_RotationAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES dbo.ScopeType(Id)
);



-- =============================================================================================================
-- MODULE 8: EMPLOYEE ROSTER
-- =============================================================================================================


-- -------------------------------------------------------
-- EMPLOYEE SHIFT ROSTER
-- Stores the actual daily schedule for each employee;
-- tracks planned vs actual times, off-day, holiday, and lock status
-- -------------------------------------------------------
CREATE TABLE dbo.EmployeeShiftRoster (
    Id                  BIGINT      PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT      NOT NULL,
    RosterDate          DATE        NOT NULL,
    ShiftId             BIGINT      NULL,
    IsOffDay            BIT         NOT NULL DEFAULT 0,
    IsHoliday           BIT         NOT NULL DEFAULT 0,
    PlannedStartTime    DATETIME2   NULL,
    PlannedEndTime      DATETIME2   NULL,
    ActualStartTime     DATETIME2   NULL,
    ActualEndTime       DATETIME2   NULL,
    Remarks             NVARCHAR(1000) NULL,
    IsLocked            BIT         NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2   NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_Roster_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_Roster_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES dbo.Shift(Id),

    CONSTRAINT UQ_EmployeeRoster
        UNIQUE (EmployeeId, RosterDate)
);

-- Add deferred FKs from ShiftSwapRequest to EmployeeShiftRoster
ALTER TABLE dbo.ShiftSwapRequest
    ADD CONSTRAINT FK_ShiftSwapRequest_RequesterRoster
        FOREIGN KEY (RequesterRosterId)
        REFERENCES dbo.EmployeeShiftRoster(Id);

ALTER TABLE dbo.ShiftSwapRequest
    ADD CONSTRAINT FK_ShiftSwapRequest_TargetRoster
        FOREIGN KEY (TargetRosterId)
        REFERENCES dbo.EmployeeShiftRoster(Id);



-- =============================================================================================================
-- MODULE 9: HOLIDAY MANAGEMENT
-- =============================================================================================================


-- -------------------------------------------------------
-- HOLIDAY CALENDAR
-- Named holiday calendars that can be assigned to scope levels
-- -------------------------------------------------------
CREATE TABLE dbo.HolidayCalendar (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    CalendarCode    NVARCHAR(100)   NOT NULL UNIQUE,
    CalendarName    NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsDefault       BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- HOLIDAY TYPE
-- Categorizes holidays (e.g. National, Regional, Optional)
-- -------------------------------------------------------
CREATE TABLE dbo.HolidayType (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    HolidayTypeCode     NVARCHAR(100)   NOT NULL UNIQUE,
    HolidayTypeName     NVARCHAR(200)   NOT NULL,
    IsOptional          BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- HOLIDAY
-- Stores individual holiday entries within a calendar;
-- supports half-day, recurring, and year-specific holidays
-- -------------------------------------------------------
CREATE TABLE dbo.Holiday (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    HolidayCalendarId   BIGINT          NOT NULL,
    HolidayTypeId       BIGINT          NOT NULL,
    HolidayCode         NVARCHAR(100)   NULL,
    HolidayName         NVARCHAR(200)   NOT NULL,
    HolidayDate         DATE            NOT NULL,
    IsHalfDay           BIT             NOT NULL DEFAULT 0,
    HalfDaySession      NVARCHAR(20)    NULL,
    IsRecurring         BIT             NOT NULL DEFAULT 1,
    ApplicableYear      INT             NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_Holiday_Calendar
        FOREIGN KEY (HolidayCalendarId)
        REFERENCES dbo.HolidayCalendar(Id),

    CONSTRAINT FK_Holiday_Type
        FOREIGN KEY (HolidayTypeId)
        REFERENCES dbo.HolidayType(Id)
);


-- -------------------------------------------------------
-- HOLIDAY CALENDAR ASSIGNMENT
-- Dynamically assigns holiday calendars to scope levels;
-- MergeStrategy controls how multiple calendars are combined
-- -------------------------------------------------------
CREATE TABLE dbo.HolidayCalendarAssignment (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    HolidayCalendarId   BIGINT          NOT NULL,
    ScopeTypeId         BIGINT          NOT NULL,
    ScopeReferenceId    BIGINT          NOT NULL,
    EffectiveFrom       DATE            NULL,
    EffectiveTo         DATE            NULL,
    PriorityOrder       INT             NOT NULL DEFAULT 1,
    MergeStrategy       NVARCHAR(50)    NULL,
    IsPrimary           BIT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_HolidayAssignment_Calendar
        FOREIGN KEY (HolidayCalendarId)
        REFERENCES dbo.HolidayCalendar(Id),

    CONSTRAINT FK_HolidayAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES dbo.ScopeType(Id)
);



-- =============================================================================================================
-- MODULE 10: ATTENDANCE MANAGEMENT
-- =============================================================================================================


-- -------------------------------------------------------
-- ATTENDANCE STATUS
-- Lookup for processed attendance outcomes
-- e.g. Present, Absent, On Leave, Work From Home
-- -------------------------------------------------------
CREATE TABLE dbo.AttendanceStatus (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    StatusCode          NVARCHAR(100)   NOT NULL UNIQUE,
    StatusName          NVARCHAR(200)   NOT NULL,
    IsPresent           BIT             NOT NULL DEFAULT 0,
    IsAbsent            BIT             NOT NULL DEFAULT 0,
    IsPaid              BIT             NOT NULL DEFAULT 0,
    CountsAsWorkingDay  BIT             NOT NULL DEFAULT 0,
    DisplayOrder        INT             NOT NULL DEFAULT 1,
    IsSystemStatus      BIT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1
);


-- -------------------------------------------------------
-- ATTENDANCE RECORD
-- Stores processed daily attendance per employee;
-- includes check-in/out, late/early deviation, and overtime
-- -------------------------------------------------------
CREATE TABLE dbo.AttendanceRecord (
    Id                      BIGINT      PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT      NOT NULL,
    AttendanceDate          DATE        NOT NULL,
    ShiftId                 BIGINT      NULL,
    AttendanceStatusId      BIGINT      NULL,
    CheckInTime             DATETIME2   NULL,
    CheckOutTime            DATETIME2   NULL,
    LateByMinutes           INT         NULL,
    EarlyExitMinutes        INT         NULL,
    WorkedMinutes           INT         NULL,
    OvertimeMinutes         INT         NULL,
    IsManualEntry           BIT         NOT NULL DEFAULT 0,
    ApprovedBy              BIGINT      NULL,
    ApprovedAt              DATETIME2   NULL,
    Remarks                 NVARCHAR(1000) NULL,
    CreatedAt               DATETIME2   NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_Attendance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_Attendance_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES dbo.Shift(Id),

    CONSTRAINT FK_Attendance_Status
        FOREIGN KEY (AttendanceStatusId)
        REFERENCES dbo.AttendanceStatus(Id),

    CONSTRAINT UQ_Attendance
        UNIQUE (EmployeeId, AttendanceDate)
);


-- -------------------------------------------------------
-- ATTENDANCE LOG
-- Stores raw biometric device punches before processing;
-- IsProcessed flags records that have been reconciled
-- -------------------------------------------------------
CREATE TABLE dbo.AttendanceLog (
    Id          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId  BIGINT          NOT NULL,
    PunchTime   DATETIME2       NOT NULL,
    PunchType   NVARCHAR(20)    NULL,
    DeviceId    NVARCHAR(100)   NULL,
    Location    NVARCHAR(500)   NULL,
    IsProcessed BIT             NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AttendanceLog_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id)
);


-- -------------------------------------------------------
-- ATTENDANCE REGULARIZATION STATUS
-- Lookup for regularization request workflow statuses
-- e.g. Pending, Approved, Rejected
-- -------------------------------------------------------
CREATE TABLE dbo.AttendanceRegularizationStatus (
    Id          BIGINT          PRIMARY KEY IDENTITY(1,1),
    StatusCode  NVARCHAR(100)   NOT NULL UNIQUE,
    StatusName  NVARCHAR(200)   NOT NULL
);


-- -------------------------------------------------------
-- ATTENDANCE REGULARIZATION
-- Stores employee requests to correct attendance entries;
-- links to approver and regularization status.
-- WorkflowInstanceId links to the approval workflow
-- instance driving the regularization approval process.
-- -------------------------------------------------------
CREATE TABLE dbo.AttendanceRegularization (
    Id                                  BIGINT      PRIMARY KEY IDENTITY(1,1),
    EmployeeId                          BIGINT      NOT NULL,
    AttendanceDate                      DATE        NOT NULL,
    RequestedCheckIn                    DATETIME2   NULL,
    RequestedCheckOut                   DATETIME2   NULL,
    Reason                              NVARCHAR(1000) NULL,
    AttendanceRegularizationStatusId    BIGINT      NOT NULL,
    WorkflowInstanceId                  BIGINT      NULL,
    ApprovedBy                          BIGINT      NULL,
    ApprovedAt                          DATETIME2   NULL,
    Remarks                             NVARCHAR(1000) NULL,
    CreatedAt                           DATETIME2   NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_Regularization_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_Regularization_Status
        FOREIGN KEY (AttendanceRegularizationStatusId)
        REFERENCES dbo.AttendanceRegularizationStatus(Id),

    CONSTRAINT FK_AttendanceRegularization_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
);


-- -------------------------------------------------------
-- MOBILE ATTENDANCE LOG
-- Stores GPS-based mobile attendance punches;
-- validates against geo-fence boundaries
-- -------------------------------------------------------
CREATE TABLE dbo.MobileAttendanceLog (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    GeoFenceId          BIGINT          NULL,
    PunchTime           DATETIME2       NOT NULL,
    Latitude            DECIMAL(18,8)   NOT NULL,
    Longitude           DECIMAL(18,8)   NOT NULL,
    IsInsideGeoFence    BIT             NOT NULL DEFAULT 0,
    DeviceInfo          NVARCHAR(500)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_MobileAttendanceLog_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id)

    -- FK_MobileAttendanceLog_GeoFence added after GeoFence table (see Module 14)
);



-- =============================================================================================================
-- MODULE 11: LEAVE MANAGEMENT
-- =============================================================================================================


-- -------------------------------------------------------
-- LEAVE TYPE
-- Defines leave categories with accrual rules,
-- carry-forward eligibility, and half-day support
-- -------------------------------------------------------
CREATE TABLE dbo.LeaveType (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    LeaveCode           NVARCHAR(100)   NOT NULL UNIQUE,
    LeaveName           NVARCHAR(200)   NOT NULL,
    IsPaid              BIT             NOT NULL DEFAULT 1,
    MaxDaysPerYear      DECIMAL(10,2)   NULL,
    AllowCarryForward   BIT             NOT NULL DEFAULT 0,
    RequiresApproval    BIT             NOT NULL DEFAULT 1,
    AllowHalfDay        BIT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- LEAVE STATUS
-- Lookup for leave request workflow statuses
-- e.g. Pending, Approved, Rejected, Cancelled
-- -------------------------------------------------------
CREATE TABLE dbo.LeaveStatus (
    Id          BIGINT          PRIMARY KEY IDENTITY(1,1),
    StatusCode  NVARCHAR(100)   NOT NULL UNIQUE,
    StatusName  NVARCHAR(200)   NOT NULL
);


-- -------------------------------------------------------
-- LEAVE REQUEST
-- Stores employee leave applications with date range,
-- session (half-day), approver, and current status.
-- WorkflowInstanceId links to the approval workflow
-- instance driving the leave approval process.
-- -------------------------------------------------------
CREATE TABLE dbo.LeaveRequest (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId      BIGINT          NOT NULL,
    LeaveTypeId     BIGINT          NOT NULL,
    LeaveStatusId   BIGINT          NOT NULL,
    FromDate        DATE            NOT NULL,
    ToDate          DATE            NOT NULL,
    TotalDays       DECIMAL(10,2)   NOT NULL,
    IsHalfDay       BIT             NOT NULL DEFAULT 0,
    HalfDaySession  NVARCHAR(20)    NULL,
    Reason          NVARCHAR(1000)  NULL,
    WorkflowInstanceId BIGINT       NULL,
    ApprovedBy      BIGINT          NULL,
    ApprovedAt      DATETIME2       NULL,
    Remarks         NVARCHAR(1000)  NULL,
    AppliedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_LeaveRequest_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_LeaveRequest_Type
        FOREIGN KEY (LeaveTypeId)
        REFERENCES dbo.LeaveType(Id),

    CONSTRAINT FK_LeaveRequest_Status
        FOREIGN KEY (LeaveStatusId)
        REFERENCES dbo.LeaveStatus(Id),

    CONSTRAINT FK_LeaveRequest_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
);


-- -------------------------------------------------------
-- LEAVE BALANCE
-- Stores annual leave balances per employee and leave type;
-- ClosingBalance is a computed column
-- -------------------------------------------------------
CREATE TABLE dbo.LeaveBalance (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId      BIGINT          NOT NULL,
    LeaveTypeId     BIGINT          NOT NULL,
    BalanceYear     INT             NOT NULL,
    OpeningBalance  DECIMAL(10,2)   NOT NULL DEFAULT 0,
    Allocated       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    Availed         DECIMAL(10,2)   NOT NULL DEFAULT 0,
    Encashed        DECIMAL(10,2)   NOT NULL DEFAULT 0,
    CarryForward    DECIMAL(10,2)   NOT NULL DEFAULT 0,
    ClosingBalance  AS (OpeningBalance + Allocated + CarryForward - Availed - Encashed),
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_LeaveBalance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_LeaveBalance_Type
        FOREIGN KEY (LeaveTypeId)
        REFERENCES dbo.LeaveType(Id),

    CONSTRAINT UQ_LeaveBalance
        UNIQUE (EmployeeId, LeaveTypeId, BalanceYear)
);


-- =============================================================================================================
-- MODULE 12: COMP-OFF
-- =============================================================================================================


-- -------------------------------------------------------
-- COMP-OFF TYPE
-- Defines compensatory off categories with optional expiry window
-- -------------------------------------------------------
CREATE TABLE dbo.CompOffType (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    CompOffTypeCode NVARCHAR(100)   NOT NULL UNIQUE,
    CompOffTypeName NVARCHAR(200)   NOT NULL,
    ExpiryDays      INT             NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- COMP-OFF BALANCE
-- Tracks earned and availed comp-off days per employee;
-- RemainingDays is a computed column; linked to source
-- attendance record.
-- WorkflowInstanceId links to the approval workflow instance
-- where comp-off redemption requires explicit approval.
-- -------------------------------------------------------
CREATE TABLE dbo.CompOffBalance (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    CompOffTypeId       BIGINT          NOT NULL,
    EarnedDate          DATE            NOT NULL,
    ExpiryDate          DATE            NULL,
    TotalDays           DECIMAL(10,2)   NOT NULL,
    AvailedDays         DECIMAL(10,2)   NOT NULL DEFAULT 0,
    RemainingDays       AS (TotalDays - AvailedDays),
    AttendanceRecordId  BIGINT          NULL,
    WorkflowInstanceId  BIGINT          NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_CompOffBalance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_CompOffBalance_CompOffType
        FOREIGN KEY (CompOffTypeId)
        REFERENCES dbo.CompOffType(Id),

    CONSTRAINT FK_CompOffBalance_AttendanceRecord
        FOREIGN KEY (AttendanceRecordId)
        REFERENCES dbo.AttendanceRecord(Id),

    CONSTRAINT FK_CompOffBalance_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
);



-- =============================================================================================================
-- MODULE 14: BIOMETRIC & GEO-FENCE
-- =============================================================================================================


-- -------------------------------------------------------
-- BIOMETRIC DEVICE
-- Stores biometric device inventory with office location
-- and sync metadata
-- -------------------------------------------------------
CREATE TABLE dbo.BiometricDevice (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    DeviceCode      NVARCHAR(100)   NOT NULL UNIQUE,
    DeviceName      NVARCHAR(200)   NOT NULL,
    SerialNumber    NVARCHAR(200)   NULL,
    OfficeId        BIGINT          NULL,
    IpAddress       NVARCHAR(100)   NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    LastSyncAt      DATETIME2       NULL,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_BiometricDevice_Office
        FOREIGN KEY (OfficeId)
        REFERENCES dbo.OfficeLocation(Id)
);


-- -------------------------------------------------------
-- BIOMETRIC EMPLOYEE MAPPING
-- Maps employees to their biometric identity on each device;
-- DeviceEmployeeCode is the ID registered on the device
-- -------------------------------------------------------
CREATE TABLE dbo.BiometricEmployeeMapping (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    BiometricDeviceId   BIGINT          NOT NULL,
    DeviceEmployeeCode  NVARCHAR(100)   NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_BiometricEmployeeMapping_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_BiometricEmployeeMapping_Device
        FOREIGN KEY (BiometricDeviceId)
        REFERENCES dbo.BiometricDevice(Id)
);


-- -------------------------------------------------------
-- GEO FENCE
-- Defines circular geo-fence zones by center coordinates
-- and radius; optionally tied to an office location
-- -------------------------------------------------------
CREATE TABLE dbo.GeoFence (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    GeoFenceCode    NVARCHAR(100)   NOT NULL UNIQUE,
    GeoFenceName    NVARCHAR(200)   NOT NULL,
    Latitude        DECIMAL(18,8)   NOT NULL,
    Longitude       DECIMAL(18,8)   NOT NULL,
    RadiusMeters    DECIMAL(18,2)   NOT NULL,
    OfficeId        BIGINT          NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_GeoFence_Office
        FOREIGN KEY (OfficeId)
        REFERENCES dbo.OfficeLocation(Id)
);

-- Add deferred FK from MobileAttendanceLog to GeoFence
ALTER TABLE dbo.MobileAttendanceLog
    ADD CONSTRAINT FK_MobileAttendanceLog_GeoFence
        FOREIGN KEY (GeoFenceId)
        REFERENCES dbo.GeoFence(Id);



-- =============================================================================================================
-- INDEXES — dbo SCHEMA
-- =============================================================================================================

-- Employee
CREATE INDEX IX_Employee_Email           ON dbo.Employee (Email);
CREATE INDEX IX_Employee_DisplayName     ON dbo.Employee (DisplayName);

-- Employee Relationships
CREATE INDEX IX_EmployeeRelationship_Parent  ON dbo.EmployeeRelationship (ParentEmployeeId);
CREATE INDEX IX_EmployeeRelationship_Child   ON dbo.EmployeeRelationship (ChildEmployeeId);

-- Employee Mappings
CREATE INDEX IX_EmployeeSkill_Skill          ON dbo.EmployeeSkill (SkillId);
CREATE INDEX IX_EmployeeDepartment_Employee  ON dbo.EmployeeDepartment (EmployeeId);
CREATE INDEX IX_EmployeeTeam_Employee        ON dbo.EmployeeTeam (EmployeeId);
CREATE INDEX IX_EmployeeLocation_Employee    ON dbo.EmployeeLocation (EmployeeId);

-- Office Location
CREATE INDEX IX_OfficeLocation_Country   ON dbo.OfficeLocation (CountryId);
CREATE INDEX IX_OfficeLocation_Region    ON dbo.OfficeLocation (RegionId);

-- Documents
CREATE INDEX IX_EmployeeDocument_Employee       ON dbo.EmployeeDocument (EmployeeId);
CREATE INDEX IX_EmployeeDocument_DocumentType   ON dbo.EmployeeDocument (DocumentTypeId);
CREATE INDEX IX_EmployeeDocument_ExpiryDate     ON dbo.EmployeeDocument (ExpiryDate);

-- -------------------------------------------------------
-- WORKFLOW INSTANCE LINKAGE INDEX — EmployeeDocument
-- Supports reverse lookup: find the document record
-- for a given workflow instance
-- -------------------------------------------------------
CREATE INDEX IX_EmployeeDocument_WorkflowInstance
    ON dbo.EmployeeDocument (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_EmployeeDocument_WorkflowInstance
    ON dbo.EmployeeDocument (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

-- Time Zone
CREATE INDEX IX_TimeZoneMaster_TimeZoneCode         ON dbo.TimeZoneMaster (TimeZoneCode);
CREATE INDEX IX_TimeZoneMaster_IanaTimeZoneId        ON dbo.TimeZoneMaster (IanaTimeZoneId);
CREATE INDEX IX_TimeZoneMaster_WindowsTimeZoneId     ON dbo.TimeZoneMaster (WindowsTimeZoneId);

-- Scope-based Assignments
CREATE INDEX IX_ShiftAssignment_Scope        ON dbo.ShiftAssignment (ScopeTypeId, ScopeReferenceId);
CREATE INDEX IX_WorkWeekAssignment_Scope     ON dbo.WorkWeekPolicyAssignment (ScopeTypeId, ScopeReferenceId);
CREATE INDEX IX_RotationAssignment_Scope     ON dbo.RotationShiftAssignment (ScopeTypeId, ScopeReferenceId);
CREATE INDEX IX_HolidayAssignment_Scope      ON dbo.HolidayCalendarAssignment (ScopeTypeId, ScopeReferenceId);

-- Roster & Attendance
CREATE INDEX IX_Roster_Employee_Date         ON dbo.EmployeeShiftRoster (EmployeeId, RosterDate);
CREATE INDEX IX_Attendance_Employee_Date     ON dbo.AttendanceRecord (EmployeeId, AttendanceDate);
CREATE INDEX IX_AttendanceLog_Employee_Time  ON dbo.AttendanceLog (EmployeeId, PunchTime);

-- Holiday
CREATE INDEX IX_Holiday_Date                 ON dbo.Holiday (HolidayDate);

-- Leave
CREATE INDEX IX_LeaveRequest_Employee        ON dbo.LeaveRequest (EmployeeId, FromDate, ToDate);
CREATE INDEX IX_LeaveBalance_Employee        ON dbo.LeaveBalance (EmployeeId, LeaveTypeId);

-- -------------------------------------------------------
-- WORKFLOW INSTANCE LINKAGE INDEX — LeaveRequest
-- Supports reverse lookup: find the leave request
-- for a given workflow instance
-- -------------------------------------------------------
CREATE INDEX IX_LeaveRequest_WorkflowInstance
    ON dbo.LeaveRequest (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_LeaveRequest_WorkflowInstance
    ON dbo.LeaveRequest (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

-- Comp-Off
CREATE INDEX IX_CompOffBalance_Employee      
    ON dbo.CompOffBalance (EmployeeId, CompOffTypeId);

-- -------------------------------------------------------
-- WORKFLOW INSTANCE LINKAGE INDEX — CompOffBalance
-- Supports reverse lookup: find the comp-off balance record
-- for a given workflow instance
-- -------------------------------------------------------
CREATE INDEX IX_CompOffBalance_WorkflowInstance
    ON dbo.CompOffBalance (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_CompOffBalance_WorkflowInstance
    ON dbo.CompOffBalance (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

-- Biometric
CREATE INDEX IX_BiometricEmployeeMapping_Employee  
    ON dbo.BiometricEmployeeMapping (EmployeeId, BiometricDeviceId);

-- Mobile Attendance
CREATE INDEX IX_MobileAttendanceLog_Employee 
    ON dbo.MobileAttendanceLog (EmployeeId, PunchTime);

-- Shift Swap
CREATE INDEX IX_ShiftSwapRequest_Requester   
    ON dbo.ShiftSwapRequest (RequesterEmployeeId, RequestedAt);

-- -------------------------------------------------------
-- WORKFLOW INSTANCE LINKAGE INDEX — ShiftSwapRequest
-- Supports reverse lookup: find the shift swap request
-- for a given workflow instance
-- -------------------------------------------------------
CREATE INDEX IX_ShiftSwapRequest_WorkflowInstance
    ON dbo.ShiftSwapRequest (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_ShiftSwapRequest_WorkflowInstance
    ON dbo.ShiftSwapRequest (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

-- Attendance Regularization
-- -------------------------------------------------------
-- WORKFLOW INSTANCE LINKAGE INDEX — AttendanceRegularization
-- Supports reverse lookup: find the regularization record
-- for a given workflow instance
-- -------------------------------------------------------
CREATE INDEX IX_AttendanceRegularization_WorkflowInstance
    ON dbo.AttendanceRegularization (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_AttendanceRegularization_WorkflowInstance
    ON dbo.AttendanceRegularization (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;
