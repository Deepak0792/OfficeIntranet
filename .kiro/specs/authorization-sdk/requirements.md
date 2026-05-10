# Authorization SDK - Requirements Document

## Overview

The Authorization SDK is a shared library that will be used by every module in the Identity microservice to enforce fine-grained permissions before allowing any action. It implements a record-level, attribute-aware permission system with three enforcement gates: scope checking, confidentiality checking, and field masking.

## Business Goals

1. **Fine-Grained Access Control**: Enable permission checks at both entity and field levels
2. **Flexible Scope Resolution**: Support multiple scope types (All, OwnRecord, OwnTeam, Department, Grade, Custom)
3. **Field Masking**: Hide or partially obscure sensitive field values based on user permissions
4. **Record Confidentiality**: Hide or restrict entire records based on confidentiality policies
5. **Audit Trail**: Log all access attempts to confidential records
6. **Zero Code Changes**: Allow new modules to be added without modifying the permission engine

## Functional Requirements

### FR1: Permission Checking

**Priority**: High

**Description**: The SDK must provide a method to check if a user has permission to perform an action on a specific record.

**Requirements**:
- Accept module name, entity name, action, user ID, and record ID as parameters
- Return a boolean indicating whether the action is allowed
- Return an appropriate HTTP status code (200, 403, 404)
- Support channel-specific permission checks (All, UI, API, Export)

**Acceptance Criteria**:
- Given a user with valid permissions, the SDK returns `IsAllowed = true` and `StatusCode = 200`
- Given a user without permissions, the SDK returns `IsAllowed = false` and `StatusCode = 403`
- Given a user without permissions to access a confidential record, the SDK returns `IsAllowed = false` and `StatusCode = 404`

### FR2: Scope Resolution

**Priority**: High

**Description**: The SDK must support multiple scope types to determine if a user can access a specific record.

**Supported Scope Types**:
- **All**: No row filtering; role alone is sufficient
- **OwnRecord**: Only the employee who owns the record
- **OwnTeam**: Team lead acting on their team member's record
- **Department**: Department head acting within their department
- **Grade**: Finance/HR user at a higher grade can see lower grade
- **Custom**: Arbitrary SQL predicate

**Requirements**:
- Each scope type must be implemented as a separate resolver
- Resolvers must read scope anchor data from shared tables (UserTeam, UserDepartment, GradeHierarchy, CustomScopeRule)
- Resolvers must support parameterized SQL for custom scopes

**Acceptance Criteria**:
- Given a user with "OwnTeam" scope, they can access records owned by their team members
- Given a user with "Department" scope, they can access records within their department
- Given a user with "Grade" scope, they can access records at their grade level and below
- Given a user with "Custom" scope, they can access records matching the custom SQL predicate

### FR3: Field Masking

**Priority**: High

**Description**: The SDK must support masking sensitive field values based on user permissions.

**Supported Mask Types**:
- **Full**: Replace entire value with `***`
- **Redact**: Replace entire value with `[REDACTED]`
- **Partial**: Apply pattern-based masking (e.g., `XXXX-{last4}`)

**Requirements**:
- Masking must be applied in the application layer during DTO serialization
- Support channel-specific masking (All, UI, API, Export)
- Support pattern-based partial masking with placeholders:
  - `{last4}`: Last 4 characters
  - `{first}`: First character
  - `{domain}`: Email domain
- Cache policies with short TTL (configurable, default 5 minutes)

**Acceptance Criteria**:
- Given a user without permission to view a sensitive field, the field value is masked
- Given a user with permission to view a sensitive field, the field value is returned in plain text
- Given a bank account field with "XXXX-{last4}" pattern, "HDFC-4821" becomes "XXXX-4821"
- Given a channel-specific policy, masking is applied only to the specified channel

### FR4: Confidentiality Checking

**Priority**: High

**Description**: The SDK must support record-level confidentiality policies.

**Confidentiality Levels**:
- **Standard**: Return `[Confidential]` stub + audit log
- **High**: Return 404 Not Found + audit log
- **Critical**: Return 404 Not Found + audit log + alert

**Requirements**:
- Support static triggers (field value matches trigger value)
- Support dynamic tagging (IsConfidential flag on record)
- Return 404 (not 403) for denied access to avoid revealing record existence
- Log all access attempts to confidential records
- Send alerts for Critical level denials to specified role group

**Acceptance Criteria**:
- Given a confidential record with "High" level, denied access returns 404
- Given a confidential record with "Critical" level, denied access sends alert to role group
- Given a user with permission to access a confidential record, the record is returned normally
- Given a user without permission to access a confidential record, the record is not revealed to exist

### FR5: Audit Logging

**Priority**: Medium

**Description**: The SDK must log all access attempts to confidential records.

**Requirements**:
- Log user ID, module, entity name, record ID, action, channel, IP address, and timestamp
- Support optional audit logging (configurable)
- Store logs in a separate table (ConfidentialAccessLog)

**Acceptance Criteria**:
- Given access to a confidential record, an audit log entry is created
- Given denied access to a confidential record, an audit log entry is created
- Audit logs include all required fields (userId, module, entityName, recordId, action, channel, ipAddress, notes)

### FR6: Policy Configuration

**Priority**: Medium

**Description**: The SDK must support configuration of policies through database tables.

**Requirements**:
- Support configuration of BusinessEntity, AttributeEntity, and AttributeRule tables
- Support configuration of FieldMaskingPolicy and ConfidentialityPolicy tables
- Support configuration of Role, RoleGroup, and UserRoleGroup tables
- Support configuration of scope anchor tables (UserTeam, UserDepartment, GradeHierarchy, CustomScopeRule)

**Acceptance Criteria**:
- Given a new module, policies can be added without code changes
- Given a new field, masking policies can be added without code changes
- Given a new role, permissions can be assigned without code changes

### FR7: Module Integration

**Priority**: High

**Description**: The SDK must be easily integrable into existing modules.

**Requirements**:
- Provide extension methods for DI registration
- Provide middleware for automatic permission checking
- Support both synchronous and asynchronous permission checks
- Support both attribute-based and programmatic permission checking

**Acceptance Criteria**:
- Given a new module, the SDK can be registered with a single extension method call
- Given a controller action, permissions can be checked with a single method call
- Given a service method, permissions can be checked with a single method call

## Non-Functional Requirements

### NFR1: Performance

**Priority**: High

**Description**: The SDK must not significantly impact request latency.

**Requirements**:
- Policy caching with configurable TTL (default 5 minutes)
- Efficient database queries using Dapper
- Minimal memory footprint

**Acceptance Criteria**:
- Permission check latency is under 100ms for cached policies
- Policy cache refresh does not block requests
- SDK memory usage is under 10MB

### NFR2: Reliability

**Priority**: High

**Description**: The SDK must be reliable and fault-tolerant.

**Requirements**:
- Graceful degradation if policy store is unavailable
- Circuit breaker for database operations
- Retry logic for transient failures

**Acceptance Criteria**:
- Given policy store is unavailable, SDK returns a default deny response
- Given transient database failure, SDK retries the operation up to 3 times
- Given persistent database failure, SDK logs the error and continues to deny requests

### NFR3: Security

**Priority**: Critical

**Description**: The SDK must enforce security policies correctly.

**Requirements**:
- Default deny for all permission checks
- No SQL injection vulnerabilities
- No information disclosure in error messages

**Acceptance Criteria**:
- Given no matching policy, the SDK denies the request
- Given malicious input, the SDK does not execute unintended SQL
- Given an error, the SDK returns a generic error message

### NFR4: Maintainability

**Priority**: Medium

**Description**: The SDK must be easy to maintain and extend.

**Requirements**:
- Clear separation of concerns
- Well-documented code
- Comprehensive test coverage

**Acceptance Criteria**:
- Given a new scope type, it can be added with a new resolver class
- Given a new masking strategy, it can be added with a new strategy class
- Code coverage is at least 90%

### NFR5: Testability

**Priority**: Medium

**Description**: The SDK must be easy to test.

**Requirements**:
- All public interfaces can be mocked
- Test doubles for policy repository
- Test doubles for scope resolvers

**Acceptance Criteria**:
- Given a unit test, all dependencies can be mocked
- Given an integration test, the SDK can be tested with a test database

## User Stories

### US1: Basic Permission Check

**As a** developer  
**I want to** check if a user has permission to view a record  
**So that** I can prevent unauthorized access

**Acceptance Criteria**:
- Given a user ID and record ID, I can call `CheckPermissionAsync` to get permission result
- Given a user without permission, the result indicates `IsAllowed = false`

### US2: Field Masking

**As a** developer  
**I want to** automatically mask sensitive fields  
**So that** I don't have to manually handle field-level permissions

**Acceptance Criteria**:
- Given a record with sensitive fields, I can call `ApplyMaskingAsync` to get masked record
- Given a user without permission to view a field, the field value is masked

### US3: Scope-Based Access

**As a** team lead  
**I want to** access records from my team members  
**So that** I can manage their work

**Acceptance Criteria**:
- Given a user with "OwnTeam" scope, they can access records from their team members
- Given a user without "OwnTeam" scope, they cannot access records from other teams

### US4: Confidential Records

**As a** HR manager  
**I want to** restrict access to sensitive records  
**So that** only authorized users can view them

**Acceptance Criteria**:
- Given a confidential record, only users with permission can view it
- Given a user without permission, they receive 404 (not 403)

### US5: Audit Trail

**As a** security administrator  
**I want to** track access to confidential records  
**So that** I can investigate potential security incidents

**Acceptance Criteria**:
- Given access to a confidential record, an audit log entry is created
- Given denied access, an audit log entry is created

## Out of Scope

- User authentication (handled by existing authentication middleware)
- Role management UI (handled by separate admin service)
- Policy management UI (handled by separate admin service)
- Multi-tenancy support (not required for initial release)
- External identity provider integration (not required for initial release)

## Assumptions

1. Users are authenticated before permission checks are performed
2. User IDs are integers (int)
3. Module names are lowercase strings (e.g., "leave", "payroll", "hr")
4. Entity names are PascalCase strings (e.g., "LeaveRequest", "PayrollSlip")
5. Field names match the property names in DTOs
6. Database tables include scope anchor columns (OwnerId, TeamId, DeptId, GradeId)
7. Role assignments are stored in UserRoleGroup table
8. Policy policies are stored in database tables (not in configuration files)

## Dependencies

- Dapper (for database access)
- Microsoft.Extensions.DependencyInjection (for DI support)
- Microsoft.AspNetCore.Http (for middleware)
- Serilog (for logging, optional)

## Success Metrics

- Permission check latency: < 100ms (p95)
- Policy cache hit rate: > 95%
- Test coverage: > 90%
- Mean time to recover from failures: < 5 minutes
- Zero security incidents due to permission bypass