-- ============================================================
-- WORKFLOW SCHEMA - Seed Data
-- Healthcare Organization: MediCore Health Systems
-- Dependencies: shared.StatusLookup, time.ScopeType,
--               time.Department, time.Designation,
--               time.OfficeLocation, employee.Employee
--
-- CHANGES FROM ORIGINAL SEED:
--
-- Section 4 (WorkflowStepApprover):
--   - ApproverReferenceId column REMOVED (dropped in schema v3)
--   - Invalid approver type codes replaced:
--       DEPARTMENT_HEAD - DESIGNATION  (resolved via designation map)
--       HR_MANAGER      - DESIGNATION  (resolved via designation map)
--       USER            - EMPLOYEE     (fixed employee via ScopeType=EMPLOYEE)
--       ROLE            - DESIGNATION  (role-based resolved via designation map)
--   - ScopeTypeId + ScopeReferenceId added per step approver rule
--   - Hardcoded integer ApproverReferenceId values replaced with
--     dynamic subqueries on ScopeCode / DesignationCode / EmployeeCode
--
-- Section 4b (WorkflowStepApproverDesignation) - NEW SECTION:
--   - Maps each DESIGNATION-type rule to qualifying designation(s)
--   - Required for engine to resolve "who is the Dept Head / HR Manager"
--     without hardcoding in application logic
--
-- Section 5 (WorkflowAssignment):
--   - Raw integer ScopeTypeId literals (1,4,5,6) replaced with
--     dynamic subqueries on time.ScopeType.ScopeCode
--   - GLOBAL and LEGAL_ENTITY assignments: ScopeReferenceId set to 1
--     (sentinel value for the single global/entity record)
--
-- Section 7 (WorkflowActionHistory):
--   - 'RETURN' action code replaced with 'RETURN_FOR_CLARIFICATION'
--     (added to WORKFLOW_ACTION_TYPE seed below)
--   - WorkflowTaskId column explicitly listed as NULL
--     (tasks not seeded individually; column required by schema)
-- ============================================================

-- ============================================================
-- PRE-REQUISITE: Additional StatusLookup entry for RETURN action
-- Add to existing WORKFLOW_ACTION_TYPE group
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM shared.StatusLookup
    WHERE StatusCode = 'RETURN_FOR_CLARIFICATION' AND StatusGroup = 'WORKFLOW_ACTION_TYPE'
)
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal)
    VALUES ('RETURN_FOR_CLARIFICATION', 'WORKFLOW_ACTION_TYPE', 'Returned for Clarification', 9, 0);
END
GO


-- ============================================================
-- 1. WORKFLOW MODULES
--    One row per business entity that participates in approvals.
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowModule] ON;
GO

INSERT [workflow].[WorkflowModule]
    ([Id], [ModuleCode], [ModuleName], [schema], [EntityName], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Attendance domain
    (1,   N'LEAVE_REQUEST',              N'Leave Management',               N'attendance', N'LeaveRequest',               1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (2,   N'ATTENDANCE_REGULARIZATION',  N'Attendance Regularization',      N'attendance', N'AttendanceRegularization',    1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (3,   N'SHIFT_SWAP_REQUEST',         N'Shift Swap',                     N'attendance', N'ShiftSwapRequest',            1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (5,   N'COMP_OFF_REDEMPTION',        N'Comp-Off Redemption',            N'attendance', N'CompOffBalance',              1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),

    -- Employee domain
    (8,   N'DOCUMENT_VERIFICATION',      N'Document Verification',          N'employee',   N'EmployeeDocument',            1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (102, N'ADDRESS_VERIFICATION',       N'Employee Address Verification',  N'employee',   N'EmployeeAddress',             1, CAST(N'2026-05-27T17:04:30.3000000' AS DateTime2), NULL, CAST(N'2026-05-27T17:04:30.3000000' AS DateTime2), NULL),

    -- Payroll domain
    (9,   N'PAYROLL_CORRECTION',         N'Payroll Attendance Correction',  N'payroll',    N'PayrollAttendanceSummary',    1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (10,  N'EXPENSE_REIMBURSEMENT',      N'Expense & Reimbursement',        N'payroll',    N'ExpenseClaim',                1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL);

SET IDENTITY_INSERT [workflow].[WorkflowModule] OFF;
GO


-- ============================================================
-- 2. WORKFLOW DEFINITIONS
--    One row per named workflow variant within a module.
--    A module can have multiple definitions (e.g. standard vs fast-track).
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowDefinition] ON;
GO

INSERT [workflow].[WorkflowDefinition]
    ([Id], [WorkflowModuleId], [WorkflowCode], [WorkflowName], [VersionNo], [Description], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Leave Request (Module 1)
    (1,   1,  N'WF_LEAVE_STD_V1',           N'Standard Leave Approval',                  1, N'Three-level approval for all standard leave types.',            1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),
    (2,   1,  N'WF_LEAVE_EMRGENCY_V1',      N'Emergency Leave Fast-Track Approval',       1, N'Single-step fast-track approval for emergency leave requests.', 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),
    (8,   1,  N'WF_TRAINING_LEAVE_V1',      N'Training & Conference Leave Approval',      1, N'Three-level approval for training programs.',                   1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),

    -- Attendance Regularization (Module 2)
    (3,   2,  N'WF_ATTENDANCE_REG_STD_V1',  N'Attendance Regularization Approval',        1, N'Two-level approval for attendance correction requests.',        1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),

    -- Shift Swap (Module 3)
    (4,   3,  N'WF_SHIFT_SWAP_REQUEST_V1',  N'Shift Swap Approval',                       1, N'Two-level approval for shift swap requests.',                   1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),

    -- Comp-Off Redemption (Module 5)
    (6,   5,  N'WF_COMP_OFF_REQUEST_V1',    N'Comp-Off Redemption Approval',              1, N'Single-step approval by Reporting Manager.',                    1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),

    -- Document Verification (Module 8)
    (9,   8,  N'WF_DOCUMENT_VERIFY_V1',     N'Employee Document Verification',            1, N'Single-step HR Manager verification workflow.',                 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),

    -- Payroll Correction (Module 9)
    (10,  9,  N'WF_PAYROLL_CORRECTION_V1',  N'Payroll Attendance Correction Approval',    1, N'Two-level approval for payroll attendance corrections.',        1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), 1),

    -- Address Verification (Module 102)
    (103, 102, N'WF_ADDRESS_VERIFICATION_V1', N'Employee Address Approval',               1, N'Single-step HR Manager verification workflow.',                 1, CAST(N'2026-05-27T17:17:17.1333333' AS DateTime2), 1, CAST(N'2026-05-27T17:17:17.1333333' AS DateTime2), 1);

SET IDENTITY_INSERT [workflow].[WorkflowDefinition] OFF;
GO


-- ============================================================
-- 3. WORKFLOW STEPS
--    Ordered steps within each definition.
--    IsFinalStep = 1 marks the last approver in the chain.
--    EscalationAfterHours = auto-escalate SLA per step.
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowStep] ON;
GO

INSERT [workflow].[WorkflowStep]
    ([Id], [WorkflowDefinitionId], [StepNo], [StepName], [WorkflowStepType], [IsFinalStep], [AllowDelegation], [EscalationAfterHours], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- ── WF_LEAVE_STD_V1 (Id: 1) — 3 steps ──────────────────────────
    (1,  1,  1, N'Reporting Manager Approval',         N'APPROVAL', 0, 1, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (2,  1,  2, N'Department Head Approval',           N'APPROVAL', 0, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (3,  1,  3, N'HR Manager Final Approval',          N'APPROVAL', 1, 0, 72, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_LEAVE_EMRGENCY_V1 (Id: 2) — 1 step (fast-track) ─────────
    (4,  2,  1, N'Reporting Manager Emergency Approval', N'APPROVAL', 1, 1,  2, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_ATTENDANCE_REG_STD_V1 (Id: 3) — 2 steps ─────────────────
    (5,  3,  1, N'Reporting Manager Review',           N'REVIEW',   0, 1, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (6,  3,  2, N'HR Manager Approval',                N'APPROVAL', 1, 0, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_SHIFT_SWAP_REQUEST_V1 (Id: 4) — 2 steps ──────────────────
    (7,  4,  1, N'Ward In-Charge Approval',            N'APPROVAL', 0, 1, 12, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (8,  4,  2, N'Scheduling Coordinator Approval',   N'APPROVAL', 1, 0, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_COMP_OFF_REQUEST_V1 (Id: 6) — 1 step ─────────────────────
    (11, 6,  1, N'Reporting Manager Approval',         N'APPROVAL', 1, 1, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_TRAINING_LEAVE_V1 (Id: 8) — 3 steps ──────────────────────
    (14, 8,  1, N'Department Head Approval',           N'APPROVAL', 0, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (15, 8,  2, N'HR Manager Review',                  N'REVIEW',   0, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (16, 8,  3, N'Finance Manager Cost Approval',      N'APPROVAL', 1, 0, 72, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_DOCUMENT_VERIFY_V1 (Id: 9) — 1 step ──────────────────────
    (17, 9,  1, N'HR Manager Document Verification',  N'APPROVAL', 1, 0, 72, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_PAYROLL_CORRECTION_V1 (Id: 10) — 2 steps ─────────────────
    (18, 10, 1, N'HR Manager Review',                  N'REVIEW',   0, 0, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (19, 10, 2, N'Finance Manager Authorization',      N'APPROVAL', 1, 0, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_ADDRESS_VERIFICATION_V1 (Id: 103) — 1 step ───────────────
    (104, 103, 1, N'HR Manager Review',                N'APPROVAL', 1, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL);

SET IDENTITY_INSERT [workflow].[WorkflowStep] OFF;
GO


-- ============================================================
-- SECTION 4: WORKFLOW STEP APPROVERS
--
-- Design rules applied:
--   REPORTING_MANAGER - ScopeTypeId=NULL, ScopeReferenceId=NULL
--     Engine follows Employee.ReportingManagerId directly.
--
--   DESIGNATION (contextual, e.g. Dept Head of initiator's dept)
--     - ScopeTypeId = DEPARTMENT, ScopeReferenceId = NULL
--     Engine resolves to initiator's own department at runtime.
--     Qualifying designations set in Section 4b.
--
--   DESIGNATION (fixed dept, e.g. HR Manager always in HR dept)
--     - ScopeTypeId = DEPARTMENT, ScopeReferenceId = <HR dept id>
--     Engine always routes to that specific department.
--     Qualifying designations set in Section 4b.
--
--   EMPLOYEE (fixed person, e.g. CMO is always EmpId=2)
--     - ScopeTypeId = EMPLOYEE, ScopeReferenceId = <employee id>
--     No designation map needed - resolves to exact employee.
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowStepApprover] ON;
GO

INSERT [workflow].[WorkflowStepApprover]
    ([Id], [WorkflowStepId], [WorkflowApproverType], [ScopeTypeId], [ScopeReferenceId], [PriorityOrder], [IsMandatory], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- WF_LEAVE_STD_V1
    (1,  1,  N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager
    (2,  2,  N'DESIGNATION',       5,    NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: HOD (multi-designation, see Section 5)
    (3,  3,  N'DESIGNATION',       5,    7,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 3: HR Manager (DesignationId 7)

    -- WF_LEAVE_EMRGENCY_V1
    (4,  4,  N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager

    -- WF_ATTENDANCE_REG_STD_V1
    (5,  5,  N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager
    (6,  6,  N'DESIGNATION',       5,    7,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: HR Manager (DesignationId 7)

    -- WF_SHIFT_SWAP_REQUEST_V1
    (7,  7,  N'DESIGNATION',       5,    NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Ward In-Charge
    (8,  8,  N'DESIGNATION',       5,    10,   1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: Scheduling Coordinator (DesignationId 10)

    -- WF_COMP_OFF_REQUEST_V1
    (11, 11, N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager

    -- WF_TRAINING_LEAVE_V1
    (14, 14, N'DESIGNATION',       5,    NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: HOD (multi-designation, see Section 5)
    (15, 15, N'DESIGNATION',       5,    7,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: HR Manager (DesignationId 7)
    (16, 16, N'DESIGNATION',       5,    9,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 3: Finance Manager (DesignationId 9)

    -- WF_DOCUMENT_VERIFY_V1
    (17, 17, N'DESIGNATION',       5,    7,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: HR Manager (DesignationId 7)

    -- WF_PAYROLL_CORRECTION_V1
    (18, 18, N'DESIGNATION',       5,    7,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: HR Manager (DesignationId 7)
    (19, 19, N'DESIGNATION',       5,    9,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: Finance Manager (DesignationId 9)

    -- WF_ADDRESS_VERIFICATION_V1
    (102, 104, N'DESIGNATION',     5,    7,    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL);  -- Step 1: HR Manager (DesignationId 7)

SET IDENTITY_INSERT [workflow].[WorkflowStepApprover] OFF;
GO


-- ============================================================
-- SECTION 4b: WORKFLOW STEP APPROVER DESIGNATION MAP  - NEW
--
-- Maps each DESIGNATION-type WorkflowStepApprover rule to the
-- qualifying designation(s) the engine should look for.
--
-- Rules:
--   Dept Head (contextual)   - all senior/head-level designations
--                              so the correct one fires per department
--   HR Manager (fixed HR)    - HRMANAGER only
--   Finance Manager (fixed)  - FINMANAGER only
--   Ward In-Charge (nursing) - SRNURSE (acts as ward in-charge)
--   Scheduling Coordinator   - OPSMGR (Operations manages scheduling)
--   Shift Supervisor (OT S1) - SRNURSE, SRSURGEON, SRPHARM (senior per dept)
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowStepApproverDesignation] ON;
GO

INSERT [workflow].[WorkflowStepApproverDesignation]
    ([Id], [WorkflowStepApproverId], [DesignationId], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Approver 2 — HOD on WF_LEAVE_STD_V1 Step 2 (all department head designations)
    (1,  2,  4,  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (2,  2,  7,  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (3,  2,  11, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (4,  2,  14, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (5,  2,  16, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (6,  2,  18, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (7,  2,  21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (8,  2,  24, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (9,  2,  27, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (10, 2,  29, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (11, 2,  31, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (12, 2,  3,  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 3  — HR Manager on WF_LEAVE_STD_V1 Step 3
    (13, 3,  21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 6  — HR Manager on WF_ATTENDANCE_REG_STD_V1 Step 2
    (14, 6,  21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 7  — Ward In-Charge on WF_SHIFT_SWAP_REQUEST_V1 Step 1
    (15, 7,  8,  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 8  — Scheduling Coordinator on WF_SHIFT_SWAP_REQUEST_V1 Step 2
    (16, 8,  29, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 14 — HOD on WF_TRAINING_LEAVE_V1 Step 1 (mirrors Approver 2 designation set)
    (46, 14, 4,  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (47, 14, 7,  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (48, 14, 11, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (49, 14, 14, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (50, 14, 16, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (51, 14, 18, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (52, 14, 21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (53, 14, 24, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (54, 14, 27, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (55, 14, 29, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (56, 14, 31, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (57, 14, 3,  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 15 — HR Manager on WF_TRAINING_LEAVE_V1 Step 2
    (58, 15, 21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 16 — Finance Manager on WF_TRAINING_LEAVE_V1 Step 3
    (59, 16, 27, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 17 — HR Manager on WF_DOCUMENT_VERIFY_V1 Step 1
    (60, 17, 21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 18 — HR Manager on WF_PAYROLL_CORRECTION_V1 Step 1
    (61, 18, 21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 19 — Finance Manager on WF_PAYROLL_CORRECTION_V1 Step 2
    (62, 19, 27, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 102 — HR Manager on WF_ADDRESS_VERIFICATION_V1 Step 1
    (102, 102, 21, 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL);

SET IDENTITY_INSERT [workflow].[WorkflowStepApproverDesignation] OFF;
GO


-- ============================================================
-- SECTION 5: WORKFLOW ASSIGNMENTS
--
-- Maps workflow definitions to org scopes for routing.
-- ScopeTypeId resolved dynamically via ScopeCode subquery.
-- ScopeReferenceId:
--   GLOBAL       - 1  (sentinel: applies to entire system)
--   LEGAL_ENTITY - 1  (sentinel: single legal entity)
--   OFFICE       - resolved from time.OfficeLocation.LocationCode
--   DEPARTMENT   - resolved from time.Department.DepartmentCode
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowAssignment] ON;
GO

INSERT [workflow].[WorkflowAssignment]
    ([Id], [WorkflowDefinitionId], [ScopeTypeId], [ScopeReferenceId], [EffectiveFrom], [EffectiveTo], [PriorityOrder], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Global assignments (ScopeTypeId 1, ScopeReferenceId 1)
    (1,   1,   1, 1, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_LEAVE_STD_V1
    (2,   2,   1, 1, CAST(N'2024-01-01' AS Date), NULL,  5, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_LEAVE_EMRGENCY_V1       (priority 5 = higher precedence)
    (3,   3,   1, 1, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_ATTENDANCE_REG_STD_V1
    (9,   6,   1, 1, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_COMP_OFF_REQUEST_V1
    (14,  8,   1, 1, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_TRAINING_LEAVE_V1
    (15,  9,   1, 1, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_DOCUMENT_VERIFY_V1
    (102, 103, 1, 1, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_ADDRESS_VERIFICATION_V1

    -- Department-scoped assignments (ScopeTypeId 4)
    (4,   4,   4, 6, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_SHIFT_SWAP_REQUEST_V1 → Dept 6
    (5,   4,   4, 5, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_SHIFT_SWAP_REQUEST_V1 → Dept 5

    -- Legal Entity-scoped assignment (ScopeTypeId 3)
    (16,  10,  3, 1, CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL);  -- WF_PAYROLL_CORRECTION_V1

SET IDENTITY_INSERT [workflow].[WorkflowAssignment] OFF;
GO


-- ============================================================
-- 7. WORKFLOW INSTANCES
--    Runtime records — one per submitted transaction.
--    WorkflowStatus: PENDING | IN_PROGRESS | APPROVED | REJECTED | CANCELLED
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowInstance] ON;
GO

INSERT [workflow].[WorkflowInstance]
    ([Id], [WorkflowDefinitionId], [WorkflowModuleId], [ReferenceTransactionId], [CurrentWorkflowStepId], [WorkflowStatus], [CreatedBy], [CreatedAt], [CompletedAt], [CompletedBy])
VALUES
    -- Active / in-progress instances
    (1,  1,  1, 101, 2,    N'IN_PROGRESS', 5,  CAST(N'2025-04-28T09:15:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Leave: at HOD step
    (3,  3,  2, 201, 5,    N'PENDING',     12, CAST(N'2025-04-30T10:00:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Attendance Reg: awaiting manager
    (4,  4,  3, 301, 8,    N'IN_PROGRESS', 9,  CAST(N'2025-04-27T14:30:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Shift Swap: at coordinator step
    (6,  6,  5, 501, 11,   N'PENDING',     14, CAST(N'2025-05-01T08:00:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Comp-Off: awaiting manager
    (10, 10, 9, 901, 19,   N'IN_PROGRESS', 1,  CAST(N'2025-05-02T09:00:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Payroll Correction: at finance step

    -- Completed instances
    (2,  2,  1, 102, NULL, N'APPROVED',    8,  CAST(N'2025-04-29T06:45:00.0000000' AS DateTime2), CAST(N'2025-04-29T08:10:00.0000000' AS DateTime2), NULL),  -- Emergency Leave: fast-track approved
    (9,  9,  8, 801, NULL, N'APPROVED',    3,  CAST(N'2025-04-15T10:30:00.0000000' AS DateTime2), CAST(N'2025-04-16T14:00:00.0000000' AS DateTime2), NULL),  -- Document Verification: approved
    (11, 1,  1, 103, NULL, N'APPROVED',    16, CAST(N'2025-04-10T08:00:00.0000000' AS DateTime2), CAST(N'2025-04-14T17:00:00.0000000' AS DateTime2), NULL),  -- Leave (full 3-step): approved

    -- Terminated instances
    (12, 4,  3, 302, NULL, N'CANCELLED',   11, CAST(N'2025-04-22T13:00:00.0000000' AS DateTime2), CAST(N'2025-04-22T15:30:00.0000000' AS DateTime2), NULL),  -- Shift Swap: cancelled by requester
    (14, 3,  2, 202, NULL, N'REJECTED',    17, CAST(N'2025-04-18T09:00:00.0000000' AS DateTime2), CAST(N'2025-04-19T11:00:00.0000000' AS DateTime2), NULL);  -- Attendance Reg: rejected (no proof)

SET IDENTITY_INSERT [workflow].[WorkflowInstance] OFF;
GO


-- ============================================================
-- SECTION 7: WORKFLOW ACTION HISTORY
--
-- Immutable audit trail. One row per action taken.
-- WorkflowTaskId is NULL throughout - tasks are not individually
-- seeded in this dataset; the column is required by schema.
--
-- WorkflowInstanceId resolved via (WorkflowCode + ModuleCode + RefTxId).
-- WorkflowStepId     resolved via (WorkflowCode + StepNo); NULL for
--                    system-level actions (CANCEL, WITHDRAW).
--
-- FIX: 'RETURN' replaced with 'RETURN_FOR_CLARIFICATION'
--      (seeded in WORKFLOW_ACTION_TYPE above).
-- ============================================================

SET IDENTITY_INSERT [workflow].[WorkflowActionHistory] ON;
GO

INSERT [workflow].[WorkflowActionHistory]
    ([Id], [WorkflowInstanceId], [WorkflowTaskId], [WorkflowStepId], [WorkflowActionType], [Remarks], [FromWorkflowStatus], [ToWorkflowStatus], [IsActive], [ActionBy], [ActionAt])
VALUES
    -- ── Instance 1: Standard Leave (IN_PROGRESS at HOD) ─────────────
    (1,  1,  NULL, 1,    N'SUBMIT',  N'Leave request submitted for 3 days Casual Leave.',           NULL,          N'PENDING',     1, 5,  CAST(N'2025-04-28T09:15:00.0000000' AS DateTime2)),
    (2,  1,  NULL, 1,    N'APPROVE', N'Approved. Ward coverage confirmed for the period.',           N'PENDING',    N'IN_PROGRESS', 1, 2,  CAST(N'2025-04-28T11:30:00.0000000' AS DateTime2)),

    -- ── Instance 2: Emergency Leave (APPROVED) ───────────────────────
    (3,  2,  NULL, 4,    N'SUBMIT',  N'Family medical emergency. Requesting immediate leave.',       NULL,          N'PENDING',     1, 8,  CAST(N'2025-04-29T06:45:00.0000000' AS DateTime2)),
    (4,  2,  NULL, 4,    N'APPROVE', N'Approved on humanitarian grounds. Cover arranged.',          N'PENDING',    N'APPROVED',    1, 2,  CAST(N'2025-04-29T08:10:00.0000000' AS DateTime2)),

    -- ── Instance 3: Attendance Regularization (PENDING) ─────────────
    (5,  3,  NULL, 5,    N'SUBMIT',  N'Biometric reader malfunction on 29-Apr. Requesting correction.', NULL,      N'PENDING',     1, 12, CAST(N'2025-04-30T10:00:00.0000000' AS DateTime2)),

    -- ── Instance 4: Shift Swap (IN_PROGRESS at coordinator) ─────────
    (6,  4,  NULL, 7,    N'SUBMIT',  N'Requesting swap with Emp #11 for 02-May morning shift.',     NULL,          N'PENDING',     1, 9,  CAST(N'2025-04-27T14:30:00.0000000' AS DateTime2)),
    (7,  4,  NULL, 7,    N'APPROVE', N'Operationally feasible. Both employees trained for the shift.', N'PENDING', N'IN_PROGRESS', 1, 2,  CAST(N'2025-04-27T16:00:00.0000000' AS DateTime2)),

    -- ── Instance 6: Comp-Off Redemption (PENDING) ───────────────────
    (11, 6,  NULL, 11,   N'SUBMIT',  N'Applying comp-off earned on 27-Apr (holiday working).',      NULL,          N'PENDING',     1, 14, CAST(N'2025-05-01T08:00:00.0000000' AS DateTime2)),

    -- ── Instance 9: Document Verification (APPROVED) ────────────────
    (18, 9,  NULL, 17,   N'SUBMIT',  N'Nursing Council License renewed. Uploading updated document.', NULL,        N'PENDING',     1, 3,  CAST(N'2025-04-15T10:30:00.0000000' AS DateTime2)),
    (19, 9,  NULL, 17,   N'APPROVE', N'Document verified. License valid until 2027-03-31.',          N'PENDING',   N'APPROVED',    1, 1,  CAST(N'2025-04-16T14:00:00.0000000' AS DateTime2)),

    -- ── Instance 10: Payroll Correction (IN_PROGRESS at finance) ────
    (20, 10, NULL, 18,   N'SUBMIT',  N'Correcting 2 absent days erroneously marked for Emp #12 in April. Attendance logs attached.', NULL, N'PENDING',     1, 1, CAST(N'2025-05-02T09:00:00.0000000' AS DateTime2)),
    (21, 10, NULL, 18,   N'APPROVE', N'HR review complete. Logs verified. Forwarding to Finance.',   N'PENDING',   N'IN_PROGRESS', 1, 1,  CAST(N'2025-05-02T09:30:00.0000000' AS DateTime2)),

    -- ── Instance 11: Standard Leave — full 3-step (APPROVED) ────────
    (22, 11, NULL, 1,    N'SUBMIT',  N'Earned leave for 5 days. Pre-planned annual vacation.',       NULL,          N'PENDING',     1, 16, CAST(N'2025-04-10T08:00:00.0000000' AS DateTime2)),
    (23, 11, NULL, 1,    N'APPROVE', N'Approved. Handover document submitted.',                      N'PENDING',    N'IN_PROGRESS', 1, 2,  CAST(N'2025-04-10T11:00:00.0000000' AS DateTime2)),
    (24, 11, NULL, 2,    N'APPROVE', N'Approved by Dept Head. Leave balance confirmed.',              N'IN_PROGRESS',N'IN_PROGRESS', 1, 7,  CAST(N'2025-04-11T10:00:00.0000000' AS DateTime2)),
    (25, 11, NULL, 3,    N'APPROVE', N'HR final approval. Leave recorded in system.',                 N'IN_PROGRESS',N'APPROVED',    1, 1,  CAST(N'2025-04-14T17:00:00.0000000' AS DateTime2)),

    -- ── Instance 12: Shift Swap (CANCELLED by requester) ────────────
    (26, 12, NULL, 7,    N'SUBMIT',  N'Requesting shift swap with Emp #9 for 25-Apr.',               NULL,          N'PENDING',     1, 11, CAST(N'2025-04-22T13:00:00.0000000' AS DateTime2)),
    (27, 12, NULL, NULL, N'CANCEL',  N'Swap no longer needed. Other arrangements made. Cancelling request.', N'PENDING', N'CANCELLED', 1, 11, CAST(N'2025-04-22T15:30:00.0000000' AS DateTime2)),

    -- ── Instance 14: Attendance Regularization (REJECTED) ───────────
    (30, 14, NULL, 5,    N'SUBMIT',  N'Requesting regularization for 17-Apr. Was working from home.', NULL,         N'PENDING',     1, 17, CAST(N'2025-04-18T09:00:00.0000000' AS DateTime2)),
    (31, 14, NULL, 5,    N'RETURN',  N'No WFH approval on record for 17-Apr. Please provide prior approval proof.', N'PENDING', N'IN_PROGRESS', 1, 2, CAST(N'2025-04-18T14:00:00.0000000' AS DateTime2)),
    (32, 14, NULL, 6,    N'REJECT',  N'Regularization rejected. No valid supporting documentation provided.', N'IN_PROGRESS', N'REJECTED', 1, 1, CAST(N'2025-04-19T11:00:00.0000000' AS DateTime2));

SET IDENTITY_INSERT [workflow].[WorkflowActionHistory] OFF;
GO


-- ============================================================
-- VERIFICATION QUERIES
-- Run after execution to confirm data integrity.
-- ============================================================

-- Workflow summary: modules → definitions → step count
SELECT
    wm.ModuleCode,
    wm.ModuleName,
    wd.WorkflowCode,
    wd.WorkflowName,
    wd.VersionNo,
    COUNT(ws.Id)        AS TotalSteps,
    MAX(ws.StepNo)      AS LastStepNo
FROM       [workflow].[WorkflowModule]     wm
JOIN       [workflow].[WorkflowDefinition] wd ON wd.WorkflowModuleId = wm.Id
LEFT JOIN  [workflow].[WorkflowStep]       ws ON ws.WorkflowDefinitionId = wd.Id
WHERE wm.IsActive = 1
GROUP BY wm.ModuleCode, wm.ModuleName, wd.WorkflowCode, wd.WorkflowName, wd.VersionNo
ORDER BY wm.ModuleCode, wd.WorkflowCode;

-- Step-level detail with approver resolution
SELECT
    wm.ModuleCode,
    wd.WorkflowCode,
    ws.StepNo,
    ws.StepName,
    ws.WorkflowStepType,
    ws.IsFinalStep,
    ws.AllowDelegation,
    ws.EscalationAfterHours,
    wsa.WorkflowApproverType,
    wsa.ScopeReferenceId        AS ApproverDesignationId
FROM       [workflow].[WorkflowModule]     wm
JOIN       [workflow].[WorkflowDefinition] wd  ON wd.WorkflowModuleId    = wm.Id
JOIN       [workflow].[WorkflowStep]       ws  ON ws.WorkflowDefinitionId = wd.Id
LEFT JOIN  [workflow].[WorkflowStepApprover] wsa ON wsa.WorkflowStepId   = ws.Id
WHERE wm.IsActive = 1
ORDER BY wm.ModuleCode, wd.WorkflowCode, ws.StepNo;

-- Instance status summary
SELECT
    wm.ModuleName,
    wd.WorkflowCode,
    wi.WorkflowStatus,
    COUNT(*)            AS InstanceCount
FROM       [workflow].[WorkflowInstance]   wi
JOIN       [workflow].[WorkflowDefinition] wd ON wd.Id = wi.WorkflowDefinitionId
JOIN       [workflow].[WorkflowModule]     wm ON wm.Id = wi.WorkflowModuleId
GROUP BY wm.ModuleName, wd.WorkflowCode, wi.WorkflowStatus
ORDER BY wm.ModuleName, wi.WorkflowStatus;


PRINT 'Workflow seed data inserted successfully.';
GO