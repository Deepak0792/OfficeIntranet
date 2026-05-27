# Workflow Engine — Design & Developer Reference

## Table of Contents

1. [Overview](#overview)
2. [Schema Architecture](#schema-architecture)
3. [Dependencies](#dependencies)
4. [Module 1 — Workflow Configuration](#module-1--workflow-configuration)
5. [Module 2 — Workflow Assignment](#module-2--workflow-assignment)
6. [Module 3 — Workflow Execution](#module-3--workflow-execution)
7. [Module 4 — Workflow Audit](#module-4--workflow-audit)
8. [Scope Resolution](#scope-resolution)
9. [Approver Resolution — How It Works](#approver-resolution--how-it-works)
10. [End-to-End Example — Hospital Leave & Expense Workflows](#end-to-end-example--hospital-leave--expense-workflows)
11. [Runtime Resolution Query](#runtime-resolution-query)
12. [Workflow Lifecycle & Status Transitions](#workflow-lifecycle--status-transitions)
13. [Indexes Reference](#indexes-reference)
14. [Seed Data Reference](#seed-data-reference)
15. [Supported Business Modules](#supported-business-modules)
16. [Cross-Microservice Integration](#cross-microservice-integration)
17. [Docker Compose Integration](#docker-compose-integration)
18. [Design Decisions & Changelog](#design-decisions--changelog)

---

## Overview

This is a **configurable, multi-step approval workflow engine** built on SQL Server. It is designed to support any business module (Leave, Expense, Attendance Regularization, Shift Swap, Hiring, Procurement, etc.) with a shared, reusable schema.

**Core capabilities:**

- Define unlimited workflow templates with ordered steps
- Each step resolves approvers dynamically at runtime using scope + designation rules
- Assign workflows to any level of the org hierarchy (Global → Employee)
- Track every state transition and action in an immutable audit log
- Support delegation, escalation, and multi-approver steps
- No approver logic is hardcoded — everything is data-driven
- Single engine serves all modules — Leave, Attendance, Shift Swap, Expense, Hiring, and any future module

---

## Schema Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  MODULE 1: CONFIGURATION                │
│                                                         │
│  WorkflowModule                                         │
│       │                                                 │
│       └── WorkflowDefinition                            │
│                   │                                     │
│                   └── WorkflowStep                      │
│                               │                         │
│                               └── WorkflowStepApprover  │
│                                           │             │
│                               WorkflowStepApproverDesig │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                  MODULE 2: ASSIGNMENT                   │
│                                                         │
│  WorkflowAssignment                                     │
│  (maps WorkflowDefinition → org scope for routing)      │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                  MODULE 3: EXECUTION                    │
│                                                         │
│  WorkflowInstance                                       │
│       │                                                 │
│       └── WorkflowTask (one per resolved approver)      │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                  MODULE 4: AUDIT                        │
│                                                         │
│  WorkflowActionHistory (immutable, append-only)         │
└─────────────────────────────────────────────────────────┘
```

**Design-time** (Modules 1 & 2) — configured once by administrators. Defines the template and where it applies.

**Runtime** (Modules 3 & 4) — created per transaction submission. Tracks live state and full audit trail.

---

## Dependencies

| Schema | Table | Used For |
|--------|-------|----------|
| `shared` | `StatusLookup` | All status/type code lookups via composite FK (StatusCode + StatusGroup) |
| `employee` | `Employee` | Initiator, approver, and action-by references |
| `time` | `ScopeType` | Org hierarchy levels (GLOBAL → EMPLOYEE) |
| `time` | `Department` | Department-level scope resolution |
| `time` | `Designation` | Approver designation matching |

---

## Module 1 — Workflow Configuration

### `workflow.WorkflowModule`

Represents a business module that owns one or more workflows.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | SMALLINT | Primary key |
| `ModuleCode` | NVARCHAR(100) | Unique code e.g. `LEAVE`, `EXPENSE`, `HIRING` |
| `ModuleName` | NVARCHAR(200) | Display name |
| `EntityName` | NVARCHAR(100) | Logical entity the module tracks e.g. `LeaveRequest` |
| `IsActive` | BIT | Soft delete flag |

**Example:**

```sql
INSERT INTO workflow.WorkflowModule (ModuleCode, ModuleName, EntityName) VALUES
('LEAVE',                   'Leave Management',                'LeaveRequest'),
('EXPENSE',                 'Expense Management',              'ExpenseRequest'),
('ATTENDANCE_REGULARIZATION','Attendance Regularization',      'AttendanceRegularization'),
('SHIFT_SWAP',              'Shift Swap',                      'ShiftSwapRequest'),
('COMP_OFF',                'Compensatory Off',                'CompOffBalance');
```

---

### `workflow.WorkflowDefinition`

A versioned workflow template. Multiple definitions can exist per module.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | SMALLINT | Primary key |
| `WorkflowModuleId` | SMALLINT | FK → WorkflowModule |
| `WorkflowCode` | NVARCHAR(100) | Unique code e.g. `LEAVE_APPROVAL_V1` |
| `WorkflowName` | NVARCHAR(200) | Display name |
| `VersionNo` | SMALLINT | Version number, default 1 |
| `Description` | NVARCHAR(1000) | Optional description |
| `IsActive` | BIT | Only one active definition per module should be active at a time |

**Example:**

```sql
INSERT INTO workflow.WorkflowDefinition (WorkflowModuleId, WorkflowCode, WorkflowName, VersionNo) VALUES
(1, 'LEAVE_APPROVAL_V1',           'Leave Approval Workflow',              1),
(2, 'EXPENSE_APPROVAL_V1',         'Expense Approval Workflow',            1),
(3, 'ATTENDANCE_REG_APPROVAL_V1',  'Attendance Regularization Workflow',   1),
(4, 'SHIFT_SWAP_APPROVAL_V1',      'Shift Swap Approval Workflow',         1),
(5, 'COMP_OFF_APPROVAL_V1',        'Compensatory Off Approval Workflow',   1);
```

---

### `workflow.WorkflowStep`

Ordered steps within a workflow definition.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | SMALLINT | Primary key |
| `WorkflowDefinitionId` | SMALLINT | FK → WorkflowDefinition |
| `StepNo` | SMALLINT | Execution order. Unique per definition |
| `StepName` | NVARCHAR(200) | Display name |
| `WorkflowStepType` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_STEP_TYPE`) |
| `WorkflowStepTypeGroup` | computed | Always `'WORKFLOW_STEP_TYPE'` |
| `IsFinalStep` | BIT | When approved, closes the workflow instance |
| `AllowDelegation` | BIT | Whether approver may delegate this step |
| `EscalationAfterHours` | INT | Auto-escalate if not acted within N hours. NULL = no escalation |
| `IsActive` | BIT | Soft delete flag |

**Step Types** (`WORKFLOW_STEP_TYPE`):

| Code | Meaning |
|------|---------|
| `APPROVAL` | Requires explicit Approve or Reject action |
| `REVIEW` | Review only, cannot reject |
| `NOTIFICATION` | Informational, auto-completes |
| `AUTO_APPROVAL` | System auto-approves, no human action needed |

**Example — Leave Approval (3 steps):**

```sql
INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep, EscalationAfterHours)
VALUES
(1, 1, 'Reporting Manager Approval', 'APPROVAL', 0, 24),
(1, 2, 'Department Head Approval',   'APPROVAL', 0, 48),
(1, 3, 'HR Manager Approval',        'APPROVAL', 1, 48);
```

**Example — Attendance Regularization (2 steps):**

```sql
INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep, EscalationAfterHours)
VALUES
(3, 1, 'Reporting Manager Approval', 'APPROVAL', 0, 24),
(3, 2, 'HR Notification',            'NOTIFICATION', 1, NULL);
```

**Example — Shift Swap (1 step — peer acceptance + manager approval):**

```sql
INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep, EscalationAfterHours)
VALUES
(4, 1, 'Target Employee Acceptance', 'APPROVAL', 0, 12),
(4, 2, 'Reporting Manager Approval', 'APPROVAL', 1, 24);
```

---

### `workflow.WorkflowStepApprover`

Defines the **rule** for resolving who approves a given step at runtime.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | SMALLINT | Primary key |
| `WorkflowStepId` | SMALLINT | FK → WorkflowStep |
| `WorkflowApproverType` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_APPROVER_TYPE`) |
| `WorkflowApproverTypeGroup` | computed | Always `'WORKFLOW_APPROVER_TYPE'` |
| `ScopeTypeId` | SMALLINT | FK → time.ScopeType. NULL = contextual |
| `ScopeReferenceId` | SMALLINT | Entity ID at the given scope level. NULL = initiator's own scope |
| `PriorityOrder` | SMALLINT | When multiple approvers exist, order of assignment |
| `IsMandatory` | BIT | Whether all mandatory approvers must approve before advancing |
| `IsActive` | BIT | Soft delete flag |

**Approver Types** (`WORKFLOW_APPROVER_TYPE`):

| Code | Meaning | Scope Required |
|------|---------|----------------|
| `REPORTING_MANAGER` | Direct manager of the initiator | NULL / NULL |
| `SKIP_MANAGER` | Manager's manager (2 levels up) | NULL / NULL |
| `DESIGNATION` | Holder of a specific designation in a scope | ScopeTypeId required |
| `ROLE` | Holder of a specific role in a scope | ScopeTypeId required |
| `EMPLOYEE` | A fixed, named employee | ScopeTypeId = EMPLOYEE, ScopeReferenceId = Employee.Id |

---

### `workflow.WorkflowStepApproverDesignation`

Maps a `WorkflowStepApprover` rule to one or more qualifying designations.
Required when `WorkflowApproverType = 'DESIGNATION'`.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | SMALLINT | Primary key |
| `WorkflowStepApproverId` | SMALLINT | FK → WorkflowStepApprover |
| `DesignationId` | SMALLINT | FK → time.Designation |

---

## Module 2 — Workflow Assignment

### `workflow.WorkflowAssignment`

Maps a workflow definition to an org scope for routing.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | SMALLINT | Primary key |
| `WorkflowDefinitionId` | SMALLINT | FK → WorkflowDefinition |
| `ScopeTypeId` | SMALLINT | FK → time.ScopeType (routing scope level) |
| `ScopeReferenceId` | SMALLINT | Entity ID at that scope |
| `EffectiveFrom` | DATE | Date from which this assignment is active |
| `EffectiveTo` | DATE | NULL = still active |
| `PriorityOrder` | SMALLINT | Lower number wins when multiple assignments match |
| `IsActive` | BIT | Soft delete flag |

**Example — Assign Leave workflow globally:**

```sql
INSERT INTO workflow.WorkflowAssignment
    (WorkflowDefinitionId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder)
VALUES
    (1,
     (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'),
     1, '2025-01-01', 1);
```

---

## Module 3 — Workflow Execution

### `workflow.WorkflowInstance`

One row per submitted transaction.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | INT | Primary key |
| `WorkflowDefinitionId` | SMALLINT | The template this instance follows |
| `WorkflowModuleId` | SMALLINT | The module that owns this instance |
| `ReferenceTransactionId` | INT | PK of the originating record (e.g. LeaveRequest.Id) |
| `CurrentWorkflowStepId` | SMALLINT | Active step. NULL when completed or cancelled |
| `WorkflowStatus` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_STATUS`) |
| `WorkflowStatusGroup` | computed | Always `'WORKFLOW_STATUS'` |
| `CreatedBy` | INT | FK → employee.Employee (initiator) |
| `CreatedAt` | DATETIME2 | Submission timestamp |
| `CompletedAt` | DATETIME2 | NULL until workflow reaches terminal status |
| `CompletedBy` | INT | FK → employee.Employee |

**Workflow Status values** (`WORKFLOW_STATUS`):

| Code | Terminal | Description |
|------|----------|-------------|
| `DRAFT` | No | Saved but not submitted |
| `PENDING` | No | Submitted, awaiting first step |
| `IN_PROGRESS` | No | At least one step completed |
| `APPROVED` | **Yes** | All steps approved |
| `REJECTED` | **Yes** | Rejected at any step |
| `CANCELLED` | **Yes** | Cancelled by admin or system |
| `WITHDRAWN` | **Yes** | Recalled by initiator |

---

### `workflow.WorkflowTask`

One row per resolved approver per step — the actionable inbox item.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | INT | Primary key |
| `WorkflowInstanceId` | INT | FK → WorkflowInstance |
| `WorkflowStepId` | SMALLINT | FK → WorkflowStep |
| `WorkflowStepApproverId` | SMALLINT | The rule that generated this task |
| `AssignedToEmployeeId` | INT | The resolved, actual approver |
| `DelegatedFromEmployeeId` | INT | Set when task was delegated |
| `TaskStatus` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_TASK_STATUS`) |
| `TaskStatusGroup` | computed | Always `'WORKFLOW_TASK_STATUS'` |
| `AssignedAt` | DATETIME2 | When task was created |
| `DueAt` | DATETIME2 | Deadline from step `EscalationAfterHours` |
| `ActionAt` | DATETIME2 | When the approver acted |
| `ActionBy` | INT | Employee who performed the action |
| `Remarks` | NVARCHAR(2000) | Approver's comments |
| `ParentWorkflowTaskId` | INT | Self-FK. Set when this is a delegated child task |

**Task Status values** (`WORKFLOW_TASK_STATUS`):

| Code | Terminal | Description |
|------|----------|-------------|
| `PENDING` | No | Awaiting approver action |
| `COMPLETED` | **Yes** | Approver acted |
| `DELEGATED` | **Yes** | Delegated — new task created |
| `CANCELLED` | **Yes** | Task voided |
| `ESCALATED` | No | Past due, escalated |

---

## Module 4 — Workflow Audit

### `workflow.WorkflowActionHistory`

Immutable, append-only log. Never updated, only inserted.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | INT | Primary key |
| `WorkflowInstanceId` | INT | FK → WorkflowInstance |
| `WorkflowTaskId` | INT | FK → WorkflowTask. NULL for system actions |
| `WorkflowStepId` | SMALLINT | The step at which the action occurred |
| `WorkflowActionType` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_ACTION_TYPE`) |
| `WorkflowActionTypeGroup` | computed | Always `'WORKFLOW_ACTION_TYPE'` |
| `ActionBy` | INT | FK → employee.Employee |
| `ActionAt` | DATETIME2 | Timestamp |
| `Remarks` | NVARCHAR(2000) | Comments |
| `FromWorkflowStatus` | NVARCHAR(50) | Status before the action |
| `FromWorkflowStatusGroup` | computed | Always `'WORKFLOW_STATUS'` |
| `ToWorkflowStatus` | NVARCHAR(50) | Status after the action |
| `ToWorkflowStatusGroup` | computed | Always `'WORKFLOW_STATUS'` |

> **Note:** `FromWorkflowStatusGroup` and `ToWorkflowStatusGroup` are separate computed columns because SQL Server cannot bind two composite foreign keys using the same computed column with different leading columns.

**Action Types** (`WORKFLOW_ACTION_TYPE`):

| Code | Description |
|------|-------------|
| `SUBMIT` | Transaction submitted |
| `APPROVE` | Step approved |
| `REJECT` | Step rejected |
| `DELEGATE` | Task delegated |
| `ESCALATE` | Task auto-escalated |
| `CANCEL` | Workflow cancelled |
| `WITHDRAW` | Withdrawn by initiator |
| `REASSIGN` | Task manually reassigned by admin |
| `RETURN` | Returned for clarification |

---

## Scope Resolution

| HierarchyLevel | ScopeCode | Meaning |
|----------------|-----------|---------|
| 1 | `GLOBAL` | Entire system |
| 2 | `COUNTRY` | Country-level entity |
| 3 | `LEGAL_ENTITY` | Legal entity / company |
| 4 | `OFFICE` | Office or branch |
| 5 | `DEPARTMENT` | Department |
| 6 | `TEAM` | Team within a department |
| 7 | `EMPLOYEE` | A specific employee (fixed approver) |

### Two Scope Patterns

**Contextual scope** — `ScopeReferenceId = NULL`

```
ScopeTypeId  = DEPARTMENT scope type id
ScopeReferenceId = NULL
→ Engine uses: SELECT DepartmentId FROM employee.Employee WHERE Id = @InitiatorId
```

**Fixed scope** — `ScopeReferenceId = <actual id>`

```
ScopeTypeId  = DEPARTMENT scope type id
ScopeReferenceId = <HR department id>
→ Engine always routes to HR regardless of initiator
```

### `REPORTING_MANAGER` and `SKIP_MANAGER` — No Scope Needed

```
REPORTING_MANAGER → Employee[initiator].ReportingManagerId
SKIP_MANAGER      → Employee[Employee[initiator].ReportingManagerId].ReportingManagerId
```

---

## Approver Resolution — How It Works

```
FOR EACH WorkflowStepApprover rule on the current step:

  IF ApproverType = 'REPORTING_MANAGER':
      resolved employee = Employee[initiator].ReportingManagerId

  IF ApproverType = 'SKIP_MANAGER':
      resolved employee = Employee[Employee[initiator].ReportingManagerId].ReportingManagerId

  IF ApproverType = 'EMPLOYEE':
      resolved employee = ScopeReferenceId  (direct, no lookup)

  IF ApproverType = 'DESIGNATION':
      target dept = IF ScopeReferenceId IS NULL
                       THEN Employee[initiator].DepartmentId
                       ELSE ScopeReferenceId
      qualifying designations = WorkflowStepApproverDesignation WHERE WorkflowStepApproverId = rule.Id
      resolved employee = Employee WHERE DepartmentId = target dept
                                    AND DesignationId IN (qualifying designations)
                                    AND IsActive = 1

  INSERT WorkflowTask (WorkflowInstanceId, WorkflowStepId, WorkflowStepApproverId,
                       AssignedToEmployeeId = resolved employee, TaskStatus = 'PENDING', ...)
```

---

## End-to-End Example — Hospital Leave & Expense Workflows

### Setup: Org Context

```
Initiator: Dr. Priya (EmpId=201)
  Designation : JRRESIDENT
  Department  : CARDIOLOGY
  Manager     : Dr. Arjun (EmpId=101, RESIDENTDR, CARDIOLOGY)

Dept Head of CARDIOLOGY: Dr. Meera (EmpId=55, CONSULTANT, CARDIOLOGY)
HR Manager             : Ms. Kavya (EmpId=301, HRMANAGER, HR)
Finance Manager        : Mr. Ravi  (EmpId=401, FINMANAGER, FINANCE)
```

### Resolution Comparison — Same Initiator, Two Workflows

| Step | Leave Workflow | Expense Workflow |
|------|---------------|-----------------|
| Step 1 | Dr. Arjun (EmpId=101) — Reporting Manager | Dr. Arjun — same rule |
| Step 2 | Dr. Meera (EmpId=55) — Dept Head, Cardiology | Dr. Meera — same rule |
| Step 3 | Ms. Kavya (EmpId=301) — HR Manager, HR Dept | Mr. Ravi (EmpId=401) — Finance Manager |

Steps 1 and 2 share identical configuration. Only Step 3 differs by pointing to a different fixed department.

---

## Runtime Resolution Query

```sql
SELECT      e.Id                AS ResolvedEmployeeId,
            e.DisplayName       AS ResolvedEmployeeName,
            d.DesignationCode   AS ResolvedDesignation,
            dept.DepartmentCode AS ResolvedDepartment
FROM        employee.Employee                           e
JOIN        time.Designation                            d   ON d.Id = e.DesignationId
JOIN        time.Department                             dept ON dept.Id = e.DepartmentId
JOIN        workflow.WorkflowStepApproverDesignation    wsad ON wsad.DesignationId = d.Id
JOIN        workflow.WorkflowStepApprover               wsa  ON wsa.Id = wsad.WorkflowStepApproverId
WHERE       wsa.Id = @WorkflowStepApproverId
AND         e.DepartmentId = CASE
                WHEN wsa.ScopeReferenceId IS NULL
                THEN (SELECT DepartmentId FROM employee.Employee WHERE Id = @InitiatorEmployeeId)
                ELSE wsa.ScopeReferenceId
            END
AND         e.IsActive = 1;
```

---

## Workflow Lifecycle & Status Transitions

```
                    ┌─────────┐
         Submit     │  DRAFT  │
    ┌───────────────└────┬────┘
    │                    │  Submit
    │               ┌────▼────┐
    │               │ PENDING │
    │               └────┬────┘
    │                    │  First step assigned
    │          ┌─────────▼──────────┐
    │          │    IN_PROGRESS     │◄──── steps cycle here
    │          └──┬──────────────┬──┘
    │       Reject│              │Approve all steps
    │        ┌────▼────┐    ┌────▼────┐
    │        │REJECTED │    │APPROVED │
    │        └─────────┘    └─────────┘
    │
    │  Withdraw (initiator)
    │        ┌──────────┐
    └────────►WITHDRAWN │
             └──────────┘

  Cancel (admin / system) → CANCELLED  (from any non-terminal state)
```

**Task lifecycle:**

```
PENDING ──► COMPLETED  (approver acts)
        ──► DELEGATED  (approver delegates → new task created)
        ──► ESCALATED  (DueAt passed)
        ──► CANCELLED  (workflow withdrawn/cancelled)
```

---

## Indexes Reference

| Index | Table | Columns | Purpose |
|-------|-------|---------|---------|
| `IX_WorkflowAssignment_Scope` | WorkflowAssignment | ScopeTypeId, ScopeReferenceId | Routing lookup on submit |
| `IX_WorkflowStepApprover_Step` | WorkflowStepApprover | WorkflowStepId | Load rules for a step |
| `IX_WorkflowStepApprover_Scope` | WorkflowStepApprover | ScopeTypeId, ScopeReferenceId | Scope-based rule filtering |
| `IX_WorkflowInstance_Module_Transaction` | WorkflowInstance | WorkflowModuleId, ReferenceTransactionId | Find instance for a transaction |
| `IX_WorkflowInstance_CreatedBy` | WorkflowInstance | CreatedBy | My submissions list |
| `IX_WorkflowInstance_CurrentStep` | WorkflowInstance | CurrentWorkflowStepId | Active step lookup |
| `IX_WorkflowTask_AssignedTo_Status` | WorkflowTask | AssignedToEmployeeId, TaskStatus | **Approver inbox — most frequent query** |
| `IX_WorkflowTask_Instance` | WorkflowTask | WorkflowInstanceId | All tasks for an instance |
| `IX_WorkflowTask_Step` | WorkflowTask | WorkflowStepId | Tasks per step |
| `IX_WorkflowActionHistory_Instance` | WorkflowActionHistory | WorkflowInstanceId | Audit trail for an instance |
| `IX_WorkflowActionHistory_Task` | WorkflowActionHistory | WorkflowTaskId | Audit trail for a task |
| `IX_WorkflowStep_Definition_StepNo` | WorkflowStep | WorkflowDefinitionId, StepNo | Ordered step traversal |

---

## Seed Data Reference

### `WORKFLOW_STEP_TYPE`

| StatusCode | Label | IsTerminal |
|------------|-------|-----------|
| `APPROVAL` | Approval Step | 0 |
| `REVIEW` | Review Step | 0 |
| `NOTIFICATION` | Notification Step | 0 |
| `AUTO_APPROVAL` | Auto Approval | 0 |

### `WORKFLOW_APPROVER_TYPE`

| StatusCode | Label |
|------------|-------|
| `EMPLOYEE` | Fixed Employee |
| `ROLE` | By Role |
| `DESIGNATION` | By Designation |
| `REPORTING_MANAGER` | Reporting Manager |
| `SKIP_MANAGER` | Skip Level Manager |

### `WORKFLOW_STATUS`

| StatusCode | Label | Terminal |
|------------|-------|----------|
| `DRAFT` | Draft | No |
| `PENDING` | Pending Approval | No |
| `IN_PROGRESS` | In Progress | No |
| `APPROVED` | Approved | **Yes** |
| `REJECTED` | Rejected | **Yes** |
| `CANCELLED` | Cancelled | **Yes** |
| `WITHDRAWN` | Withdrawn | **Yes** |

### `WORKFLOW_ACTION_TYPE`

| StatusCode | Label |
|------------|-------|
| `SUBMIT` | Submitted |
| `APPROVE` | Approved |
| `REJECT` | Rejected |
| `DELEGATE` | Delegated |
| `ESCALATE` | Escalated |
| `CANCEL` | Cancelled |
| `WITHDRAW` | Withdrawn |
| `REASSIGN` | Reassigned |
| `RETURN` | Return for Clarification |

### `WORKFLOW_TASK_STATUS`

| StatusCode | Label | Terminal |
|------------|-------|----------|
| `PENDING` | Pending | No |
| `COMPLETED` | Completed | **Yes** |
| `DELEGATED` | Delegated | **Yes** |
| `CANCELLED` | Cancelled | **Yes** |
| `ESCALATED` | Escalated | No |

### `WorkflowModule` Seed — Supported Business Modules

| ModuleCode | ModuleName | EntityName |
|------------|-----------|-----------|
| `LEAVE` | Leave Management | LeaveRequest |
| `EXPENSE` | Expense Management | ExpenseRequest |
| `ATTENDANCE_REGULARIZATION` | Attendance Regularization | AttendanceRegularization |
| `SHIFT_SWAP` | Shift Swap | ShiftSwapRequest |
| `COMP_OFF` | Compensatory Off | CompOffBalance |
| `HIRING` | Hiring & Recruitment | JobApplication |
| `ONBOARDING` | Employee Onboarding | OnboardingTask |
| `EXIT` | Exit Management | ExitRequest |

---

## Supported Business Modules

The workflow engine is module-agnostic. Any business transaction that requires approval routes through the same engine. The owning microservice submits a `WorkflowInstance` and polls for status changes.

### How a Module Integrates

1. **Design time** — Admin creates a `WorkflowDefinition` + `WorkflowStep` + `WorkflowStepApprover` records for the module.
2. **Assignment** — Admin assigns the definition to an org scope via `WorkflowAssignment`.
3. **Submission** — The owning service (e.g. Attendance.API) inserts a `WorkflowInstance` with `WorkflowModuleId` and `ReferenceTransactionId` pointing to the originating record.
4. **Execution** — The Workflow engine resolves approvers, creates `WorkflowTask` rows, and manages transitions.
5. **Notification** — On each state change, the engine publishes a RabbitMQ event `workflow.instance.status_changed` with the module code and reference ID.
6. **Callback** — The owning service consumes the event and updates its own record's status (e.g. `LeaveRequest.LeaveStatus = APPROVED`).

### Module → Status Field Mapping

| WorkflowModule | Owning Service | Status Column Updated on Completion |
|----------------|---------------|-------------------------------------|
| `LEAVE` | Attendance.API | `attendance.LeaveRequest.LeaveStatus` |
| `ATTENDANCE_REGULARIZATION` | Attendance.API | `attendance.AttendanceRegularization.RegularizationStatus` |
| `SHIFT_SWAP` | Attendance.API | `attendance.ShiftSwapRequest.ShiftSwapStatus` |
| `COMP_OFF` | Attendance.API | `attendance.CompOffBalance.WorkflowInstanceId` |
| `EXPENSE` | HR/Finance.API | `expense.ExpenseClaim.ClaimStatus` |
| `HIRING` | HR.API | `hr.JobApplication.ApplicationStatus` |

---

## Cross-Microservice Integration

```
Attendance.API / HR.API / Payroll.API
        │
        │  POST /api/v1/workflow/instances
        │  { moduleCode, referenceTransactionId, initiatedByEmployeeId }
        ▼
Workflow.API
        │
        │  Resolves approvers → creates WorkflowTasks
        │  Publishes: workflow.instance.status_changed (RabbitMQ)
        ▼
RabbitMQ Exchange: sdxcore.events
        │
        ├── Queue: sdxcore.attendance.workflow.callback
        │         → Attendance consumer updates LeaveRequest / Regularization / ShiftSwap status
        │
        ├── Queue: sdxcore.hr.workflow.callback
        │         → HR consumer updates OnboardingTask / ExitRequest status
        │
        └── Queue: sdxcore.notification.workflow.send
                  → Notification consumer sends email/push to approver and initiator
```

**Event payload published on status change:**

```json
{
  "eventType": "workflow.instance.status_changed",
  "workflowInstanceId": 1042,
  "workflowModuleCode": "LEAVE",
  "referenceTransactionId": 501,
  "previousStatus": "IN_PROGRESS",
  "newStatus": "APPROVED",
  "completedAt": "2025-11-14T10:22:00Z",
  "actionByEmployeeId": 301
}
```

---

## Docker Compose Integration

### Add `workflow-api` to `docker-compose.yml`

```yaml
  workflow-api:
    build:
      context: ..
      dockerfile: src/Services/Workflow/SdxCore.Workflow.API/Dockerfile
    container_name: sdxcore-workflow-api
    environment:
      - ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT:-Development}
      - ASPNETCORE_URLS=http://+:80
      - ConnectionStrings__DefaultConnection=Server=sql-server;Database=SdxCore;User Id=sa;Password=${SQL_SA_PASSWORD};TrustServerCertificate=True;MultipleActiveResultSets=true
      - Authentication__InternalApiKey=${AUTH_GATEWAY_INTERNAL_API_KEY}
      - Redis__ConnectionString=redis:6379
      - RabbitMQ__Host=rabbitmq
      - RabbitMQ__VirtualHost=sdxcore
      - RabbitMQ__Username=${RABBITMQ_DEFAULT_USER}
      - RabbitMQ__Password=${RABBITMQ_DEFAULT_PASS}
    ports:
      - "${WORKFLOW_PORT:-5005}:80"
    networks:
      - sdxcore-network
    depends_on:
      sql-server:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: curl --fail http://localhost:80/health || exit 1
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    restart: unless-stopped
```

### Add to Gateway YARP cluster environment variables

```yaml
- ReverseProxy__Clusters__workflow-cluster__Destinations__workflow-api__Address=http://workflow-api:80
```

### Add to `.env.example`

```dotenv
WORKFLOW_PORT=5005
```

### EF Core Migration

```bash
dotnet ef migrations add InitialWorkflow \
  --project src/Services/Workflow/SdxCore.Workflow.Persistence \
  --startup-project src/Services/Workflow/SdxCore.Workflow.API

dotnet ef database update \
  --project src/Services/Workflow/SdxCore.Workflow.Persistence \
  --startup-project src/Services/Workflow/SdxCore.Workflow.API
```

---

## Design Decisions & Changelog

### v1 → v2

**ScopeType moved from `WorkflowAssignment` to `WorkflowStepApprover`**
Each step now resolves approvers from its own independent scope. This allows Step 1 to route from the initiator's department and Step 3 to always route to HR.

**`WorkflowTask` table added**
`WorkflowStepApprover` defines who *should* approve. `WorkflowTask` is the concrete inbox item created when that rule is evaluated for a specific submission.

**`WorkflowActionHistory` dual FK collision fixed**
Split `WorkflowStatusGroup` into `FromWorkflowStatusGroup` and `ToWorkflowStatusGroup` — two independent computed columns to satisfy two separate composite FKs.

### v2 → v3

**`WorkflowStepApprover.ApproverReferenceId` removed**
`EMPLOYEE` is a first-class `ScopeType` at `HierarchyLevel = 7`. Fixed approvers use `ScopeTypeId = EMPLOYEE`, `ScopeReferenceId = employee.Id` — the same resolution path as all other scope types.

**`WorkflowStepApproverDesignation` added**
Makes qualifying designations per step configurable via data rather than hardcoded logic.

**Seed inserts corrected**
`StatusName` → `Label` (matches `shared.StatusLookup` schema).

### v3 → v4

**Multi-module support formalized**
`WorkflowModule` seed extended to cover `ATTENDANCE_REGULARIZATION`, `SHIFT_SWAP`, `COMP_OFF`, `HIRING`, `ONBOARDING`, and `EXIT`.

**`AUTO_APPROVAL` step type added**
Replaces the `FYI` type from v1/v2 — system auto-completes without human action. Used for HR notification steps.

**`RETURN` action type added**
Allows approvers to return a request to the initiator for clarification without full rejection.

**Cross-microservice integration pattern documented**
RabbitMQ event `workflow.instance.status_changed` standardized as the callback mechanism for all owning microservices.