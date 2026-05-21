-- SEED DATA

-- SEED 1  -  Business Modules
INSERT INTO auth.BusinessModule (ModuleCode, ModuleName, Description, CreatedBy) VALUES
('EMPLOYEE',    'Employee',             'Core employee profile and org structure',      1),
('ATTENDANCE',  'Attendance',           'Leave, shifts, roster, attendance tracking',   1),
('PAYROLL',     'Payroll',              'Salary, disbursement, tax, salary slips',       1),
('HR',          'HR',                   'Recruitment, onboarding, performance, exit',    1),
('HELPDESK',    'Helpdesk',             'IT tickets, assets, software licences',         1),
('WORKFLOW',    'Workflow',             'Cross-module approval workflow engine',          1),
('ADMIN',       'Administration',       'System configuration, roles, lookups',          1);
GO

-- SEED 2  -  Business Entities

-- EMPLOYEE module
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'Employee',              'Employee Profile',          1 FROM auth.BusinessModule WHERE ModuleCode = 'EMPLOYEE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'EmployeeDocument',      'Employee Document',         1 FROM auth.BusinessModule WHERE ModuleCode = 'EMPLOYEE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'EmployeeRelationship',  'Reporting Relationship',    1 FROM auth.BusinessModule WHERE ModuleCode = 'EMPLOYEE';

-- ATTENDANCE module
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'LeaveRequest',              'Leave Request',                 1 FROM auth.BusinessModule WHERE ModuleCode = 'ATTENDANCE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'LeaveBalance',              'Leave Balance',                 1 FROM auth.BusinessModule WHERE ModuleCode = 'ATTENDANCE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'AttendanceRecord',          'Attendance Record',             1 FROM auth.BusinessModule WHERE ModuleCode = 'ATTENDANCE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'AttendanceRegularization',  'Attendance Regularization',     1 FROM auth.BusinessModule WHERE ModuleCode = 'ATTENDANCE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'ShiftSwapRequest',          'Shift Swap Request',            1 FROM auth.BusinessModule WHERE ModuleCode = 'ATTENDANCE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'CompOffBalance',            'Comp-Off Balance',              1 FROM auth.BusinessModule WHERE ModuleCode = 'ATTENDANCE';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'HolidayCalendar',           'Holiday Calendar',              1 FROM auth.BusinessModule WHERE ModuleCode = 'ATTENDANCE';

-- PAYROLL module
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'SalaryRecord',          'Salary Record',             1 FROM auth.BusinessModule WHERE ModuleCode = 'PAYROLL';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'SalarySlip',            'Salary Slip',               1 FROM auth.BusinessModule WHERE ModuleCode = 'PAYROLL';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'PayrollDisbursement',   'Payroll Disbursement',      1 FROM auth.BusinessModule WHERE ModuleCode = 'PAYROLL';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'TaxDeclaration',        'Tax Declaration',           1 FROM auth.BusinessModule WHERE ModuleCode = 'PAYROLL';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'BankAccount',           'Bank Account',              1 FROM auth.BusinessModule WHERE ModuleCode = 'PAYROLL';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'SalaryStructure',       'Salary Structure',          1 FROM auth.BusinessModule WHERE ModuleCode = 'PAYROLL';

-- HR module
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'JobPosting',            'Job Posting',               1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'JobApplication',        'Job Application',           1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'Interview',             'Interview',                 1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'OfferLetter',           'Offer Letter',              1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'OnboardingTask',        'Onboarding Task',           1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'DocumentVerification',  'Document Verification',     1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'BackgroundVerification','Background Verification',   1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'PolicyDocument',        'Policy Document',           1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'PerformanceCycle',      'Performance Cycle',         1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'PerformanceReview',     'Performance Review',        1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'Goal',                  'Goal',                      1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'TrainingProgram',       'Training Program',          1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'ExitRecord',            'Exit Record',               1 FROM auth.BusinessModule WHERE ModuleCode = 'HR';

-- HELPDESK module
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'HelpdeskTicket',        'Helpdesk Ticket',           1 FROM auth.BusinessModule WHERE ModuleCode = 'HELPDESK';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'Asset',                 'Asset',                     1 FROM auth.BusinessModule WHERE ModuleCode = 'HELPDESK';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'SoftwareLicense',       'Software License',          1 FROM auth.BusinessModule WHERE ModuleCode = 'HELPDESK';

-- ADMIN module
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'RoleManagement',        'Role Management',           1 FROM auth.BusinessModule WHERE ModuleCode = 'ADMIN';
INSERT INTO auth.BusinessEntity (BusinessModuleId, EntityName, EntityLabel, CreatedBy)
SELECT Id, 'WorkflowConfig',        'Workflow Configuration',    1 FROM auth.BusinessModule WHERE ModuleCode = 'ADMIN';
GO

-- SEED 3  -  Entity Actions
INSERT INTO auth.EntityAction (ActionCode, CreatedBy) VALUES
('VIEW',              1),
('CREATE',            1),
('UPDATE',            1),
('DELETE',            1),
('APPROVE',           1),
('REJECT',            1),
('EXPORT',            1),
('ASSIGN',            1),
('VIEW_CONFIDENTIAL', 1);
GO

-- SEED 4  -  Permissions
-- Pattern: one READ permission (VIEW) + one WRITE permission bundle (CREATE+UPDATE+DELETE)
--          + APPROVAL where workflow applies + EXPORT for report-heavy entities.

-- Helper macro-style inserts grouped by entity
-- ATTENDANCE - LeaveRequest
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_REQUEST.VIEW',    'View Leave Request',
       be.Id, ea.Id, 'READ', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveRequest' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_REQUEST.CREATE',  'Apply Leave',
       be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveRequest' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_REQUEST.UPDATE',  'Edit Leave Request',
       be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveRequest' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_REQUEST.DELETE',  'Cancel Leave Request',
       be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveRequest' AND ea.ActionCode = 'DELETE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_REQUEST.APPROVE', 'Approve Leave Request',
       be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveRequest' AND ea.ActionCode = 'APPROVE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_REQUEST.REJECT',  'Reject Leave Request',
       be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveRequest' AND ea.ActionCode = 'REJECT';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_REQUEST.EXPORT',  'Export Leave Report',
       be.Id, ea.Id, 'EXPORT', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveRequest' AND ea.ActionCode = 'EXPORT';

-- ATTENDANCE - LeaveBalance
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'LEAVE_BALANCE.VIEW',    'View Leave Balance',
       be.Id, ea.Id, 'READ', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'LeaveBalance' AND ea.ActionCode = 'VIEW';

-- ATTENDANCE - AttendanceRecord
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ATTENDANCE_RECORD.VIEW',   'View Attendance',
       be.Id, ea.Id, 'READ', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'AttendanceRecord' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ATTENDANCE_RECORD.UPDATE', 'Edit Attendance Record',
       be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'AttendanceRecord' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ATTENDANCE_RECORD.EXPORT', 'Export Attendance Report',
       be.Id, ea.Id, 'EXPORT', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'AttendanceRecord' AND ea.ActionCode = 'EXPORT';

-- ATTENDANCE - AttendanceRegularization
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ATTENDANCE_REG.VIEW',    'View Attendance Regularization',
       be.Id, ea.Id, 'READ', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'AttendanceRegularization' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ATTENDANCE_REG.CREATE',  'Apply Attendance Regularization',
       be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'AttendanceRegularization' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ATTENDANCE_REG.APPROVE', 'Approve Attendance Regularization',
       be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'AttendanceRegularization' AND ea.ActionCode = 'APPROVE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ATTENDANCE_REG.REJECT',  'Reject Attendance Regularization',
       be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'AttendanceRegularization' AND ea.ActionCode = 'REJECT';

-- ATTENDANCE - ShiftSwapRequest
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SHIFT_SWAP.VIEW',    'View Shift Swap',
       be.Id, ea.Id, 'READ', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'ShiftSwapRequest' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SHIFT_SWAP.CREATE',  'Request Shift Swap',
       be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'ShiftSwapRequest' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SHIFT_SWAP.APPROVE', 'Approve Shift Swap',
       be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'ShiftSwapRequest' AND ea.ActionCode = 'APPROVE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SHIFT_SWAP.REJECT',  'Reject Shift Swap',
       be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'ShiftSwapRequest' AND ea.ActionCode = 'REJECT';

-- EMPLOYEE - Employee Profile
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EMPLOYEE.VIEW',   'View Employee Profile',  be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Employee' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EMPLOYEE.CREATE', 'Create Employee',        be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Employee' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EMPLOYEE.UPDATE', 'Edit Employee Profile',  be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Employee' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EMPLOYEE.EXPORT', 'Export Employee Data',   be.Id, ea.Id, 'EXPORT', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Employee' AND ea.ActionCode = 'EXPORT';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EMPLOYEE.VIEW_CONFIDENTIAL', 'View Confidential Employee Data',
       be.Id, ea.Id, 'ADMIN', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Employee' AND ea.ActionCode = 'VIEW_CONFIDENTIAL';

-- PAYROLL - SalaryRecord
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SALARY_RECORD.VIEW',   'View Salary Record',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'SalaryRecord' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SALARY_RECORD.UPDATE', 'Edit Salary Record',   be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'SalaryRecord' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SALARY_RECORD.VIEW_CONFIDENTIAL', 'View Confidential Salary Data',
       be.Id, ea.Id, 'ADMIN', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'SalaryRecord' AND ea.ActionCode = 'VIEW_CONFIDENTIAL';

-- PAYROLL - SalarySlip
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SALARY_SLIP.VIEW',   'View Salary Slip',   be.Id, ea.Id, 'READ',   1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'SalarySlip' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'SALARY_SLIP.EXPORT', 'Download Salary Slip',be.Id, ea.Id, 'EXPORT', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'SalarySlip' AND ea.ActionCode = 'EXPORT';

-- PAYROLL - PayrollDisbursement
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'PAYROLL_DISBURSEMENT.VIEW',    'View Payroll Disbursement',    be.Id, ea.Id, 'READ',     1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PayrollDisbursement' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'PAYROLL_DISBURSEMENT.CREATE',  'Create Payroll Disbursement',  be.Id, ea.Id, 'WRITE',    1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PayrollDisbursement' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'PAYROLL_DISBURSEMENT.APPROVE', 'Approve Payroll Disbursement', be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PayrollDisbursement' AND ea.ActionCode = 'APPROVE';

-- PAYROLL - TaxDeclaration
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'TAX_DECLARATION.VIEW',   'View Tax Declaration',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'TaxDeclaration' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'TAX_DECLARATION.CREATE', 'Submit Tax Declaration', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'TaxDeclaration' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'TAX_DECLARATION.APPROVE','Approve Tax Declaration', be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'TaxDeclaration' AND ea.ActionCode = 'APPROVE';

-- PAYROLL - BankAccount
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'BANK_ACCOUNT.VIEW',   'View Bank Account',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'BankAccount' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'BANK_ACCOUNT.UPDATE', 'Edit Bank Account',   be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'BankAccount' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'BANK_ACCOUNT.VIEW_CONFIDENTIAL', 'View Confidential Bank Data',
       be.Id, ea.Id, 'ADMIN', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'BankAccount' AND ea.ActionCode = 'VIEW_CONFIDENTIAL';

-- HR - JobPosting
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'JOB_POSTING.VIEW',   'View Job Posting',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'JobPosting' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'JOB_POSTING.CREATE', 'Create Job Posting', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'JobPosting' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'JOB_POSTING.UPDATE', 'Edit Job Posting',   be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'JobPosting' AND ea.ActionCode = 'UPDATE';

-- HR - JobApplication / Interview / OfferLetter
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'JOB_APPLICATION.VIEW',    'View Job Application',    be.Id, ea.Id, 'READ',     1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'JobApplication' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'JOB_APPLICATION.UPDATE',  'Update Application Status',be.Id, ea.Id, 'WRITE',    1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'JobApplication' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'INTERVIEW.VIEW',    'View Interview',     be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Interview' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'INTERVIEW.CREATE',  'Schedule Interview', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Interview' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'OFFER_LETTER.VIEW',   'View Offer Letter',  be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'OfferLetter' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'OFFER_LETTER.CREATE', 'Issue Offer Letter', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'OfferLetter' AND ea.ActionCode = 'CREATE';

-- HR - Onboarding
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ONBOARDING_TASK.VIEW',   'View Onboarding Task',     be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'OnboardingTask' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ONBOARDING_TASK.UPDATE', 'Complete Onboarding Task', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'OnboardingTask' AND ea.ActionCode = 'UPDATE';

-- HR - PerformanceReview
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'PERFORMANCE_REVIEW.VIEW',    'View Performance Review',    be.Id, ea.Id, 'READ',     1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PerformanceReview' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'PERFORMANCE_REVIEW.UPDATE',  'Submit Performance Review',  be.Id, ea.Id, 'WRITE',    1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PerformanceReview' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'PERFORMANCE_REVIEW.APPROVE', 'Approve Performance Review', be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PerformanceReview' AND ea.ActionCode = 'APPROVE';

-- HR - Goal
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'GOAL.VIEW',    'View Goal',    be.Id, ea.Id, 'READ',     1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Goal' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'GOAL.CREATE',  'Create Goal',  be.Id, ea.Id, 'WRITE',    1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Goal' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'GOAL.APPROVE', 'Approve Goal', be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Goal' AND ea.ActionCode = 'APPROVE';

-- HR - ExitRecord
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EXIT_RECORD.VIEW',    'View Exit Record',    be.Id, ea.Id, 'READ',     1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'ExitRecord' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EXIT_RECORD.CREATE',  'Initiate Exit',       be.Id, ea.Id, 'WRITE',    1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'ExitRecord' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'EXIT_RECORD.APPROVE', 'Approve Exit Record', be.Id, ea.Id, 'APPROVAL', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'ExitRecord' AND ea.ActionCode = 'APPROVE';

-- HR - Training
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'TRAINING_PROGRAM.VIEW',   'View Training Program',    be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'TrainingProgram' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'TRAINING_PROGRAM.CREATE', 'Create Training Program',  be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'TrainingProgram' AND ea.ActionCode = 'CREATE';

-- HR - Policy Document
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'POLICY_DOCUMENT.VIEW',   'View Policy Document',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PolicyDocument' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'POLICY_DOCUMENT.CREATE', 'Publish Policy Document',be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'PolicyDocument' AND ea.ActionCode = 'CREATE';

-- HELPDESK - HelpdeskTicket
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'HELPDESK_TICKET.VIEW',   'View Helpdesk Ticket',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'HelpdeskTicket' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'HELPDESK_TICKET.CREATE', 'Raise Helpdesk Ticket',  be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'HelpdeskTicket' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'HELPDESK_TICKET.UPDATE', 'Update Helpdesk Ticket', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'HelpdeskTicket' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'HELPDESK_TICKET.ASSIGN', 'Assign Helpdesk Ticket', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'HelpdeskTicket' AND ea.ActionCode = 'ASSIGN';

-- HELPDESK - Asset
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ASSET.VIEW',   'View Asset',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Asset' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ASSET.CREATE', 'Register Asset',be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Asset' AND ea.ActionCode = 'CREATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ASSET.UPDATE', 'Update Asset', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Asset' AND ea.ActionCode = 'UPDATE';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ASSET.ASSIGN', 'Assign Asset', be.Id, ea.Id, 'WRITE', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'Asset' AND ea.ActionCode = 'ASSIGN';

-- ADMIN - RoleManagement
INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ROLE_MANAGEMENT.VIEW',   'View Role Configuration',   be.Id, ea.Id, 'READ',  1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'RoleManagement' AND ea.ActionCode = 'VIEW';

INSERT INTO auth.Permission (PermissionCode, PermissionName, BusinessEntityId, EntityActionId, PermissionCategory, CreatedBy)
SELECT 'ROLE_MANAGEMENT.UPDATE', 'Manage Role Configuration', be.Id, ea.Id, 'ADMIN', 1
FROM auth.BusinessEntity be, auth.EntityAction ea
WHERE be.EntityName = 'RoleManagement' AND ea.ActionCode = 'UPDATE';
GO

-- SEED 5  -  Roles
-- Each Role is a cohesive, single-responsibility permission set.
INSERT INTO auth.Role (RoleCode, RoleName, Description, IsSystemRole, CreatedBy) VALUES
-- SYSTEM
('SUPER_ADMIN',             'Super Admin',                  'Full system access across all modules',          1, 1),
('EMPLOYEE_SELF_SERVICE',   'Employee Self Service',        'Own records only - every employee gets this',    1, 1),

-- EMPLOYEE module
('EMPLOYEE_VIEWER',         'Employee Viewer',              'Read-only access to employee profiles',          0, 1),
('EMPLOYEE_EDITOR',         'Employee Editor',              'Create and update employee records',             0, 1),

-- ATTENDANCE module
('LEAVE_VIEWER',            'Leave Viewer',                 'View leave requests and balances',               0, 1),
('LEAVE_EDITOR',            'Leave Editor',                 'Apply and edit leave requests',                  0, 1),
('LEAVE_APPROVER',          'Leave Approver',               'Approve and reject leave requests',              0, 1),
('ATTENDANCE_VIEWER',       'Attendance Viewer',            'View attendance records',                        0, 1),
('ATTENDANCE_EDITOR',       'Attendance Editor',            'Edit and regularize attendance',                 0, 1),
('ATTENDANCE_APPROVER',     'Attendance Approver',          'Approve attendance regularizations',             0, 1),
('SHIFT_MANAGER',           'Shift Manager',                'Manage shifts, swaps and rosters',               0, 1),

-- PAYROLL module
('PAYROLL_VIEWER',          'Payroll Viewer',               'Read-only payroll access',                       0, 1),
('PAYROLL_EDITOR',          'Payroll Editor',               'Manage salary structures and records',           0, 1),
('PAYROLL_APPROVER',        'Payroll Approver',             'Approve payroll disbursements',                  0, 1),
('TAX_ADMIN',               'Tax Admin',                    'Manage and approve tax declarations',            0, 1),
('SALARY_CONFIDENTIAL',     'Salary Confidential Viewer',   'View unmasked salary and bank details',          0, 1),

-- HR module
('RECRUITER',               'Recruiter',                    'Manage job postings, applications, interviews',  0, 1),
('ONBOARDING_ADMIN',        'Onboarding Admin',             'Manage onboarding tasks and verifications',      0, 1),
('HR_VIEWER',               'HR Viewer',                    'Read-only HR data access',                       0, 1),
('HR_EDITOR',               'HR Editor',                    'Full HR data management',                        0, 1),
('PERFORMANCE_ADMIN',       'Performance Admin',            'Manage performance cycles and reviews',          0, 1),
('PERFORMANCE_APPROVER',    'Performance Approver',         'Approve performance reviews and goals',          0, 1),
('TRAINING_ADMIN',          'Training Admin',               'Manage training programs and records',           0, 1),
('EXIT_ADMIN',              'Exit Admin',                   'Manage exit process and clearance',              0, 1),
('POLICY_ADMIN',            'Policy Admin',                 'Publish and manage policy documents',            0, 1),

-- HELPDESK module
('HELPDESK_AGENT',          'Helpdesk Agent',               'Handle and update helpdesk tickets',             0, 1),
('HELPDESK_MANAGER',        'Helpdesk Manager',             'Manage tickets, assets and assignments',         0, 1),
('ASSET_MANAGER',           'Asset Manager',                'Register, update and assign assets',             0, 1),

-- MANAGER (cross-module)
('PEOPLE_MANAGER',          'People Manager',               'View team data, approve leave and attendance',   0, 1),

-- ADMIN
('SYSTEM_CONFIG_ADMIN',     'System Config Admin',          'Manage roles, lookups and system configuration', 0, 1);
GO

-- SEED 6  -  Role Permissions
-- Map each role to its permissions.  DENY rows are added only where an explicit block is needed.

-- EMPLOYEE_SELF_SERVICE: own profile VIEW + own LEAVE / ATTENDANCE + salary slip
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'EMPLOYEE_SELF_SERVICE'
  AND p.PermissionCode IN (
      'EMPLOYEE.VIEW',
      'LEAVE_REQUEST.VIEW', 'LEAVE_REQUEST.CREATE', 'LEAVE_REQUEST.DELETE',
      'LEAVE_BALANCE.VIEW',
      'ATTENDANCE_RECORD.VIEW',
      'ATTENDANCE_REG.VIEW', 'ATTENDANCE_REG.CREATE',
      'SHIFT_SWAP.VIEW',     'SHIFT_SWAP.CREATE',
      'SALARY_SLIP.VIEW',    'SALARY_SLIP.EXPORT',
      'TAX_DECLARATION.VIEW','TAX_DECLARATION.CREATE',
      'BANK_ACCOUNT.VIEW',   'BANK_ACCOUNT.UPDATE',
      'PERFORMANCE_REVIEW.VIEW', 'GOAL.VIEW', 'GOAL.CREATE',
      'ONBOARDING_TASK.VIEW',
      'POLICY_DOCUMENT.VIEW',
      'TRAINING_PROGRAM.VIEW',
      'HELPDESK_TICKET.VIEW',    'HELPDESK_TICKET.CREATE'
  );

-- EMPLOYEE_VIEWER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'EMPLOYEE_VIEWER'
  AND p.PermissionCode IN ('EMPLOYEE.VIEW', 'EMPLOYEE.EXPORT');

-- EMPLOYEE_EDITOR
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'EMPLOYEE_EDITOR'
  AND p.PermissionCode IN ('EMPLOYEE.VIEW', 'EMPLOYEE.CREATE', 'EMPLOYEE.UPDATE', 'EMPLOYEE.EXPORT');

-- LEAVE_VIEWER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'LEAVE_VIEWER'
  AND p.PermissionCode IN ('LEAVE_REQUEST.VIEW', 'LEAVE_REQUEST.EXPORT', 'LEAVE_BALANCE.VIEW');

-- LEAVE_EDITOR
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'LEAVE_EDITOR'
  AND p.PermissionCode IN (
      'LEAVE_REQUEST.VIEW','LEAVE_REQUEST.CREATE','LEAVE_REQUEST.UPDATE',
      'LEAVE_REQUEST.DELETE','LEAVE_REQUEST.EXPORT','LEAVE_BALANCE.VIEW');

-- LEAVE_APPROVER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'LEAVE_APPROVER'
  AND p.PermissionCode IN (
      'LEAVE_REQUEST.VIEW','LEAVE_REQUEST.APPROVE','LEAVE_REQUEST.REJECT',
      'LEAVE_REQUEST.EXPORT','LEAVE_BALANCE.VIEW');

-- ATTENDANCE_VIEWER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'ATTENDANCE_VIEWER'
  AND p.PermissionCode IN (
      'ATTENDANCE_RECORD.VIEW','ATTENDANCE_RECORD.EXPORT','ATTENDANCE_REG.VIEW');

-- ATTENDANCE_EDITOR
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'ATTENDANCE_EDITOR'
  AND p.PermissionCode IN (
      'ATTENDANCE_RECORD.VIEW','ATTENDANCE_RECORD.UPDATE','ATTENDANCE_RECORD.EXPORT',
      'ATTENDANCE_REG.VIEW','ATTENDANCE_REG.CREATE');

-- ATTENDANCE_APPROVER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'ATTENDANCE_APPROVER'
  AND p.PermissionCode IN (
      'ATTENDANCE_RECORD.VIEW','ATTENDANCE_RECORD.EXPORT',
      'ATTENDANCE_REG.VIEW','ATTENDANCE_REG.APPROVE','ATTENDANCE_REG.REJECT');

-- SHIFT_MANAGER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'SHIFT_MANAGER'
  AND p.PermissionCode IN (
      'ATTENDANCE_RECORD.VIEW','SHIFT_SWAP.VIEW',
      'SHIFT_SWAP.APPROVE','SHIFT_SWAP.REJECT');

-- PAYROLL_VIEWER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'PAYROLL_VIEWER'
  AND p.PermissionCode IN (
      'SALARY_RECORD.VIEW','SALARY_SLIP.VIEW','SALARY_SLIP.EXPORT',
      'PAYROLL_DISBURSEMENT.VIEW');

-- PAYROLL_EDITOR
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'PAYROLL_EDITOR'
  AND p.PermissionCode IN (
      'SALARY_RECORD.VIEW','SALARY_RECORD.UPDATE',
      'SALARY_SLIP.VIEW','SALARY_SLIP.EXPORT',
      'PAYROLL_DISBURSEMENT.VIEW','PAYROLL_DISBURSEMENT.CREATE');

-- PAYROLL_APPROVER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'PAYROLL_APPROVER'
  AND p.PermissionCode IN (
      'PAYROLL_DISBURSEMENT.VIEW','PAYROLL_DISBURSEMENT.APPROVE',
      'SALARY_RECORD.VIEW','SALARY_SLIP.VIEW');

-- TAX_ADMIN
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'TAX_ADMIN'
  AND p.PermissionCode IN (
      'TAX_DECLARATION.VIEW','TAX_DECLARATION.APPROVE',
      'BANK_ACCOUNT.VIEW');

-- SALARY_CONFIDENTIAL
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'SALARY_CONFIDENTIAL'
  AND p.PermissionCode IN (
      'SALARY_RECORD.VIEW_CONFIDENTIAL',
      'BANK_ACCOUNT.VIEW_CONFIDENTIAL',
      'EMPLOYEE.VIEW_CONFIDENTIAL');

-- RECRUITER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'RECRUITER'
  AND p.PermissionCode IN (
      'JOB_POSTING.VIEW','JOB_POSTING.CREATE','JOB_POSTING.UPDATE',
      'JOB_APPLICATION.VIEW','JOB_APPLICATION.UPDATE',
      'INTERVIEW.VIEW','INTERVIEW.CREATE',
      'OFFER_LETTER.VIEW','OFFER_LETTER.CREATE',
      'EMPLOYEE.VIEW');

-- ONBOARDING_ADMIN
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'ONBOARDING_ADMIN'
  AND p.PermissionCode IN (
      'ONBOARDING_TASK.VIEW','ONBOARDING_TASK.UPDATE',
      'EMPLOYEE.VIEW','EMPLOYEE.CREATE');

-- HR_VIEWER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'HR_VIEWER'
  AND p.PermissionCode IN (
      'EMPLOYEE.VIEW','EMPLOYEE.EXPORT',
      'LEAVE_REQUEST.VIEW','LEAVE_BALANCE.VIEW',
      'ATTENDANCE_RECORD.VIEW',
      'PERFORMANCE_REVIEW.VIEW','GOAL.VIEW',
      'TRAINING_PROGRAM.VIEW',
      'EXIT_RECORD.VIEW',
      'POLICY_DOCUMENT.VIEW');

-- HR_EDITOR
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'HR_EDITOR'
  AND p.PermissionCode IN (
      'EMPLOYEE.VIEW','EMPLOYEE.CREATE','EMPLOYEE.UPDATE','EMPLOYEE.EXPORT',
      'LEAVE_REQUEST.VIEW','LEAVE_REQUEST.UPDATE',
      'ATTENDANCE_RECORD.VIEW','ATTENDANCE_RECORD.UPDATE',
      'PERFORMANCE_REVIEW.VIEW',
      'EXIT_RECORD.VIEW','EXIT_RECORD.CREATE',
      'POLICY_DOCUMENT.VIEW','POLICY_DOCUMENT.CREATE',
      'TRAINING_PROGRAM.VIEW','TRAINING_PROGRAM.CREATE');

-- PERFORMANCE_ADMIN
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'PERFORMANCE_ADMIN'
  AND p.PermissionCode IN (
      'PERFORMANCE_REVIEW.VIEW','PERFORMANCE_REVIEW.UPDATE',
      'GOAL.VIEW','GOAL.CREATE');

-- PERFORMANCE_APPROVER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'PERFORMANCE_APPROVER'
  AND p.PermissionCode IN (
      'PERFORMANCE_REVIEW.VIEW','PERFORMANCE_REVIEW.APPROVE',
      'GOAL.VIEW','GOAL.APPROVE');

-- TRAINING_ADMIN
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'TRAINING_ADMIN'
  AND p.PermissionCode IN (
      'TRAINING_PROGRAM.VIEW','TRAINING_PROGRAM.CREATE','EMPLOYEE.VIEW');

-- EXIT_ADMIN
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'EXIT_ADMIN'
  AND p.PermissionCode IN (
      'EXIT_RECORD.VIEW','EXIT_RECORD.CREATE','EXIT_RECORD.APPROVE','EMPLOYEE.VIEW');

-- POLICY_ADMIN
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'POLICY_ADMIN'
  AND p.PermissionCode IN ('POLICY_DOCUMENT.VIEW','POLICY_DOCUMENT.CREATE');

-- HELPDESK_AGENT
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'HELPDESK_AGENT'
  AND p.PermissionCode IN (
      'HELPDESK_TICKET.VIEW','HELPDESK_TICKET.UPDATE','ASSET.VIEW');

-- HELPDESK_MANAGER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'HELPDESK_MANAGER'
  AND p.PermissionCode IN (
      'HELPDESK_TICKET.VIEW','HELPDESK_TICKET.UPDATE','HELPDESK_TICKET.ASSIGN',
      'ASSET.VIEW','ASSET.CREATE','ASSET.UPDATE','ASSET.ASSIGN');

-- ASSET_MANAGER
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'ASSET_MANAGER'
  AND p.PermissionCode IN (
      'ASSET.VIEW','ASSET.CREATE','ASSET.UPDATE','ASSET.ASSIGN',
      'HELPDESK_TICKET.VIEW');

-- PEOPLE_MANAGER (cross-module: team lead / line manager)
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'PEOPLE_MANAGER'
  AND p.PermissionCode IN (
      'EMPLOYEE.VIEW',
      'LEAVE_REQUEST.VIEW','LEAVE_REQUEST.APPROVE','LEAVE_REQUEST.REJECT',
      'LEAVE_BALANCE.VIEW',
      'ATTENDANCE_RECORD.VIEW','ATTENDANCE_RECORD.EXPORT',
      'ATTENDANCE_REG.VIEW','ATTENDANCE_REG.APPROVE','ATTENDANCE_REG.REJECT',
      'SHIFT_SWAP.VIEW','SHIFT_SWAP.APPROVE','SHIFT_SWAP.REJECT',
      'PERFORMANCE_REVIEW.VIEW','PERFORMANCE_REVIEW.UPDATE','PERFORMANCE_REVIEW.APPROVE',
      'GOAL.VIEW','GOAL.APPROVE',
      'TRAINING_PROGRAM.VIEW');

-- SYSTEM_CONFIG_ADMIN
INSERT INTO auth.RolePermission (RoleId, PermissionId, Effect, CreatedBy)
SELECT r.Id, p.Id, 'ALLOW', 1
FROM auth.Role r, auth.Permission p
WHERE r.RoleCode = 'SYSTEM_CONFIG_ADMIN'
  AND p.PermissionCode IN (
      'ROLE_MANAGEMENT.VIEW','ROLE_MANAGEMENT.UPDATE');
GO

-- SEED 7  -  RoleGroups  (business-function + department bundles)
INSERT INTO auth.RoleGroup (RoleGroupCode, RoleGroupName, Description, CreatedBy) VALUES
-- Core HR
('HR_OPERATIONS',         'HR Operations',              'Day-to-day HR administration - employee records, leave, attendance',    1),
('HR_MANAGER',            'HR Manager',                 'Full HR management including confidential data and approvals',          1),
('RECRUITMENT_TEAM',      'Recruitment Team',           'Talent acquisition: job postings, interviews, offers',                  1),
('ONBOARDING_TEAM',       'Onboarding Team',            'New-hire onboarding tasks and document verification',                   1),
('HR_BUSINESS_PARTNER',   'HR Business Partner',        'Strategic HR: performance, training, exit, policy',                    1),

-- Payroll & Finance
('PAYROLL_OPERATIONS',    'Payroll Operations',         'Payroll processing, salary structures, disbursements',                  1),
('PAYROLL_CONTROLLER',    'Payroll Controller',         'Payroll approval and confidential salary data access',                  1),
('FINANCE_TAX',           'Finance & Tax',              'Tax declaration review, approval and compliance',                       1),

-- People Management
('PEOPLE_MANAGER',        'People Manager',             'Line manager: approve leave, attendance, review performance',           1),
('SENIOR_MANAGER',        'Senior Manager',             'Senior management with broader team visibility',                        1),

-- IT & Helpdesk
('HELPDESK_SUPPORT',      'Helpdesk Support',           'Handle IT support tickets',                                            1),
('IT_OPERATIONS',         'IT Operations',              'Manage IT assets, software licences and helpdesk team',                1),

-- Employee Self-Service
('EMPLOYEE',              'Employee',                   'Base group for all employees - self-service access only',               1),

-- Executive & Audit
('EXECUTIVE',             'Executive',                  'Senior leadership with read-only cross-module visibility',              1),
('SYSTEM_ADMINISTRATOR',  'System Administrator',       'System configuration, roles and master data management',               1);
GO

-- SEED 8  -  RoleGroup - Role mappings
-- SEED 8  -  RoleGroup - Role mappings  (CORRECTED)
INSERT INTO auth.RoleGroupRole (RoleGroupId, RoleId, CreatedBy)
SELECT rg.Id, r.Id, 1
FROM auth.RoleGroup rg
CROSS JOIN auth.Role r
WHERE
  (rg.RoleGroupCode = 'EMPLOYEE'               AND r.RoleCode IN ('EMPLOYEE_SELF_SERVICE'))
  OR (rg.RoleGroupCode = 'HR_OPERATIONS'       AND r.RoleCode IN (
        'EMPLOYEE_VIEWER','EMPLOYEE_EDITOR',
        'LEAVE_VIEWER','LEAVE_EDITOR',
        'ATTENDANCE_VIEWER','ATTENDANCE_EDITOR',
        'HR_VIEWER'))
  OR (rg.RoleGroupCode = 'HR_MANAGER'          AND r.RoleCode IN (
        'EMPLOYEE_VIEWER','EMPLOYEE_EDITOR',
        'HR_VIEWER','HR_EDITOR',
        'LEAVE_APPROVER','ATTENDANCE_APPROVER',
        'POLICY_ADMIN','PERFORMANCE_ADMIN',
        'EXIT_ADMIN'))
  OR (rg.RoleGroupCode = 'RECRUITMENT_TEAM'    AND r.RoleCode IN (
        'EMPLOYEE_VIEWER','RECRUITER'))
  OR (rg.RoleGroupCode = 'ONBOARDING_TEAM'     AND r.RoleCode IN (
        'EMPLOYEE_VIEWER','ONBOARDING_ADMIN'))
  OR (rg.RoleGroupCode = 'HR_BUSINESS_PARTNER' AND r.RoleCode IN (
        'HR_VIEWER','HR_EDITOR',
        'PERFORMANCE_ADMIN','PERFORMANCE_APPROVER',
        'TRAINING_ADMIN','EXIT_ADMIN',
        'POLICY_ADMIN'))
  OR (rg.RoleGroupCode = 'PAYROLL_OPERATIONS'  AND r.RoleCode IN (
        'PAYROLL_VIEWER','PAYROLL_EDITOR',
        'TAX_ADMIN','EMPLOYEE_VIEWER'))
  OR (rg.RoleGroupCode = 'PAYROLL_CONTROLLER'  AND r.RoleCode IN (
        'PAYROLL_VIEWER','PAYROLL_APPROVER',
        'SALARY_CONFIDENTIAL','TAX_ADMIN'))
  OR (rg.RoleGroupCode = 'FINANCE_TAX'         AND r.RoleCode IN (
        'TAX_ADMIN','PAYROLL_VIEWER'))
  OR (rg.RoleGroupCode = 'PEOPLE_MANAGER'      AND r.RoleCode IN (
        'EMPLOYEE_SELF_SERVICE','PEOPLE_MANAGER',
        'LEAVE_APPROVER','ATTENDANCE_APPROVER',
        'PERFORMANCE_APPROVER','SHIFT_MANAGER'))
  OR (rg.RoleGroupCode = 'SENIOR_MANAGER'      AND r.RoleCode IN (
        'EMPLOYEE_SELF_SERVICE','PEOPLE_MANAGER',
        'LEAVE_APPROVER','ATTENDANCE_APPROVER',
        'PERFORMANCE_APPROVER','HR_VIEWER',
        'PAYROLL_VIEWER'))
  OR (rg.RoleGroupCode = 'HELPDESK_SUPPORT'    AND r.RoleCode IN (
        'EMPLOYEE_SELF_SERVICE','HELPDESK_AGENT'))
  OR (rg.RoleGroupCode = 'IT_OPERATIONS'       AND r.RoleCode IN (
        'EMPLOYEE_SELF_SERVICE','HELPDESK_MANAGER','ASSET_MANAGER'))
  OR (rg.RoleGroupCode = 'EXECUTIVE'           AND r.RoleCode IN (
        'EMPLOYEE_SELF_SERVICE','EMPLOYEE_VIEWER',
        'HR_VIEWER','PAYROLL_VIEWER',
        'ATTENDANCE_VIEWER','LEAVE_VIEWER'))
  OR (rg.RoleGroupCode = 'SYSTEM_ADMINISTRATOR' AND r.RoleCode IN (
        -- Removed 'ROLE_MANAGEMENT.VIEW' - that is a PermissionCode, not a RoleCode.
        -- SYSTEM_CONFIG_ADMIN role already carries ROLE_MANAGEMENT.VIEW permission.
        'EMPLOYEE_SELF_SERVICE','SYSTEM_CONFIG_ADMIN','HR_VIEWER'));
GO

-- SEED 9  -  Confidential Fields
-- Defined using (EntityName, FieldName) - both logical, decoupled from DB schema.
-- By default ALL other fields are unmasked; only fields listed here are subject to masking.
INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'Employee', 'PANNumber',      'PAN Number',          'PARTIAL_MASK', 'XXXXX####X', 4, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'Employee';
INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'Employee', 'AadhaarNumber',  'Aadhaar Number',      'PARTIAL_MASK', 'XXXX-XXXX-####', 5, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'Employee';
INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'Employee', 'PassportNumber', 'Passport Number',     'FULL_MASK',    NULL, 3, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'Employee';
INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'Employee', 'DateOfBirth',    'Date of Birth',       'REDACT',       NULL, 2, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'Employee';

INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'SalaryRecord', 'AnnualCTC',  'Annual CTC',          'REDACT',       NULL, 4, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'SalaryRecord';
INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'SalaryRecord', 'MonthlyCTC', 'Monthly CTC',         'REDACT',       NULL, 4, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'SalaryRecord';
INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'SalaryRecord', 'MonthlyNet', 'Net Monthly Pay',     'REDACT',       NULL, 4, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'SalaryRecord';

INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'BankAccount', 'AccountNumber',   'Bank Account Number', 'PARTIAL_MASK','XXXXXXX{last4}', 5, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'BankAccount';
INSERT INTO auth.ConfidentialField
    (BusinessEntityId, EntityName, FieldName, FieldLabel, DefaultMaskType, MaskPattern, SensitivityLevel, CreatedBy)
SELECT be.Id, 'BankAccount', 'IFSCCode',        'IFSC Code',           'PARTIAL_MASK','XXXXXXXX{last4}',3, 1 FROM auth.BusinessEntity be WHERE be.EntityName = 'BankAccount';
GO

-- SEED 10  -  Confidential Access Policies  (who can bypass masking)

-- SALARY_CONFIDENTIAL role - bypass salary and bank masking
INSERT INTO auth.ConfidentialAccessPolicy (ConfidentialFieldId, GranteeRoleId, Effect, CreatedBy)
SELECT cf.Id, r.Id, 'ALLOW', 1
FROM auth.ConfidentialField cf
CROSS JOIN auth.Role r
WHERE r.RoleCode = 'SALARY_CONFIDENTIAL'
  AND cf.EntityName IN ('SalaryRecord', 'BankAccount');

-- HR_EDITOR role - bypass Employee identity fields (PAN, Aadhaar, DOB, Passport)
INSERT INTO auth.ConfidentialAccessPolicy (ConfidentialFieldId, GranteeRoleId, Effect, CreatedBy)
SELECT cf.Id, r.Id, 'ALLOW', 1
FROM auth.ConfidentialField cf
CROSS JOIN auth.Role r
WHERE r.RoleCode = 'HR_EDITOR'
  AND cf.EntityName = 'Employee';

-- SUPER_ADMIN - bypass all confidential fields
INSERT INTO auth.ConfidentialAccessPolicy (ConfidentialFieldId, GranteeRoleId, Effect, CreatedBy)
SELECT cf.Id, r.Id, 'ALLOW', 1
FROM auth.ConfidentialField cf
CROSS JOIN auth.Role r
WHERE r.RoleCode = 'SUPER_ADMIN';
GO

-- SEED 11  -  Record Access Policies  (RLS defaults per role)
-- Each policy declares the broadest scope a role can see for a given entity.
-- RecordAccessScope rows further narrow this to specific ScopeType / ScopeReferenceId values.

-- EMPLOYEE_SELF_SERVICE: EMPLOYEE scope (own records only)
INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'EMPLOYEE', 'ALLOW',
       'Employees see only their own records', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode = 'EMPLOYEE_SELF_SERVICE';

-- PEOPLE_MANAGER: TEAM scope
INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'TEAM', 'ALLOW',
       'Managers see records of their direct team', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode = 'PEOPLE_MANAGER'
  AND be.EntityName IN (
      'LeaveRequest','LeaveBalance','AttendanceRecord',
      'AttendanceRegularization','ShiftSwapRequest',
      'PerformanceReview','Goal','Employee');

-- HR_VIEWER / HR_EDITOR / HR_EDITOR: GLOBAL
INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'GLOBAL', 'ALLOW',
       'HR staff see all employee records globally', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode IN ('HR_VIEWER','HR_EDITOR')
  AND be.EntityName IN (
      'Employee','LeaveRequest','LeaveBalance',
      'AttendanceRecord','PerformanceReview','Goal','ExitRecord');

-- PAYROLL_EDITOR / PAYROLL_VIEWER: LEGAL_ENTITY scope
INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'LEGAL_ENTITY', 'ALLOW',
       'Payroll team scoped to assigned legal entity', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode IN ('PAYROLL_EDITOR','PAYROLL_VIEWER','PAYROLL_APPROVER','PAYROLL_CONTROLLER')
  AND be.EntityName IN (
      'SalaryRecord','SalarySlip','PayrollDisbursement','TaxDeclaration','BankAccount');

-- LEAVE_APPROVER: DEPARTMENT scope
INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'DEPARTMENT', 'ALLOW',
       'Leave approvers see requests within their department', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode = 'LEAVE_APPROVER'
  AND be.EntityName IN ('LeaveRequest','LeaveBalance');

-- RECRUITER: GLOBAL (own job postings / applications)
INSERT INTO auth.RecordAccessPolicy
    (RoleId, BusinessEntityId, AccessScope, Effect, ConditionJson, Description, CreatedBy)
SELECT r.Id, be.Id, 'GLOBAL', 'ALLOW',
       '{"conditions":[{"attribute":"PostedByEmployeeId","operator":"EQUALS","value":"$user.employeeId"}]}',
       'Recruiter sees only job postings they created', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode = 'RECRUITER'
  AND be.EntityName = 'JobPosting';

INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'GLOBAL', 'ALLOW',
       'Recruiter sees applications for their job postings', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode = 'RECRUITER'
  AND be.EntityName IN ('JobApplication','Interview','OfferLetter');

-- HELPDESK_AGENT: own tickets scope
INSERT INTO auth.RecordAccessPolicy
    (RoleId, BusinessEntityId, AccessScope, Effect, ConditionJson, Description, CreatedBy)
SELECT r.Id, be.Id, 'GLOBAL', 'ALLOW',
       '{"conditions":[{"attribute":"AssignedToEmployeeId","operator":"EQUALS","value":"$user.employeeId"}]}',
       'Helpdesk agents see only tickets assigned to them', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode = 'HELPDESK_AGENT'
  AND be.EntityName = 'HelpdeskTicket';

-- HELPDESK_MANAGER / ASSET_MANAGER: GLOBAL for helpdesk entities
INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'GLOBAL', 'ALLOW',
       'Helpdesk managers see all tickets and assets', 1
FROM auth.Role r, auth.BusinessEntity be
WHERE r.RoleCode IN ('HELPDESK_MANAGER','ASSET_MANAGER')
  AND be.EntityName IN ('HelpdeskTicket','Asset','SoftwareLicense');

-- SUPER_ADMIN: GLOBAL on everything
INSERT INTO auth.RecordAccessPolicy (RoleId, BusinessEntityId, AccessScope, Effect, Description, CreatedBy)
SELECT r.Id, be.Id, 'GLOBAL', 'ALLOW',
       'Super Admin has global access to all entities', 1
FROM auth.Role r
CROSS JOIN auth.BusinessEntity be
WHERE r.RoleCode = 'SUPER_ADMIN';

PRINT 'Auth schema seed data inserted successfully.';