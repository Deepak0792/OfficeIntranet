-- ============================================================================================================================
-- AUTH SCHEMA  —  Enterprise Authorization Framework
-- SQL Server  |  Schema: auth
-- ----------------------------------------------------------------------------------------------------------------------------
-- Purpose   : Centralized authorization for all microservices.
--             Supports RBAC · ABAC · Record-Level Security · Field-Level Security · UI · API · Workflow authorization
--             and Delegated Access (employee A temporarily grants permissions to employee B).
--
-- Design principles
--   • Business-entity-centric  — EntityDefinition uses logical business names, NOT physical table/column names.
--   • ConfidentialField        — uses (EntityName, FieldName) logical names; masking enforced in the service layer.
--   • No masking by default    — only fields explicitly registered in ConfidentialField are masked.
--   • Simple & modular         — nine self-contained modules, each responsible for one concern.
--   • DENY wins                — an explicit DENY on a RolePermission always overrides any ALLOW.
--   • Scope hierarchy          — GLOBAL > COUNTRY > LEGAL_ENTITY > OFFICE > DEPARTMENT > TEAM > EMPLOYEE.
--   • Delegated access         — time-bounded, permission-scoped grants from one employee to another;
--                                evaluated alongside RBAC in every permission check.
--
-- Dependencies : shared (StatusLookup) · employee (Employee) · time (ScopeType) · workflow (WorkflowDefinition / WorkflowStep)
--
-- Module map
--   MODULE 1  ENTITY REGISTRY          BusinessModule · BusinessEntity · EntityAction
--   MODULE 2  PERMISSION CATALOGUE     Permission
--   MODULE 3  ROLE MANAGEMENT          Role · RoleGroup · RoleGroupRole · RolePermission
--   MODULE 4  EMPLOYEE ASSIGNMENT      EmployeeRoleGroup
--   MODULE 5  RECORD-LEVEL SECURITY    RecordAccessPolicy · RecordAccessScope
--   MODULE 6  FIELD-LEVEL SECURITY     ConfidentialField · ConfidentialAccessPolicy
--   MODULE 7  UI & API AUTHORIZATION   UIResource · UIPermission · APIResource · APIPermission
--   MODULE 8  WORKFLOW AUTHORIZATION   WorkflowPermission
--   MODULE 9  DELEGATED ACCESS         DelegatedAccess · DelegatedAccessPermission
-- ============================================================================================================================


-- ============================================================================================================================
-- SCHEMA
-- ============================================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'auth')
    EXEC('CREATE SCHEMA auth');
GO

-- ============================================================================================================================
-- MODULE 1  —  ENTITY REGISTRY
-- Defines the logical business surface area that can be authorized.
-- Uses business-level names; no coupling to physical table or column names.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 1.1  BusinessModule
--      Top-level grouping that mirrors the microservice / product module.
--      Examples: Attendance, Payroll, HR, Helpdesk
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.BusinessModule (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    ModuleCode      NVARCHAR(50)    NOT NULL,
    ModuleName      NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(500)   NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       BIGINT          NOT NULL,
    UpdatedAt       DATETIME2       NULL,
    UpdatedBy       BIGINT          NULL,

    CONSTRAINT PK_BusinessModule     PRIMARY KEY (Id),
    CONSTRAINT UQ_BusinessModule_Code UNIQUE      (ModuleCode)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 1.2  BusinessEntity
--      A named, authorizable business concept within a module.
--      Examples: LeaveRequest, SalarySlip, PerformanceReview, HelpdeskTicket
--
--      Design note: EntityName is the canonical logical name used throughout
--      the auth framework. It is decoupled from any physical schema/table name.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.BusinessEntity (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    BusinessModuleId    BIGINT          NOT NULL,
    EntityName          NVARCHAR(100)   NOT NULL,   -- logical name, e.g. "LeaveRequest"
    EntityLabel         NVARCHAR(200)   NOT NULL,   -- display label,  e.g. "Leave Request"
    Description         NVARCHAR(500)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT          NOT NULL,
    UpdatedAt           DATETIME2       NULL,
    UpdatedBy           BIGINT          NULL,

    CONSTRAINT PK_BusinessEntity       PRIMARY KEY (Id),
    CONSTRAINT UQ_BusinessEntity_Name  UNIQUE      (EntityName),

    CONSTRAINT FK_BusinessEntity_Module
        FOREIGN KEY (BusinessModuleId)
        REFERENCES auth.BusinessModule (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 1.3  EntityAction
--      Actions that can be performed on a BusinessEntity.
--      Linked to the PERMISSION_ACTION status group for label/description.
--      Examples: VIEW, CREATE, UPDATE, DELETE, APPROVE, REJECT, EXPORT
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.EntityAction (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    ActionCode      NVARCHAR(50)    NOT NULL,
    ActionGroup     AS CAST('PERMISSION_ACTION' AS NVARCHAR(50)) PERSISTED,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       BIGINT          NOT NULL,

    CONSTRAINT PK_EntityAction      PRIMARY KEY (Id),
    CONSTRAINT UQ_EntityAction_Code UNIQUE      (ActionCode),

    CONSTRAINT FK_EntityAction_ActionCode
        FOREIGN KEY (ActionCode, ActionGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================================================================================
-- MODULE 2  —  PERMISSION CATALOGUE
-- A Permission is the combination of a BusinessEntity + an EntityAction.
-- Permissions are tagged with a PermissionCategory for grouping (READ / WRITE / APPROVAL …).
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 2.1  Permission
--      Examples:
--        LeaveRequest  + VIEW    → LEAVE_REQUEST.VIEW
--        LeaveRequest  + APPROVE → LEAVE_REQUEST.APPROVE
--        SalarySlip    + EXPORT  → SALARY_SLIP.EXPORT
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.Permission (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    PermissionCode          NVARCHAR(200)   NOT NULL,    -- e.g. LEAVE_REQUEST.APPROVE
    PermissionName          NVARCHAR(300)   NOT NULL,
    BusinessEntityId        BIGINT          NOT NULL,
    EntityActionId          BIGINT          NOT NULL,
    PermissionCategory      NVARCHAR(50)    NOT NULL,    -- PERMISSION_CATEGORY
    PermissionCategoryGroup AS CAST('PERMISSION_CATEGORY' AS NVARCHAR(50)) PERSISTED,
    Description             NVARCHAR(500)   NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               BIGINT          NOT NULL,
    UpdatedAt               DATETIME2       NULL,
    UpdatedBy               BIGINT          NULL,

    CONSTRAINT PK_Permission           PRIMARY KEY (Id),
    CONSTRAINT UQ_Permission_Code      UNIQUE      (PermissionCode),
    CONSTRAINT UQ_Permission_Entity_Action UNIQUE  (BusinessEntityId, EntityActionId),

    CONSTRAINT FK_Permission_BusinessEntity
        FOREIGN KEY (BusinessEntityId)
        REFERENCES auth.BusinessEntity (Id),

    CONSTRAINT FK_Permission_EntityAction
        FOREIGN KEY (EntityActionId)
        REFERENCES auth.EntityAction (Id),

    CONSTRAINT FK_Permission_Category
        FOREIGN KEY (PermissionCategory, PermissionCategoryGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================================================================================
-- MODULE 3  —  ROLE MANAGEMENT
-- Role     — a named set of permissions for a specific job function.
-- RoleGroup — a curated bundle of roles that maps to a business function / department responsibility.
--             Employees are assigned to a RoleGroup, not to individual roles directly.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 3.1  Role
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.Role (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    RoleCode        NVARCHAR(100)   NOT NULL,
    RoleName        NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(500)   NULL,
    IsSystemRole    BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       BIGINT          NOT NULL,
    UpdatedAt       DATETIME2       NULL,
    UpdatedBy       BIGINT          NULL,

    CONSTRAINT PK_Role       PRIMARY KEY (Id),
    CONSTRAINT UQ_Role_Code  UNIQUE      (RoleCode)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 3.2  RoleGroup
--      Represents a business function + department combination.
--      Examples: HR Operations, Payroll Team, People Manager, Helpdesk Agent
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.RoleGroup (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    RoleGroupCode   NVARCHAR(100)   NOT NULL,
    RoleGroupName   NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(500)   NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       BIGINT          NOT NULL,
    UpdatedAt       DATETIME2       NULL,
    UpdatedBy       BIGINT          NULL,

    CONSTRAINT PK_RoleGroup       PRIMARY KEY (Id),
    CONSTRAINT UQ_RoleGroup_Code  UNIQUE      (RoleGroupCode)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 3.3  RoleGroupRole
--      Many-to-many: which roles are included in a RoleGroup.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.RoleGroupRole (
    Id          BIGINT      NOT NULL IDENTITY(1,1),
    RoleGroupId BIGINT      NOT NULL,
    RoleId      BIGINT      NOT NULL,
    IsActive    BIT         NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy   BIGINT      NOT NULL,

    CONSTRAINT PK_RoleGroupRole     PRIMARY KEY (Id),
    CONSTRAINT UQ_RoleGroupRole     UNIQUE      (RoleGroupId, RoleId),

    CONSTRAINT FK_RoleGroupRole_RoleGroup
        FOREIGN KEY (RoleGroupId) REFERENCES auth.RoleGroup (Id),

    CONSTRAINT FK_RoleGroupRole_Role
        FOREIGN KEY (RoleId)      REFERENCES auth.Role (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 3.4  RolePermission
--      Grants (ALLOW) or explicitly denies (DENY) a permission to a role.
--      DENY always wins at evaluation time.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.RolePermission (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    RoleId          BIGINT          NOT NULL,
    PermissionId    BIGINT          NOT NULL,
    Effect          NVARCHAR(50)    NOT NULL DEFAULT 'ALLOW',   -- AUTH_EFFECT
    EffectGroup     AS CAST('AUTH_EFFECT' AS NVARCHAR(50)) PERSISTED,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       BIGINT          NOT NULL,
    UpdatedAt       DATETIME2       NULL,
    UpdatedBy       BIGINT          NULL,

    CONSTRAINT PK_RolePermission    PRIMARY KEY (Id),
    CONSTRAINT UQ_RolePermission    UNIQUE      (RoleId, PermissionId),

    CONSTRAINT FK_RolePermission_Role
        FOREIGN KEY (RoleId)        REFERENCES auth.Role       (Id),

    CONSTRAINT FK_RolePermission_Permission
        FOREIGN KEY (PermissionId)  REFERENCES auth.Permission (Id),

    CONSTRAINT FK_RolePermission_Effect
        FOREIGN KEY (Effect, EffectGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================================================================================
-- MODULE 4  —  EMPLOYEE ASSIGNMENT
-- Employees are assigned to one or more RoleGroups.
-- Each assignment can carry an optional scope (legal entity, department, etc.)
-- so the same RoleGroup can mean different things in different scopes.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 4.1  EmployeeRoleGroup
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.EmployeeRoleGroup (
    Id                  BIGINT      NOT NULL IDENTITY(1,1),
    EmployeeId          BIGINT      NOT NULL,
    RoleGroupId         BIGINT      NOT NULL,
    -- Optional scope: narrows the effective reach of this assignment.
    -- ScopeTypeId  → time.ScopeType (GLOBAL/COUNTRY/LEGAL_ENTITY/OFFICE/DEPARTMENT/TEAM/EMPLOYEE)
    -- ScopeRefId   → PK of the scoped entity (e.g. DepartmentId when ScopeType = DEPARTMENT)
    ScopeTypeId         BIGINT      NULL,
    ScopeRefId          BIGINT      NULL,
    EffectiveFrom       DATE        NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    EffectiveTo         DATE        NULL,
    AssignedBy          BIGINT      NOT NULL,
    IsActive            BIT         NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT      NOT NULL,
    UpdatedAt           DATETIME2   NULL,
    UpdatedBy           BIGINT      NULL,

    CONSTRAINT PK_EmployeeRoleGroup PRIMARY KEY (Id),

    CONSTRAINT FK_ERG_Employee
        FOREIGN KEY (EmployeeId)    REFERENCES employee.Employee (Id),

    CONSTRAINT FK_ERG_RoleGroup
        FOREIGN KEY (RoleGroupId)   REFERENCES auth.RoleGroup (Id),

    CONSTRAINT FK_ERG_ScopeType
        FOREIGN KEY (ScopeTypeId)   REFERENCES time.ScopeType (Id),

    CONSTRAINT FK_ERG_AssignedBy
        FOREIGN KEY (AssignedBy)    REFERENCES employee.Employee (Id)
);
GO

-- ============================================================================================================================
-- MODULE 5  —  RECORD-LEVEL SECURITY  (RLS)
-- Controls which rows of a BusinessEntity an employee (via their role) can access.
-- Two tables work together:
--   RecordAccessPolicy  — declares the access scope for a Role on a BusinessEntity.
--   RecordAccessScope   — lists the concrete scope values that the policy applies to,
--                          and optionally attaches ABAC conditions (JSON).
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 5.1  RecordAccessPolicy
--      "Role X can access BusinessEntity Y within scope Z."
--      AccessScope maps to the RECORD_ACCESS_SCOPE status group.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.RecordAccessPolicy (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    RoleId              BIGINT          NOT NULL,
    BusinessEntityId    BIGINT          NOT NULL,
    -- The broadest scope level this policy applies to.
    AccessScope         NVARCHAR(50)    NOT NULL,    -- RECORD_ACCESS_SCOPE
    AccessScopeGroup    AS CAST('RECORD_ACCESS_SCOPE' AS NVARCHAR(50)) PERSISTED,
    Effect              NVARCHAR(50)    NOT NULL DEFAULT 'ALLOW',
    EffectGroup         AS CAST('AUTH_EFFECT' AS NVARCHAR(50)) PERSISTED,
    -- ABAC conditions (evaluated at runtime in the service layer).
    -- JSON array: [{"attribute":"EmploymentType","operator":"EQUALS","value":"FULL_TIME"}]
    ConditionJson       NVARCHAR(MAX)   NULL,
    Description         NVARCHAR(500)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT          NOT NULL,
    UpdatedAt           DATETIME2       NULL,
    UpdatedBy           BIGINT          NULL,

    CONSTRAINT PK_RecordAccessPolicy    PRIMARY KEY (Id),
    CONSTRAINT UQ_RecordAccessPolicy    UNIQUE      (RoleId, BusinessEntityId),

    CONSTRAINT FK_RAP_Role
        FOREIGN KEY (RoleId)            REFERENCES auth.Role           (Id),

    CONSTRAINT FK_RAP_BusinessEntity
        FOREIGN KEY (BusinessEntityId)  REFERENCES auth.BusinessEntity (Id),

    CONSTRAINT FK_RAP_AccessScope
        FOREIGN KEY (AccessScope, AccessScopeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_RAP_Effect
        FOREIGN KEY (Effect, EffectGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 5.2  RecordAccessScope
--      Concrete scope values for a RecordAccessPolicy.
--      When ScopeRefId IS NULL the policy covers all values of that ScopeType
--      (e.g. ScopeType = DEPARTMENT, ScopeRefId = NULL → all departments).
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.RecordAccessScope (
    Id                      BIGINT      NOT NULL IDENTITY(1,1),
    RecordAccessPolicyId    BIGINT      NOT NULL,
    ScopeTypeId             BIGINT      NOT NULL,    -- time.ScopeType
    ScopeRefId              BIGINT      NULL,         -- PK of the scoped entity; NULL = all
    IsActive                BIT         NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               BIGINT      NOT NULL,

    CONSTRAINT PK_RecordAccessScope PRIMARY KEY (Id),

    CONSTRAINT FK_RAS_RecordAccessPolicy
        FOREIGN KEY (RecordAccessPolicyId) REFERENCES auth.RecordAccessPolicy (Id),

    CONSTRAINT FK_RAS_ScopeType
        FOREIGN KEY (ScopeTypeId)          REFERENCES time.ScopeType (Id)
);
GO

-- ============================================================================================================================
-- MODULE 6  —  FIELD-LEVEL SECURITY  (FLS)
-- Only fields explicitly registered in ConfidentialField are masked.
-- All other fields are returned as-is.
--
-- ConfidentialField  — declares a sensitive field using (EntityName, FieldName) — both logical names.
-- ConfidentialAccessPolicy — grants VIEW_CONFIDENTIAL to a role for a specific field,
--                            meaning those role members skip masking and receive raw values.
--
-- Masking is enforced in the service / authorization layer AFTER data is fetched from the DB.
-- The DB always stores and returns the original value.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 6.1  ConfidentialField
--      EntityName  — the logical BusinessEntity name  (e.g. "Employee")
--      FieldName   — the logical field / attribute name (e.g. "PANNumber")
--      Neither references a physical schema, table, or column name.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.ConfidentialField (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    BusinessEntityId    BIGINT          NOT NULL,
    EntityName          NVARCHAR(100)   NOT NULL,    -- logical entity  (e.g. "Employee")
    FieldName           NVARCHAR(100)   NOT NULL,    -- logical field   (e.g. "PANNumber")
    FieldLabel          NVARCHAR(200)   NOT NULL,    -- display label
    DefaultMaskType     NVARCHAR(50)    NOT NULL,    -- FIELD_MASK_TYPE
    DefaultMaskTypeGroup AS CAST('FIELD_MASK_TYPE' AS NVARCHAR(50)) PERSISTED,
    MaskPattern         NVARCHAR(200)   NULL,        -- optional pattern, e.g. 'XXXXX####X'
    SensitivityLevel    TINYINT         NOT NULL DEFAULT 1,  -- 1 (low) … 5 (critical)
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT          NOT NULL,
    UpdatedAt           DATETIME2       NULL,
    UpdatedBy           BIGINT          NULL,

    CONSTRAINT PK_ConfidentialField         PRIMARY KEY (Id),
    CONSTRAINT UQ_ConfidentialField         UNIQUE      (EntityName, FieldName),

    CONSTRAINT FK_CF_BusinessEntity
        FOREIGN KEY (BusinessEntityId)      REFERENCES auth.BusinessEntity (Id),

    CONSTRAINT FK_CF_MaskType
        FOREIGN KEY (DefaultMaskType, DefaultMaskTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 6.2  ConfidentialAccessPolicy
--      Grants a Role (or a specific Employee) the ability to bypass masking
--      for a particular ConfidentialField.
--      Effect = ALLOW  → see raw value (masking bypassed).
--      Effect = DENY   → always mask, even if the role would otherwise allow it.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.ConfidentialAccessPolicy (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    ConfidentialFieldId     BIGINT          NOT NULL,
    GranteeRoleId           BIGINT          NULL,    -- grant to a role ...
    GranteeEmployeeId       BIGINT          NULL,    -- ... or to a specific employee
    Effect                  NVARCHAR(50)    NOT NULL DEFAULT 'ALLOW',
    EffectGroup             AS CAST('AUTH_EFFECT' AS NVARCHAR(50)) PERSISTED,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               BIGINT          NOT NULL,
    UpdatedAt               DATETIME2       NULL,
    UpdatedBy               BIGINT          NULL,

    CONSTRAINT PK_ConfidentialAccessPolicy PRIMARY KEY (Id),

    CONSTRAINT CK_CAP_GranteeRequired
        CHECK (GranteeRoleId IS NOT NULL OR GranteeEmployeeId IS NOT NULL),

    CONSTRAINT FK_CAP_ConfidentialField
        FOREIGN KEY (ConfidentialFieldId)  REFERENCES auth.ConfidentialField (Id),

    CONSTRAINT FK_CAP_GranteeRole
        FOREIGN KEY (GranteeRoleId)        REFERENCES auth.Role (Id),

    CONSTRAINT FK_CAP_GranteeEmployee
        FOREIGN KEY (GranteeEmployeeId)    REFERENCES employee.Employee (Id),

    CONSTRAINT FK_CAP_Effect
        FOREIGN KEY (Effect, EffectGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================================================================================
-- MODULE 7  —  UI & API AUTHORIZATION
-- Controls page/component visibility and API endpoint access.
-- Both reference BusinessEntity to keep the model coherent.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 7.1  UIResource
--      A navigable page, menu item, or component in the frontend.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.UIResource (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    BusinessEntityId    BIGINT          NULL,        -- optional link to business entity
    ResourceKey         NVARCHAR(200)   NOT NULL,    -- e.g. "PAGE:/payroll/salary-slip"
    ResourceLabel       NVARCHAR(200)   NOT NULL,    -- e.g. "Salary Slip"
    ResourceType        NVARCHAR(50)    NOT NULL,    -- PAGE | MENU | COMPONENT | BUTTON
    ParentUIResourceId  BIGINT          NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT          NOT NULL,
    UpdatedAt           DATETIME2       NULL,
    UpdatedBy           BIGINT          NULL,

    CONSTRAINT PK_UIResource        PRIMARY KEY (Id),
    CONSTRAINT UQ_UIResource_Key    UNIQUE      (ResourceKey),

    CONSTRAINT FK_UIResource_BusinessEntity
        FOREIGN KEY (BusinessEntityId)  REFERENCES auth.BusinessEntity (Id),

    CONSTRAINT FK_UIResource_Parent
        FOREIGN KEY (ParentUIResourceId) REFERENCES auth.UIResource (Id)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 7.2  UIPermission
--      Maps a Role to a UIResource (ALLOW / DENY visibility).
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.UIPermission (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    RoleId          BIGINT          NOT NULL,
    UIResourceId    BIGINT          NOT NULL,
    Effect          NVARCHAR(50)    NOT NULL DEFAULT 'ALLOW',
    EffectGroup     AS CAST('AUTH_EFFECT' AS NVARCHAR(50)) PERSISTED,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       BIGINT          NOT NULL,
    UpdatedAt       DATETIME2       NULL,
    UpdatedBy       BIGINT          NULL,

    CONSTRAINT PK_UIPermission  PRIMARY KEY (Id),
    CONSTRAINT UQ_UIPermission  UNIQUE      (RoleId, UIResourceId),

    CONSTRAINT FK_UIPermission_Role
        FOREIGN KEY (RoleId)        REFERENCES auth.Role       (Id),

    CONSTRAINT FK_UIPermission_UIResource
        FOREIGN KEY (UIResourceId)  REFERENCES auth.UIResource (Id),

    CONSTRAINT FK_UIPermission_Effect
        FOREIGN KEY (Effect, EffectGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 7.3  APIResource
--      A REST endpoint registered for authorization.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.APIResource (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    BusinessEntityId    BIGINT          NULL,
    ResourceKey         NVARCHAR(300)   NOT NULL,    -- e.g. "POST /api/attendance/leave"
    RoutePath           NVARCHAR(300)   NOT NULL,    -- e.g. "/api/attendance/leave"
    HttpMethod          NVARCHAR(50)    NOT NULL,
    HttpMethodGroup     AS CAST('HTTP_METHOD' AS NVARCHAR(50)) PERSISTED,
    ServiceName         NVARCHAR(100)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT          NOT NULL,
    UpdatedAt           DATETIME2       NULL,
    UpdatedBy           BIGINT          NULL,

    CONSTRAINT PK_APIResource       PRIMARY KEY (Id),
    CONSTRAINT UQ_APIResource_Key   UNIQUE      (RoutePath, HttpMethod),

    CONSTRAINT FK_APIResource_BusinessEntity
        FOREIGN KEY (BusinessEntityId)  REFERENCES auth.BusinessEntity (Id),

    CONSTRAINT FK_APIResource_HttpMethod
        FOREIGN KEY (HttpMethod, HttpMethodGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 7.4  APIPermission
--      Maps a Role to an APIResource (ALLOW / DENY).
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.APIPermission (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    RoleId          BIGINT          NOT NULL,
    APIResourceId   BIGINT          NOT NULL,
    Effect          NVARCHAR(50)    NOT NULL DEFAULT 'ALLOW',
    EffectGroup     AS CAST('AUTH_EFFECT' AS NVARCHAR(50)) PERSISTED,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       BIGINT          NOT NULL,
    UpdatedAt       DATETIME2       NULL,
    UpdatedBy       BIGINT          NULL,

    CONSTRAINT PK_APIPermission PRIMARY KEY (Id),
    CONSTRAINT UQ_APIPermission UNIQUE      (RoleId, APIResourceId),

    CONSTRAINT FK_APIPermission_Role
        FOREIGN KEY (RoleId)        REFERENCES auth.Role        (Id),

    CONSTRAINT FK_APIPermission_APIResource
        FOREIGN KEY (APIResourceId) REFERENCES auth.APIResource (Id),

    CONSTRAINT FK_APIPermission_Effect
        FOREIGN KEY (Effect, EffectGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================================================================================
-- MODULE 8  —  WORKFLOW AUTHORIZATION
-- Controls who can perform which workflow action (APPROVE / REJECT / SUBMIT)
-- on a specific WorkflowStep, based on their Role.
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 8.1  WorkflowPermission
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.WorkflowPermission (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    WorkflowDefinitionId    BIGINT          NOT NULL,
    WorkflowStepId          BIGINT          NOT NULL,
    RoleId                  BIGINT          NOT NULL,
    -- Action must be a workflow-relevant permission action (APPROVE / REJECT / VIEW …)
    EntityActionId          BIGINT          NOT NULL,
    Effect                  NVARCHAR(50)    NOT NULL DEFAULT 'ALLOW',
    EffectGroup             AS CAST('AUTH_EFFECT' AS NVARCHAR(50)) PERSISTED,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               BIGINT          NOT NULL,
    UpdatedAt               DATETIME2       NULL,
    UpdatedBy               BIGINT          NULL,

    CONSTRAINT PK_WorkflowPermission PRIMARY KEY (Id),
    CONSTRAINT UQ_WorkflowPermission UNIQUE      (WorkflowStepId, RoleId, EntityActionId),

    CONSTRAINT FK_WP_WorkflowDefinition
        FOREIGN KEY (WorkflowDefinitionId) REFERENCES workflow.WorkflowDefinition (Id),

    CONSTRAINT FK_WP_WorkflowStep
        FOREIGN KEY (WorkflowStepId)       REFERENCES workflow.WorkflowStep (Id),

    CONSTRAINT FK_WP_Role
        FOREIGN KEY (RoleId)               REFERENCES auth.Role (Id),

    CONSTRAINT FK_WP_EntityAction
        FOREIGN KEY (EntityActionId)       REFERENCES auth.EntityAction (Id),

    CONSTRAINT FK_WP_Effect
        FOREIGN KEY (Effect, EffectGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ============================================================================================================================
-- MODULE 9  —  DELEGATED ACCESS
-- ----------------------------------------------------------------------------------------------------------------------------
-- Allows employee A (Delegator) to temporarily grant a scoped set of permissions
-- to employee B (Delegatee) for a defined time window.
--
-- Two-table design
--   DelegatedAccess            — the delegation envelope: who, to whom, when, why, status.
--   DelegatedAccessPermission  — the exact permissions being delegated (one row per Permission).
--
-- Key rules enforced by the service layer
--   1. A delegation is active only when:
--        DelegationStatus = 'ACTIVE'
--        AND GETUTCDATE() BETWEEN ValidFrom AND ValidTo
--   2. The delegator can only delegate permissions they currently hold themselves
--      (service layer must verify before inserting DelegatedAccessPermission rows).
--   3. A Delegatee inherits delegated permissions ADDITIONALLY to their own RBAC permissions.
--   4. DENY on any of the delegatee's own RolePermissions still wins — delegation cannot
--      override an explicit DENY.
--   5. Delegation is surfaced in vw_EmployeeEffectiveDelegatedPermissions (see Views section).
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- 9.1  DelegatedAccess
--      The delegation envelope.
--      One row per delegation agreement between a Delegator and a Delegatee.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.DelegatedAccess (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),

    -- Who is granting access
    DelegatorEmployeeId BIGINT          NOT NULL,

    -- Who receives the access
    DelegateeEmployeeId BIGINT          NOT NULL,

    -- Optional scope: when set, the delegated permissions apply only within this scope
    -- (e.g. a manager on leave grants their leave-approval right scoped to their department).
    -- ScopeTypeId  → time.ScopeType
    -- ScopeRefId   → PK of the scoped entity (e.g. DepartmentId)
    ScopeTypeId         BIGINT          NULL,
    ScopeRefId          BIGINT          NULL,

    -- Validity window — both are DATETIME2 so intra-day delegations are supported.
    ValidFrom           DATETIME2       NOT NULL,
    ValidTo             DATETIME2       NOT NULL,

    -- Human-readable reason (shown to delegatee and admins)
    Reason              NVARCHAR(500)   NULL,

    -- Lifecycle status
    DelegationStatus    NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    DelegationStatusGroup AS CAST('DELEGATED_ACCESS_STATUS' AS NVARCHAR(50)) PERSISTED,

    -- Acceptance / revocation tracking
    AcceptedAt          DATETIME2       NULL,
    DeclinedAt          DATETIME2       NULL,
    DeclineReason       NVARCHAR(500)   NULL,
    RevokedAt           DATETIME2       NULL,
    RevokedBy           BIGINT          NULL,
    RevokeReason        NVARCHAR(500)   NULL,

    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT          NOT NULL,
    UpdatedAt           DATETIME2       NULL,
    UpdatedBy           BIGINT          NULL,

    CONSTRAINT PK_DelegatedAccess PRIMARY KEY (Id),

    CONSTRAINT CK_DelegatedAccess_DifferentEmployees
        CHECK (DelegatorEmployeeId <> DelegateeEmployeeId),

    CONSTRAINT CK_DelegatedAccess_ValidWindow
        CHECK (ValidTo > ValidFrom),

    CONSTRAINT FK_DA_Delegator
        FOREIGN KEY (DelegatorEmployeeId) REFERENCES employee.Employee (Id),

    CONSTRAINT FK_DA_Delegatee
        FOREIGN KEY (DelegateeEmployeeId) REFERENCES employee.Employee (Id),

    CONSTRAINT FK_DA_ScopeType
        FOREIGN KEY (ScopeTypeId)         REFERENCES time.ScopeType (Id),

    CONSTRAINT FK_DA_RevokedBy
        FOREIGN KEY (RevokedBy)           REFERENCES employee.Employee (Id),

    CONSTRAINT FK_DA_DelegationStatus
        FOREIGN KEY (DelegationStatus, DelegationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- 9.2  DelegatedAccessPermission
--      The individual permissions being shared.
--      Each row grants one Permission to the Delegatee for the duration of the parent
--      DelegatedAccess record.
--
--      Effect follows the same AUTH_EFFECT pattern:
--        ALLOW (default) — the delegatee gains this permission.
--        DENY            — explicitly exclude a permission even if other delegations would grant it.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE auth.DelegatedAccessPermission (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    DelegatedAccessId   BIGINT          NOT NULL,
    PermissionId        BIGINT          NOT NULL,
    Effect              NVARCHAR(50)    NOT NULL DEFAULT 'ALLOW',
    EffectGroup         AS CAST('AUTH_EFFECT' AS NVARCHAR(50)) PERSISTED,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           BIGINT          NOT NULL,

    CONSTRAINT PK_DelegatedAccessPermission   PRIMARY KEY (Id),
    CONSTRAINT UQ_DelegatedAccessPermission   UNIQUE      (DelegatedAccessId, PermissionId),

    CONSTRAINT FK_DAP_DelegatedAccess
        FOREIGN KEY (DelegatedAccessId) REFERENCES auth.DelegatedAccess (Id),

    CONSTRAINT FK_DAP_Permission
        FOREIGN KEY (PermissionId)      REFERENCES auth.Permission (Id),

    CONSTRAINT FK_DAP_Effect
        FOREIGN KEY (Effect, EffectGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO
-- ============================================================================================================================

-- BusinessEntity
CREATE INDEX IX_BusinessEntity_Module   ON auth.BusinessEntity (BusinessModuleId);

-- Permission
CREATE INDEX IX_Permission_Entity       ON auth.Permission (BusinessEntityId);
CREATE INDEX IX_Permission_Action       ON auth.Permission (EntityActionId);
CREATE INDEX IX_Permission_Category     ON auth.Permission (PermissionCategory);

-- RoleGroupRole
CREATE INDEX IX_RoleGroupRole_Group     ON auth.RoleGroupRole (RoleGroupId);
CREATE INDEX IX_RoleGroupRole_Role      ON auth.RoleGroupRole (RoleId);

-- RolePermission
CREATE INDEX IX_RolePermission_Role     ON auth.RolePermission (RoleId, IsActive);
CREATE INDEX IX_RolePermission_Perm     ON auth.RolePermission (PermissionId, IsActive);
CREATE INDEX IX_RolePermission_Effect   ON auth.RolePermission (RoleId, Effect, IsActive);

-- EmployeeRoleGroup  (hot path — evaluated on every auth check)
CREATE INDEX IX_ERG_Employee            ON auth.EmployeeRoleGroup (EmployeeId, IsActive, EffectiveFrom, EffectiveTo);
CREATE INDEX IX_ERG_RoleGroup           ON auth.EmployeeRoleGroup (RoleGroupId, IsActive);
CREATE INDEX IX_ERG_Scope               ON auth.EmployeeRoleGroup (ScopeTypeId, ScopeRefId);

-- RecordAccessPolicy
CREATE INDEX IX_RAP_Role_Entity         ON auth.RecordAccessPolicy (RoleId, BusinessEntityId, IsActive);
CREATE INDEX IX_RAP_AccessScope         ON auth.RecordAccessPolicy (AccessScope, IsActive);

-- RecordAccessScope
CREATE INDEX IX_RAS_Policy              ON auth.RecordAccessScope (RecordAccessPolicyId, IsActive);
CREATE INDEX IX_RAS_Scope               ON auth.RecordAccessScope (ScopeTypeId, ScopeRefId);

-- ConfidentialField
CREATE INDEX IX_CF_EntityField          ON auth.ConfidentialField (EntityName, FieldName);
CREATE INDEX IX_CF_BusinessEntity       ON auth.ConfidentialField (BusinessEntityId);

-- ConfidentialAccessPolicy
CREATE INDEX IX_CAP_Field               ON auth.ConfidentialAccessPolicy (ConfidentialFieldId, IsActive);
CREATE INDEX IX_CAP_Role                ON auth.ConfidentialAccessPolicy (GranteeRoleId,     IsActive);
CREATE INDEX IX_CAP_Employee            ON auth.ConfidentialAccessPolicy (GranteeEmployeeId, IsActive);

-- UIResource / UIPermission
CREATE INDEX IX_UIResource_Parent       ON auth.UIResource   (ParentUIResourceId);
CREATE INDEX IX_UIPermission_Role       ON auth.UIPermission (RoleId,       IsActive);
CREATE INDEX IX_UIPermission_Resource   ON auth.UIPermission (UIResourceId, IsActive);

-- APIResource / APIPermission
CREATE INDEX IX_APIResource_Path        ON auth.APIResource   (RoutePath, HttpMethod);
CREATE INDEX IX_APIPermission_Role      ON auth.APIPermission (RoleId,        IsActive);
CREATE INDEX IX_APIPermission_Resource  ON auth.APIPermission (APIResourceId, IsActive);

-- WorkflowPermission
CREATE INDEX IX_WP_Step_Role            ON auth.WorkflowPermission (WorkflowStepId, RoleId, IsActive);

-- DelegatedAccess  (hot path — checked on every delegatee permission resolution)
CREATE INDEX IX_DA_Delegatee_Status     ON auth.DelegatedAccess (DelegateeEmployeeId, DelegationStatus, IsActive, ValidFrom, ValidTo);
CREATE INDEX IX_DA_Delegator_Status     ON auth.DelegatedAccess (DelegatorEmployeeId, DelegationStatus, IsActive);
CREATE INDEX IX_DA_Validity             ON auth.DelegatedAccess (ValidFrom, ValidTo, DelegationStatus);
CREATE INDEX IX_DA_Scope                ON auth.DelegatedAccess (ScopeTypeId, ScopeRefId);

-- DelegatedAccessPermission
CREATE INDEX IX_DAP_DelegatedAccess     ON auth.DelegatedAccessPermission (DelegatedAccessId, IsActive);
CREATE INDEX IX_DAP_Permission_Effect   ON auth.DelegatedAccessPermission (PermissionId, Effect, IsActive);

GO

-- ============================================================================================================================
-- VIEWS  —  Runtime resolution helpers consumed by microservices
-- ============================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------------------
-- V1  vw_EmployeeEffectiveRoles
--     Returns every active role currently in effect for each employee
--     (via their active RoleGroup assignments).
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW auth.vw_EmployeeEffectiveRoles AS
SELECT
    erg.EmployeeId,
    rg.Id           AS RoleGroupId,
    rg.RoleGroupCode,
    rg.RoleGroupName,
    r.Id            AS RoleId,
    r.RoleCode,
    r.RoleName,
    erg.ScopeTypeId,
    erg.ScopeRefId,
    erg.EffectiveFrom,
    erg.EffectiveTo
FROM      auth.EmployeeRoleGroup erg
JOIN      auth.RoleGroup         rg  ON rg.Id     = erg.RoleGroupId  AND rg.IsActive  = 1
JOIN      auth.RoleGroupRole     rgr ON rgr.RoleGroupId = rg.Id       AND rgr.IsActive = 1
JOIN      auth.Role              r   ON r.Id       = rgr.RoleId       AND r.IsActive   = 1
WHERE erg.IsActive     = 1
  AND erg.EffectiveFrom <= CAST(GETUTCDATE() AS DATE)
  AND (erg.EffectiveTo  IS NULL OR erg.EffectiveTo >= CAST(GETUTCDATE() AS DATE));
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- V2  vw_EmployeeEffectivePermissions
--     Flat permission list for each employee.
--     Consumers: API gateway middleware, service-layer permission checks.
--     DENY-wins logic: filter out any PermissionCode where ANY role carries DENY.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW auth.vw_EmployeeEffectivePermissions AS
SELECT
    er.EmployeeId,
    er.RoleGroupId,
    er.RoleGroupCode,
    er.RoleId,
    er.RoleCode,
    p.PermissionCode,
    p.Id                AS PermissionId,
    be.EntityName       AS BusinessEntity,
    ea.ActionCode,
    p.PermissionCategory,
    rp.Effect,
    er.ScopeTypeId,
    er.ScopeRefId
FROM      auth.vw_EmployeeEffectiveRoles er
JOIN      auth.RolePermission rp ON rp.RoleId     = er.RoleId      AND rp.IsActive = 1
JOIN      auth.Permission     p  ON p.Id          = rp.PermissionId AND p.IsActive  = 1
JOIN      auth.BusinessEntity be ON be.Id         = p.BusinessEntityId
JOIN      auth.EntityAction   ea ON ea.Id         = p.EntityActionId;
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- V3  vw_EmployeeConfidentialAccess
--     For a given employee, lists all confidential fields they may view unmasked.
--     Service layer: if (EntityName, FieldName) NOT in this view → apply mask.
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW auth.vw_EmployeeConfidentialAccess AS
-- Grant via Role
SELECT
    er.EmployeeId,
    cf.EntityName,
    cf.FieldName,
    cf.FieldLabel,
    cf.DefaultMaskType,
    cf.MaskPattern,
    cap.Effect
FROM      auth.vw_EmployeeEffectiveRoles    er
JOIN      auth.ConfidentialAccessPolicy     cap ON cap.GranteeRoleId = er.RoleId AND cap.IsActive = 1
JOIN      auth.ConfidentialField            cf  ON cf.Id             = cap.ConfidentialFieldId AND cf.IsActive = 1

UNION ALL

-- Grant via direct Employee override
SELECT
    cap.GranteeEmployeeId   AS EmployeeId,
    cf.EntityName,
    cf.FieldName,
    cf.FieldLabel,
    cf.DefaultMaskType,
    cf.MaskPattern,
    cap.Effect
FROM      auth.ConfidentialAccessPolicy cap
JOIN      auth.ConfidentialField        cf  ON cf.Id = cap.ConfidentialFieldId AND cf.IsActive = 1
WHERE cap.GranteeEmployeeId IS NOT NULL
  AND cap.IsActive = 1;
GO

-- ----------------------------------------------------------------------------------------------------------------------------
-- V4  vw_EmployeeEffectiveDelegatedPermissions
--     Returns all permissions currently delegated TO an employee
--     (i.e. permissions the employee holds by virtue of someone else's delegation).
--
--     Usage in service layer:
--       UNION this view into permission checks alongside vw_EmployeeEffectivePermissions.
--       DENY on the delegatee's own RolePermissions still wins — apply after union.
--
--     Active delegation criteria:
--       DelegationStatus = 'ACTIVE'
--       AND GETUTCDATE() BETWEEN ValidFrom AND ValidTo
--       AND DelegatedAccess.IsActive = 1
--       AND DelegatedAccessPermission.IsActive = 1
-- ----------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW auth.vw_EmployeeEffectiveDelegatedPermissions AS
SELECT
    da.DelegateeEmployeeId              AS EmployeeId,
    da.Id                               AS DelegatedAccessId,
    da.DelegatorEmployeeId,
    dap.PermissionId,
    p.PermissionCode,
    be.EntityName                       AS BusinessEntity,
    ea.ActionCode,
    p.PermissionCategory,
    dap.Effect,
    da.ScopeTypeId,
    da.ScopeRefId,
    da.ValidFrom,
    da.ValidTo,
    da.Reason                           AS DelegationReason
FROM      auth.DelegatedAccess           da
JOIN      auth.DelegatedAccessPermission dap ON dap.DelegatedAccessId = da.Id
                                             AND dap.IsActive          = 1
JOIN      auth.Permission                p   ON p.Id                   = dap.PermissionId
                                             AND p.IsActive             = 1
JOIN      auth.BusinessEntity            be  ON be.Id                  = p.BusinessEntityId
JOIN      auth.EntityAction              ea  ON ea.Id                  = p.EntityActionId
WHERE da.IsActive          = 1
  AND da.DelegationStatus  = 'ACTIVE'
  AND GETUTCDATE() BETWEEN da.ValidFrom AND da.ValidTo;
GO

PRINT 'Auth schema created successfully.';

GO