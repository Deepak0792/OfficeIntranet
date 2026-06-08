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

INSERT [workflow].[WorkflowModule]
    ([Id], [ModuleCode], [ModuleName],[Schema], [EntityName], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Attendance domain
    (NEWID(),   N'LEAVE_REQUEST',              N'Leave Management',               N'attendance', N'LeaveRequest',                1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (NEWID(),   N'ATTENDANCE_REGULARIZATION',  N'Attendance Regularization',      N'attendance', N'AttendanceRegularization',    1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (NEWID(),   N'SHIFT_SWAP_REQUEST',         N'Shift Swap',                     N'attendance', N'ShiftSwapRequest',            1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (NEWID(),   N'COMP_OFF_REDEMPTION',        N'Comp-Off Redemption',            N'attendance', N'CompOffBalance',              1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
                                                                                  
    -- Employee domain                                                           
    (NEWID(),   N'DOCUMENT_VERIFICATION',      N'Document Verification',          N'employee', N'EmployeeDocument',            1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (NEWID(),   N'ADDRESS_VERIFICATION',       N'Employee Address Verification',  N'employee', N'EmployeeAddress',             1, CAST(N'2026-05-27T17:04:30.3000000' AS DateTime2), NULL, CAST(N'2026-05-27T17:04:30.3000000' AS DateTime2), NULL),
                                                                                  
    -- Payroll domain                                                             
    (NEWID(),   N'PAYROLL_CORRECTION',         N'Payroll Attendance Correction',  N'payroll', N'PayrollAttendanceSummary',    1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL),
    (NEWID(),   N'EXPENSE_REIMBURSEMENT',      N'Expense & Reimbursement',        N'expense', N'ExpenseClaim',                1, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7633333' AS DateTime2), NULL);
GO


-- ============================================================
-- 2. WORKFLOW DEFINITIONS
--    One row per named workflow variant within a module.
--    A module can have multiple definitions (e.g. standard vs fast-track).
-- ============================================================

INSERT [workflow].[WorkflowDefinition]
    ([Id], [WorkflowModuleId], [WorkflowCode], [WorkflowName], [VersionNo], [Description], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Leave Request (Module 1)
    (NEWID(),   (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'LEAVE_REQUEST'),  N'WF_LEAVE_STD_V1',           N'Standard Leave Approval',                  1, N'Three-level approval for all standard leave types.',            1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),
    (NEWID(),   (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'LEAVE_REQUEST'),  N'WF_LEAVE_EMRGENCY_V1',      N'Emergency Leave Fast-Track Approval',       1, N'Single-step fast-track approval for emergency leave requests.', 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),
    (NEWID(),   (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'LEAVE_REQUEST'),  N'WF_TRAINING_LEAVE_V1',      N'Training & Conference Leave Approval',      1, N'Three-level approval for training programs.',                   1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),

    -- Attendance Regularization (Module 2)
    (NEWID(),   (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'ATTENDANCE_REGULARIZATION'),  N'WF_ATTENDANCE_REG_STD_V1',  N'Attendance Regularization Approval',        1, N'Two-level approval for attendance correction requests.',        1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),

    -- Shift Swap (Module 3)
    (NEWID(),   (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'SHIFT_SWAP_REQUEST'),  N'WF_SHIFT_SWAP_REQUEST_V1',  N'Shift Swap Approval',                       1, N'Two-level approval for shift swap requests.',                   1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),

    -- Comp-Off Redemption (Module 5)
    (NEWID(),   (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'COMP_OFF_REDEMPTION'),  N'WF_COMP_OFF_REQUEST_V1',    N'Comp-Off Redemption Approval',              1, N'Single-step approval by Reporting Manager.',                    1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),

    -- Document Verification (Module 8)
    (NEWID(),   (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'DOCUMENT_VERIFICATION'),  N'WF_DOCUMENT_VERIFY_V1',     N'Employee Document Verification',            1, N'Single-step HR Manager verification workflow.',                 1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),

    -- Payroll Correction (Module 9)
    (NEWID(),  (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'PAYROLL_CORRECTION'),  N'WF_PAYROLL_CORRECTION_V1',  N'Payroll Attendance Correction Approval',    1, N'Two-level approval for payroll attendance corrections.',        1, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.7766667' AS DateTime2), NULL),

    -- Address Verification (Module 102)
    (NEWID(), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'EXPENSE_REIMBURSEMENT'), N'WF_ADDRESS_VERIFICATION_V1', N'Employee Address Approval',               1, N'Single-step HR Manager verification workflow.',                 1, CAST(N'2026-05-27T17:17:17.1333333' AS DateTime2), NULL, CAST(N'2026-05-27T17:17:17.1333333' AS DateTime2), NULL);

GO


-- ============================================================
-- 3. WORKFLOW STEPS
--    Ordered steps within each definition.
--    IsFinalStep = 1 marks the last approver in the chain.
--    EscalationAfterHours = auto-escalate SLA per step.
-- ============================================================

INSERT [workflow].[WorkflowStep]
    ([Id], [WorkflowDefinitionId], [StepNo], [StepName], [WorkflowStepType], [IsFinalStep], [AllowDelegation], [EscalationAfterHours], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- ── WF_LEAVE_STD_V1 (Id: 1) — 3 steps ──────────────────────────
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1'),  1, N'Reporting Manager Approval',         N'APPROVAL', 0, 1, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1'),  2, N'Department Head Approval',           N'APPROVAL', 0, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1'),  3, N'HR Manager Final Approval',          N'APPROVAL', 1, 0, 72, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_LEAVE_EMRGENCY_V1 (Id: 2) — 1 step (fast-track) ─────────
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1'),  1, N'Reporting Manager Emergency Approval', N'APPROVAL', 1, 1,  2, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_ATTENDANCE_REG_STD_V1 (Id: 3) — 2 steps ─────────────────
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1'),  1, N'Reporting Manager Review',           N'REVIEW',   0, 1, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1'),  2, N'HR Manager Approval',                N'APPROVAL', 1, 0, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_SHIFT_SWAP_REQUEST_V1 (Id: 4) — 2 steps ──────────────────
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1'),  1, N'Ward In-Charge Approval',            N'APPROVAL', 0, 1, 12, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (NEWID(),  (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1'),  2, N'Scheduling Coordinator Approval',   N'APPROVAL', 1, 0, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_COMP_OFF_REQUEST_V1 (Id: 6) — 1 step ─────────────────────
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_COMP_OFF_REQUEST_V1'),  1, N'Reporting Manager Approval',         N'APPROVAL', 1, 1, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_TRAINING_LEAVE_V1 (Id: 8) — 3 steps ──────────────────────
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1'),  1, N'Department Head Approval',           N'APPROVAL', 0, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1'),  2, N'HR Manager Review',                  N'REVIEW',   0, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1'),  3, N'Finance Manager Cost Approval',      N'APPROVAL', 1, 0, 72, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_DOCUMENT_VERIFY_V1 (Id: 9) — 1 step ──────────────────────
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_DOCUMENT_VERIFY_V1'),  1, N'HR Manager Document Verification',  N'APPROVAL', 1, 0, 72, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_PAYROLL_CORRECTION_V1 (Id: 10) — 2 steps ─────────────────
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1'), 1, N'HR Manager Review',                  N'REVIEW',   0, 0, 24, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1'), 2, N'Finance Manager Authorization',      N'APPROVAL', 1, 0, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL),

    -- ── WF_ADDRESS_VERIFICATION_V1 (Id: 103) — 1 step ───────────────
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ADDRESS_VERIFICATION_V1'), 1, N'HR Manager Review',                N'APPROVAL', 1, 1, 48, 1, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8000000' AS DateTime2), NULL);

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

INSERT [workflow].[WorkflowStepApprover]
    ([Id], [WorkflowStepId], [WorkflowApproverType], [ScopeTypeId], [ScopeReferenceId], [PriorityOrder], [IsMandatory], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- WF_LEAVE_STD_V1
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Reporting Manager Approval'),  N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval'),  N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: HOD (multi-designation, see Section 5)
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'HR Manager Final Approval'),  N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    (SELECT Id FROM time.Department WHERE DepartmentCode = 'HR'),    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 3: HR Manager (DesignationId 7)

    -- WF_LEAVE_EMRGENCY_V1
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') AND StepName = 'Reporting Manager Emergency Approval'),  N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager

    -- WF_ATTENDANCE_REG_STD_V1
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1') AND StepName = 'Reporting Manager Review'),  N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1') AND StepName = 'HR Manager Approval'),  N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    (SELECT Id FROM time.Department WHERE DepartmentCode = 'HR'),    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: HR Manager (DesignationId 7)

    -- WF_SHIFT_SWAP_REQUEST_V1
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1') AND StepName = 'Ward In-Charge Approval'),  N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    (SELECT Id FROM time.Department WHERE DepartmentCode = 'OPERATIONS'), 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Ward In-Charge
    (NEWID(),  (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1') AND StepName = 'Scheduling Coordinator Approval'),  N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    NULL,   1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: Scheduling Coordinator (DesignationId 10)

    -- WF_COMP_OFF_REQUEST_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_COMP_OFF_REQUEST_V1') AND StepName = 'Reporting Manager Approval'), N'REPORTING_MANAGER', NULL, NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: Reporting Manager

    -- WF_TRAINING_LEAVE_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval'), N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    NULL, 1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: HOD (multi-designation, see Section 5)
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'HR Manager Review'), N'DESIGNATION',  (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode = 'HR') ,   1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: HR Manager (DesignationId 7)
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Finance Manager Cost Approval'), N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    (SELECT Id FROM time.Department WHERE DepartmentCode = 'FINANCE'),    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 3: Finance Manager (DesignationId 9)

    -- WF_DOCUMENT_VERIFY_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_DOCUMENT_VERIFY_V1') AND StepName = 'HR Manager Document Verification'), N'DESIGNATION',  (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    (SELECT Id FROM time.Department WHERE DepartmentCode = 'HR'),    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: HR Manager (DesignationId 7)

    -- WF_PAYROLL_CORRECTION_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1') AND StepName = 'HR Manager Review'), N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),   (SELECT Id FROM time.Department WHERE DepartmentCode = 'HR'),    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 1: HR Manager (DesignationId 7)
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1') AND StepName = 'Finance Manager Authorization'), N'DESIGNATION',       (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),    (SELECT Id FROM time.Department WHERE DepartmentCode = 'FINANCE'),    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL),  -- Step 2: Finance Manager (DesignationId 9)

    -- WF_ADDRESS_VERIFICATION_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ADDRESS_VERIFICATION_V1') AND StepName = 'HR Manager Review'), N'DESIGNATION',     (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'),   (SELECT Id FROM time.Department WHERE DepartmentCode = 'HR'),    1, 1, 1, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8366667' AS DateTime2), NULL);  -- Step 1: HR Manager (DesignationId 7)

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

INSERT [workflow].[WorkflowStepApproverDesignation]
    ([Id], [WorkflowStepApproverId], [DesignationId], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Approver 2 — HOD on WF_LEAVE_STD_V1 Step 2 (all department head designations)
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'CONSULTANT'),  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'CHFNURSE'),  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'CHIEFPHARM'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'RADIOLOGIST'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'PATHOLOGIST'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'HOPADMIN'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'ITMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'FINMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'OPSMGR'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'EMERPHYSICIAN'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'Department Head Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'SRSURGEON'),  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 3  — HR Manager on WF_LEAVE_STD_V1 Step 3
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1') AND StepName = 'HR Manager Final Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 6  — HR Manager on WF_ATTENDANCE_REG_STD_V1 Step 2
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1') AND StepName = 'Reporting Manager Review')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 7  — Ward In-Charge on WF_SHIFT_SWAP_REQUEST_V1 Step 1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1') AND StepName = 'Ward In-Charge Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'SRNURSE'),  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 8  — Scheduling Coordinator on WF_SHIFT_SWAP_REQUEST_V1 Step 2
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1') AND StepName = 'Scheduling Coordinator Approval')),  (SELECT Id FROM time.Designation WHERE DesignationCode = 'OPSMGR'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 14 — HOD on WF_TRAINING_LEAVE_V1 Step 1 (mirrors Approver 2 designation set)
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'CONSULTANT'),  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'CHFNURSE'),  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'CHIEFPHARM'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'RADIOLOGIST'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'PATHOLOGIST'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'HOPADMIN'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'ITMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'FINMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'OPSMGR'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'EMERPHYSICIAN'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Department Head Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'SRSURGEON'),  1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 15 — HR Manager on WF_TRAINING_LEAVE_V1 Step 2
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'HR Manager Review')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 16 — Finance Manager on WF_TRAINING_LEAVE_V1 Step 3
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1') AND StepName = 'Finance Manager Cost Approval')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'FINMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 17 — HR Manager on WF_DOCUMENT_VERIFY_V1 Step 1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_DOCUMENT_VERIFY_V1') AND StepName = 'HR Manager Document Verification')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 18 — HR Manager on WF_PAYROLL_CORRECTION_V1 Step 1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT TOP 1 Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1') AND StepName = 'HR Manager Review')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 19 — Finance Manager on WF_PAYROLL_CORRECTION_V1 Step 2
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT TOP 1 Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1') AND StepName = 'Finance Manager Authorization')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'FINMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL),

    -- Approver 102 — HR Manager on WF_ADDRESS_VERIFICATION_V1 Step 1
    (NEWID(), (SELECT Id FROM workflow.WorkflowStepApprover WHERE WorkflowStepId = (SELECT Id FROM workflow.WorkflowStep where WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ADDRESS_VERIFICATION_V1') AND StepName = 'HR Manager Review')), (SELECT Id FROM time.Designation WHERE DesignationCode = 'HRMANAGER'), 1, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.8866667' AS DateTime2), NULL);

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

INSERT [workflow].[WorkflowAssignment]
    ([Id], [WorkflowDefinitionId], [ScopeTypeId], [ScopeReferenceId], [EffectiveFrom], [EffectiveTo], [PriorityOrder], [IsActive], [CreatedAt], [CreatedBy], [LastUpdatedAt], [LastUpdatedBy])
VALUES
    -- Global assignments (ScopeTypeId 1, ScopeReferenceId 1)
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_LEAVE_STD_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL,  5, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_LEAVE_EMRGENCY_V1       (priority 5 = higher precedence)
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_ATTENDANCE_REG_STD_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_COMP_OFF_REQUEST_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_COMP_OFF_REQUEST_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_TRAINING_LEAVE_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_TRAINING_LEAVE_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_DOCUMENT_VERIFY_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_DOCUMENT_VERIFY_V1
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ADDRESS_VERIFICATION_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_ADDRESS_VERIFICATION_V1

    -- Department-scoped assignments (ScopeTypeId 4)
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode = 'LOC-HYD-01'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_SHIFT_SWAP_REQUEST_V1 → Dept 6
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode = 'LOC-CHN-01'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL),  -- WF_SHIFT_SWAP_REQUEST_V1 → Dept 5

    -- Legal Entity-scoped assignment (ScopeTypeId 3)
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'LEGAL_ENTITY'), (SELECT Id FROM time.LegalEntity WHERE EntityCode = 'MEDCARE-IN'), CAST(N'2024-01-01' AS Date), NULL, 10, 1, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL, CAST(N'2026-05-21T10:42:36.9100000' AS DateTime2), NULL);  -- WF_PAYROLL_CORRECTION_V1

GO


-- ============================================================
-- 7. WORKFLOW INSTANCES
--    Runtime records — one per submitted transaction.
--    WorkflowStatus: PENDING | IN_PROGRESS | APPROVED | REJECTED | CANCELLED
-- ============================================================

INSERT [workflow].[WorkflowInstance]
    ([Id], [WorkflowDefinitionId], [WorkflowModuleId], [ReferenceTransactionId], [CurrentWorkflowStepId], [WorkflowStatus], [CreatedBy], [CreatedAt], [CompletedAt], [CompletedBy])
VALUES
    -- Active / in-progress instances
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'LEAVE_REQUEST'), NEWID(), NULL,    N'IN_PROGRESS', NEWID(),  CAST(N'2025-04-28T09:15:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Leave: at HOD step
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'ATTENDANCE_REGULARIZATION'), NEWID(), NULL,    N'PENDING', NEWID(), CAST(N'2025-04-30T10:00:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Attendance Reg: awaiting manager
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'SHIFT_SWAP_REQUEST'), NEWID(), NULL,    N'IN_PROGRESS', NEWID(),  CAST(N'2025-04-27T14:30:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Shift Swap: at coordinator step
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_COMP_OFF_REQUEST_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'COMP_OFF_REDEMPTION'), NEWID(), NULL,   N'PENDING',     NEWID(), CAST(N'2025-05-01T08:00:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Comp-Off: awaiting manager
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_PAYROLL_CORRECTION_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'PAYROLL_CORRECTION'), NEWID(), NULL,   N'IN_PROGRESS', NEWID(),  CAST(N'2025-05-02T09:00:00.0000000' AS DateTime2), NULL,                                         NULL),  -- Payroll Correction: at finance step

    -- Completed instances
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'LEAVE_REQUEST'), NEWID(), NULL, N'APPROVED',   NEWID() ,  CAST(N'2025-04-29T06:45:00.0000000' AS DateTime2), CAST(N'2025-04-29T08:10:00.0000000' AS DateTime2), NULL),  -- Emergency Leave: fast-track approved
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_DOCUMENT_VERIFY_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'DOCUMENT_VERIFICATION'), NEWID(), NULL, N'APPROVED',    NEWID(),  CAST(N'2025-04-15T10:30:00.0000000' AS DateTime2), CAST(N'2025-04-16T14:00:00.0000000' AS DateTime2), NULL),  -- Document Verification: approved
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'LEAVE_REQUEST'), NEWID(), NULL, N'APPROVED',    NEWID(), CAST(N'2025-04-10T08:00:00.0000000' AS DateTime2), CAST(N'2025-04-14T17:00:00.0000000' AS DateTime2), NULL),  -- Leave (full 3-step): approved

    -- Terminated instances
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'SHIFT_SWAP_REQUEST'), NEWID(), NULL, N'CANCELLED',   NEWID(), CAST(N'2025-04-22T13:00:00.0000000' AS DateTime2), CAST(N'2025-04-22T15:30:00.0000000' AS DateTime2), NULL),  -- Shift Swap: cancelled by requester
    (NEWID(), (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1'), (SELECT Id FROM workflow.WorkflowModule where ModuleCode = 'ATTENDANCE_REGULARIZATION'), NEWID(), NULL, N'REJECTED',    NEWID(), CAST(N'2025-04-18T09:00:00.0000000' AS DateTime2), CAST(N'2025-04-19T11:00:00.0000000' AS DateTime2), NULL);  -- Attendance Reg: rejected (no proof)

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

INSERT [workflow].[WorkflowActionHistory]
    ([Id], [WorkflowInstanceId], [WorkflowTaskId], [WorkflowStepId], [WorkflowActionType], [Remarks], [FromWorkflowStatus], [ToWorkflowStatus], [IsActive], [ActionBy], [ActionAt])
VALUES
    -- Instance 1: Standard Leave (IN_PROGRESS at HOD)
    (NEWID(),  (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1')),  NULL, NULL,    N'SUBMIT',  N'Leave request submitted for 3 days Casual Leave.',           NULL,          N'PENDING',     1, NEWID(),  CAST(N'2025-04-28T09:15:00.0000000' AS DateTime2)),
    (NEWID(),  (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_STD_V1')),  NULL, NULL,    N'APPROVE', N'Approved. Ward coverage confirmed for the period.',           N'PENDING',    N'IN_PROGRESS', 1, NEWID(),  CAST(N'2025-04-28T11:30:00.0000000' AS DateTime2)),

    -- Instance 2: Emergency Leave (APPROVED)
    (NEWID(),  (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1')),  NULL, NULL,    N'SUBMIT',  N'Family medical emergency. Requesting immediate leave.',       NULL,          N'PENDING',     1, NEWID(),  CAST(N'2025-04-29T06:45:00.0000000' AS DateTime2)),
    (NEWID(),  (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1')),  NULL, NULL,    N'APPROVE', N'Approved on humanitarian grounds. Cover arranged.',          N'PENDING',    N'APPROVED',    1, NEWID(),  CAST(N'2025-04-29T08:10:00.0000000' AS DateTime2)),

    -- Instance 3: Attendance Regularization (PENDING)
    (NEWID(),  (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_ATTENDANCE_REG_STD_V1')),  NULL, NULL,    N'SUBMIT',  N'Biometric reader malfunction on 29-Apr. Requesting correction.', NULL,      N'PENDING',     1, NEWID(), CAST(N'2025-04-30T10:00:00.0000000' AS DateTime2)),

    -- Instance 4: Shift Swap (IN_PROGRESS at coordinator)
    (NEWID(),  (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1')),  NULL, NULL,    N'SUBMIT',  N'Requesting swap with Emp #11 for 02-May morning shift.',     NULL,          N'PENDING',     1, NEWID(),  CAST(N'2025-04-27T14:30:00.0000000' AS DateTime2)),
    (NEWID(),  (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_SHIFT_SWAP_REQUEST_V1')),  NULL, NULL,    N'APPROVE', N'Operationally feasible. Both employees trained for the shift.', N'PENDING', N'IN_PROGRESS', 1, NEWID(),  CAST(N'2025-04-27T16:00:00.0000000' AS DateTime2)),

    -- Instance 6: Comp-Off Redemption (PENDING)
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_COMP_OFF_REQUEST_V1')),  NULL, NULL,   N'SUBMIT',  N'Applying comp-off earned on 27-Apr (holiday working).',      NULL,          N'PENDING',     1, NEWID(), CAST(N'2025-05-01T08:00:00.0000000' AS DateTime2)),

    -- Instance 9: Document Verification (APPROVED)
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_DOCUMENT_VERIFY_V1')),  NULL, NULL,   N'SUBMIT',  N'Nursing Council License renewed. Uploading updated document.', NULL,        N'PENDING',     1, NEWID(),  CAST(N'2025-04-15T10:30:00.0000000' AS DateTime2)),
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_DOCUMENT_VERIFY_V1')),  NULL, NULL,   N'APPROVE', N'Document verified. License valid until 2027-03-31.',          N'PENDING',   N'APPROVED',    1, NEWID(),  CAST(N'2025-04-16T14:00:00.0000000' AS DateTime2)),

    -- Instance 10: Payroll Correction (IN_PROGRESS at finance)

    -- Instance 11: Standard Leave — full 3-step (APPROVED)
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'SUBMIT',  N'Earned leave for 5 days. Pre-planned annual vacation.',       NULL,          N'PENDING',     1, NEWID(), CAST(N'2025-04-10T08:00:00.0000000' AS DateTime2)),
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'APPROVE', N'Approved. Handover document submitted.',                      N'PENDING',    N'IN_PROGRESS', 1, NEWID(),  CAST(N'2025-04-10T11:00:00.0000000' AS DateTime2)),
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'APPROVE', N'Approved by Dept Head. Leave balance confirmed.',              N'IN_PROGRESS',N'IN_PROGRESS', 1, NEWID(),  CAST(N'2025-04-11T10:00:00.0000000' AS DateTime2)),
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'APPROVE', N'HR final approval. Leave recorded in system.',                 N'IN_PROGRESS',N'APPROVED',    1, NEWID(),  CAST(N'2025-04-14T17:00:00.0000000' AS DateTime2)),

    -- Instance 12: Shift Swap (CANCELLED by requester)
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'SUBMIT',  N'Requesting shift swap with Emp #9 for 25-Apr.',               NULL,          N'PENDING',     1, NEWID(), CAST(N'2025-04-22T13:00:00.0000000' AS DateTime2)),
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'CANCEL',  N'Swap no longer needed. Other arrangements made. Cancelling request.', N'PENDING', N'CANCELLED', 1, NEWID(), CAST(N'2025-04-22T15:30:00.0000000' AS DateTime2)),

    -- Instance 14: Attendance Regularization (REJECTED)
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'SUBMIT',  N'Requesting regularization for 17-Apr. Was working from home.', NULL,         N'PENDING',     1, NEWID(), CAST(N'2025-04-18T09:00:00.0000000' AS DateTime2)),
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'RETURN',  N'No WFH approval on record for 17-Apr. Please provide prior approval proof.', N'PENDING', N'IN_PROGRESS', 1, NEWID(), CAST(N'2025-04-18T14:00:00.0000000' AS DateTime2)),
    (NEWID(), (SELECT TOP 1 Id FROM workflow.WorkflowInstance WHERE WorkflowDefinitionId = (SELECT Id FROM workflow.WorkflowDefinition where WorkflowCode = 'WF_LEAVE_EMRGENCY_V1') ORDER BY CreatedAt DESC), NULL, NULL,    N'REJECT',  N'Regularization rejected. No valid supporting documentation provided.', N'IN_PROGRESS', N'REJECTED', 1, NEWID(), CAST(N'2025-04-19T11:00:00.0000000' AS DateTime2));

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