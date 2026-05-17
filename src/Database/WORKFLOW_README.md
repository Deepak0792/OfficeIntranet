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
15. [Design Decisions & Changelog](#design-decisions--changelog)

---

## Overview

This is a **configurable, multi-step approval workflow engine** built on SQL Server. It is designed to support any business module (Leave, Expense, Hiring, Procurement, etc.) with a shared, reusable schema.

**Core capabilities:**

- Define unlimited workflow templates with ordered steps
- Each step resolves approvers dynamically at runtime using scope + designation rules
- Assign workflows to any level of the org hierarchy (Global → Employee)
- Track every state transition and action in an immutable audit log
- Support delegation, escalation, and multi-approver steps
- No approver logic is hardcoded — everything is data-driven

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
| `Id` | BIGINT | Primary key |
| `ModuleCode` | NVARCHAR(100) | Unique code e.g. `LEAVE`, `EXPENSE`, `HIRING` |
| `ModuleName` | NVARCHAR(200) | Display name |
| `EntityName` | NVARCHAR(100) | Logical entity the module tracks e.g. `LeaveRequest` |
| `IsActive` | BIT | Soft delete flag |

**Example:**

```sql
INSERT INTO workflow.WorkflowModule (ModuleCode, ModuleName, EntityName) VALUES
('LEAVE',   'Leave Management',   'LeaveRequest'),
('EXPENSE', 'Expense Management', 'ExpenseRequest');
```

---

### `workflow.WorkflowDefinition`

A versioned workflow template. Multiple definitions can exist per module (e.g. different workflows for different leave types).

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowModuleId` | BIGINT | FK → WorkflowModule |
| `WorkflowCode` | NVARCHAR(100) | Unique code e.g. `LEAVE_APPROVAL_V1` |
| `WorkflowName` | NVARCHAR(200) | Display name |
| `VersionNo` | INT | Version number, default 1 |
| `Description` | NVARCHAR(1000) | Optional description |
| `IsActive` | BIT | Only one active definition per module should be active at a time |

**Example:**

```sql
INSERT INTO workflow.WorkflowDefinition (WorkflowModuleId, WorkflowCode, WorkflowName, VersionNo) VALUES
(1, 'LEAVE_APPROVAL_V1',   'Leave Approval Workflow',   1),
(2, 'EXPENSE_APPROVAL_V1', 'Expense Approval Workflow',  1);
```

---

### `workflow.WorkflowStep`

Ordered steps within a workflow definition. Each step has a type, escalation policy, and delegation flag.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowDefinitionId` | BIGINT | FK → WorkflowDefinition |
| `StepNo` | INT | Execution order. Unique per definition |
| `StepName` | NVARCHAR(200) | Display name |
| `WorkflowStepType` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_STEP_TYPE`) |
| `WorkflowStepTypeGroup` | computed | Always `'WORKFLOW_STEP_TYPE'` — backs composite FK |
| `IsFinalStep` | BIT | When approved, closes the workflow instance |
| `AllowDelegation` | BIT | Whether approver may delegate this step |
| `EscalationAfterHours` | INT | Auto-escalate task if not acted within N hours. NULL = no escalation |
| `IsActive` | BIT | Soft delete flag |

**Step Types** (`WORKFLOW_STEP_TYPE`):

| Code | Meaning |
|------|---------|
| `APPROVAL` | Requires explicit Approve or Reject action |
| `REVIEW` | Review only, cannot reject |
| `NOTIFICATION` | Informational, auto-completes |
| `FYI` | For Your Information, no action required |

**Example — Leave Approval (3 steps):**

```sql
-- Step 1: Reporting Manager approval
INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep, EscalationAfterHours)
VALUES (1, 1, 'Reporting Manager Approval', 'APPROVAL', 0, 24);

-- Step 2: Department Head approval
INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep, EscalationAfterHours)
VALUES (1, 2, 'Department Head Approval', 'APPROVAL', 0, 48);

-- Step 3: HR Manager approval (final)
INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep, EscalationAfterHours)
VALUES (1, 3, 'HR Manager Approval', 'APPROVAL', 1, 48);
```

---

### `workflow.WorkflowStepApprover`

Defines the **rule** for resolving who approves a given step. This is not a person — it is a resolution instruction the engine evaluates at runtime.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowStepId` | BIGINT | FK → WorkflowStep |
| `WorkflowApproverType` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_APPROVER_TYPE`) |
| `WorkflowApproverTypeGroup` | computed | Always `'WORKFLOW_APPROVER_TYPE'` |
| `ScopeTypeId` | BIGINT | FK → time.ScopeType. NULL = contextual (derives from initiator) |
| `ScopeReferenceId` | BIGINT | Entity ID at the given scope level. NULL = initiator's own scope |
| `PriorityOrder` | INT | When multiple approvers exist, order of assignment |
| `IsMandatory` | BIT | Whether all mandatory approvers must approve before advancing |
| `IsActive` | BIT | Soft delete flag |

**Approver Types** (`WORKFLOW_APPROVER_TYPE`):

| Code | Meaning | Scope Required |
|------|---------|----------------|
| `REPORTING_MANAGER` | Direct manager of the initiator | NULL / NULL — always contextual |
| `SKIP_MANAGER` | Manager's manager (2 levels up) | NULL / NULL — always contextual |
| `DESIGNATION` | Holder of a specific designation in a scope | ScopeTypeId required; ScopeReferenceId optional |
| `ROLE` | Holder of a specific role in a scope | ScopeTypeId required; ScopeReferenceId optional |
| `EMPLOYEE` | A fixed, named employee | ScopeTypeId = EMPLOYEE, ScopeReferenceId = Employee.Id |

---

### `workflow.WorkflowStepApproverDesignation`

Maps a `WorkflowStepApprover` rule to one or more qualifying designations. Required when `WorkflowApproverType = 'DESIGNATION'`.

Without this table the engine cannot determine which designation counts as "Department Head" for Step 2 — that logic would need to be hardcoded in the application.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowStepApproverId` | BIGINT | FK → WorkflowStepApprover |
| `DesignationId` | BIGINT | FK → time.Designation |

A single step approver rule can accept **multiple designations** — for example, Step 2 ("Department Head") may accept `CONSULTANT` in Clinical, `HRMANAGER` in HR, and `FINMANAGER` in Finance. The engine matches whichever designation is held by an active employee in the resolved department.

---

## Module 2 — Workflow Assignment

### `workflow.WorkflowAssignment`

Maps a workflow definition to an org scope for **routing**. Answers the question: *"Which workflow template should be triggered when a transaction is submitted by someone in scope X?"*

This scope is for routing only, not for approver resolution.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowDefinitionId` | BIGINT | FK → WorkflowDefinition |
| `ScopeTypeId` | BIGINT | FK → time.ScopeType (routing scope level) |
| `ScopeReferenceId` | BIGINT | Entity ID at that scope (e.g. Department ID) |
| `EffectiveFrom` | DATE | Date from which this assignment is active |
| `EffectiveTo` | DATE | NULL = still active |
| `PriorityOrder` | INT | When multiple assignments match, lower number wins |
| `IsActive` | BIT | Soft delete flag |

**Example — Assign Leave workflow to all departments:**

```sql
-- Assign to GLOBAL scope = applies to everyone
INSERT INTO workflow.WorkflowAssignment
    (WorkflowDefinitionId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder)
VALUES
    (1,  -- LEAVE_APPROVAL_V1
     (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'),
     1,   -- Global entity reference
     '2025-01-01', 1);
```

**Example — Override for a specific department:**

```sql
-- Cardiology gets a different (stricter) leave workflow
INSERT INTO workflow.WorkflowAssignment
    (WorkflowDefinitionId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder)
VALUES
    (5,  -- LEAVE_CLINICAL_V1 (stricter version)
     (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),
     (SELECT Id FROM time.Department WHERE DepartmentCode = 'CARDIOLOGY'),
     '2025-01-01', 2);
-- Higher PriorityOrder = more specific = wins over GLOBAL assignment
```

---

## Module 3 — Workflow Execution

### `workflow.WorkflowInstance`

One row per submitted transaction. Tracks the current step and overall status of the workflow.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowDefinitionId` | BIGINT | The template this instance follows |
| `WorkflowModuleId` | BIGINT | The module that owns this instance |
| `ReferenceTransactionId` | BIGINT | PK of the originating record (e.g. LeaveRequest.Id) |
| `CurrentWorkflowStepId` | BIGINT | Active step. NULL when completed or cancelled |
| `WorkflowStatus` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_STATUS`) |
| `WorkflowStatusGroup` | computed | Always `'WORKFLOW_STATUS'` |
| `InitiatedBy` | BIGINT | FK → employee.Employee |
| `InitiatedAt` | DATETIME2 | Submission timestamp |
| `CompletedAt` | DATETIME2 | NULL until workflow reaches terminal status |

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

One row per resolved approver per step. This is the **actionable inbox item** that appears in an approver's task list.

`WorkflowStepApprover` defines the rule → `WorkflowTask` is the concrete instance of that rule for one specific workflow execution.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowInstanceId` | BIGINT | FK → WorkflowInstance |
| `WorkflowStepId` | BIGINT | FK → WorkflowStep |
| `WorkflowStepApproverId` | BIGINT | The rule that generated this task |
| `AssignedToEmployeeId` | BIGINT | The resolved, actual approver |
| `DelegatedFromEmployeeId` | BIGINT | Set when task was delegated from another employee |
| `TaskStatus` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_TASK_STATUS`) |
| `TaskStatusGroup` | computed | Always `'WORKFLOW_TASK_STATUS'` |
| `AssignedAt` | DATETIME2 | When task was created |
| `DueAt` | DATETIME2 | Deadline computed from step `EscalationAfterHours` |
| `ActionAt` | DATETIME2 | When the approver acted |
| `Remarks` | NVARCHAR(2000) | Approver's comments |
| `ParentWorkflowTaskId` | BIGINT | Self-FK. Set when this is a delegated child task |

**Task Status values** (`WORKFLOW_TASK_STATUS`):

| Code | Terminal | Description |
|------|----------|-------------|
| `PENDING` | No | Awaiting approver action |
| `COMPLETED` | **Yes** | Approver acted (Approved or Rejected) |
| `DELEGATED` | **Yes** | Approver delegated — new task created for delegate |
| `CANCELLED` | **Yes** | Task voided (e.g. workflow withdrawn) |
| `ESCALATED` | No | Past due, escalated to next level |

**Delegation chain example:**

```
WorkflowTask Id=10  AssignedTo=EmpA  Status=DELEGATED  ParentTaskId=NULL
WorkflowTask Id=11  AssignedTo=EmpB  Status=PENDING    ParentTaskId=10
                    DelegatedFrom=EmpA
```

---

## Module 4 — Workflow Audit

### `workflow.WorkflowActionHistory`

Immutable, append-only log of every action taken against a workflow instance. Never updated, only inserted.

| Column | Type | Description |
|--------|------|-------------|
| `Id` | BIGINT | Primary key |
| `WorkflowInstanceId` | BIGINT | FK → WorkflowInstance |
| `WorkflowTaskId` | BIGINT | FK → WorkflowTask. NULL for system-generated actions |
| `WorkflowStepId` | BIGINT | The step at which the action occurred |
| `WorkflowActionType` | NVARCHAR(50) | FK → StatusLookup (group: `WORKFLOW_ACTION_TYPE`) |
| `WorkflowActionTypeGroup` | computed | Always `'WORKFLOW_ACTION_TYPE'` |
| `ActionBy` | BIGINT | FK → employee.Employee |
| `ActionAt` | DATETIME2 | Timestamp |
| `Remarks` | NVARCHAR(2000) | Approver's comments |
| `FromWorkflowStatus` | NVARCHAR(50) | Status before the action |
| `FromWorkflowStatusGroup` | computed | Always `'WORKFLOW_STATUS'` — backs FK independently |
| `ToWorkflowStatus` | NVARCHAR(50) | Status after the action |
| `ToWorkflowStatusGroup` | computed | Always `'WORKFLOW_STATUS'` — backs FK independently |

> **Note on dual computed columns:** `FromWorkflowStatusGroup` and `ToWorkflowStatusGroup` are separate computed columns (not shared) because SQL Server cannot bind two composite foreign keys using the same computed column with different leading columns. Each computed column independently backs its own FK into `shared.StatusLookup`.

**Action Types** (`WORKFLOW_ACTION_TYPE`):

| Code | Description |
|------|-------------|
| `SUBMIT` | Transaction submitted by initiator |
| `APPROVE` | Step approved |
| `REJECT` | Step rejected |
| `DELEGATE` | Task delegated to another employee |
| `ESCALATE` | Task auto-escalated after due time |
| `CANCEL` | Workflow cancelled |
| `WITHDRAW` | Withdrawn by initiator |
| `REASSIGN` | Task manually reassigned by admin |

---

## Scope Resolution

The engine uses a 7-level org hierarchy from `time.ScopeType` to resolve approvers. No new scope types are needed beyond what is already seeded.

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

The engine resolves the scope from the initiator's own org data at runtime.

```
ScopeTypeId  = DEPARTMENT scope type id
ScopeReferenceId = NULL
→ Engine uses: SELECT DepartmentId FROM employee.Employee WHERE Id = @InitiatorId
```

**Fixed scope** — `ScopeReferenceId = <actual id>`

The engine always routes to the same org unit regardless of who submits.

```
ScopeTypeId  = DEPARTMENT scope type id
ScopeReferenceId = <HR department id>
→ Engine uses: ScopeReferenceId directly — always HR
```

### `REPORTING_MANAGER` and `SKIP_MANAGER` — No Scope Needed

These approver types are always `NULL / NULL`. The engine resolves them by traversing `employee.Employee.ReportingManagerId` directly — no scope lookup is needed.

```
REPORTING_MANAGER → Employee[initiator].ReportingManagerId
SKIP_MANAGER      → Employee[Employee[initiator].ReportingManagerId].ReportingManagerId
```

---

## Approver Resolution — How It Works

At runtime, when a `WorkflowInstance` advances to a step, the engine executes this logic:

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
  Designation : JRRESIDENT (Junior Resident)
  Department  : CARDIOLOGY
  Reporting Manager: Dr. Arjun (EmpId=101, RESIDENTDR, CARDIOLOGY)

Dept Head of CARDIOLOGY: Dr. Meera (EmpId=55, CONSULTANT, CARDIOLOGY)
HR Manager             : Ms. Kavya (EmpId=301, HRMANAGER, HR)
Finance Manager        : Mr. Ravi  (EmpId=401, FINMANAGER, FINANCE)
```

---

### Step 1 — Configure WorkflowStepApprover Rules

```sql
-- ── LEAVE WORKFLOW ──────────────────────────────────────────

-- Step 1: Reporting Manager (contextual — no scope)
INSERT INTO workflow.WorkflowStepApprover
    (WorkflowStepId, WorkflowApproverType, ScopeTypeId, ScopeReferenceId)
VALUES (@LeaveStep1Id, 'REPORTING_MANAGER', NULL, NULL);

-- Step 2: Department Head of initiator's own department
INSERT INTO workflow.WorkflowStepApprover
    (WorkflowStepId, WorkflowApproverType, ScopeTypeId, ScopeReferenceId)
VALUES (@LeaveStep2Id, 'DESIGNATION',
        (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),
        NULL);  -- NULL = use initiator's department at runtime

-- Map qualifying designations for Step 2 (anyone who can be a Dept Head)
INSERT INTO workflow.WorkflowStepApproverDesignation (WorkflowStepApproverId, DesignationId)
SELECT @LeaveStep2ApproverId, Id FROM time.Designation
WHERE DesignationCode IN ('CONSULTANT','CHFNURSE','CHIEFPHARM','HOPADMIN',
                          'HRMANAGER','ITMANAGER','FINMANAGER','OPSMGR');

-- Step 3: HR Manager — fixed to HR department regardless of initiator
INSERT INTO workflow.WorkflowStepApprover
    (WorkflowStepId, WorkflowApproverType, ScopeTypeId, ScopeReferenceId)
VALUES (@LeaveStep3Id, 'DESIGNATION',
        (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),
        (SELECT Id FROM time.Department WHERE DepartmentCode = 'HR'));

INSERT INTO workflow.WorkflowStepApproverDesignation (WorkflowStepApproverId, DesignationId)
VALUES (@LeaveStep3ApproverId,
        (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'));


-- ── EXPENSE WORKFLOW ────────────────────────────────────────

-- Steps 1 & 2: identical pattern to Leave (different StepIds, same logic)

-- Step 3: Finance Manager — fixed to FINANCE department
INSERT INTO workflow.WorkflowStepApprover
    (WorkflowStepId, WorkflowApproverType, ScopeTypeId, ScopeReferenceId)
VALUES (@ExpenseStep3Id, 'DESIGNATION',
        (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),
        (SELECT Id FROM time.Department WHERE DepartmentCode = 'FINANCE'));

INSERT INTO workflow.WorkflowStepApproverDesignation (WorkflowStepApproverId, DesignationId)
VALUES (@ExpenseStep3ApproverId,
        (SELECT Id FROM time.Designation WHERE DesignationCode = 'FINMANAGER'));
```

---

### Step 2 — Dr. Priya Submits a Leave Request

```sql
-- 1. Create workflow instance
INSERT INTO workflow.WorkflowInstance
    (WorkflowDefinitionId, WorkflowModuleId, ReferenceTransactionId,
     CurrentWorkflowStepId, WorkflowStatus, InitiatedBy)
VALUES (1, 1, @LeaveRequestId, @LeaveStep1Id, 'PENDING', 201);

-- 2. Engine resolves Step 1 approver: REPORTING_MANAGER → EmpId=101 (Dr. Arjun)
INSERT INTO workflow.WorkflowTask
    (WorkflowInstanceId, WorkflowStepId, WorkflowStepApproverId,
     AssignedToEmployeeId, TaskStatus, DueAt)
VALUES (@InstanceId, @LeaveStep1Id, @Step1ApproverId,
        101, 'PENDING', DATEADD(HOUR, 24, GETUTCDATE()));

-- 3. Log the submission
INSERT INTO workflow.WorkflowActionHistory
    (WorkflowInstanceId, WorkflowStepId, WorkflowActionType,
     ActionBy, FromWorkflowStatus, ToWorkflowStatus)
VALUES (@InstanceId, @LeaveStep1Id, 'SUBMIT', 201, 'DRAFT', 'PENDING');
```

---

### Step 3 — Dr. Arjun Approves (Step 1 → Step 2)

```sql
-- 1. Complete Step 1 task
UPDATE workflow.WorkflowTask
SET    TaskStatus = 'COMPLETED', ActionAt = GETUTCDATE(), Remarks = 'Approved'
WHERE  Id = @Task1Id;

-- 2. Advance instance to Step 2
UPDATE workflow.WorkflowInstance
SET    CurrentWorkflowStepId = @LeaveStep2Id, WorkflowStatus = 'IN_PROGRESS'
WHERE  Id = @InstanceId;

-- 3. Engine resolves Step 2: DESIGNATION + initiator's dept (CARDIOLOGY)
--    Finds Dr. Meera (EmpId=55, CONSULTANT in CARDIOLOGY)
INSERT INTO workflow.WorkflowTask
    (WorkflowInstanceId, WorkflowStepId, WorkflowStepApproverId,
     AssignedToEmployeeId, TaskStatus, DueAt)
VALUES (@InstanceId, @LeaveStep2Id, @Step2ApproverId,
        55, 'PENDING', DATEADD(HOUR, 48, GETUTCDATE()));

-- 4. Log the action
INSERT INTO workflow.WorkflowActionHistory
    (WorkflowInstanceId, WorkflowTaskId, WorkflowStepId, WorkflowActionType,
     ActionBy, FromWorkflowStatus, ToWorkflowStatus)
VALUES (@InstanceId, @Task1Id, @LeaveStep1Id, 'APPROVE', 101, 'PENDING', 'IN_PROGRESS');
```

---

### Step 4 — Dr. Meera Approves (Step 2 → Step 3)

Engine resolves Step 3: DESIGNATION + **fixed** DEPARTMENT=HR → Ms. Kavya (EmpId=301).

Note: the scope here ignores the initiator's department entirely. Whether Dr. Priya is in Cardiology, Oncology, or Surgery — Step 3 always routes to HR.

---

### Step 5 — Ms. Kavya Approves (Final Step)

```sql
-- 1. Complete Step 3 task
UPDATE workflow.WorkflowTask
SET    TaskStatus = 'COMPLETED', ActionAt = GETUTCDATE()
WHERE  Id = @Task3Id;

-- 2. Close the workflow instance (IsFinalStep = 1)
UPDATE workflow.WorkflowInstance
SET    CurrentWorkflowStepId = NULL,
       WorkflowStatus = 'APPROVED',
       CompletedAt = GETUTCDATE()
WHERE  Id = @InstanceId;

-- 3. Log final approval
INSERT INTO workflow.WorkflowActionHistory
    (WorkflowInstanceId, WorkflowTaskId, WorkflowStepId, WorkflowActionType,
     ActionBy, FromWorkflowStatus, ToWorkflowStatus)
VALUES (@InstanceId, @Task3Id, @LeaveStep3Id, 'APPROVE', 301, 'IN_PROGRESS', 'APPROVED');
```

---

### Resolution Comparison — Same Initiator, Two Workflows

| Step | Leave Workflow | Expense Workflow |
|------|---------------|-----------------|
| Step 1 | Dr. Arjun (EmpId=101) — Reporting Manager | Dr. Arjun (EmpId=101) — same rule |
| Step 2 | Dr. Meera (EmpId=55) — Dept Head, Cardiology | Dr. Meera (EmpId=55) — same rule |
| Step 3 | Ms. Kavya (EmpId=301) — HR Manager, HR Dept | Mr. Ravi (EmpId=401) — Finance Manager, Finance Dept |

Steps 1 and 2 share identical configuration across both workflows. Only Step 3 differs by pointing to a different fixed department.

---

## Runtime Resolution Query

Standard resolution query for `DESIGNATION` type approvers. Run by the engine when advancing to a step.

```sql
-- Parameters:
--   @WorkflowStepApproverId  BIGINT  -- The rule being resolved
--   @InitiatorEmployeeId     BIGINT  -- Who submitted the transaction

SELECT      e.Id                AS ResolvedEmployeeId,
            e.EmployeeName      AS ResolvedEmployeeName,
            d.DesignationCode   AS ResolvedDesignation,
            dept.DepartmentCode AS ResolvedDepartment
FROM        employee.Employee                           e
JOIN        time.Designation                            d
                ON  d.Id = e.DesignationId
JOIN        time.Department                             dept
                ON  dept.Id = e.DepartmentId
JOIN        workflow.WorkflowStepApproverDesignation    wsad
                ON  wsad.DesignationId = d.Id
JOIN        workflow.WorkflowStepApprover               wsa
                ON  wsa.Id = wsad.WorkflowStepApproverId
WHERE       wsa.Id = @WorkflowStepApproverId
AND         e.DepartmentId = CASE
                -- NULL ScopeReferenceId = contextual (initiator's department)
                WHEN wsa.ScopeReferenceId IS NULL
                THEN (SELECT DepartmentId FROM employee.Employee WHERE Id = @InitiatorEmployeeId)
                -- Non-NULL = fixed department, ignore initiator
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

**Task lifecycle within a step:**

```
PENDING ──► COMPLETED  (approver acts)
        ──► DELEGATED  (approver delegates → new task created for delegate)
        ──► ESCALATED  (DueAt passed, no action)
        ──► CANCELLED  (workflow withdrawn/cancelled before action)
```

---

## Indexes Reference

| Index | Table | Columns | Purpose |
|-------|-------|---------|---------|
| `IX_WorkflowAssignment_Scope` | WorkflowAssignment | ScopeTypeId, ScopeReferenceId | Routing lookup on submit |
| `IX_WorkflowStepApprover_Step` | WorkflowStepApprover | WorkflowStepId | Load rules for a step |
| `IX_WorkflowStepApprover_Scope` | WorkflowStepApprover | ScopeTypeId, ScopeReferenceId | Scope-based rule filtering |
| `IX_WorkflowInstance_Module_Transaction` | WorkflowInstance | WorkflowModuleId, ReferenceTransactionId | Find instance for a transaction |
| `IX_WorkflowInstance_InitiatedBy` | WorkflowInstance | InitiatedBy | My submissions list |
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

| StatusCode | Label |
|------------|-------|
| `APPROVAL` | Approval Step |
| `REVIEW` | Review Step |
| `NOTIFICATION` | Notification Step |
| `FYI` | For Your Information |

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

### `WORKFLOW_TASK_STATUS`

| StatusCode | Label | Terminal |
|------------|-------|----------|
| `PENDING` | Pending | No |
| `COMPLETED` | Completed | **Yes** |
| `DELEGATED` | Delegated | **Yes** |
| `CANCELLED` | Cancelled | **Yes** |
| `ESCALATED` | Escalated | No |

---

## Design Decisions & Changelog

### v1 → v2

**ScopeType moved from `WorkflowAssignment` to `WorkflowStepApprover`**

In v1, `ScopeType` sat at the `WorkflowAssignment` (definition) level, meaning all steps in a workflow shared the same scope. This made it impossible for Step 1 to resolve from a department and Step 3 to always route to HR. Moving scope to `WorkflowStepApprover` gives each step its own independent resolution context.

**`WorkflowTask` table added**

`WorkflowStepApprover` defines who *should* approve (a rule). There was no table for the concrete, actionable task created when that rule is evaluated for a specific submission. `WorkflowTask` fills this gap — it is what powers the approver inbox.

**`WorkflowActionHistory` dual FK collision fixed**

The original schema had a single `WorkflowStatusGroup` computed column referenced by both `FromWorkflowStatus` and `ToWorkflowStatus` composite FKs. SQL Server cannot bind two composite FKs using the same computed column with different leading columns. Split into `FromWorkflowStatusGroup` and `ToWorkflowStatusGroup` — two independent computed columns.

### v2 → v3

**`WorkflowStepApprover.ApproverReferenceId` removed**

`EMPLOYEE` is already a `ScopeType` at `HierarchyLevel = 7`. A fixed approver is expressed as `ScopeTypeId = EMPLOYEE scope id`, `ScopeReferenceId = employee.Id` — the same resolution path as every other scope type. A dedicated `ApproverReferenceId` column would create two divergent paths for the same concept and require the engine to check which one to use.

**`WorkflowStepApproverDesignation` added**

Without this table, the engine had no data-driven way to know which designation qualifies as "Department Head" for a given step. The mapping table makes this configurable per step rather than hardcoded in application logic.

**Seed inserts corrected**

Column name corrected from `StatusName` (v2) to `Label` (matches `shared.StatusLookup` schema). Inserts moved from comment block to live executable SQL. `IsTerminal` populated meaningfully for all status groups.