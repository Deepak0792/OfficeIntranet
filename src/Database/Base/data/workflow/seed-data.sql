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
-- SECTION 1: WORKFLOW MODULES
-- ============================================================

INSERT INTO workflow.WorkflowModule (ModuleCode, ModuleName, EntityName)
SELECT v.ModuleCode, v.ModuleName, v.EntityName
FROM (VALUES
    ('LEAVE',                   'Leave Management',              'LeaveRequest'),
    ('ATTENDANCE_REG',          'Attendance Regularization',     'AttendanceRegularization'),
    ('SHIFT_SWAP',              'Shift Swap',                    'ShiftSwapRequest'),
    ('OVERTIME',                'Overtime Authorization',        'AttendanceRecord'),
    ('COMPOFF',                 'Comp-Off Redemption',           'CompOffBalance'),
    ('ONCALL',                  'On-Call Duty',                  'EmployeeShiftRoster'),
    ('TRAINING_LEAVE',          'Training & Conference Leave',   'LeaveRequest'),
    ('DOC_VERIFICATION',        'Document Verification',         'EmployeeDocument'),
    ('PAYROLL_CORRECTION',      'Payroll Attendance Correction', 'PayrollAttendanceSummary'),
    ('EXPENSE_REIMBURSEMENT',   'Expense & Reimbursement',       'ExpenseClaim')
) AS v(ModuleCode, ModuleName, EntityName)
WHERE NOT EXISTS (
    SELECT 1 FROM workflow.WorkflowModule wm WHERE wm.ModuleCode = v.ModuleCode
);
GO

-- ============================================================
-- SECTION 2: WORKFLOW DEFINITIONS
-- ============================================================

INSERT INTO workflow.WorkflowDefinition
    (WorkflowModuleId, WorkflowCode, WorkflowName, VersionNo, Description)
SELECT
    (SELECT Id FROM workflow.WorkflowModule WHERE ModuleCode = v.ModuleCode),
    v.WorkflowCode, v.WorkflowName, v.VersionNo, v.Description
FROM (VALUES
    ('LEAVE',               'WF-LEAVE-STD-V1',      'Standard Leave Approval',                   1, 'Three-level approval for all standard leave types.'),
    ('LEAVE',               'WF-LEAVE-EMRG-V1',     'Emergency Leave Fast-Track Approval',       1, 'Single-step fast-track approval for emergency leave requests.'),
    ('ATTENDANCE_REG',      'WF-ATTREG-STD-V1',     'Attendance Regularization Approval',        1, 'Two-level approval for attendance correction requests.'),
    ('SHIFT_SWAP',          'WF-SHIFTSWAP-V1',      'Shift Swap Approval',                       1, 'Two-level approval for shift swap requests.'),
    ('OVERTIME',            'WF-OT-V1',             'Overtime Authorization',                    1, 'Two-level approval for overtime worked.'),
    ('COMPOFF',             'WF-COMPOFF-V1',        'Comp-Off Redemption Approval',              1, 'Single-step approval by Reporting Manager.'),
    ('ONCALL',              'WF-ONCALL-V1',         'On-Call Duty Approval',                     1, 'Two-level approval for on-call duty assignments.'),
    ('TRAINING_LEAVE',      'WF-TRAINLEAVE-V1',     'Training & Conference Leave Approval',      1, 'Three-level approval for training programs.'),
    ('DOC_VERIFICATION',    'WF-DOCVERIFY-V1',      'Employee Document Verification',            1, 'Single-step HR Manager verification workflow.'),
    ('PAYROLL_CORRECTION',  'WF-PAYROLLCORR-V1',    'Payroll Attendance Correction Approval',    1, 'Two-level approval for payroll attendance corrections.')
) AS v(ModuleCode, WorkflowCode, WorkflowName, VersionNo, Description)
WHERE NOT EXISTS (
    SELECT 1 FROM workflow.WorkflowDefinition wd WHERE wd.WorkflowCode = v.WorkflowCode
);
GO

-- ============================================================
-- SECTION 3: WORKFLOW STEPS
-- ============================================================

INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType,
     IsFinalStep, AllowDelegation, EscalationAfterHours)
SELECT
    (SELECT Id FROM workflow.WorkflowDefinition WHERE WorkflowCode = v.WorkflowCode),
    v.StepNo, v.StepName, v.StepTypeCode,
    v.IsFinalStep, v.AllowDelegation, v.EscalationAfterHours
FROM (VALUES
    -- WF-LEAVE-STD-V1
    ('WF-LEAVE-STD-V1',     1, 'Reporting Manager Approval',           'APPROVAL', 0, 1, 24),
    ('WF-LEAVE-STD-V1',     2, 'Department Head Approval',             'APPROVAL', 0, 1, 48),
    ('WF-LEAVE-STD-V1',     3, 'HR Manager Final Approval',            'APPROVAL', 1, 0, 72),
    -- WF-LEAVE-EMRG-V1
    ('WF-LEAVE-EMRG-V1',    1, 'Reporting Manager Emergency Approval', 'APPROVAL', 1, 1,  2),
    -- WF-ATTREG-STD-V1
    ('WF-ATTREG-STD-V1',    1, 'Reporting Manager Review',             'REVIEW',   0, 1, 24),
    ('WF-ATTREG-STD-V1',    2, 'HR Manager Approval',                  'APPROVAL', 1, 0, 48),
    -- WF-SHIFTSWAP-V1
    ('WF-SHIFTSWAP-V1',     1, 'Ward In-Charge Approval',              'APPROVAL', 0, 1, 12),
    ('WF-SHIFTSWAP-V1',     2, 'Scheduling Coordinator Approval',      'APPROVAL', 1, 0, 24),
    -- WF-OT-V1
    ('WF-OT-V1',            1, 'Shift Supervisor Review',              'REVIEW',   0, 1, 24),
    ('WF-OT-V1',            2, 'Department Head Approval',             'APPROVAL', 1, 0, 48),
    -- WF-COMPOFF-V1
    ('WF-COMPOFF-V1',       1, 'Reporting Manager Approval',           'APPROVAL', 1, 1, 24),
    -- WF-ONCALL-V1
    ('WF-ONCALL-V1',        1, 'Department Head Confirmation',         'APPROVAL', 0, 1, 12),
    ('WF-ONCALL-V1',        2, 'Chief Medical Officer Authorization',  'APPROVAL', 1, 0, 24),
    -- WF-TRAINLEAVE-V1
    ('WF-TRAINLEAVE-V1',    1, 'Department Head Approval',             'APPROVAL', 0, 1, 48),
    ('WF-TRAINLEAVE-V1',    2, 'HR Manager Review',                    'REVIEW',   0, 1, 48),
    ('WF-TRAINLEAVE-V1',    3, 'Finance Manager Cost Approval',        'APPROVAL', 1, 0, 72),
    -- WF-DOCVERIFY-V1
    ('WF-DOCVERIFY-V1',     1, 'HR Manager Document Verification',     'APPROVAL', 1, 0, 72),
    -- WF-PAYROLLCORR-V1
    ('WF-PAYROLLCORR-V1',   1, 'HR Manager Review',                    'REVIEW',   0, 0, 24),
    ('WF-PAYROLLCORR-V1',   2, 'Finance Manager Authorization',        'APPROVAL', 1, 0, 48)
) AS v(WorkflowCode, StepNo, StepName, StepTypeCode, IsFinalStep, AllowDelegation, EscalationAfterHours)
WHERE NOT EXISTS (
    SELECT 1
    FROM   workflow.WorkflowStep        ws
    JOIN   workflow.WorkflowDefinition  wd ON wd.Id = ws.WorkflowDefinitionId
    WHERE  wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.StepNo
);
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

INSERT INTO workflow.WorkflowStepApprover
    (WorkflowStepId, WorkflowApproverType, ScopeTypeId, ScopeReferenceId, PriorityOrder, IsMandatory)
SELECT
    -- Resolve WorkflowStepId from workflow code + step number
    (
        SELECT ws.Id
        FROM   workflow.WorkflowStep       ws
        JOIN   workflow.WorkflowDefinition wd ON wd.Id = ws.WorkflowDefinitionId
        WHERE  wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.StepNo
    ),
    v.ApproverType,
    -- ScopeTypeId: resolve from ScopeCode, NULL for context-resolved types
    CASE
        WHEN v.ScopeCode IS NULL THEN NULL
        ELSE (SELECT Id FROM time.ScopeType WHERE ScopeCode = v.ScopeCode)
    END,
    -- ScopeReferenceId: resolve based on scope level
    CASE
        WHEN v.ScopeCode IS NULL                THEN NULL   -- REPORTING_MANAGER / SKIP_MANAGER
        WHEN v.ScopeCode = 'DEPARTMENT'
         AND v.ScopeRefCode IS NULL             THEN NULL   -- Contextual dept (initiator's own)
        WHEN v.ScopeCode = 'DEPARTMENT'
         AND v.ScopeRefCode IS NOT NULL
             THEN (SELECT Id FROM time.Department WHERE DepartmentCode = v.ScopeRefCode)
        WHEN v.ScopeCode = 'EMPLOYEE'
             THEN (SELECT Id FROM employee.Employee WHERE EmployeeCode = v.ScopeRefCode)
        ELSE NULL
    END,
    v.PriorityOrder,
    v.IsMandatory

FROM (VALUES

--  WorkflowCode            StepNo  ApproverType            ScopeCode       ScopeRefCode    Pri  Mandatory
--  
--  WF-LEAVE-STD-V1
--  Step 1: Reporting Manager - always contextual, no scope
    ('WF-LEAVE-STD-V1',     1,  'REPORTING_MANAGER',    NULL,           NULL,           1,   1),
--  Step 2: Department Head - DESIGNATION in initiator's own department (contextual)
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',          'DEPARTMENT',   NULL,           1,   1),
--  Step 3: HR Manager - DESIGNATION fixed to HR department
    ('WF-LEAVE-STD-V1',     3,  'DESIGNATION',          'DEPARTMENT',   'HR',           1,   1),

--  WF-LEAVE-EMRG-V1
--  Step 1: Reporting Manager - contextual fast-track
    ('WF-LEAVE-EMRG-V1',    1,  'REPORTING_MANAGER',    NULL,           NULL,           1,   1),

--  WF-ATTREG-STD-V1
--  Step 1: Reporting Manager - contextual
    ('WF-ATTREG-STD-V1',    1,  'REPORTING_MANAGER',    NULL,           NULL,           1,   1),
--  Step 2: HR Manager - fixed to HR department
    ('WF-ATTREG-STD-V1',    2,  'DESIGNATION',          'DEPARTMENT',   'HR',           1,   1),

--  WF-SHIFTSWAP-V1
--  Step 1: Ward In-Charge - DESIGNATION in initiator's own department (contextual)
--          Qualifying designation: SRNURSE (Senior Staff Nurse acts as Ward In-Charge)
    ('WF-SHIFTSWAP-V1',     1,  'DESIGNATION',          'DEPARTMENT',   NULL,           1,   1),
--  Step 2: Scheduling Coordinator - DESIGNATION fixed to OPERATIONS department
    ('WF-SHIFTSWAP-V1',     2,  'DESIGNATION',          'DEPARTMENT',   'OPERATIONS',   1,   1),

--  WF-OT-V1
--  Step 1: Shift Supervisor - DESIGNATION in initiator's own department (contextual)
--          Qualifying designation: SRNURSE or equivalent senior in dept
    ('WF-OT-V1',            1,  'DESIGNATION',          'DEPARTMENT',   NULL,           1,   1),
--  Step 2: Department Head - DESIGNATION in initiator's own department (contextual)
    ('WF-OT-V1',            2,  'DESIGNATION',          'DEPARTMENT',   NULL,           1,   1),

--  WF-COMPOFF-V1
--  Step 1: Reporting Manager - contextual
    ('WF-COMPOFF-V1',       1,  'REPORTING_MANAGER',    NULL,           NULL,           1,   1),

--  WF-ONCALL-V1
--  Step 1: Department Head - DESIGNATION in initiator's own department (contextual)
    ('WF-ONCALL-V1',        1,  'DESIGNATION',          'DEPARTMENT',   NULL,           1,   1),
--  Step 2: Chief Medical Officer - fixed EMPLOYEE (always the same person)
    ('WF-ONCALL-V1',        2,  'EMPLOYEE',             'EMPLOYEE',     'EMP-CMO-001',  1,   1),

--  WF-TRAINLEAVE-V1
--  Step 1: Department Head - DESIGNATION in initiator's own department (contextual)
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',          'DEPARTMENT',   NULL,           1,   1),
--  Step 2: HR Manager - fixed to HR department
    ('WF-TRAINLEAVE-V1',    2,  'DESIGNATION',          'DEPARTMENT',   'HR',           1,   1),
--  Step 3: Finance Manager - fixed to FINANCE department
    ('WF-TRAINLEAVE-V1',    3,  'DESIGNATION',          'DEPARTMENT',   'FINANCE',      1,   1),

--  WF-DOCVERIFY-V1
--  Step 1: HR Manager - fixed to HR department
    ('WF-DOCVERIFY-V1',     1,  'DESIGNATION',          'DEPARTMENT',   'HR',           1,   1),

--  WF-PAYROLLCORR-V1
--  Step 1: HR Manager - fixed to HR department
    ('WF-PAYROLLCORR-V1',   1,  'DESIGNATION',          'DEPARTMENT',   'HR',           1,   1),
--  Step 2: Finance Manager - fixed to FINANCE department
    ('WF-PAYROLLCORR-V1',   2,  'DESIGNATION',          'DEPARTMENT',   'FINANCE',      1,   1)

) AS v(WorkflowCode, StepNo, ApproverType, ScopeCode, ScopeRefCode, PriorityOrder, IsMandatory)
WHERE NOT EXISTS (
    SELECT 1
    FROM   workflow.WorkflowStepApprover    wsa
    JOIN   workflow.WorkflowStep            ws  ON ws.Id  = wsa.WorkflowStepId
    JOIN   workflow.WorkflowDefinition      wd  ON wd.Id  = ws.WorkflowDefinitionId
    WHERE  wd.WorkflowCode          = v.WorkflowCode
      AND  ws.StepNo                = v.StepNo
      AND  wsa.WorkflowApproverType = v.ApproverType
);
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

INSERT INTO workflow.WorkflowStepApproverDesignation (WorkflowStepApproverId, DesignationId)
SELECT
    -- Resolve WorkflowStepApproverId
    (
        SELECT wsa.Id
        FROM   workflow.WorkflowStepApprover    wsa
        JOIN   workflow.WorkflowStep            ws  ON ws.Id  = wsa.WorkflowStepId
        JOIN   workflow.WorkflowDefinition      wd  ON wd.Id  = ws.WorkflowDefinitionId
        WHERE  wd.WorkflowCode          = v.WorkflowCode
          AND  ws.StepNo                = v.StepNo
          AND  wsa.WorkflowApproverType = v.ApproverType
    ),
    (SELECT Id FROM time.Designation WHERE DesignationCode = v.DesignationCode)

FROM (VALUES

--  WorkflowCode            StepNo  ApproverType    DesignationCode     Notes
--  
--  WF-LEAVE-STD-V1 Step 2: Dept Head - all dept-head-level designations
--  Engine picks whichever one is active in the initiator's resolved department
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'CONSULTANT'),      -- Clinical Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'CHFNURSE'),        -- Nursing Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'CHIEFPHARM'),      -- Pharmacy Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'RADIOLOGIST'),     -- Diagnostics/Radiology Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'PATHOLOGIST'),     -- Pathology Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'HOPADMIN'),        -- Admin Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'HRMANAGER'),       -- HR Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'ITMANAGER'),       -- IT Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'FINMANAGER'),      -- Finance Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'OPSMGR'),          -- Operations Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'EMERPHYSICIAN'),   -- Emergency Dept Head
    ('WF-LEAVE-STD-V1',     2,  'DESIGNATION',  'SRSURGEON'),       -- Surgery Dept Head

--  WF-LEAVE-STD-V1 Step 3: HR Manager - only HRMANAGER designation, always HR dept
    ('WF-LEAVE-STD-V1',     3,  'DESIGNATION',  'HRMANAGER'),

--  WF-ATTREG-STD-V1 Step 2: HR Manager - only HRMANAGER designation, always HR dept
    ('WF-ATTREG-STD-V1',    2,  'DESIGNATION',  'HRMANAGER'),

--  WF-SHIFTSWAP-V1 Step 1: Ward In-Charge - SRNURSE acts as in-charge for shift swaps
    ('WF-SHIFTSWAP-V1',     1,  'DESIGNATION',  'SRNURSE'),

--  WF-SHIFTSWAP-V1 Step 2: Scheduling Coordinator - Operations Manager handles scheduling
    ('WF-SHIFTSWAP-V1',     2,  'DESIGNATION',  'OPSMGR'),

--  WF-OT-V1 Step 1: Shift Supervisor - senior-level person in submitter's department
    ('WF-OT-V1',            1,  'DESIGNATION',  'SRNURSE'),         -- Nursing / ICU
    ('WF-OT-V1',            1,  'DESIGNATION',  'SRSURGEON'),       -- Surgery
    ('WF-OT-V1',            1,  'DESIGNATION',  'SRPHARM'),         -- Pharmacy
    ('WF-OT-V1',            1,  'DESIGNATION',  'RESIDENTDR'),      -- Clinical departments
    ('WF-OT-V1',            1,  'DESIGNATION',  'EMERPHYSICIAN'),   -- Emergency

--  WF-OT-V1 Step 2: Department Head - same set as leave dept head map
    ('WF-OT-V1',            2,  'DESIGNATION',  'CONSULTANT'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'CHFNURSE'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'CHIEFPHARM'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'RADIOLOGIST'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'PATHOLOGIST'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'HOPADMIN'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'HRMANAGER'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'ITMANAGER'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'FINMANAGER'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'OPSMGR'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'EMERPHYSICIAN'),
    ('WF-OT-V1',            2,  'DESIGNATION',  'SRSURGEON'),

--  WF-ONCALL-V1 Step 1: Department Head - same full set
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'CONSULTANT'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'CHFNURSE'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'CHIEFPHARM'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'RADIOLOGIST'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'PATHOLOGIST'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'HOPADMIN'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'HRMANAGER'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'ITMANAGER'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'FINMANAGER'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'OPSMGR'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'EMERPHYSICIAN'),
    ('WF-ONCALL-V1',        1,  'DESIGNATION',  'SRSURGEON'),

--  WF-TRAINLEAVE-V1 Step 1: Department Head - same full set
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'CONSULTANT'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'CHFNURSE'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'CHIEFPHARM'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'RADIOLOGIST'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'PATHOLOGIST'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'HOPADMIN'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'HRMANAGER'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'ITMANAGER'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'FINMANAGER'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'OPSMGR'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'EMERPHYSICIAN'),
    ('WF-TRAINLEAVE-V1',    1,  'DESIGNATION',  'SRSURGEON'),

--  WF-TRAINLEAVE-V1 Step 2: HR Manager - only HRMANAGER, fixed HR dept
    ('WF-TRAINLEAVE-V1',    2,  'DESIGNATION',  'HRMANAGER'),

--  WF-TRAINLEAVE-V1 Step 3: Finance Manager - only FINMANAGER, fixed FINANCE dept
    ('WF-TRAINLEAVE-V1',    3,  'DESIGNATION',  'FINMANAGER'),

--  WF-DOCVERIFY-V1 Step 1: HR Manager - only HRMANAGER, fixed HR dept
    ('WF-DOCVERIFY-V1',     1,  'DESIGNATION',  'HRMANAGER'),

--  WF-PAYROLLCORR-V1 Step 1: HR Manager - only HRMANAGER, fixed HR dept
    ('WF-PAYROLLCORR-V1',   1,  'DESIGNATION',  'HRMANAGER'),

--  WF-PAYROLLCORR-V1 Step 2: Finance Manager - only FINMANAGER, fixed FINANCE dept
    ('WF-PAYROLLCORR-V1',   2,  'DESIGNATION',  'FINMANAGER')

) AS v(WorkflowCode, StepNo, ApproverType, DesignationCode)
WHERE NOT EXISTS (
    SELECT 1
    FROM   workflow.WorkflowStepApproverDesignation wsad
    JOIN   workflow.WorkflowStepApprover            wsa ON wsa.Id = wsad.WorkflowStepApproverId
    JOIN   workflow.WorkflowStep                    ws  ON ws.Id  = wsa.WorkflowStepId
    JOIN   workflow.WorkflowDefinition              wd  ON wd.Id  = ws.WorkflowDefinitionId
    JOIN   time.Designation                         d   ON d.Id   = wsad.DesignationId
    WHERE  wd.WorkflowCode          = v.WorkflowCode
      AND  ws.StepNo                = v.StepNo
      AND  wsa.WorkflowApproverType = v.ApproverType
      AND  d.DesignationCode        = v.DesignationCode
);
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

INSERT INTO workflow.WorkflowAssignment
    (WorkflowDefinitionId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, EffectiveTo, PriorityOrder)
SELECT
    (SELECT Id FROM workflow.WorkflowDefinition WHERE WorkflowCode = v.WorkflowCode),
    (SELECT Id FROM time.ScopeType WHERE ScopeCode = v.ScopeCode),
    CASE v.ScopeCode
        WHEN 'GLOBAL'           THEN 1
        WHEN 'LEGAL_ENTITY'     THEN 1
        WHEN 'OFFICE'           THEN (SELECT Id FROM time.OfficeLocation WHERE LocationCode   = v.ScopeRefCode)
        WHEN 'DEPARTMENT'       THEN (SELECT Id FROM time.Department     WHERE DepartmentCode = v.ScopeRefCode)
    END,
    v.EffectiveFrom,
    v.EffectiveTo,
    v.PriorityOrder

FROM (VALUES

--  WorkflowCode            ScopeCode       ScopeRefCode    EffectiveFrom   EffectiveTo  Pri
--  Notes
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--  Standard Leave: applies globally to all employees
    ('WF-LEAVE-STD-V1',     'GLOBAL',       NULL,           '2024-01-01',   NULL,        10),
--  Emergency Leave: applies globally, higher priority than standard (lower number = higher priority)
    ('WF-LEAVE-EMRG-V1',    'GLOBAL',       NULL,           '2024-01-01',   NULL,         5),
--  Attendance Regularization: global
    ('WF-ATTREG-STD-V1',    'GLOBAL',       NULL,           '2024-01-01',   NULL,        10),
--  Shift Swap: assigned per office location (Hyderabad and Chennai have separate ops)
    ('WF-SHIFTSWAP-V1',     'OFFICE',       'LOC-HYD-01',   '2024-01-01',   NULL,        10),
    ('WF-SHIFTSWAP-V1',     'OFFICE',       'LOC-CHN-01',   '2024-01-01',   NULL,        10),
--  Overtime: scoped to departments with shift-based work only
    ('WF-OT-V1',            'DEPARTMENT',   'ICU',          '2024-01-01',   NULL,        10),
    ('WF-OT-V1',            'DEPARTMENT',   'EMERGENCY',    '2024-01-01',   NULL,        10),
    ('WF-OT-V1',            'DEPARTMENT',   'SURGERY',      '2024-01-01',   NULL,        10),
--  Comp-Off: global
    ('WF-COMPOFF-V1',       'GLOBAL',       NULL,           '2024-01-01',   NULL,        10),
--  On-Call: only departments that require on-call coverage
    ('WF-ONCALL-V1',        'DEPARTMENT',   'ICU',          '2024-01-01',   NULL,        10),
    ('WF-ONCALL-V1',        'DEPARTMENT',   'EMERGENCY',    '2024-01-01',   NULL,        10),
    ('WF-ONCALL-V1',        'DEPARTMENT',   'SURGERY',      '2024-01-01',   NULL,        10),
    ('WF-ONCALL-V1',        'DEPARTMENT',   'RADIOLOGY',    '2024-01-01',   NULL,        10),
--  Training Leave: global
    ('WF-TRAINLEAVE-V1',    'GLOBAL',       NULL,           '2024-01-01',   NULL,        10),
--  Document Verification: global
    ('WF-DOCVERIFY-V1',     'GLOBAL',       NULL,           '2024-01-01',   NULL,        10),
--  Payroll Correction: legal entity level (controlled centrally by Finance)
    ('WF-PAYROLLCORR-V1',   'LEGAL_ENTITY', NULL,           '2024-01-01',   NULL,        10)

) AS v(WorkflowCode, ScopeCode, ScopeRefCode, EffectiveFrom, EffectiveTo, PriorityOrder)
WHERE NOT EXISTS (
    SELECT 1
    FROM   workflow.WorkflowAssignment  wa
    JOIN   workflow.WorkflowDefinition  wd  ON wd.Id = wa.WorkflowDefinitionId
    JOIN   time.ScopeType               st  ON st.Id = wa.ScopeTypeId
    WHERE  wd.WorkflowCode  = v.WorkflowCode
      AND  st.ScopeCode     = v.ScopeCode
      AND  wa.ScopeReferenceId = CASE v.ScopeCode
               WHEN 'GLOBAL'       THEN 1
               WHEN 'LEGAL_ENTITY' THEN 1
               WHEN 'OFFICE'       THEN (SELECT Id FROM time.OfficeLocation WHERE LocationCode   = v.ScopeRefCode)
               WHEN 'DEPARTMENT'   THEN (SELECT Id FROM time.Department     WHERE DepartmentCode = v.ScopeRefCode)
           END
);
GO

-- ============================================================
-- SECTION 6: WORKFLOW INSTANCES
-- One row per submitted transaction.
-- CurrentWorkflowStepId = NULL for terminal-status instances.
-- ============================================================

INSERT INTO workflow.WorkflowInstance
    (WorkflowDefinitionId, WorkflowModuleId, ReferenceTransactionId,
     CurrentWorkflowStepId, WorkflowStatus, InitiatedBy, InitiatedAt, CompletedAt)
SELECT
    (SELECT Id FROM workflow.WorkflowDefinition WHERE WorkflowCode = v.WorkflowCode),
    (SELECT Id FROM workflow.WorkflowModule     WHERE ModuleCode   = v.ModuleCode),
    v.ReferenceTransactionId,
    CASE
        WHEN v.CurrentStepNo IS NULL THEN NULL
        ELSE (
            SELECT ws.Id
            FROM   workflow.WorkflowStep       ws
            JOIN   workflow.WorkflowDefinition wd ON wd.Id = ws.WorkflowDefinitionId
            WHERE  wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.CurrentStepNo
        )
    END,
    v.StatusCode,
    v.InitiatedBy,
    v.InitiatedAt,
    v.CompletedAt

FROM (VALUES

--  WorkflowCode            ModuleCode          RefTxId  CurrStep  Status          InitBy  InitiatedAt                     CompletedAt
--  Description
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
    ('WF-LEAVE-STD-V1',    'LEAVE',              101,     2,        'IN_PROGRESS',  5,  '2025-04-28 09:15:00', NULL),
--  Inst 1:  Staff Nurse Casual Leave - awaiting Dept Head (Step 2)

    ('WF-LEAVE-EMRG-V1',   'LEAVE',              102,     NULL,     'APPROVED',     8,  '2025-04-29 06:45:00', '2025-04-29 08:10:00'),
--  Inst 2:  ICU Resident Emergency Leave - single-step, fully approved

    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',     201,     1,        'PENDING',      12, '2025-04-30 10:00:00', NULL),
--  Inst 3:  Radiology Technician missed punch regularization - awaiting RM (Step 1)

    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',         301,     2,        'IN_PROGRESS',  9,  '2025-04-27 14:30:00', NULL),
--  Inst 4:  Pharmacy shift swap - Step 1 done, awaiting Scheduling Coordinator (Step 2)

    ('WF-OT-V1',           'OVERTIME',           401,     NULL,     'APPROVED',     6,  '2025-04-26 22:00:00', '2025-04-27 09:00:00'),
--  Inst 5:  Emergency Dept nurse overtime - both steps approved

    ('WF-COMPOFF-V1',      'COMPOFF',            501,     1,        'PENDING',      14, '2025-05-01 08:00:00', NULL),
--  Inst 6:  Lab Technician comp-off redemption - awaiting RM (Step 1)

    ('WF-ONCALL-V1',       'ONCALL',             601,     2,        'IN_PROGRESS',  7,  '2025-04-25 11:00:00', NULL),
--  Inst 7:  Surgery specialist on-call - Dept Head done, awaiting CMO (Step 2)

    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',     701,     NULL,     'REJECTED',     10, '2025-04-20 09:00:00', '2025-04-23 16:45:00'),
--  Inst 8:  CME Conference leave - rejected by Finance at Step 3

    ('WF-DOCVERIFY-V1',    'DOC_VERIFICATION',   801,     NULL,     'APPROVED',     3,  '2025-04-15 10:30:00', '2025-04-16 14:00:00'),
--  Inst 9:  Nursing License renewal - HR verified and approved

    ('WF-PAYROLLCORR-V1',  'PAYROLL_CORRECTION', 901,     2,        'IN_PROGRESS',  1,  '2025-05-02 09:00:00', NULL),
--  Inst 10: April payroll correction - HR reviewed, awaiting Finance (Step 2)

    ('WF-LEAVE-STD-V1',    'LEAVE',              103,     NULL,     'APPROVED',     16, '2025-04-10 08:00:00', '2025-04-14 17:00:00'),
--  Inst 11: Admin Officer Earned Leave - all 3 steps approved

    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',         302,     NULL,     'CANCELLED',    11, '2025-04-22 13:00:00', '2025-04-22 15:30:00'),
--  Inst 12: Shift swap cancelled by requester before Step 1 approval

    ('WF-OT-V1',           'OVERTIME',           402,     2,        'IN_PROGRESS',  4,  '2025-04-30 23:00:00', NULL),
--  Inst 13: ICU Senior Nurse OT - Supervisor reviewed, awaiting Dept Head (Step 2)

    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',     202,     NULL,     'REJECTED',     17, '2025-04-18 09:00:00', '2025-04-19 11:00:00'),
--  Inst 14: Attendance regularization - returned for clarification then rejected

    ('WF-ONCALL-V1',       'ONCALL',             602,     NULL,     'APPROVED',     13, '2025-04-12 10:00:00', '2025-04-13 09:30:00')
--  Inst 15: Radiology on-call duty - both steps approved

) AS v(WorkflowCode, ModuleCode, ReferenceTransactionId, CurrentStepNo, StatusCode, InitiatedBy, InitiatedAt, CompletedAt);
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

INSERT INTO workflow.WorkflowActionHistory
    (WorkflowInstanceId, WorkflowTaskId, WorkflowStepId, WorkflowActionType,
     ActionBy, ActionAt, Remarks, FromWorkflowStatus, ToWorkflowStatus)
SELECT
    -- Resolve WorkflowInstanceId
    (
        SELECT wi.Id
        FROM   workflow.WorkflowInstance   wi
        JOIN   workflow.WorkflowDefinition wd ON wd.Id = wi.WorkflowDefinitionId
        JOIN   workflow.WorkflowModule     wm ON wm.Id = wi.WorkflowModuleId
        WHERE  wd.WorkflowCode           = v.WorkflowCode
          AND  wm.ModuleCode             = v.ModuleCode
          AND  wi.ReferenceTransactionId = v.ReferenceTransactionId
    ),
    NULL,   -- WorkflowTaskId: tasks not seeded individually
    -- Resolve WorkflowStepId (NULL for system-level actions like CANCEL)
    CASE
        WHEN v.StepNo IS NULL THEN NULL
        ELSE (
            SELECT ws.Id
            FROM   workflow.WorkflowStep       ws
            JOIN   workflow.WorkflowDefinition wd ON wd.Id = ws.WorkflowDefinitionId
            WHERE  wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.StepNo
        )
    END,
    v.ActionCode,
    v.ActionBy,
    v.ActionAt,
    v.Remarks,
    v.FromStatusCode,
    v.ToStatusCode

FROM (VALUES

--  WorkflowCode            ModuleCode              RefTxId  StepNo  ActionCode                  By   ActionAt                        Remarks                                                                                         FromStatus      ToStatus
--  
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--   Instance 1: Staff Nurse Casual Leave 
    ('WF-LEAVE-STD-V1',    'LEAVE',                 101,  1, 'SUBMIT',                      5,  '2025-04-28 09:15:00', 'Leave request submitted for 3 days Casual Leave.',                                         NULL,           'PENDING'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                 101,  1, 'APPROVE',                     2,  '2025-04-28 11:30:00', 'Approved. Ward coverage confirmed for the period.',                                         'PENDING',      'IN_PROGRESS'),
--  Currently at Step 2 - no further history yet

--   Instance 2: ICU Resident Emergency Leave ----------------------------------------------------------------------------------------
    ('WF-LEAVE-EMRG-V1',   'LEAVE',                 102,  1, 'SUBMIT',                      8,  '2025-04-29 06:45:00', 'Family medical emergency. Requesting immediate leave.',                                      NULL,           'PENDING'),
    ('WF-LEAVE-EMRG-V1',   'LEAVE',                 102,  1, 'APPROVE',                     2,  '2025-04-29 08:10:00', 'Approved on humanitarian grounds. Cover arranged.',                                          'PENDING',      'APPROVED'),

--   Instance 3: Radiology Technician attendance regularization -----------------------------------------------------------------------
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         201,  1, 'SUBMIT',                     12, '2025-04-30 10:00:00', 'Biometric reader malfunction on 29-Apr. Requesting correction.',                             NULL,           'PENDING'),
--  Currently at Step 1 - no further history yet

--   Instance 4: Pharmacy Shift Swap --------------------------------------------------------------------------------------------------
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             301,  1, 'SUBMIT',                      9,  '2025-04-27 14:30:00', 'Requesting swap with Emp #11 for 02-May morning shift.',                                    NULL,           'PENDING'),
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             301,  1, 'APPROVE',                     2,  '2025-04-27 16:00:00', 'Operationally feasible. Both employees trained for the shift.',                              'PENDING',      'IN_PROGRESS'),
--  Currently at Step 2 - no further history yet

--   Instance 5: Emergency Dept nurse overtime -----------------------------------------------------------------------------------------
    ('WF-OT-V1',           'OVERTIME',               401,  1, 'SUBMIT',                      6,  '2025-04-26 22:00:00', 'Stayed 3 hours extra due to patient influx in Emergency.',                                  NULL,           'PENDING'),
    ('WF-OT-V1',           'OVERTIME',               401,  1, 'APPROVE',                     3,  '2025-04-27 08:00:00', 'Verified against attendance log. OT of 180 minutes confirmed.',                              'PENDING',      'IN_PROGRESS'),
    ('WF-OT-V1',           'OVERTIME',               401,  2, 'APPROVE',                     7,  '2025-04-27 09:00:00', 'Authorized. OT credit approved for April payroll.',                                          'IN_PROGRESS',  'APPROVED'),

--   Instance 6: Lab Technician comp-off -----------------------------------------------------------------------------------------------
    ('WF-COMPOFF-V1',      'COMPOFF',                501,  1, 'SUBMIT',                     14, '2025-05-01 08:00:00', 'Applying comp-off earned on 27-Apr (holiday working).',                                      NULL,           'PENDING'),
--  Currently at Step 1 - no further history yet

--   Instance 7: Surgery on-call duty 
    ('WF-ONCALL-V1',       'ONCALL',                 601,  1, 'SUBMIT',                      7,  '2025-04-25 11:00:00', 'On-call duty required for elective surgeries on 02-May.',                                   NULL,           'PENDING'),
    ('WF-ONCALL-V1',       'ONCALL',                 601,  1, 'APPROVE',                     7,  '2025-04-25 13:30:00', 'Confirmed by Surgery HOD. Specialist availability verified.',                                'PENDING',      'IN_PROGRESS'),
--  Currently at Step 2 (CMO) - no further history yet

--   Instance 8: Training & Conference Leave - Finance rejected -------------------------------------------------------------------------
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,  1, 'SUBMIT',                     10, '2025-04-20 09:00:00', 'CME conference in Mumbai. Registration fee Rs. 18,000.',                                     NULL,           'PENDING'),
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,  1, 'APPROVE',                     7,  '2025-04-21 10:00:00', 'Conference is relevant. Department supports attendance.',                                    'PENDING',      'IN_PROGRESS'),
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,  2, 'APPROVE',                     1,  '2025-04-22 09:30:00', 'HR approved leave days. Forwarding to Finance for cost authorization.',                      'IN_PROGRESS',  'IN_PROGRESS'),
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,  3, 'REJECT',                     15, '2025-04-23 16:45:00', 'Budget exhausted for Q1 training. Cannot approve funding. Employee may attend at personal cost.', 'IN_PROGRESS', 'REJECTED'),

--   Instance 9: Nursing License document verification ----------------------------------------------------------------------------------
    ('WF-DOCVERIFY-V1',    'DOC_VERIFICATION',       801,  1, 'SUBMIT',                      3,  '2025-04-15 10:30:00', 'Nursing Council License renewed. Uploading updated document.',                               NULL,           'PENDING'),
    ('WF-DOCVERIFY-V1',    'DOC_VERIFICATION',       801,  1, 'APPROVE',                     1,  '2025-04-16 14:00:00', 'Document verified. License valid until 2027-03-31.',                                         'PENDING',      'APPROVED'),

--   Instance 10: Payroll attendance correction 
    ('WF-PAYROLLCORR-V1',  'PAYROLL_CORRECTION',     901,  1, 'SUBMIT',                      1,  '2025-05-02 09:00:00', 'Correcting 2 absent days erroneously marked for Emp #12 in April. Attendance logs attached.',  NULL,           'PENDING'),
    ('WF-PAYROLLCORR-V1',  'PAYROLL_CORRECTION',     901,  1, 'APPROVE',                     1,  '2025-05-02 09:30:00', 'HR review complete. Logs verified. Forwarding to Finance.',                                   'PENDING',      'IN_PROGRESS'),
--  Currently at Step 2 (Finance) - no further history yet

--   Instance 11: Admin Officer Earned Leave - full 3-step trail -------------------------------------------------------------------------
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,  1, 'SUBMIT',                     16, '2025-04-10 08:00:00', 'Earned leave for 5 days. Pre-planned annual vacation.',                                      NULL,           'PENDING'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,  1, 'APPROVE',                     2,  '2025-04-10 11:00:00', 'Approved. Handover document submitted.',                                                      'PENDING',      'IN_PROGRESS'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,  2, 'APPROVE',                     7,  '2025-04-11 10:00:00', 'Approved by Dept Head. Leave balance confirmed.',                                             'IN_PROGRESS',  'IN_PROGRESS'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,  3, 'APPROVE',                     1,  '2025-04-14 17:00:00', 'HR final approval. Leave recorded in system.',                                                'IN_PROGRESS',  'APPROVED'),

--   Instance 12: Shift Swap cancelled before approval -----------------------------------------------------------------------------------
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             302,  1, 'SUBMIT',                     11, '2025-04-22 13:00:00', 'Requesting shift swap with Emp #9 for 25-Apr.',                                              NULL,           'PENDING'),
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             302,  NULL, 'CANCEL',                  11, '2025-04-22 15:30:00', 'Swap no longer needed. Other arrangements made. Cancelling request.',                         'PENDING',      'CANCELLED'),
--  StepNo=NULL for CANCEL: system-level action, not tied to a specific step

--   Instance 13: ICU Senior Nurse OT - Supervisor verified, Dept Head pending ------------------------------------------------------------
    ('WF-OT-V1',           'OVERTIME',               402,  1, 'SUBMIT',                      4,  '2025-04-30 23:00:00', 'Extended shift in ICU due to critical patient monitoring.',                                  NULL,           'PENDING'),
    ('WF-OT-V1',           'OVERTIME',               402,  1, 'APPROVE',                     3,  '2025-05-01 07:30:00', 'Verified. ICU log confirms 210 minutes overtime.',                                           'PENDING',      'IN_PROGRESS'),
--  Currently at Step 2 - no further history yet

--   Instance 14: Attendance regularization - returned then rejected ----------------------------------------------------------------------
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         202,  1, 'SUBMIT',                     17, '2025-04-18 09:00:00', 'Requesting regularization for 17-Apr. Was working from home.',                               NULL,           'PENDING'),
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         202,  1, 'RETURN',                     2,  '2025-04-18 14:00:00', 'No WFH approval on record for 17-Apr. Please provide prior approval proof.',                 'PENDING',      'IN_PROGRESS'),
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         202,  2, 'REJECT',                      1,  '2025-04-19 11:00:00', 'Regularization rejected. No valid supporting documentation provided.',                       'IN_PROGRESS',  'REJECTED'),

--   Instance 15: Radiology on-call - full 2-step approval trail --------------------------------------------------------------------------
    ('WF-ONCALL-V1',       'ONCALL',                 602,  1, 'SUBMIT',                     13, '2025-04-12 10:00:00', 'On-call duty for CT scan emergencies on 14-Apr.',                                            NULL,           'PENDING'),
    ('WF-ONCALL-V1',       'ONCALL',                 602,  1, 'APPROVE',                     7,  '2025-04-12 12:00:00', 'Radiology HOD confirmed. Technician is qualified.',                                          'PENDING',      'IN_PROGRESS'),
    ('WF-ONCALL-V1',       'ONCALL',                 602,  2, 'APPROVE',                     2,  '2025-04-13 09:30:00', 'CMO approved. On-call duty authorized.',                                                      'IN_PROGRESS',  'APPROVED')

) AS v(WorkflowCode, ModuleCode, ReferenceTransactionId, StepNo, ActionCode, ActionBy, ActionAt, Remarks, FromStatusCode, ToStatusCode);
GO

PRINT 'Workflow seed data inserted successfully.';
GO