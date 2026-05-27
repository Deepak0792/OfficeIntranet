# SdxCore.Workflow — API Endpoints Reference

---

## Schema Overview

**Schema:** `workflow`
**Service:** `SdxCore.Workflow.API`
**Port:** `http://localhost:5005`
**Gateway Route Prefix:** `/api/v1/workflow/**`
**Purpose:** Configurable multi-step approval workflow engine for all modules — Leave, Attendance Regularization, Shift Swap, Expense, Hiring, Onboarding, Exit, and any future approval-based process.

**Cross-schema Dependencies:**

| Dependency | Schema | Used By |
|------------|--------|---------|
| `StatusLookup` | `shared` | WorkflowStepType, ApproverType, WorkflowStatus, TaskStatus, ActionType |
| `Employee` | `employee` | Initiator, assignee, action-by on tasks and audit |
| `ScopeType` | `time` | Approver resolution + workflow assignment routing |
| `Department` | `time` | Scope resolution for DESIGNATION-type approvers |
| `Designation` | `time` | WorkflowStepApproverDesignation FK |

**Gateway Security:** ALL endpoints require `[GatewayOnly]`. Direct external access returns `403 Forbidden`.

**Soft Delete Pattern:** All configuration tables use `IsActive`. No hard deletes. Use `PATCH /{id}/status`.

---

## Common Patterns & Rules

### Gateway Security — `[GatewayOnly]`
All controllers validate the `X-Internal-ApiKey` header. Requests without a valid key receive:

```json
{
  "success": false,
  "message": "Access denied. This endpoint is only accessible through the API Gateway.",
  "data": null,
  "errors": ["Direct access is not permitted."]
}
```

### Audit Fields
- `CreatedBy` / `LastUpdatedBy` injected automatically by `BaseRepository` from `IRequestContext.UserId`.
- Populated from the `X-User-Id` header injected by the Gateway.
- Never accepted in request body.

### Data Type Mapping

| SQL Type | C# Type |
|----------|---------|
| `SMALLINT` | `short` |
| `INT` | `int` |
| `BIT` | `bool` |
| `DATETIME2` | `DateTime` |
| `DATE` | `DateOnly` |
| `NVARCHAR` | `string` |

### Response Envelopes
- `ApiResponse<T>` — single object.
- `PagedResponse<T>` — paged list.

---

## 1. WorkflowModule

**Base route:** `/api/v1/workflow/modules`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/modules` | List all workflow modules |
| GET | `/api/v1/workflow/modules/{id}` | Module detail |
| GET | `/api/v1/workflow/modules/by-code/{moduleCode}` | Lookup module by code (e.g. `LEAVE`, `ATTENDANCE_REGULARIZATION`) |
| POST | `/api/v1/workflow/modules` | Create a new workflow module |
| PUT | `/api/v1/workflow/modules/{id}` | Update module name or entity name |
| PATCH | `/api/v1/workflow/modules/{id}/status` | Activate or deactivate |

**Key Fields:** `ModuleCode`, `ModuleName`, `EntityName`, `IsActive`

**Seed Values:**

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

## 2. WorkflowDefinition

**Base route:** `/api/v1/workflow/definitions`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/definitions` | Paged list of all workflow definitions |
| GET | `/api/v1/workflow/definitions/{id}` | Definition detail with version info |
| GET | `/api/v1/workflow/definitions/by-module/{moduleId}` | All definitions for a module |
| GET | `/api/v1/workflow/definitions/by-code/{workflowCode}` | Lookup by unique workflow code |
| GET | `/api/v1/workflow/definitions/{id}/steps` | All steps for a definition (ordered by StepNo) |
| POST | `/api/v1/workflow/definitions` | Create a new workflow definition |
| PUT | `/api/v1/workflow/definitions/{id}` | Update name, version, description |
| PATCH | `/api/v1/workflow/definitions/{id}/status` | Activate or deactivate |

**Key Fields:** `WorkflowModuleId`, `WorkflowCode`, `WorkflowName`, `VersionNo`, `Description`, `IsActive`

**Business Rules:**
- Only one `IsActive = true` definition per module should be active at any time (validated at application layer).
- New versions are created as new rows with incremented `VersionNo`. Old versions are deactivated.

---

## 3. WorkflowStep

**Base route:** `/api/v1/workflow/definitions/{definitionId}/steps`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/definitions/{definitionId}/steps` | All steps for a definition ordered by StepNo |
| GET | `/api/v1/workflow/definitions/{definitionId}/steps/{id}` | Step detail with approver rules |
| POST | `/api/v1/workflow/definitions/{definitionId}/steps` | Add a step to a definition |
| PUT | `/api/v1/workflow/definitions/{definitionId}/steps/{id}` | Update step name, type, escalation hours |
| PATCH | `/api/v1/workflow/definitions/{definitionId}/steps/{id}/status` | Activate or deactivate a step |
| PATCH | `/api/v1/workflow/definitions/{definitionId}/steps/{id}/reorder` | Change step order (StepNo) |

**Key Fields:** `WorkflowDefinitionId`, `StepNo`, `StepName`, `WorkflowStepType`, `IsFinalStep`, `AllowDelegation`, `EscalationAfterHours`, `IsActive`

**`PATCH /{id}/reorder` body:**
```json
{ "stepNo": 2 }
```
Reordering updates the `StepNo` of the target step and adjusts the sequence of other steps accordingly.

---

## 4. WorkflowStepApprover

**Base route:** `/api/v1/workflow/steps/{stepId}/approvers`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/steps/{stepId}/approvers` | All approver rules for a step |
| GET | `/api/v1/workflow/steps/{stepId}/approvers/{id}` | Approver rule detail with scope info |
| POST | `/api/v1/workflow/steps/{stepId}/approvers` | Add an approver resolution rule to a step |
| PUT | `/api/v1/workflow/steps/{stepId}/approvers/{id}` | Update scope, priority, mandatory flag |
| PATCH | `/api/v1/workflow/steps/{stepId}/approvers/{id}/status` | Activate or deactivate |

**Key Fields:** `WorkflowStepId`, `WorkflowApproverType`, `ScopeTypeId`, `ScopeReferenceId`, `PriorityOrder`, `IsMandatory`, `IsActive`

**Request body for `POST`:**
```json
{
  "workflowApproverType": "DESIGNATION",
  "scopeTypeId": 5,
  "scopeReferenceId": null,
  "priorityOrder": 1,
  "isMandatory": true
}
```
`scopeReferenceId = null` means contextual — derive scope from initiator's org data at runtime.

---

## 5. WorkflowStepApproverDesignation

**Base route:** `/api/v1/workflow/approvers/{approverId}/designations`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/approvers/{approverId}/designations` | All qualifying designations for an approver rule |
| POST | `/api/v1/workflow/approvers/{approverId}/designations` | Add a qualifying designation |
| DELETE | `/api/v1/workflow/approvers/{approverId}/designations/{designationId}` | Remove a qualifying designation |

**Key Fields:** `WorkflowStepApproverId`, `DesignationId`

> **Note:** This is the only resource in the Workflow service that uses `DELETE` — there is no `IsActive` flag on designation mappings. Removing a designation from a step approver rule is a direct hard-delete of the mapping row, not a soft delete.

---

## 6. WorkflowAssignment

**Base route:** `/api/v1/workflow/assignments`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/assignments` | All workflow assignments |
| GET | `/api/v1/workflow/assignments/{id}` | Assignment detail |
| GET | `/api/v1/workflow/assignments/by-definition/{definitionId}` | All org assignments for a definition |
| GET | `/api/v1/workflow/assignments/resolve` | Resolve which definition applies for a given module + employee |
| POST | `/api/v1/workflow/assignments` | Assign a workflow definition to an org scope |
| PUT | `/api/v1/workflow/assignments/{id}` | Update effective dates or priority order |
| PATCH | `/api/v1/workflow/assignments/{id}/status` | Activate or deactivate |

**Key Fields:** `WorkflowDefinitionId`, `ScopeTypeId`, `ScopeReferenceId`, `EffectiveFrom`, `EffectiveTo`, `PriorityOrder`, `IsActive`

**`GET /resolve` — Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `moduleCode` | string | Yes | e.g. `LEAVE`, `ATTENDANCE_REGULARIZATION` |
| `employeeId` | int | Yes | The employee submitting the transaction |
| `effectiveDate` | date | No | Defaults to today (UTC) |

**Response:** Returns the resolved `WorkflowDefinitionId` and `WorkflowCode` that applies to this employee + module combination, considering scope hierarchy and priority order.

---

## 7. WorkflowInstance (Runtime)

**Base route:** `/api/v1/workflow/instances`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/instances` | Paged list with filters |
| GET | `/api/v1/workflow/instances/{id}` | Instance detail — current step, status, tasks |
| GET | `/api/v1/workflow/instances/{id}/tasks` | All tasks for an instance |
| GET | `/api/v1/workflow/instances/{id}/history` | Full audit trail for an instance |
| GET | `/api/v1/workflow/instances/by-transaction` | Find instance by module + reference transaction ID |
| GET | `/api/v1/workflow/instances/my-submissions` | All instances initiated by the current user |
| POST | `/api/v1/workflow/instances` | Submit a new transaction to workflow |
| PATCH | `/api/v1/workflow/instances/{id}/cancel` | Cancel an in-progress workflow (admin/system) |
| PATCH | `/api/v1/workflow/instances/{id}/withdraw` | Withdraw a submission (initiator only) |

**Key Fields:** `WorkflowDefinitionId`, `WorkflowModuleId`, `ReferenceTransactionId`, `CurrentWorkflowStepId`, `WorkflowStatus`, `CreatedBy`, `CreatedAt`, `CompletedAt`

**`POST /instances` — Submit body:**
```json
{
  "workflowModuleCode": "LEAVE",
  "referenceTransactionId": 501,
  "initiatedByEmployeeId": 201
}
```
The engine resolves the correct `WorkflowDefinition` via `WorkflowAssignment` and creates the first step's tasks automatically.

**`GET /by-transaction` — Query Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `moduleCode` | string | Yes |
| `referenceTransactionId` | int | Yes |

**`GET /instances` — Filters:**
- `?moduleCode=` — filter by module
- `?status=` — filter by workflow status
- `?initiatedBy=` — filter by initiator
- `?fromDate=&toDate=` — filter by submission date range
- `?page=&pageSize=` — pagination

---

## 8. WorkflowTask (Runtime)

**Base route:** `/api/v1/workflow/tasks`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/tasks/my-pending` | All pending tasks assigned to the current user (inbox) |
| GET | `/api/v1/workflow/tasks/{id}` | Task detail with instance and step context |
| PATCH | `/api/v1/workflow/tasks/{id}/approve` | Approve a task |
| PATCH | `/api/v1/workflow/tasks/{id}/reject` | Reject a task (terminates instance) |
| PATCH | `/api/v1/workflow/tasks/{id}/delegate` | Delegate task to another employee |
| PATCH | `/api/v1/workflow/tasks/{id}/return` | Return to initiator for clarification |
| PATCH | `/api/v1/workflow/tasks/{id}/reassign` | Admin reassignment to a different employee |

**Key Fields:** `WorkflowInstanceId`, `WorkflowStepId`, `AssignedToEmployeeId`, `DelegatedFromEmployeeId`, `TaskStatus`, `DueAt`, `ActionAt`, `Remarks`, `ParentWorkflowTaskId`

**`PATCH /approve` body:**
```json
{ "remarks": "Approved. Proceed." }
```

**`PATCH /reject` body:**
```json
{ "remarks": "Leave dates conflict with project deadline." }
```

**`PATCH /delegate` body:**
```json
{
  "delegateToEmployeeId": 310,
  "remarks": "On leave — delegating to deputy."
}
```

**`PATCH /return` body:**
```json
{ "remarks": "Please provide supporting documentation for the dates." }
```

**`PATCH /reassign` body (admin only):**
```json
{
  "reassignToEmployeeId": 315,
  "remarks": "Original approver transferred to another department."
}
```

**`GET /my-pending` — Query Parameters:**
- `?moduleCode=` — filter by module (e.g. show only LEAVE tasks)
- `?page=&pageSize=` — pagination

> `GET /my-pending` is the **approver inbox** — the most frequently called endpoint in the workflow service. It queries `WorkflowTask WHERE AssignedToEmployeeId = {currentUserId} AND TaskStatus = 'PENDING'`.

---

## 9. WorkflowActionHistory (Audit)

**Base route:** `/api/v1/workflow/instances/{instanceId}/history`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| GET | `/api/v1/workflow/instances/{instanceId}/history` | Full chronological audit trail for an instance |
| GET | `/api/v1/workflow/tasks/{taskId}/history` | Audit entries for a specific task |

**Key Fields:** `WorkflowInstanceId`, `WorkflowTaskId`, `WorkflowStepId`, `WorkflowActionType`, `ActionBy`, `ActionAt`, `Remarks`, `FromWorkflowStatus`, `ToWorkflowStatus`

> Audit history is read-only. No POST, PUT, or PATCH endpoints exist for this resource.

---

## 10. Workflow Resolution Utility

**Base route:** `/api/v1/workflow/resolve`

| Method | Route | Business Purpose |
|--------|-------|-----------------|
| POST | `/api/v1/workflow/resolve/approvers` | Preview approver resolution for a given step + initiator (dry-run, no task created) |
| GET | `/api/v1/workflow/resolve/definition` | Resolve applicable workflow definition for a module + employee |

**`POST /resolve/approvers` — Preview body:**
```json
{
  "workflowStepId": 3,
  "initiatorEmployeeId": 201
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "workflowStepApproverId": 5,
      "approverType": "DESIGNATION",
      "resolvedEmployeeId": 55,
      "resolvedEmployeeName": "Dr. Meera",
      "resolvedDesignation": "CONSULTANT",
      "resolvedDepartment": "CARDIOLOGY"
    }
  ]
}
```
Used by admins to verify configuration before going live.

---

## Endpoint Count Summary

| Resource | GET | POST | PUT | PATCH | DELETE | Total |
|----------|-----|------|-----|-------|--------|-------|
| WorkflowModule | 3 | 1 | 1 | 1 | — | 6 |
| WorkflowDefinition | 5 | 1 | 1 | 1 | — | 8 |
| WorkflowStep | 2 | 1 | 1 | 2 | — | 6 |
| WorkflowStepApprover | 2 | 1 | 1 | 1 | — | 5 |
| WorkflowStepApproverDesignation | 1 | 1 | — | — | 1 | 3 |
| WorkflowAssignment | 3 | 1 | 1 | 1 | — | 6 |
| WorkflowInstance | 7 | 1 | — | 2 | — | 10 |
| WorkflowTask | 2 | — | — | 5 | — | 7 |
| WorkflowActionHistory | 2 | — | — | — | — | 2 |
| Workflow Resolution | 1 | 1 | — | — | — | 2 |
| **TOTAL** | **28** | **8** | **5** | **13** | **1** | **55** |

---

## Configuration Seeding Order

When bootstrapping the workflow engine for a new environment:

1. Seed `shared.StatusLookup` — all `WORKFLOW_*` groups (step type, approver type, status, task status, action type).
2. Seed `workflow.WorkflowModule` — one row per business module.
3. Create `workflow.WorkflowDefinition` — one per module (or multiple versions).
4. Create `workflow.WorkflowStep` — ordered steps per definition.
5. Create `workflow.WorkflowStepApprover` — resolution rules per step.
6. Create `workflow.WorkflowStepApproverDesignation` — qualifying designations for `DESIGNATION`-type rules.
7. Create `workflow.WorkflowAssignment` — assign definitions to org scopes.

---

## Integration Pattern — How Owning Services Use the Workflow API

### Step 1 — Submit transaction to workflow

Called by Attendance.API when employee submits a leave request:

```
POST /api/v1/workflow/instances
{
  "workflowModuleCode": "LEAVE",
  "referenceTransactionId": 501,
  "initiatedByEmployeeId": 201
}
```

Response includes `workflowInstanceId`. The owning service stores this on the originating record (`LeaveRequest.WorkflowInstanceId = 1042`).

### Step 2 — Engine resolves approvers and creates tasks

Workflow.API internally evaluates `WorkflowAssignment` to find the applicable `WorkflowDefinition`, then resolves `WorkflowStepApprover` rules for Step 1 and creates `WorkflowTask` rows.

### Step 3 — Approver acts via task inbox

Approver calls `PATCH /api/v1/workflow/tasks/{id}/approve` from their task inbox.

### Step 4 — Engine advances or terminates

On approve, the engine creates tasks for the next step. On the final step approval, `WorkflowInstance.WorkflowStatus = APPROVED`.

### Step 5 — RabbitMQ event published

```json
{
  "eventType": "workflow.instance.status_changed",
  "workflowInstanceId": 1042,
  "workflowModuleCode": "LEAVE",
  "referenceTransactionId": 501,
  "newStatus": "APPROVED"
}
```

### Step 6 — Owning service updates its record

Attendance.API consumes the event and sets `LeaveRequest.LeaveStatus = APPROVED` and `LeaveRequest.ApprovedBy`, `ApprovedAt`.