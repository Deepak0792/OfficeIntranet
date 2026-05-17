# Office Intranet - Architecture Design Document

## Document Overview

This document captures the architectural decisions, design patterns, and structural changes introduced during the microservices database transformation.

---

## 1. Transformation Summary

### Before: Monolithic Architecture
- Single `dbo` schema with 30+ tables
- All HRMS functionality in one namespace
- Tight coupling between domains
- Complex foreign key dependencies

### After: Microservices Architecture
- 8 independent schemas with clear boundaries
- Each schema represents a distinct business domain
- Explicit cross-service references via foreign keys
- Support for independent deployment and scaling

---

## 2. Service Boundary Design

### 2.1 Foundational Services

| Service | Responsibility | Rationale |
|---------|---------------|-----------|
| **shared** | Status codes, lookup data | Common foundation required by all services |
| **time** | Time, location, organization | Infrastructure data needed by multiple services |

### 2.2 Core Services

| Service | Responsibility | Rationale |
|---------|---------------|-----------|
| **employee** | Employee master data | Central entity referenced by all business services |
| **workflow** | Approval engine | Cross-cutting capability used by multiple domains |

### 2.3 Business Services

| Service | Responsibility | Rationale |
|---------|---------------|-----------|
| **attendance** | Time & attendance | Self-contained time tracking domain |
| **hr** | HR lifecycle | Complete employee lifecycle (recruit → exit) |
| **payroll** | Compensation processing | Requires employee and legal entity data |
| **helpdesk** | IT support | Independent support operations |

---

## 3. Dependency Architecture

### 3.1 Dependency Graph

```
                    ┌──────────┐
                    │  shared  │
                    └────┬─────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
    ┌─────▼──────┐ ┌────▼─────┐ ┌────▼──────┐
    │    time    │ │workflow  │ │ employee  │
    └────────────┘ └────┬─────┘ └────┬──────┘
                        │              │
              ┌─────────┼─────────┐    │
              │         │         │    │
        ┌─────▼──┐ ┌───▼────┐ ┌─▼────┐ ┌▼──────┐
        │attendance│ │  hr   │ │payroll│ │helpdesk│
        └─────────┘ └────────┘ └───────┘ └───────┘
```

### 3.2 Dependency Principles

1. **No circular dependencies** — Acyclic graph ensures deployability
2. **Layered deployment** — Foundation → Core → Business
3. **Optional coupling** — Workflow references are nullable where appropriate
4. **Shared nothing within services** — Each service owns its data

---

## 4. Design Patterns

### 4.1 Status Code Domain Isolation

**Problem**: How to prevent a payroll status from being used in HR module?

**Solution**: Composite foreign key with StatusGroup

```sql
-- Table definition
JobPostingStatus    NVARCHAR(50)    NOT NULL,
JobPostingStatusGroup AS CAST('JOB_POSTING_STATUS' AS NVARCHAR(50)) PERSISTED,

-- Foreign key constraint
CONSTRAINT FK_JobPosting_Status
    FOREIGN KEY (JobPostingStatus, JobPostingStatusGroup)
    REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
```

**Benefits:**
- Database-level type safety
- Automatic domain isolation
- No application-layer validation needed

### 4.2 Scope-Based Assignment

**Problem**: How to assign workflows, shifts, holidays to different organizational levels?

**Solution**: Generic scope mechanism using ScopeType + ScopeReferenceId

```sql
-- ScopeType defines hierarchy levels
INSERT INTO time.ScopeType VALUES
('GLOBAL', 'Global', 1),
('COUNTRY', 'Country', 2),
('LEGAL_ENTITY', 'Legal Entity', 3),
('OFFICE', 'Office', 4),
('DEPARTMENT', 'Department', 5),
('TEAM', 'Team', 6),
('EMPLOYEE', 'Employee', 7);

-- Assignment tables use same pattern
WorkflowAssignment (WorkflowDefinitionId, ScopeTypeId, ScopeReferenceId, ...)
ShiftAssignment (ShiftId, ScopeTypeId, ScopeReferenceId, ...)
HolidayCalendarAssignment (HolidayCalendarId, ScopeTypeId, ScopeReferenceId, ...)
```

**Benefits:**
- Single mechanism for organizational assignment
- Extensible to new scope levels
- Consistent query patterns

### 4.3 Computed Columns

**Problem**: How to maintain derived values without application logic?

**Solution**: Persisted computed columns

```sql
-- Leave balance calculation
ClosingBalance AS (OpeningBalance + Allocated + CarryForward - Availed - Encashed)

-- Net pay calculation
NetAmountCredited AS (GrossAmount - TotalDeductions)

-- Taxable income
EstimatedTaxableIncome AS (DeclaredTotalIncome - DeclaredExemptions - DeclaredDeductions)
```

**Benefits:**
- Automatic recalculation
- No application-side logic
- Consistent across queries

### 4.4 Time-Based Records

**Problem**: How to maintain historical salary data when changes occur?

**Solution**: Effective date range on records

```sql
EmployeeSalary (
    ...
    EffectiveFrom   DATE NOT NULL,
    EffectiveTo    DATE NULL,
    IsActive       BIT NOT NULL DEFAULT 1
)

-- Query current salary
SELECT * FROM payroll.EmployeeSalary 
WHERE EmployeeId = @id AND IsActive = 1;

-- Query historical
SELECT * FROM payroll.EmployeeSalary 
WHERE EmployeeId = @id 
  AND EffectiveFrom <= @asOfDate 
  AND (EffectiveTo IS NULL OR EffectiveTo >= @asOfDate);
```

**Benefits:**
- Audit trail without separate history table
- Supports backdated changes
- Current state queries remain simple

### 4.5 Workflow Integration

**Problem**: How to integrate approval workflows with business entities?

**Solution**: Optional WorkflowInstanceId reference

```sql
LeaveRequest (
    ...
    WorkflowInstanceId  BIGINT NULL,
    ...
    CONSTRAINT FK_LeaveRequest_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
)

-- Unique index for workflow linkage (nullable)
CREATE UNIQUE INDEX UIX_LeaveRequest_WorkflowInstance
ON attendance.LeaveRequest(WorkflowInstanceId)
WHERE WorkflowInstanceId IS NOT NULL;
```

**Benefits:**
- Supports both manual and workflow-driven processes
- One-way linkage (transaction → workflow, not reverse)
- Audit trail via workflow.WorkflowActionHistory

---

## 5. Schema Organization

### 5.1 Table Grouping by Module

Each service schema is organized into logical modules:

**hr Schema Modules:**
- Module A: Recruitment & Selection (14 tables)
- Module B: Onboarding (6 tables)
- Module C: Policy Documents (4 tables)
- Module D: Performance Reviews (5 tables)
- Module E: Training Records (4 tables)
- Module F: Exit Management (3 tables)

**attendance Schema Modules:**
- Attendance Processing (4 tables)
- Leave Management (6 tables)
- Shift Management (9 tables)
- Holiday Management (5 tables)

### 5.2 Indexing Strategy

**Primary Indexes (Primary Keys):**
- Identity columns for all tables
- Composite keys where appropriate (e.g., StatusLookup)

**Secondary Indexes (Foreign Keys):**
- All FK columns indexed for join performance

**Filtered Indexes:**
- Workflow instance linkage (WHERE WorkflowInstanceId IS NOT NULL)
- Pending status lookups

**Covering Indexes:**
- Include frequently accessed columns for common queries

---

## 6. Data Integrity Decisions

### 6.1 Soft Delete vs Hard Delete

**Decision**: Use `IsActive` flag for all transactional tables

**Rationale:**
- Preserves audit trail
- Supports accidental deletion recovery
- Maintains referential integrity

### 6.2 Nullable vs Required References

**Decision**: Mixed approach based on business requirement

| Reference Type | Approach | Examples |
|---------------|----------|----------|
| Business required | NOT NULL | EmployeeId in LeaveRequest |
| Optional relationship | NULL | OfficeId in Ticket |
| Future requirement | NULL | WorkflowInstanceId |

### 6.3 Cascade Rules

**Decision**: No cascading deletes

**Rationale:**
- Prevents accidental data loss
- Explicit deletion through stored procedures
- Audit trail preservation

---

## 7. Migration Strategy

### 7.1 Execution Order Rationale

The migration executes in dependency order with a specific pattern:

```
Phase 1 (Foundation):
  1. shared  → No dependencies, foundational data
  2. time    → Infrastructure, no external deps

Phase 2 (Core):
  3. workflow → Uses employee for approver resolution
  4. employee → Uses time for locations/departments

Phase 3 (Business):
  5. attendance → Uses employee, workflow, time
  6. hr         → Uses employee, workflow, time
  7. payroll    → Uses employee, time
  8. helpdesk   → Uses employee, time
```

### 7.2 Migration Compatibility

**Decision**: Null foreign keys where dependencies are optional

Example: EmployeeDocument has optional WorkflowInstanceId, allowing employee data to exist independently of workflow service.

---

## 8. Scalability Considerations

### 8.1 Schema as Service Boundary

Each schema can be deployed as an independent database:
- Separate backup/restore cycles
- Independent scaling per service
- Domain-specific optimization

### 8.2 Cross-Service Query Patterns

**Synchronous (Foreign Keys):**
- For tight coupling (e.g., LeaveRequest → Employee)
- Direct JOIN possible within same transaction

**Asynchronous (Event-Based - Future):**
- For loose coupling between services
- Event publishing for state changes
- Event consumers for downstream processing

---

## 9. Security Implications

### 9.1 Current State
- Schema-level permissions can be applied
- Row-level security not implemented (future enhancement)

### 9.2 Recommended Enhancements
- Schema-level ownership (dbo → service account)
- Application roles per schema
- Encryption for sensitive fields (PII, bank details)

---

## 10. Testing Strategy

### 10.1 Schema Validation
- Verify all FK relationships resolve correctly
- Confirm index existence for FK columns
- Validate computed column expressions

### 10.2 Data Integrity
- Check constraint validation
- Unique constraint enforcement
- Default value application

### 10.3 Migration Testing
- Fresh database creation
- Incremental table addition
- Cross-schema query verification

---

## 11. Future Architectural Enhancements

| Enhancement | Description | Priority |
|-------------|-------------|----------|
| Event Sourcing | Implement event log for inter-service communication | High |
| Read Replicas | Create reporting-specific replicas | Medium |
| Schema Security | Implement row-level security policies | Medium |
| GraphQL API | Unified query layer across services | Low |
| CQRS Pattern | Separate read/write models per service | Low |

---

## 12. Decision Log

| Decision | Date | Rationale |
|----------|------|-----------|
| Microservices split | Initial design | Independent deployment, domain isolation |
| Shared status lookup | Design phase | Single source of truth for status codes |
| Scope-based assignment | Design phase | Generic mechanism for organizational assignment |
| Soft delete pattern | Design phase | Audit trail preservation |
| Nullable workflow FK | Design phase | Support manual/processed modes |
| BiometricDevice in hr | User request | HR owns device management |
| GeoFence in hr | User request | Mobile attendance tied to HR domain |

---

## Appendix: Table Counts by Service

| Service | Tables | Lines of SQL |
|---------|--------|---------------|
| shared | 1 | ~29,567 (seed data) |
| time | 11 | ~10,306 |
| workflow | 7 | ~10,076 |
| employee | 12 | ~17,980 |
| attendance | 24 | ~31,187 |
| hr | 32 | ~50,347 |
| payroll | 20 | ~34,319 |
| helpdesk | 15 | ~22,829 |

---

*Document Version: 1.0*
*Last Updated: 2025*
*Author: Claude Code Assistant*