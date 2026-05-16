-- WORKFLOW SCHEMA - Seed Data
-- Healthcare Organization (MediCore Health Systems)
-- Dependencies: shared, time, employee
-- FIX: All foreign key references resolved dynamically via subqueries on Code columns.
-- No hardcoded IDENTITY integers used anywhere.

-- SEED DATA - Workflow Modules

-- SECTION 1: WORKFLOW MODULES

INSERT INTO workflow.WorkflowModule (ModuleCode, ModuleName, EntityName)
SELECT v.ModuleCode, v.ModuleName, v.EntityName
FROM (VALUES
    ('LEAVE',               'Leave Management',              'LeaveRequest'),
    ('ATTENDANCE_REG',      'Attendance Regularization',     'AttendanceRegularization'),
    ('SHIFT_SWAP',          'Shift Swap',                    'ShiftSwapRequest'),
    ('OVERTIME',            'Overtime Authorization',        'AttendanceRecord'),
    ('COMPOFF',             'Comp-Off Redemption',           'CompOffBalance'),
    ('ONCALL',              'On-Call Duty',                  'EmployeeShiftRoster'),
    ('TRAINING_LEAVE',      'Training & Conference Leave',   'LeaveRequest'),
    ('DOC_VERIFICATION',    'Document Verification',         'EmployeeDocument'),
    ('PAYROLL_CORRECTION',  'Payroll Attendance Correction', 'PayrollAttendanceSummary')
) AS v(ModuleCode, ModuleName, EntityName)
WHERE NOT EXISTS (
    SELECT 1 FROM workflow.WorkflowModule wm WHERE wm.ModuleCode = v.ModuleCode
);
GO


-- SECTION 2: WORKFLOW DEFINITIONS

INSERT INTO workflow.WorkflowDefinition (WorkflowModuleId, WorkflowCode, WorkflowName, VersionNo, Description)
SELECT
    (SELECT Id FROM workflow.WorkflowModule WHERE ModuleCode = v.ModuleCode),
    v.WorkflowCode, v.WorkflowName, v.VersionNo, v.Description
FROM (VALUES
    ('LEAVE',             'WF-LEAVE-STD-V1',      'Standard Leave Approval',                1,
     'Three-level approval for all standard leave types.'),
    ('LEAVE',             'WF-LEAVE-EMRG-V1',     'Emergency Leave Fast-Track Approval',    1,
     'Single-step fast-track approval for emergency leave requests.'),
    ('ATTENDANCE_REG',    'WF-ATTREG-STD-V1',     'Attendance Regularization Approval',   1,
     'Two-level approval for attendance correction requests.'),
    ('SHIFT_SWAP',        'WF-SHIFTSWAP-V1',       'Shift Swap Approval',                   1,
     'Two-level approval for shift swap requests.'),
    ('OVERTIME',          'WF-OT-V1',              'Overtime Authorization',               1,
     'Two-level approval for overtime worked.'),
    ('COMPOFF',           'WF-COMPOFF-V1',         'Comp-Off Redemption Approval',         1,
     'Single-step approval by Reporting Manager.'),
    ('ONCALL',            'WF-ONCALL-V1',          'On-Call Duty Approval',                 1,
     'Two-level approval for on-call duty assignments.'),
    ('TRAINING_LEAVE',    'WF-TRAINLEAVE-V1',      'Training & Conference Leave Approval',   1,
     'Three-level approval for training programs.'),
    ('DOC_VERIFICATION',  'WF-DOCVERIFY-V1',       'Employee Document Verification',        1,
     'Single-step HR Manager verification workflow.'),
    ('PAYROLL_CORRECTION','WF-PAYROLLCORR-V1',     'Payroll Attendance Correction Approval', 1,
     'Two-level approval for payroll attendance corrections.')
) AS v(ModuleCode, WorkflowCode, WorkflowName, VersionNo, Description)
WHERE NOT EXISTS (
    SELECT 1 FROM workflow.WorkflowDefinition wd WHERE wd.WorkflowCode = v.WorkflowCode
);
GO


-- SECTION 3: WORKFLOW STEPS

INSERT INTO workflow.WorkflowStep
    (WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep, AllowDelegation, EscalationAfterHours)
SELECT
    (SELECT Id FROM workflow.WorkflowDefinition WHERE WorkflowCode  = v.WorkflowCode),
    v.StepNo,
    v.StepName,
    v.StepTypeCode,
    v.IsFinalStep,
    v.AllowDelegation,
    v.EscalationAfterHours
FROM (VALUES
    -- WF-LEAVE-STD-V1
    ('WF-LEAVE-STD-V1',    1, 'Reporting Manager Approval', 'APPROVAL',     0, 1, 24),
    ('WF-LEAVE-STD-V1',    2, 'Department Head Approval',  'APPROVAL',     0, 1, 48),
    ('WF-LEAVE-STD-V1',    3, 'HR Manager Final Approval', 'APPROVAL',     1, 0, 72),
    -- WF-LEAVE-EMRG-V1
    ('WF-LEAVE-EMRG-V1',   1, 'Reporting Manager Emergency Approval', 'APPROVAL', 1, 1, 2),
    -- WF-ATTREG-STD-V1
    ('WF-ATTREG-STD-V1',   1, 'Reporting Manager Review', 'REVIEW',       0, 1, 24),
    ('WF-ATTREG-STD-V1',   2, 'HR Manager Approval',      'APPROVAL',     1, 0, 48),
    -- WF-SHIFTSWAP-V1
    ('WF-SHIFTSWAP-V1',    1, 'Ward In-Charge Approval',   'APPROVAL',     0, 1, 12),
    ('WF-SHIFTSWAP-V1',    2, 'Scheduling Coordinator',   'APPROVAL',     1, 0, 24),
    -- WF-OT-V1
    ('WF-OT-V1',           1, 'Shift Supervisor Review',  'REVIEW',       0, 1, 24),
    ('WF-OT-V1',           2, 'Department Head Approval',  'APPROVAL',     1, 0, 48),
    -- WF-COMPOFF-V1
    ('WF-COMPOFF-V1',      1, 'Reporting Manager Approval', 'APPROVAL',    1, 1, 24),
    -- WF-ONCALL-V1
    ('WF-ONCALL-V1',       1, 'Department Head Confirmation', 'APPROVAL',    0, 1, 12),
    ('WF-ONCALL-V1',       2, 'Chief Medical Officer Authorization', 'APPROVAL', 1, 0, 24),
    -- WF-TRAINLEAVE-V1
    ('WF-TRAINLEAVE-V1',   1, 'Department Head Approval',    'APPROVAL',     0, 1, 48),
    ('WF-TRAINLEAVE-V1',   2, 'HR Manager Review',           'REVIEW',      0, 1, 48),
    ('WF-TRAINLEAVE-V1',   3, 'Finance Manager Cost Approval', 'APPROVAL',    1, 0, 72),
    -- WF-DOCVERIFY-V1
    ('WF-DOCVERIFY-V1',    1, 'HR Manager Document Verification', 'APPROVAL', 1, 0, 72),
    -- WF-PAYROLLCORR-V1
    ('WF-PAYROLLCORR-V1',  1, 'HR Manager Review',           'REVIEW',      0, 0, 24),
    ('WF-PAYROLLCORR-V1',  2, 'Finance Manager Authorization', 'APPROVAL',    1, 0, 48)
) AS v(WorkflowCode, StepNo, StepName, StepTypeCode, IsFinalStep, AllowDelegation, EscalationAfterHours)
WHERE NOT EXISTS (
    SELECT 1
    FROM   workflow.WorkflowStep ws
    INNER JOIN workflow.WorkflowDefinition wd ON wd.Id = ws.WorkflowDefinitionId
    WHERE  wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.StepNo
);
GO
-- SECTION 4: WORKFLOW STEP APPROVERS

INSERT INTO workflow.WorkflowStepApprover
    (WorkflowStepId, WorkflowApproverType, ApproverReferenceId, PriorityOrder, IsMandatory)
SELECT
    (SELECT ws.Id FROM workflow.WorkflowStep ws
     INNER JOIN workflow.WorkflowDefinition wd ON wd.Id = ws.WorkflowDefinitionId
     WHERE wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.StepNo),
    v.ApproverTypeCode,
    v.ApproverReferenceId,
    v.PriorityOrder,
    v.IsMandatory
FROM (VALUES
    ('WF-LEAVE-STD-V1',    1, 'REPORTING_MANAGER', NULL, 1, 1),
    ('WF-LEAVE-STD-V1',    2, 'DEPARTMENT_HEAD',   NULL, 1, 1),
    ('WF-LEAVE-STD-V1',    3, 'HR_MANAGER',        NULL, 1, 1),
    ('WF-LEAVE-EMRG-V1',   1, 'REPORTING_MANAGER', NULL, 1, 1),
    ('WF-ATTREG-STD-V1',   1, 'REPORTING_MANAGER', NULL, 1, 1),
    ('WF-ATTREG-STD-V1',   2, 'HR_MANAGER',        NULL, 1, 1),
    ('WF-SHIFTSWAP-V1',    1, 'ROLE',              3,    1, 1),  -- Ward In-Charge
    ('WF-SHIFTSWAP-V1',    2, 'ROLE',              7,    1, 1),  -- Scheduling Coordinator
    ('WF-OT-V1',           1, 'ROLE',              4,    1, 1),  -- Shift Supervisor
    ('WF-OT-V1',           2, 'DEPARTMENT_HEAD',   NULL, 1, 1),
    ('WF-COMPOFF-V1',      1, 'REPORTING_MANAGER', NULL, 1, 1),
    ('WF-ONCALL-V1',       1, 'DEPARTMENT_HEAD',   NULL, 1, 1),
    ('WF-ONCALL-V1',       2, 'USER',              2,    1, 1),  -- CMO EmployeeId=2
    ('WF-TRAINLEAVE-V1',   1, 'DEPARTMENT_HEAD',   NULL, 1, 1),
    ('WF-TRAINLEAVE-V1',   2, 'HR_MANAGER',        NULL, 1, 1),
    ('WF-TRAINLEAVE-V1',   3, 'ROLE',              6,    1, 1),  -- Finance Manager
    ('WF-DOCVERIFY-V1',    1, 'HR_MANAGER',        NULL, 1, 1),
    ('WF-PAYROLLCORR-V1',  1, 'HR_MANAGER',        NULL, 1, 1),
    ('WF-PAYROLLCORR-V1',  2, 'ROLE',              6,    1, 1)   -- Finance Manager
) AS v(WorkflowCode, StepNo, ApproverTypeCode, ApproverReferenceId, PriorityOrder, IsMandatory);
GO

-- SECTION 5: WORKFLOW ASSIGNMENTS

INSERT INTO workflow.WorkflowAssignment
    (WorkflowDefinitionId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, EffectiveTo, PriorityOrder)
SELECT
    (SELECT Id FROM workflow.WorkflowDefinition WHERE WorkflowCode = v.WorkflowCode),
    v.ScopeTypeId,
    CASE v.ScopeTypeId
        WHEN 1 THEN 1  -- GLOBAL
        WHEN 4 THEN 1  -- LEGAL_ENTITY
        WHEN 5 THEN (SELECT Id FROM time.OfficeLocation WHERE LocationCode   = v.ScopeRefCode)
        WHEN 6 THEN (SELECT Id FROM time.Department     WHERE DepartmentCode = v.ScopeRefCode)
    END,
    v.EffectiveFrom,
    v.EffectiveTo,
    v.PriorityOrder
FROM (VALUES
    ('WF-LEAVE-STD-V1',     1, NULL,           '2024-01-01', NULL, 10),
    ('WF-LEAVE-EMRG-V1',    1, NULL,           '2024-01-01', NULL,  5),
    ('WF-ATTREG-STD-V1',    1, NULL,           '2024-01-01', NULL, 10),
    ('WF-SHIFTSWAP-V1',     5, 'LOC-HYD-01',  '2024-01-01', NULL, 10),
    ('WF-SHIFTSWAP-V1',     5, 'LOC-CHN-01',  '2024-01-01', NULL, 10),
    ('WF-OT-V1',            6, 'ICU',         '2024-01-01', NULL, 10),
    ('WF-OT-V1',            6, 'EMERGENCY',    '2024-01-01', NULL, 10),
    ('WF-OT-V1',            6, 'SURGERY',      '2024-01-01', NULL, 10),
    ('WF-COMPOFF-V1',       1, NULL,           '2024-01-01', NULL, 10),
    ('WF-ONCALL-V1',        6, 'ICU',         '2024-01-01', NULL, 10),
    ('WF-ONCALL-V1',        6, 'EMERGENCY',   '2024-01-01', NULL, 10),
    ('WF-ONCALL-V1',        6, 'SURGERY',      '2024-01-01', NULL, 10),
    ('WF-ONCALL-V1',        6, 'RADIOLOGY',    '2024-01-01', NULL, 10),
    ('WF-TRAINLEAVE-V1',    1, NULL,           '2024-01-01', NULL, 10),
    ('WF-DOCVERIFY-V1',     1, NULL,           '2024-01-01', NULL, 10),
    ('WF-PAYROLLCORR-V1',   4, NULL,           '2024-01-01', NULL, 10)
) AS v(WorkflowCode, ScopeTypeId, ScopeRefCode, EffectiveFrom, EffectiveTo, PriorityOrder)
WHERE NOT EXISTS (
    SELECT 1
    FROM   workflow.WorkflowAssignment  wa
    INNER JOIN workflow.WorkflowDefinition wd ON wd.Id = wa.WorkflowDefinitionId
    WHERE  wd.WorkflowCode   = v.WorkflowCode
      AND  wa.ScopeTypeId     = v.ScopeTypeId
      AND  wa.ScopeReferenceId = CASE v.ScopeTypeId
                                     WHEN 1 THEN 1
                                     WHEN 4 THEN 1
                                     WHEN 5 THEN (SELECT Id FROM time.OfficeLocation WHERE LocationCode   = v.ScopeRefCode)
                                     WHEN 6 THEN (SELECT Id FROM time.Department     WHERE DepartmentCode = v.ScopeRefCode)
                                 END
);
GO


-- SECTION 6: WORKFLOW INSTANCES

INSERT INTO workflow.WorkflowInstance
    (WorkflowDefinitionId, WorkflowModuleId, ReferenceTransactionId,
     CurrentWorkflowStepId, WorkflowStatus, InitiatedBy, InitiatedAt, CompletedAt)
SELECT
    (SELECT Id FROM workflow.WorkflowDefinition WHERE WorkflowCode = v.WorkflowCode),
    (SELECT Id FROM workflow.WorkflowModule     WHERE ModuleCode   = v.ModuleCode),
    v.ReferenceTransactionId,
    CASE WHEN v.CurrentStepNo IS NULL THEN NULL
         ELSE (
             SELECT ws.Id FROM workflow.WorkflowStep ws
             INNER JOIN workflow.WorkflowDefinition wd ON wd.Id = ws.WorkflowDefinitionId
             WHERE wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.CurrentStepNo
         )
    END,
    v.StatusCode,
    v.InitiatedBy,
    v.InitiatedAt,
    v.CompletedAt
FROM (VALUES

--  WorkflowCode            ModuleCode              RefTxId  CurrStepNo  StatusCode      InitBy  InitiatedAt                     CompletedAt
    ('WF-LEAVE-STD-V1',    'LEAVE',                 101,     2,          'IN_PROGRESS',  5,  '2025-04-28 09:15:00', NULL),                       -- Inst 1:  Staff Nurse Casual Leave - at Dept Head step
    ('WF-LEAVE-EMRG-V1',   'LEAVE',                 102,     NULL,       'APPROVED',     8,  '2025-04-29 06:45:00', '2025-04-29 08:10:00'),       -- Inst 2:  ICU Resident Emergency Leave - Approved
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         201,     1,          'PENDING',      12, '2025-04-30 10:00:00', NULL),                       -- Inst 3:  Radiology Technician missed punch - Pending
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             301,     2,          'IN_PROGRESS',  9,  '2025-04-27 14:30:00', NULL),                       -- Inst 4:  Pharmacy shift swap - awaiting Scheduling
    ('WF-OT-V1',           'OVERTIME',               401,     NULL,       'APPROVED',     6,  '2025-04-26 22:00:00', '2025-04-27 09:00:00'),       -- Inst 5:  Emergency nurse OT - Approved
    ('WF-COMPOFF-V1',      'COMPOFF',                501,     1,          'PENDING',      14, '2025-05-01 08:00:00', NULL),                       -- Inst 6:  Lab Technician comp-off - Pending
    ('WF-ONCALL-V1',       'ONCALL',                 601,     2,          'IN_PROGRESS',  7,  '2025-04-25 11:00:00', NULL),                       -- Inst 7:  Surgery specialist on-call - awaiting CMO
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,     NULL,       'REJECTED',     10, '2025-04-20 09:00:00', '2025-04-23 16:45:00'),       -- Inst 8:  CME Conference leave - Finance rejected
    ('WF-DOCVERIFY-V1',    'DOC_VERIFICATION',       801,     NULL,       'APPROVED',     3,  '2025-04-15 10:30:00', '2025-04-16 14:00:00'),       -- Inst 9:  Nursing License renewal - Approved
    ('WF-PAYROLLCORR-V1',  'PAYROLL_CORRECTION',     901,     2,          'IN_PROGRESS',  1,  '2025-05-02 09:00:00', NULL),                       -- Inst 10: April payroll correction - at Finance step
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,     NULL,       'APPROVED',     16, '2025-04-10 08:00:00', '2025-04-14 17:00:00'),       -- Inst 11: Admin Officer Earned Leave - Approved
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             302,     NULL,       'CANCELLED',    11, '2025-04-22 13:00:00', '2025-04-22 15:30:00'),       -- Inst 12: Shift swap cancelled by requester
    ('WF-OT-V1',           'OVERTIME',               402,     2,          'IN_PROGRESS',  4,  '2025-04-30 23:00:00', NULL),                       -- Inst 13: ICU Senior Nurse OT - awaiting Dept Head
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         202,     NULL,       'REJECTED',     17, '2025-04-18 09:00:00', '2025-04-19 11:00:00'),       -- Inst 14: Regularization rejected - no documentation
    ('WF-ONCALL-V1',       'ONCALL',                 602,     NULL,       'APPROVED',     13, '2025-04-12 10:00:00', '2025-04-13 09:30:00')        -- Inst 15: Radiology on-call - Approved

) AS v(WorkflowCode, ModuleCode, ReferenceTransactionId, CurrentStepNo, StatusCode, InitiatedBy, InitiatedAt, CompletedAt);
GO


-- SECTION 7: WORKFLOW ACTION HISTORY

INSERT INTO workflow.WorkflowActionHistory
    (WorkflowInstanceId, WorkflowStepId, WorkflowActionType,
     ActionBy, ActionAt, Remarks, FromWorkflowStatus, ToWorkflowStatus)
SELECT
    (
        SELECT wi.Id FROM workflow.WorkflowInstance wi
        INNER JOIN workflow.WorkflowDefinition wd ON wd.Id = wi.WorkflowDefinitionId
        INNER JOIN workflow.WorkflowModule     wm ON wm.Id = wi.WorkflowModuleId
        WHERE wd.WorkflowCode             = v.WorkflowCode
          AND wm.ModuleCode               = v.ModuleCode
          AND wi.ReferenceTransactionId   = v.ReferenceTransactionId
    ),
    CASE WHEN v.StepNo IS NULL THEN NULL
         ELSE (
             SELECT ws.Id FROM workflow.WorkflowStep ws
             INNER JOIN workflow.WorkflowDefinition wd ON wd.Id = ws.WorkflowDefinitionId
             WHERE wd.WorkflowCode = v.WorkflowCode AND ws.StepNo = v.StepNo
         )
    END,
    v.ActionCode,
    v.ActionBy,
    v.ActionAt,
    v.Remarks,
    CASE WHEN v.FromStatusCode IS NULL THEN NULL
         ELSE v.FromStatusCode END,
    v.ToStatusCode
FROM (VALUES

--  WorkflowCode            ModuleCode              RefTxId  StepNo  ActionCode  By   ActionAt                        Remarks                                                                                                                 FromStatus      ToStatus

--  Instance 1: Staff Nurse Casual Leave
    ('WF-LEAVE-STD-V1',    'LEAVE',                 101,     1,      'SUBMIT',   5,  '2025-04-28 09:15:00', 'Leave request submitted for 3 days Casual Leave.',                                                                              NULL,           'PENDING'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                 101,     1,      'APPROVE',  2,  '2025-04-28 11:30:00', 'Approved. Ward coverage confirmed for the period.',                                                                             'PENDING',      'IN_PROGRESS'),

--  Instance 2: ICU Resident Emergency Leave
    ('WF-LEAVE-EMRG-V1',   'LEAVE',                 102,     1,      'SUBMIT',   8,  '2025-04-29 06:45:00', 'Family medical emergency. Requesting immediate leave.',                                                                         NULL,           'PENDING'),
    ('WF-LEAVE-EMRG-V1',   'LEAVE',                 102,     1,      'APPROVE',  2,  '2025-04-29 08:10:00', 'Approved on humanitarian grounds. Cover arranged.',                                                                             'PENDING',      'APPROVED'),

--  Instance 3: Radiology Technician attendance regularization
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         201,     1,      'SUBMIT',   12, '2025-04-30 10:00:00', 'Biometric reader malfunction on 29-Apr. Requesting correction.',                                                                NULL,           'PENDING'),

--  Instance 4: Pharmacy Shift Swap
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             301,     1,      'SUBMIT',   9,  '2025-04-27 14:30:00', 'Requesting swap with Emp #11 for 02-May morning shift.',                                                                       NULL,           'PENDING'),
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             301,     1,      'APPROVE',  2,  '2025-04-27 16:00:00', 'Operationally feasible. Both employees are trained for the shift.',                                                             'PENDING',      'IN_PROGRESS'),

--  Instance 5: Emergency Dept nurse overtime
    ('WF-OT-V1',           'OVERTIME',               401,     1,      'SUBMIT',   6,  '2025-04-26 22:00:00', 'Stayed 3 hours extra due to patient influx in Emergency.',                                                                     NULL,           'PENDING'),
    ('WF-OT-V1',           'OVERTIME',               401,     1,      'APPROVE',  3,  '2025-04-27 08:00:00', 'Verified against attendance log. OT of 180 minutes confirmed.',                                                                'PENDING',      'IN_PROGRESS'),
    ('WF-OT-V1',           'OVERTIME',               401,     2,      'APPROVE',  7,  '2025-04-27 09:00:00', 'Authorized. OT credit approved for April payroll.',                                                                            'IN_PROGRESS',  'APPROVED'),

--  Instance 6: Lab Technician comp-off
    ('WF-COMPOFF-V1',      'COMPOFF',                501,     1,      'SUBMIT',   14, '2025-05-01 08:00:00', 'Applying comp-off earned on 27-Apr (holiday working).',                                                                        NULL,           'PENDING'),

--  Instance 7: Surgery on-call duty
    ('WF-ONCALL-V1',       'ONCALL',                 601,     1,      'SUBMIT',   7,  '2025-04-25 11:00:00', 'On-call duty required for elective surgeries on 02-May.',                                                                      NULL,           'PENDING'),
    ('WF-ONCALL-V1',       'ONCALL',                 601,     1,      'APPROVE',  7,  '2025-04-25 13:30:00', 'Confirmed by Surgery HOD. Specialist availability verified.',                                                                   'PENDING',      'IN_PROGRESS'),

--  Instance 8: Training & Conference Leave - Finance rejected
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,     1,      'SUBMIT',   10, '2025-04-20 09:00:00', 'CME conference in Mumbai. Registration fee Rs. 18,000.',                                                                       NULL,           'PENDING'),
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,     1,      'APPROVE',  7,  '2025-04-21 10:00:00', 'Conference is relevant. Department supports attendance.',                                                                       'PENDING',      'IN_PROGRESS'),
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,     2,      'APPROVE',  1,  '2025-04-22 09:30:00', 'HR approved leave days. Forwarding to Finance for cost authorization.',                                                         'IN_PROGRESS',  'IN_PROGRESS'),
    ('WF-TRAINLEAVE-V1',   'TRAINING_LEAVE',         701,     3,      'REJECT',   15, '2025-04-23 16:45:00', 'Budget exhausted for Q1 training. Cannot approve funding. Employee may attend at personal cost.',                               'IN_PROGRESS',  'REJECTED'),

--  Instance 9: Nursing License document verification
    ('WF-DOCVERIFY-V1',    'DOC_VERIFICATION',       801,     1,      'SUBMIT',   3,  '2025-04-15 10:30:00', 'Nursing Council License renewed. Uploading updated document.',                                                                  NULL,           'PENDING'),
    ('WF-DOCVERIFY-V1',    'DOC_VERIFICATION',       801,     1,      'APPROVE',  1,  '2025-04-16 14:00:00', 'Document verified. License valid until 2027-03-31.',                                                                           'PENDING',      'APPROVED'),

--  Instance 10: Payroll attendance correction
    ('WF-PAYROLLCORR-V1',  'PAYROLL_CORRECTION',     901,     1,      'SUBMIT',   1,  '2025-05-02 09:00:00', 'Correcting 2 absent days erroneously marked for Emp #12 in April. Attendance logs attached.',                                  NULL,           'PENDING'),
    ('WF-PAYROLLCORR-V1',  'PAYROLL_CORRECTION',     901,     1,      'APPROVE',  1,  '2025-05-02 09:30:00', 'HR review complete. Logs verified. Forwarding to Finance.',                                                                    'PENDING',      'IN_PROGRESS'),

--  Instance 11: Admin Officer Earned Leave - full 3-step approval trail
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,     1,      'SUBMIT',   16, '2025-04-10 08:00:00', 'Earned leave for 5 days. Pre-planned annual vacation.',                                                                        NULL,           'PENDING'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,     1,      'APPROVE',  2,  '2025-04-10 11:00:00', 'Approved. Handover document submitted.',                                                                                       'PENDING',      'IN_PROGRESS'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,     2,      'APPROVE',  7,  '2025-04-11 10:00:00', 'Approved by Dept Head. Leave balance confirmed.',                                                                              'IN_PROGRESS',  'IN_PROGRESS'),
    ('WF-LEAVE-STD-V1',    'LEAVE',                  103,     3,      'APPROVE',  1,  '2025-04-14 17:00:00', 'HR final approval. Leave recorded in system.',                                                                                 'IN_PROGRESS',  'APPROVED'),

--  Instance 12: Shift Swap cancelled before approval
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             302,     1,      'SUBMIT',   11, '2025-04-22 13:00:00', 'Requesting shift swap with Emp #9 for 25-Apr.',                                                                                NULL,           'PENDING'),
    ('WF-SHIFTSWAP-V1',    'SHIFT_SWAP',             302,     NULL,   'CANCEL',   11, '2025-04-22 15:30:00', 'Swap no longer needed. Other arrangements made. Cancelling request.',                                                           'PENDING',      'CANCELLED'),

--  Instance 13: ICU Senior Nurse overtime - supervisor verified, Dept Head pending
    ('WF-OT-V1',           'OVERTIME',               402,     1,      'SUBMIT',   4,  '2025-04-30 23:00:00', 'Extended shift in ICU due to critical patient monitoring.',                                                                    NULL,           'PENDING'),
    ('WF-OT-V1',           'OVERTIME',               402,     1,      'APPROVE',  3,  '2025-05-01 07:30:00', 'Verified. ICU log confirms 210 minutes overtime.',                                                                             'PENDING',      'IN_PROGRESS'),

--  Instance 14: Attendance regularization - returned then rejected
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         202,     1,      'SUBMIT',   17, '2025-04-18 09:00:00', 'Requesting regularization for 17-Apr. Was working from home.',                                                                 NULL,           'PENDING'),
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         202,     1,      'RETURN',   2,  '2025-04-18 14:00:00', 'No WFH approval on record for 17-Apr. Please provide prior approval proof.',                                                   'PENDING',      'IN_PROGRESS'),
    ('WF-ATTREG-STD-V1',   'ATTENDANCE_REG',         202,     2,      'REJECT',   1,  '2025-04-19 11:00:00', 'Regularization rejected. No valid supporting documentation provided.',                                                          'IN_PROGRESS',  'REJECTED'),

--  Instance 15: Radiology on-call - full 2-step approval trail
    ('WF-ONCALL-V1',       'ONCALL',                 602,     1,      'SUBMIT',   13, '2025-04-12 10:00:00', 'On-call duty for CT scan emergencies on 14-Apr.',                                                                              NULL,           'PENDING'),
    ('WF-ONCALL-V1',       'ONCALL',                 602,     1,      'APPROVE',  7,  '2025-04-12 12:00:00', 'Radiology HOD confirmed. Technician is qualified.',                                                                            'PENDING',      'IN_PROGRESS'),
    ('WF-ONCALL-V1',       'ONCALL',                 602,     2,      'APPROVE',  2,  '2025-04-13 09:30:00', 'CMO approved. On-call duty authorized.',                                                                                       'IN_PROGRESS',  'APPROVED')

) AS v(WorkflowCode, ModuleCode, ReferenceTransactionId, StepNo, ActionCode, ActionBy, ActionAt, Remarks, FromStatusCode, ToStatusCode);
GO
PRINT 'Workflow schema seed data inserted successfully.';
GO