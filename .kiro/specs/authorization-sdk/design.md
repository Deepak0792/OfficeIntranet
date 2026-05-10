# Authorization SDK - Design Document

## Overview

The Authorization SDK is a shared library that will be used by every module in the Identity microservice to enforce fine-grained permissions before allowing any action. It implements a record-level, attribute-aware permission system with three enforcement gates: scope checking, confidentiality checking, and field masking.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Application Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │
│  │  Controllers │  │  Services    │  │  Middleware  │               │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘               │
│         │                  │                  │                       │
│         └──────────────────┴──────────────────┘                       │
│                            │                                          │
│                    ┌───────▼───────┐                                  │
│                    │  Auth SDK     │                                  │
│                    │  Gateway      │                                  │
│                    └───────┬───────┘                                  │
│                            │                                          │
│         ┌──────────────────┼──────────────────┐                      │
│         │                  │                  │                      │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐               │
│  │  Gate 1:     │  │  Gate 2:     │  │  Gate 3:     │               │
│  │  Scope Check │  │ Confidential │  │  Field Mask  │               │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘               │
│         │                  │                  │                       │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐               │
│  │  Scope        │  │  Confidential│  │  Masking     │               │
│  │  Resolvers    │  │  Policies    │  │  Engine      │               │
│  └──────────────┘  └──────────────┘  └──────────────┘               │
│                            │                                          │
│                    ┌───────▼───────┐                                  │
│                    │  Policy Store │                                  │
│                    │  (Database)   │                                  │
│                    └───────────────┘                                  │
└─────────────────────────────────────────────────────────────────────┘
```

### Component Structure

```
SdxCore.Identity.Authorization/
├── Core/
│   ├── Models/
│   │   ├── PermissionRequest.cs
│   │   ├── PermissionResult.cs
│   │   ├── FieldMaskingPolicy.cs
│   │   └── ConfidentialityPolicy.cs
│   ├── Interfaces/
│   │   ├── IPermissionEngine.cs
│   │   ├── IScopeResolver.cs
│   │   ├── IFieldMaskingEngine.cs
│   │   └── IConfidentialityEngine.cs
│   └── Exceptions/
│       ├── PermissionDeniedException.cs
│       └── ConfidentialAccessException.cs
├── ScopeResolvers/
│   ├── AllScopeResolver.cs
│   ├── OwnRecordScopeResolver.cs
│   ├── OwnTeamScopeResolver.cs
│   ├── DepartmentScopeResolver.cs
│   ├── GradeScopeResolver.cs
│   └── CustomScopeResolver.cs
├── FieldMasking/
│   ├── MaskingStrategies/
│   │   ├── FullMaskingStrategy.cs
│   │   ├── PartialMaskingStrategy.cs
│   │   └── RedactMaskingStrategy.cs
│   └── MaskingEngine.cs
├── Confidentiality/
│   ├── ConfidentialityEngine.cs
│   └── AuditLogWriter.cs
├── Infrastructure/
│   ├── PolicyRepository.cs
│   └── ScopeResolverRegistry.cs
└── Extensions/
    └── ServiceCollectionExtensions.cs
```

## Core Models

### PermissionRequest

```csharp
public class PermissionRequest
{
    public string Module { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public string Action { get; set; } = string.Empty;
    public int UserId { get; set; }
    public int? RecordId { get; set; }
    public string Channel { get; set; } = "All"; // All, UI, API, Export
}
```

### PermissionResult

```csharp
public class PermissionResult
{
    public bool IsAllowed { get; set; }
    public string? Reason { get; set; }
    public int StatusCode { get; set; } // 200, 403, 404
}
```

### FieldMaskingPolicy

```csharp
public class FieldMaskingPolicy
{
    public int Id { get; set; }
    public string Module { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public string FieldName { get; set; } = string.Empty;
    public string MaskType { get; set; } = string.Empty; // Full, Partial, Redact
    public string? MaskPattern { get; set; }
    public string RequiredPermission { get; set; } = string.Empty;
    public string AppliesTo { get; set; } = "All";
}
```

### ConfidentialityPolicy

```csharp
public class ConfidentialityPolicy
{
    public int Id { get; set; }
    public string Module { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public string ConfidentialityLevel { get; set; } = string.Empty; // Standard, High, Critical
    public string? TriggerField { get; set; }
    public string? TriggerValue { get; set; }
    public string AccessDeniedBehaviour { get; set; } = "Hide";
    public string RequiredPermission { get; set; } = string.Empty;
    public int? NotifyRoleGroupId { get; set; }
}
```

## Permission Flow: BusinessEntityRule → User RoleGroup

The permission system uses a chain of relationships to map BusinessEntityRule to user RoleGroup:

```
BusinessEntityRule
    ↓ (via Name)
AttributeRule
    ↓ (via AttributeRulePermission)
AttributeRulePermission
    ↓ (via AttributeRulePermissionRole)
Role
    ↓ (via RoleGroupRole)
RoleGroup
    ↓ (via UserRoleGroup)
User
```

### Detailed Mapping

1. **BusinessEntityRule** defines an action on an entity (e.g., "ApproveLeave", "ViewSlip")
   - `BusinessEntityId` links to the BusinessEntity
   - `Name` is the action name
   - `ScopeType` defines how scope is resolved (All, OwnRecord, OwnTeam, Department, Grade, Custom)

2. **AttributeRule** links to BusinessEntityRule via the action name
   - `AttributeEntityId` links to the AttributeEntity
   - `Name` matches the BusinessEntityRule.Name
   - `ScopeType` and `ScopeResolverKey` are inherited from BusinessEntityRule

3. **AttributeRulePermission** links AttributeRule to a Permission
   - `AttributeRuleId` links to the AttributeRule
   - `PermissionId` links to Permission (View, Edit, Create, Delete, Approve)

4. **AttributeRulePermissionRole** links AttributeRulePermission to a Role
   - `AttributeRulePermissionId` links to the AttributeRulePermission
   - `RoleId` links to the Role

5. **RoleGroupRole** links Role to a RoleGroup
   - `RoleGroupId` links to the RoleGroup
   - `RoleId` links to the Role

6. **UserRoleGroup** links User to a RoleGroup
   - `UserId` is the user ID
   - `RoleGroupId` links to the RoleGroup
   - `EffectiveFrom` and `EffectiveTo` define the validity period

### Permission Check Flow

When checking if a user can perform an action:

1. **Get User's RoleGroups**: Query `UserRoleGroup` for the user's active role groups
2. **Get RoleGroup Roles**: Query `RoleGroupRole` for roles in those groups
3. **Get Role Permissions**: Query `AttributeRulePermissionRole` for permissions assigned to those roles
4. **Get Attribute Rules**: Query `AttributeRule` for rules matching the action name
5. **Get BusinessEntityRule**: Query `BusinessEntityRule` for the entity and action
6. **Check Scope**: Use the `ScopeType` and `ScopeResolverKey` to verify the user's scope

### Example SQL Query

```sql
-- Check if user has permission to perform an action on an entity
SELECT DISTINCT br.Name AS BusinessEntityRuleName
FROM UserRoleGroup ugr
JOIN RoleGroupRole rgr ON ugr.RoleGroupId = rgr.RoleGroupId
JOIN AttributeRulePermissionRole arpr ON rgr.RoleId = arpr.RoleId
JOIN AttributeRule ar ON arpr.AttributeRuleId = ar.Id
JOIN BusinessEntityRule ber ON ar.Name = ber.Name
WHERE ugr.UserId = @UserId
  AND ber.ModuleId = @ModuleId
  AND ber.Name = @BusinessEntityRuleName
  AND ugr.EffectiveFrom <= GETDATE()
  AND (ugr.EffectiveTo IS NULL OR ugr.EffectiveTo >= GETDATE());
```

## Gate 1: Scope Resolution

### IScopeResolver Interface

```csharp
public interface IScopeResolver
{
    string ScopeType { get; }
    Task<bool> CanAccessAsync(int userId, int recordOwnerId, int? teamId, int? deptId, int? gradeId, CancellationToken cancellationToken = default);
}
```

### Scope Resolver Implementations

#### AllScopeResolver
- Always returns true
- Used when no row filtering is needed

#### OwnRecordScopeResolver
- Checks if `userId == recordOwnerId`
- Users can only access their own records

#### OwnTeamScopeResolver
- Checks if user is a team lead for the record's team
- Requires `UserTeam` table lookup

#### DepartmentScopeResolver
- Checks if user is a department head for the record's department
- Requires `UserDepartment` table lookup

#### GradeScopeResolver
- Checks if user's grade can view the record's grade
- Requires `GradeHierarchy` table lookup

#### CustomScopeResolver
- Executes custom SQL fragment from `CustomScopeRule` table
- Parameters: `@CurrentUserId`, `@RecordOwnerId`, `@TeamId`, `@DeptId`, `@GradeId`

## Gate 2: Confidentiality Checking

### ConfidentialityEngine

```csharp
public interface IConfidentialityEngine
{
    Task<ConfidentialityResult> CheckAsync(
        string module,
        string entityName,
        int userId,
        object record,
        string channel,
        CancellationToken cancellationToken = default);
}
```

### ConfidentialityResult

```csharp
public class ConfidentialityResult
{
    public bool IsAllowed { get; set; }
    public string AccessDeniedBehaviour { get; set; } = string.Empty;
    public int StatusCode { get; set; }
    public bool ShouldAlert { get; set; }
}
```

### Audit Logging

```csharp
public interface IConfidentialAccessLogWriter
{
    Task LogAsync(
        int userId,
        string module,
        string entityName,
        int recordId,
        string action,
        string channel,
        string? ipAddress,
        string? notes);
}
```

## Gate 3: Field Masking

### IFieldMaskingEngine Interface

```csharp
public interface IFieldMaskingEngine
{
    Task<T> ApplyMaskingAsync<T>(
        string module,
        string entityName,
        T record,
        int userId,
        string channel,
        CancellationToken cancellationToken = default);
}
```

### Masking Strategy Interface

```csharp
public interface IMaskingStrategy
{
    string ApplyMask(string value);
}
```

### Masking Strategy Implementations

#### FullMaskingStrategy
- Replaces entire value with `***`

#### RedactMaskingStrategy
- Replaces entire value with `[REDACTED]`

#### PartialMaskingStrategy
- Supports pattern-based masking:
  - `XXXX-{last4}` → `HDFC-4821` → `XXXX-4821`
  - `XXXXX{last4}X` → `ABCDE1234F` → `XXXXX234X`
  - `+91-XXXX-{last4}` → `+91-9876-5432` → `+91-XXXX-5432`
  - `{first}***@{domain}` → `ravi@company.com` → `r***@company.com`
  - `XXXX-XXXX-{last4}` → `1234-5678-9012` → `XXXX-XXXX-9012`

## Permission Engine Implementation

### IPermissionEngine Interface

```csharp
public interface IPermissionEngine
{
    Task<PermissionResult> CheckAsync(
        PermissionRequest request,
        CancellationToken cancellationToken = default);
}
```

### Permission Check Flow

The permission engine implements the three-gate enforcement model:

#### Gate 1: Scope Check

1. **Get User's RoleGroups**: Query `UserRoleGroup` for active role groups
2. **Get Role Permissions**: Query `AttributeRulePermissionRole` for permissions
3. **Get Attribute Rules**: Query `AttributeRule` for matching action
4. **Get BusinessEntityRule**: Query `BusinessEntityRule` for entity and action
5. **Resolve Scope**: Use `ScopeResolverRegistry` to resolve the scope
6. **Check Scope**: Call `CanAccessAsync` with record's anchor data

#### Gate 2: Confidentiality Check

1. **Check Record**: Determine if record is confidential (static or dynamic)
2. **Get Policy**: Query `ConfidentialityPolicy` for matching policy
3. **Check Permission**: Verify user has required permission
4. **Log Audit**: Write to `ConfidentialAccessLog`
5. **Send Alert**: If Critical level, notify role group

#### Gate 3: Field Masking

1. **Get Policies**: Query `FieldMaskingPolicy` for entity and channel
2. **Check Permissions**: For each policy, verify user has permission
3. **Apply Mask**: Apply masking strategy for fields without permission

### Example Implementation

```csharp
public class PermissionEngine : IPermissionEngine
{
    private readonly IPolicyRepository _policyRepository;
    private readonly ScopeResolverRegistry _scopeResolverRegistry;
    private readonly IFieldMaskingEngine _fieldMaskingEngine;
    private readonly IConfidentialityEngine _confidentialityEngine;
    
    public async Task<PermissionResult> CheckAsync(
        PermissionRequest request,
        CancellationToken cancellationToken = default)
    {
        // Gate 1: Scope Check
        var scopeResult = await CheckScopeAsync(request, cancellationToken);
        if (!scopeResult.IsAllowed)
        {
            return new PermissionResult
            {
                IsAllowed = false,
                Reason = "Permission denied",
                StatusCode = 403
            };
        }
        
        // Gate 2: Confidentiality Check
        var record = await _recordRepository.GetByIdAsync(request.RecordId.Value);
        var confidentialityResult = await _confidentialityEngine.CheckAsync(
            request.Module, request.EntityName, request.UserId, record, request.Channel);
        
        if (!confidentialityResult.IsAllowed)
        {
            return new PermissionResult
            {
                IsAllowed = false,
                Reason = "Record not found",
                StatusCode = confidentialityResult.StatusCode
            };
        }
        
        // Gate 3: Field Masking
        var maskedRecord = await _fieldMaskingEngine.ApplyMaskingAsync(
            request.Module, request.EntityName, record, request.UserId, request.Channel);
        
        return new PermissionResult
        {
            IsAllowed = true,
            StatusCode = 200
        };
    }
    
    private async Task<PermissionResult> CheckScopeAsync(
        PermissionRequest request,
        CancellationToken cancellationToken)
    {
        // Get user's role groups
        var roleGroupIds = await _policyRepository.GetUserRoleGroupIdsAsync(request.UserId);
        
        // Get business entity rules for this module and entity
        var entityRules = await _policyRepository.GetEntityRulesAsync(request.Module, request.EntityName);
        
        // Find matching rule for this action
        var matchingRule = entityRules.FirstOrDefault(r => r.Name == request.Action);
        if (matchingRule == null)
        {
            return new PermissionResult { IsAllowed = false, StatusCode = 403 };
        }
        
        // Get scope resolver
        var scopeResolver = _scopeResolverRegistry.GetResolver(matchingRule.ScopeType);
        
        // Check scope
        var canAccess = await scopeResolver.CanAccessAsync(
            request.UserId,
            recordOwnerId: record.OwnerId,
            teamId: record.TeamId,
            deptId: record.DeptId,
            gradeId: record.GradeId);
        
        return new PermissionResult
        {
            IsAllowed = canAccess,
            StatusCode = canAccess ? 200 : 403
        };
    }
}
```

## Policy Repository

### IPolicyRepository Interface

```csharp
public interface IPolicyRepository
{
    // Business Entity Rules
    Task<IEnumerable<BusinessEntityRule>> GetEntityRulesAsync(string module, string entityName, CancellationToken cancellationToken = default);
    
    // Attribute Rules
    Task<IEnumerable<AttributeRule>> GetAttributeRulesAsync(string module, string entityName, CancellationToken cancellationToken = default);
    
    // Field Masking Policies
    Task<IEnumerable<FieldMaskingPolicy>> GetFieldMaskingPoliciesAsync(string module, string entityName, string channel, CancellationToken cancellationToken = default);
    
    // Confidentiality Policies
    Task<IEnumerable<ConfidentialityPolicy>> GetConfidentialityPoliciesAsync(string module, string entityName, CancellationToken cancellationToken = default);
    
    // Scope Anchor Data
    Task<UserTeamInfo?> GetUserTeamInfoAsync(int userId, CancellationToken cancellationToken = default);
    Task<UserDepartmentInfo?> GetUserDepartmentInfoAsync(int userId, CancellationToken cancellationToken = default);
    Task<bool> CanViewGradeAsync(int viewerGradeId, int recordGradeId, CancellationToken cancellationToken = default);
    
    // Role Information
    Task<IEnumerable<int>> GetUserRoleGroupIdsAsync(int userId, CancellationToken cancellationToken = default);
}
```

## Infrastructure

### ScopeResolverRegistry

```csharp
public class ScopeResolverRegistry
{
    private readonly Dictionary<string, IScopeResolver> _resolvers;
    
    public void Register(string scopeType, IScopeResolver resolver);
    public IScopeResolver GetResolver(string scopeType);
}
```

### Policy Repository Implementation

Uses Dapper for efficient database queries with the following tables:
- `Module`
- `BusinessEntity`
- `BusinessEntityRule`
- `AttributeEntity`
- `AttributeRule`
- `Permission`
- `AttributeRulePermission`
- `AttributeRulePermissionRole`
- `Role`
- `RoleGroup`
- `RoleGroupRole`
- `UserRoleGroup`
- `UserTeam`
- `UserDepartment`
- `GradeHierarchy`
- `CustomScopeRule`
- `FieldMaskingPolicy`
- `ConfidentialityPolicy`
- `ConfidentialAccessLog`

## Extension Methods

### ServiceCollectionExtensions

```csharp
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddAuthorizationSdk(
        this IServiceCollection services,
        Action<AuthorizationSdkOptions> configureOptions);
}
```

### AuthorizationSdkOptions

```csharp
public class AuthorizationSdkOptions
{
    public string ConnectionString { get; set; } = string.Empty;
    public TimeSpan PolicyCacheTtl { get; set; } = TimeSpan.FromMinutes(5);
    public bool EnableAuditLogging { get; set; } = true;
}
```

## Usage Example

```csharp
public class LeaveController : ControllerBase
{
    private readonly IPermissionEngine _permissionEngine;
    
    public LeaveController(IPermissionEngine permissionEngine)
    {
        _permissionEngine = permissionEngine;
    }
    
    [HttpGet("{id}")]
    public async Task<IActionResult> GetLeaveRequest(int id)
    {
        var request = new PermissionRequest
        {
            Module = "Leave",
            EntityName = "LeaveRequest",
            Action = "View",
            UserId = UserId,
            RecordId = id,
            Channel = "UI"
        };
        
        var result = await _permissionEngine.CheckAsync(request);
        
        if (!result.IsAllowed)
        {
            return StatusCode(result.StatusCode, result.Reason);
        }
        
        var leaveRequest = await _leaveRepository.GetByIdAsync(id);
        
        // Apply field masking
        var maskedRequest = await _fieldMaskingEngine.ApplyMaskingAsync(
            "Leave", "LeaveRequest", leaveRequest, UserId, "UI");
        
        return Ok(maskedRequest);
    }
}
```

## Database Schema

### Module Table

```sql
CREATE TABLE Module (
    Id          INT           PRIMARY KEY IDENTITY,
    Name        NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    IsActive    BIT           NOT NULL DEFAULT 1,
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE()
);
```

### BusinessEntity Table

```sql
CREATE TABLE BusinessEntity (
    Id          INT           PRIMARY KEY IDENTITY,
    ModuleId    INT           NOT NULL REFERENCES Module(Id),
    Name        NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL,
    IsActive    BIT           NOT NULL DEFAULT 1,
    UNIQUE (ModuleId, Name)
);
```

### BusinessEntityRule Table

```sql
CREATE TABLE BusinessEntityRule (
    Id               INT           PRIMARY KEY IDENTITY,
    BusinessEntityId INT           NOT NULL REFERENCES BusinessEntity(Id),
    Name             NVARCHAR(100) NOT NULL,
    ScopeType        NVARCHAR(50)  NOT NULL,
    ScopeResolverKey NVARCHAR(100) NULL,
    Description      NVARCHAR(255) NULL,
    UNIQUE (BusinessEntityId, Name)
);
```

### AttributeEntity Table

```sql
CREATE TABLE AttributeEntity (
    Id               INT           PRIMARY KEY IDENTITY,
    BusinessEntityId INT           NOT NULL REFERENCES BusinessEntity(Id),
    FieldName        NVARCHAR(100) NOT NULL,
    DataType         NVARCHAR(50)  NOT NULL,
    IsSensitive      BIT           NOT NULL DEFAULT 0,
    Description      NVARCHAR(255) NULL,
    UNIQUE (BusinessEntityId, FieldName)
);
```

### AttributeRule Table

```sql
CREATE TABLE AttributeRule (
    Id                INT           PRIMARY KEY IDENTITY,
    AttributeEntityId INT           NOT NULL REFERENCES AttributeEntity(Id),
    Name              NVARCHAR(100) NOT NULL,
    ScopeType         NVARCHAR(50)  NOT NULL,
    ScopeResolverKey  NVARCHAR(100) NULL,
    Description       NVARCHAR(255) NULL
);
```

### Permission Table

```sql
CREATE TABLE Permission (
    Id   INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(50) NOT NULL UNIQUE
);
```

### AttributeRulePermission Table

```sql
CREATE TABLE AttributeRulePermission (
    Id              INT PRIMARY KEY IDENTITY,
    AttributeRuleId INT NOT NULL REFERENCES AttributeRule(Id),
    PermissionId    INT NOT NULL REFERENCES Permission(Id),
    UNIQUE (AttributeRuleId, PermissionId)
);
```

### AttributeRulePermissionRole Table

```sql
CREATE TABLE AttributeRulePermissionRole (
    Id                       INT PRIMARY KEY IDENTITY,
    AttributeRulePermissionId INT NOT NULL REFERENCES AttributeRulePermission(Id),
    RoleId                   INT NOT NULL REFERENCES Role(Id),
    UNIQUE (AttributeRulePermissionId, RoleId)
);
```

### Role Table

```sql
CREATE TABLE Role (
    Id          INT           PRIMARY KEY IDENTITY,
    Name        NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);
```

### RoleGroup Table

```sql
CREATE TABLE RoleGroup (
    Id          INT           PRIMARY KEY IDENTITY,
    Name        NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);
```

### RoleGroupRole Table

```sql
CREATE TABLE RoleGroupRole (
    RoleGroupId INT NOT NULL REFERENCES RoleGroup(Id),
    RoleId      INT NOT NULL REFERENCES Role(Id),
    PRIMARY KEY (RoleGroupId, RoleId)
);
```

### UserRoleGroup Table

```sql
CREATE TABLE UserRoleGroup (
    UserId        INT NOT NULL,
    RoleGroupId   INT NOT NULL REFERENCES RoleGroup(Id),
    EffectiveFrom DATETIME NULL,
    EffectiveTo   DATETIME NULL,
    PRIMARY KEY (UserId, RoleGroupId)
);
```

### UserTeam Table

```sql
CREATE TABLE UserTeam (
    UserId   INT           NOT NULL,
    TeamId   INT           NOT NULL,
    RoleName NVARCHAR(50)  NOT NULL,
    PRIMARY KEY (UserId, TeamId)
);
```

### UserDepartment Table

```sql
CREATE TABLE UserDepartment (
    UserId   INT           NOT NULL,
    DeptId   INT           NOT NULL,
    RoleName NVARCHAR(50)  NOT NULL,
    PRIMARY KEY (UserId, DeptId)
);
```

### GradeHierarchy Table

```sql
CREATE TABLE GradeHierarchy (
    GradeId          INT NOT NULL,
    CanViewGradeId   INT NOT NULL,
    PRIMARY KEY (GradeId, CanViewGradeId)
);
```

### CustomScopeRule Table

```sql
CREATE TABLE CustomScopeRule (
    RuleKey     NVARCHAR(100) PRIMARY KEY,
    SqlFragment NVARCHAR(MAX) NOT NULL,
    Description NVARCHAR(255) NULL
);
```

### FieldMaskingPolicy Table

```sql
CREATE TABLE FieldMaskingPolicy (
    Id                 INT           PRIMARY KEY IDENTITY,
    BusinessEntityId   INT           NOT NULL REFERENCES BusinessEntity(Id),
    FieldName          NVARCHAR(100) NOT NULL,
    MaskType           NVARCHAR(20)  NOT NULL,
    MaskPattern        NVARCHAR(100) NULL,
    RequiredPermission NVARCHAR(100) NOT NULL,
    AppliesTo          NVARCHAR(20)  NOT NULL DEFAULT 'All',
    IsActive           BIT           NOT NULL DEFAULT 1,
    CreatedBy          INT           NULL,
    CreatedAt          DATETIME      NOT NULL DEFAULT GETDATE(),
    UNIQUE (BusinessEntityId, FieldName, AppliesTo)
);
```

### ConfidentialityPolicy Table

```sql
CREATE TABLE ConfidentialityPolicy (
    Id                    INT           PRIMARY KEY IDENTITY,
    BusinessEntityId      INT           NOT NULL REFERENCES BusinessEntity(Id),
    ConfidentialityLevel  NVARCHAR(20)  NOT NULL,
    TriggerField          NVARCHAR(100) NULL,
    TriggerValue          NVARCHAR(100) NULL,
    AccessDeniedBehaviour NVARCHAR(20)  NOT NULL,
    RequiredPermission    NVARCHAR(100) NOT NULL,
    NotifyRoleGroupId     INT           NULL REFERENCES RoleGroup(Id),
    IsActive              BIT           NOT NULL DEFAULT 1
);
```

### ConfidentialAccessLog Table

```sql
CREATE TABLE ConfidentialAccessLog (
    Id          INT           PRIMARY KEY IDENTITY,
    UserId      INT           NOT NULL,
    Module      NVARCHAR(100) NOT NULL,
    EntityName  NVARCHAR(100) NOT NULL,
    RecordId    INT           NOT NULL,
    PolicyId    INT           NULL REFERENCES ConfidentialityPolicy(Id),
    Action      NVARCHAR(20)  NOT NULL,
    Channel     NVARCHAR(20)  NULL,
    IpAddress   NVARCHAR(50)  NULL,
    AccessedAt  DATETIME      NOT NULL DEFAULT GETDATE(),
    Notes       NVARCHAR(500) NULL
);
```

## Module Table Contract

Every module table must include these four context columns:

```sql
ALTER TABLE LeaveRequest     ADD OwnerId INT NULL, TeamId INT NULL, DeptId INT NULL, GradeId INT NULL;
ALTER TABLE PayrollSlip      ADD OwnerId INT NULL, TeamId INT NULL, DeptId INT NULL, GradeId INT NULL;
ALTER TABLE AttendanceLog    ADD OwnerId INT NULL, TeamId INT NULL, DeptId INT NULL, GradeId INT NULL;
ALTER TABLE PerformanceReview ADD OwnerId INT NULL, TeamId INT NULL, DeptId INT NULL, GradeId INT NULL;
ALTER TABLE TravelRequest    ADD OwnerId INT NULL, TeamId INT NULL, DeptId INT NULL, GradeId INT NULL;
```

## Confidentiality Tagging Columns

Each module table can include these columns for runtime confidentiality tagging:

```sql
ALTER TABLE PerformanceReview  ADD IsConfidential BIT DEFAULT 0, ConfidentialityLevel NVARCHAR(20) NULL, MarkedBy INT NULL, MarkedAt DATETIME NULL;
ALTER TABLE LeaveRequest        ADD IsConfidential BIT DEFAULT 0, ConfidentialityLevel NVARCHAR(20) NULL, MarkedBy INT NULL, MarkedAt DATETIME NULL;
ALTER TABLE PayrollSlip         ADD IsConfidential BIT DEFAULT 0, ConfidentialityLevel NVARCHAR(20) NULL, MarkedBy INT NULL, MarkedAt DATETIME NULL;
```

## Implementation Order

1. **Phase 1**: Core models and interfaces
2. **Phase 2**: Scope resolvers and registry
3. **Phase 3**: Policy repository
4. **Phase 4**: Field masking engine
5. **Phase 5**: Confidentiality engine
6. **Phase 6**: Main permission engine
7. **Phase 7**: Extension methods and DI setup
8. **Phase 8**: Tests and documentation

## Testing Strategy

### Unit Tests
- Scope resolver implementations
- Masking strategy implementations
- Policy repository queries

### Integration Tests
- End-to-end permission checking
- Field masking with various patterns
- Confidentiality policy enforcement

### Test Coverage Targets
- Scope resolvers: 100%
- Masking strategies: 100%
- Policy repository: 100%
- Main engine: 90%
- Confidentiality engine: 90%