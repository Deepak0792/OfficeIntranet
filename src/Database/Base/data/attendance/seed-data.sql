
-- EMPLOYEE SCHEMA - Seed Data
-- Organization: MedCare India Pvt. Ltd. (India)
-- Dependencies: shared, employee, time

-- MODULE 1: ATTENDANCE CORE DATA

-- LEAVE MANAGEMENT

PRINT 'Inserting LeaveType...';
INSERT INTO attendance.LeaveType (Id, LeaveCode, LeaveName, IsPaid, MaxDaysPerYear, AllowCarryForward, RequiresApproval, AllowHalfDay) VALUES
(NEWID(), 'CL',      'Casual Leave',                         1, 12.00, 0, 1, 1),
(NEWID(), 'SL',      'Sick Leave',                           1, 12.00, 0, 1, 1),
(NEWID(), 'EL',      'Earned Leave / Privilege Leave',       1, 18.00, 1, 1, 1),
(NEWID(), 'ML',      'Maternity Leave',                      1, 182.00,0, 1, 0),
(NEWID(), 'PL',      'Paternity Leave',                      1, 15.00, 0, 1, 0),
(NEWID(), 'OL',      'Optional / Restricted Holiday Leave',  0, 2.00,  0, 1, 1),
(NEWID(), 'LWP',     'Leave Without Pay',                    0, NULL,  0, 1, 0),
(NEWID(), 'COMPOFF', 'Compensatory Off Leave',               1, NULL,  0, 1, 1),
(NEWID(), 'BL',      'Bereavement Leave',                    1, 5.00,  0, 1, 0),
(NEWID(), 'STUDYLEAVE','Study / Exam Leave',                 1, 5.00,  0, 1, 0);


PRINT 'Inserting LeaveBalance (2025)...';
INSERT INTO attendance.LeaveBalance (Id, EmployeeId, LeaveTypeId, BalanceYear, OpeningBalance, Allocated, Availed, Encashed, CarryForward, LastUpdatedAt) VALUES
-- EMP001 CMO
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='EL'),  2025, 5.00, 18.00, 0.00,  0.00, 5.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
-- EMP009 Resident
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='EL'),  2025, 0.00, 18.00, 0.00,  0.00, 0.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 3.00,  0.00, 0.00, GETUTCDATE()),
-- EMP010 Senior ICU Nurse
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='EL'),  2025, 3.00, 18.00, 0.00,  0.00, 3.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
-- EMP011 Staff Nurse
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='EL'),  2025, 0.00, 18.00, 0.00,  0.00, 0.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 1.00,  0.00, 0.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
-- EMP005 HR Manager
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='EL'),  2025, 7.00, 18.00, 0.00,  0.00, 7.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE());

PRINT 'Inserting LeaveRequest (samples)...';
INSERT INTO attendance.LeaveRequest (Id, EmployeeId, LeaveTypeId, LeaveStatus, FromDate, ToDate, TotalDays, IsHalfDay, Reason, ApprovedBy, ApprovedAt, CreatedAt) VALUES
-- EMP009 Resident took sick leave
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'),
 (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='SL'),
 'APPROVED',
 '2025-03-10', '2025-03-12', 3.00, 0, 'Viral fever', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), '2025-03-09 20:00:00', '2025-03-09 18:00:00'),
-- EMP011 Staff Nurse casual leave
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'),
 (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='CL'),
 'APPROVED',
 '2025-04-14', '2025-04-14', 1.00, 0, 'Personal work', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), '2025-04-11 10:00:00', '2025-04-10 14:00:00'),
-- EMP028 Nurse - Maternity leave
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'),
 (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='ML'),
 'APPROVED',
 '2025-05-01', '2025-10-30', 183.00, 0, 'Maternity leave', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), '2025-04-20 11:00:00', '2025-04-15 09:00:00'),
-- EMP013 Pharmacist - Earned leave
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'),
 (SELECT Id FROM attendance.LeaveType WHERE LeaveCode='EL'),
 'PENDING',
 '2025-05-20', '2025-05-24', 5.00, 0, 'Family vacation', NULL, NULL, '2025-05-08 10:00:00');

-- COMP-OFF

PRINT 'Inserting CompOffType...';
INSERT INTO attendance.CompOffType (Id, CompOffTypeCode, CompOffTypeName, ExpiryDays) VALUES
(NEWID(), 'CO-WEEKENDDUTY',  'Weekend Duty Comp-Off',            90),
(NEWID(), 'CO-HOLIDAYDUTY',  'Holiday Duty Comp-Off',            90),
(NEWID(), 'CO-OVERTIME',     'Overtime Comp-Off',                60),
(NEWID(), 'CO-EMERGENCYDUTY','Emergency Call Duty Comp-Off',     45);

PRINT 'Inserting CompOffBalance (samples)...';
INSERT INTO attendance.CompOffBalance (Id, EmployeeId, CompOffTypeId, EarnedDate, ExpiryDate, TotalDays, AvailedDays, AttendanceRecordId) VALUES
-- EMP010 ICU Nurse worked weekend
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'),
 (SELECT Id FROM attendance.CompOffType WHERE CompOffTypeCode='CO-WEEKENDDUTY'),
 '2025-03-29', '2025-06-27', 1.00, 0.00,
 (SELECT Id FROM attendance.AttendanceRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010') AND AttendanceDate='2025-04-01')),
-- EMP020 Emergency Physician - Holiday duty
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'),
 (SELECT Id FROM attendance.CompOffType WHERE CompOffTypeCode='CO-HOLIDAYDUTY'),
 '2025-01-26', '2025-04-26', 1.00, 0.00, NULL);

 
-- WORK WEEK POLICY

PRINT 'Inserting WorkWeekPolicy...';
INSERT INTO attendance.WorkWeekPolicy (Id, PolicyCode, PolicyName, Description, IsDefault) VALUES
(NEWID(), 'WWP-ADMIN-INDIA',     'Standard 5-Day Work Week (Mon-Fri)', 'Administrative staff: Monday to Friday, 9AM-6PM', 1),
(NEWID(), 'WWP-CLINICAL-6DAY',   'Clinical 6-Day Work Week (Mon-Sat)', 'Clinical staff: 6 days rotating schedule', 0),
(NEWID(), 'WWP-NURSING-SHIFT',   'Nursing Rotating Shift Policy',       'Nursing staff: rotating 8-hour shifts 7 days', 0),
(NEWID(), 'WWP-EMERGENCY-7DAY',  'Emergency 7-Day Policy',             'Emergency dept: 7 days, 3-shift rotation', 0);

-- Mon-Fri Admin (480 min = 8h, with 1h break means 9AM-6PM)
PRINT 'Inserting WorkWeekPolicyDay - Admin Mon-Fri...';
INSERT INTO attendance.WorkWeekPolicyDay (Id, WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 0, 0, NULL,  0), -- Sunday off
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 1, 1, 480,   0), -- Monday
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 2, 1, 480,   0), -- Tuesday
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 3, 1, 480,   0), -- Wednesday
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 4, 1, 480,   0), -- Thursday
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 5, 1, 480,   0), -- Friday
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 6, 0, NULL,  0); -- Saturday off

-- Mon-Sat Clinical 6-day
INSERT INTO attendance.WorkWeekPolicyDay (Id, WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 0, 0, NULL, 0), -- Sunday off
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 1, 1, 480,  0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 2, 1, 480,  0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 3, 1, 480,  0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 4, 1, 480,  0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 5, 1, 480,  0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 6, 1, 240,  1); -- Saturday half-day

-- Nursing 7-day (8h shifts, roster-driven off)
INSERT INTO attendance.WorkWeekPolicyDay (Id, WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 0, 1, 480, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 1, 1, 480, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 2, 1, 480, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 3, 1, 480, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 4, 1, 480, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 5, 1, 480, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 6, 1, 480, 0);

-- Emergency 7-day
INSERT INTO attendance.WorkWeekPolicyDay (Id, WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 0, 1, 720, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 1, 1, 720, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 2, 1, 720, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 3, 1, 720, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 4, 1, 720, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 5, 1, 720, 0),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 6, 1, 720, 0);


PRINT 'Inserting WorkWeekPolicyAssignment...';
-- Global default: Admin policy
INSERT INTO attendance.WorkWeekPolicyAssignment (Id, WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), '2012-01-01', 1);

-- Clinical departments - 6-day
INSERT INTO attendance.WorkWeekPolicyAssignment (Id, WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'), '2012-01-01', 2),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'), '2012-01-01', 2),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='ONCOLOGY'), '2012-01-01', 2);

-- Nursing - Shift policy
INSERT INTO attendance.WorkWeekPolicyAssignment (Id, WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'), '2012-01-01', 3),
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='ICU'), '2012-01-01', 3);

-- Emergency - 7-day
INSERT INTO attendance.WorkWeekPolicyAssignment (Id, WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
(NEWID(), (SELECT Id FROM attendance.WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='EMERGENCY'), '2012-01-01', 4);

-- SHIFT MANAGEMENT

PRINT 'Inserting Shift...';
INSERT INTO attendance.Shift (Id, ShiftCode, ShiftName, StartTime, EndTime, BreakDurationMinutes, GraceInMinutes, GraceOutMinutes, MinimumWorkingMinutes, MaximumWorkingMinutes, AttendanceFinalizeBufferMinutes, MaxAllowedCheckoutDelayMinutes, IsNightShift, CrossesMidnight, IsFlexible, AllowOvertime) VALUES
-- General / Admin shift - IST 9:00-18:00 (standard Indian office hours)
(NEWID(), 'SHF-GEN',     'General Shift (9AM-6PM)',          '09:00', '18:00', 60, 15, 15, 420, 540, 240, 120, 0, 0, 0, 1),
-- Clinical morning shift - 08:00-14:00
(NEWID(), 'SHF-MORN',    'Morning Shift (8AM-2PM)',           '08:00', '14:00', 30, 10, 10, 330, 360, 240, 120, 0, 0, 0, 1),
-- Clinical afternoon/evening shift - 14:00-20:00
(NEWID(), 'SHF-AFT',     'Afternoon Shift (2PM-8PM)',        '14:00', '20:00', 30, 10, 10, 330, 360, 240, 120, 0, 0, 0, 1),
-- Night shift - 20:00-08:00 (crosses midnight)
(NEWID(), 'SHF-NIGHT',   'Night Shift (8PM-8AM)',            '20:00', '08:00', 60, 10, 10, 660, 720, 240, 120, 1, 1, 0, 1),
-- Emergency 12-hour Day - 08:00-20:00
(NEWID(), 'SHF-EMER-D',  'Emergency Day Shift (8AM-8PM)',     '08:00', '20:00', 60, 10, 10, 660, 720, 240, 120, 0, 0, 0, 1),
-- Emergency 12-hour Night - 20:00-08:00
(NEWID(), 'SHF-EMER-N',  'Emergency Night Shift (8PM-8AM)',   '20:00', '08:00', 60, 10, 10, 660, 720, 240, 120, 1, 1, 0, 1),
-- OPD Shift - 10:00-17:00 (Outpatient Departments)
(NEWID(), 'SHF-OPD',     'OPD Shift (10AM-5PM)',              '10:00', '17:00', 30, 15, 15, 360, 420, 240, 120, 0, 0, 0, 1),
-- Flexible IT/Admin - 10:00-19:00
(NEWID(), 'SHF-FLEX',    'Flexible Shift (10AM-7PM)',         '10:00', '19:00', 60, 30, 30, 420, 540, 240, 120, 1, 1, 0, 1);


PRINT 'Inserting ShiftSwapStatus...';
INSERT INTO attendance.ShiftSwapStatus (Id, StatusCode, StatusName) VALUES
(NEWID(), 'PENDING',     'Pending Approval'),
(NEWID(), 'APPROVED',    'Approved'),
(NEWID(), 'REJECTED',    'Rejected'),
(NEWID(), 'CANCELLED',   'Cancelled by Requester'),
(NEWID(), 'WITHDRAWN',   'Withdrawn by Target');


PRINT 'Inserting ShiftAssignment...';
-- Global default: General shift (admin/support/finance)
INSERT INTO attendance.ShiftAssignment (Id, ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='GLOBAL'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), '2012-01-01', 1, 1);

-- HR, Finance, Admin, IT - General / Flexible
INSERT INTO attendance.ShiftAssignment (Id, ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          '2012-01-01', 2, 1),
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='FINANCE'),     '2012-01-01', 2, 1),
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='ADMIN'),       '2012-01-01', 2, 1),
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-FLEX'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),          '2012-01-01', 2, 1);

-- Clinical/OPD - Morning shift as primary
INSERT INTO attendance.ShiftAssignment (Id, ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    '2012-01-01', 3, 1),
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  '2012-01-01', 3, 1),
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='ONCOLOGY'),    '2012-01-01', 3, 1),
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='NEUROLOGY'),   '2012-01-01', 3, 1),
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='PEDIATRICS'),  '2012-01-01', 3, 1);

-- Emergency - 12-hour day primary
INSERT INTO attendance.ShiftAssignment (Id, ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-EMER-D'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='EMERGENCY'),   '2012-01-01', 4, 1);

-- Pharmacy - Morning shift
INSERT INTO attendance.ShiftAssignment (Id, ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    '2012-01-01', 3, 1);

-- Individual overrides: Resident EMP009 works morning
INSERT INTO attendance.ShiftAssignment (Id, ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
(NEWID(), (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='EMPLOYEE'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), '2021-08-01', 5, 1);


-- ROTATION SHIFT

PRINT 'Inserting RotationShift...';
INSERT INTO attendance.RotationShift (Id, RotationCode, RotationName, CycleLengthDays) VALUES
(NEWID(), 'ROT-NURSING-3SHIFT',  'Nursing 3-Shift Rotation (19 days)',   19),
(NEWID(), 'ROT-EMER-12HR',       'Emergency 12-Hour 2-Shift Rotation',   6);

PRINT 'Inserting RotationShiftDetail...';
-- 5 Days Morning, 1 Day Off
-- 5 Days Afternoon, 1 Day Off
-- 5 Days Night, 2 Days Off
-- Total = 19 Days
INSERT INTO attendance.RotationShiftDetail (Id, RotationShiftId, SequenceNo, ShiftId, DurationDays, IsOffDay)
VALUES
-- 5 days morning, 1 day off
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), 1, (SELECT Id FROM attendance.Shift WHERE ShiftCode = 'SHF-MORN'), 5, 0 ),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), 2, NULL, 1, 1),
-- 5 days afternoon, 1 day off
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), 3, (SELECT Id FROM attendance.Shift WHERE ShiftCode = 'SHF-AFT'), 5, 0 ),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), 4, NULL, 1, 1),
-- 5 days night, 1 day off
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), 5, (SELECT Id FROM attendance.Shift WHERE ShiftCode = 'SHF-NIGHT'), 5, 0 ),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), 6, NULL, 2, 1);

-- Emergency: 2 days Day - 1 off - 2 days Night - 1 off
INSERT INTO attendance.RotationShiftDetail (Id, RotationShiftId, SequenceNo, ShiftId, DurationDays, IsOffDay) VALUES
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode='ROT-EMER-12HR'), 1, (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-EMER-D'), 2, 0),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode='ROT-EMER-12HR'), 2, NULL,                                                 1, 1),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode='ROT-EMER-12HR'), 3, (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-EMER-N'), 2, 0),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode='ROT-EMER-12HR'), 4, NULL,                                                 1, 1);


PRINT 'Inserting RotationShiftAssignment...';
-- Nursing dept - 3-shift rotation
INSERT INTO attendance.RotationShiftAssignment (Id, RotationShiftId, ScopeTypeId, ScopeReferenceId, RotationStartDate, EffectiveFrom, RotationOffsetDays)
VALUES
-- nursing department
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode = 'NURSING'), '2024-01-01', '2024-01-01', 0),
-- icu department
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode = 'ICU'), '2024-01-01', '2024-01-01', 0);

-- Emergency dept - 12-hr rotation
INSERT INTO attendance.RotationShiftAssignment (Id, RotationShiftId, ScopeTypeId, ScopeReferenceId, RotationStartDate, EffectiveFrom) VALUES
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode='ROT-EMER-12HR'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM time.Department WHERE DepartmentCode='EMERGENCY'), '2024-01-01', '2024-01-01');

-- EMPLOYEE-SPECIFIC STAGGERED ROTATIONS
-- This prevents all nurses from being OFF
-- on the same day.
-- Example for 9 nurses:
-- EMP001 → Offset 0
-- EMP002 → Offset 2
-- EMP003 → Offset 4
-- EMP004 → Offset 6
-- etc.
-- Example Employee Overrides
INSERT INTO attendance.RotationShiftAssignment
(Id, RotationShiftId, ScopeTypeId, ScopeReferenceId, RotationStartDate, EffectiveFrom, RotationOffsetDays)
VALUES (NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'EMPLOYEE'), (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP010'), '2024-01-01', '2024-01-01', 0),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'EMPLOYEE'), (SELECT Id FROM employee.Employee
WHERE EmployeeCode = 'EMP011'), '2024-01-01', '2024-01-01', 3),
(NEWID(), (SELECT Id FROM attendance.RotationShift WHERE RotationCode = 'ROT-NURSING-3SHIFT'), (SELECT Id FROM time.ScopeType WHERE ScopeCode = 'EMPLOYEE'), (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP012'), '2024-01-01', '2024-01-01', 6);


-- EMPLOYEE ROSTER (Sample - April 2025)
PRINT 'Inserting EmployeeShiftRoster (sample for 2025-04-01 to 2025-04-03)...';
INSERT INTO attendance.EmployeeShiftRoster (Id, EmployeeId, RosterDate, ShiftId, IsOffDay, IsHoliday, PlannedStartTime, PlannedEndTime) VALUES
-- EMP001 CMO - General shift
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2025-04-01', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-01 09:00:00', '2025-04-01 18:00:00'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2025-04-02', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-02 09:00:00', '2025-04-02 18:00:00'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2025-04-03', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-03 09:00:00', '2025-04-03 18:00:00'),
-- EMP010 ICU Senior Nurse - Morning shift
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), '2025-04-01', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-MORN'), 0, 0, '2025-04-01 07:00:00', '2025-04-01 15:00:00'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), '2025-04-02', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-AFT'),  0, 0, '2025-04-02 14:00:00', '2025-04-02 22:00:00'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), '2025-04-03', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-NIGHT'),0, 0, '2025-04-03 22:00:00', '2025-04-04 06:00:00'),
-- EMP020 Emergency Physician - 12-hr Day
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), '2025-04-01', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-EMER-D'),0, 0,'2025-04-01 08:00:00', '2025-04-01 20:00:00'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), '2025-04-02', NULL,                                                1, 0, NULL, NULL), -- Off day
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), '2025-04-03', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-EMER-N'),0, 0,'2025-04-03 20:00:00', '2025-04-04 08:00:00'),
-- EMP005 HR Manager - General shift
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2025-04-01', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-01 09:00:00', '2025-04-01 18:00:00'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2025-04-02', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-02 09:00:00', '2025-04-02 18:00:00'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2025-04-03', (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-03 09:00:00', '2025-04-03 18:00:00');


PRINT 'Inserting Roster Generation Types...';
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal) VALUES
('MONTHLY', 'ROSTER_GENERATION_TYPE', 'Monthly', 'Roster generated for complete month', 1, 0),
('WEEKLY',  'ROSTER_GENERATION_TYPE', 'Weekly',  'Roster generated for weekly duration', 2, 0),
('ADHOC',   'ROSTER_GENERATION_TYPE', 'Adhoc',   'Roster generated manually for specific employees or dates', 3, 0);

-- HOLIDAY MANAGEMENT

PRINT 'Inserting HolidayCalendar...';
INSERT INTO attendance.HolidayCalendar (Id, CalendarCode, CalendarName, Description, IsDefault) VALUES
(NEWID(), 'HC-INDIA-NATIONAL',   'India National Holidays',          'Public holidays applicable across India',           1),
(NEWID(), 'HC-MH-STATE',         'Maharashtra State Holidays',       'State-specific holidays for Maharashtra',           0),
(NEWID(), 'HC-DL-STATE',         'Delhi State Holidays',             'State-specific holidays for Delhi',                 0),
(NEWID(), 'HC-KA-STATE',         'Karnataka State Holidays',         'State-specific holidays for Karnataka',             0),
(NEWID(), 'HC-TN-STATE',         'Tamil Nadu State Holidays',        'State-specific holidays for Tamil Nadu',            0),
(NEWID(), 'HC-TS-STATE',         'Telangana State Holidays',         'State-specific holidays for Telangana',             0),
(NEWID(), 'HC-WB-STATE',         'West Bengal State Holidays',       'State-specific holidays for West Bengal',           0),
(NEWID(), 'HC-OPTIONAL',         'Optional / Restricted Holidays',   'Employees may choose from optional holiday list',   0);


PRINT 'Inserting HolidayType...';
INSERT INTO attendance.HolidayType (Id, HolidayTypeCode, HolidayTypeName, IsOptional) VALUES
(NEWID(), 'NATIONAL',    'National Holiday',         0),
(NEWID(), 'STATE',       'State Public Holiday',     0),
(NEWID(), 'RELIGIOUS',   'Religious Festival',       0),
(NEWID(), 'OPTIONAL',    'Optional / Restricted',    1);

PRINT 'Inserting Holiday (2025)...';
-- National Holidays
INSERT INTO attendance.Holiday (Id, HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring, ApplicableYear) VALUES
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-REPDAY',   'Republic Day',                     '2025-01-26', 0, 1, NULL),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-HOLI',     'Holi',                             '2025-03-14', 0, 1, NULL),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-UGADI',    'Ugadi / Gudi Padwa',               '2025-03-30', 0, 0, 2025),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-GOODFRI',  'Good Friday',                      '2025-04-18', 0, 0, 2025),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-AMBEDKAR', 'Dr. B.R. Ambedkar Jayanti',        '2025-04-14', 0, 1, NULL),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-LABDAY',   'Labour Day / May Day',             '2025-05-01', 0, 1, NULL),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-EID',      'Eid-ul-Fitr',                      '2025-03-31', 0, 0, 2025),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-INDEPDAY', 'Independence Day',                 '2025-08-15', 0, 1, NULL),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-JANMASHTAMI','Janmashtami',                   '2025-08-16', 0, 0, 2025),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-GANDHIJAY','Gandhi Jayanti',                   '2025-10-02', 0, 1, NULL),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-DUSSEHRA', 'Dussehra / Navratri',              '2025-10-02', 0, 0, 2025),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-DIWALI',   'Diwali (Lakshmi Puja)',            '2025-10-20', 0, 0, 2025),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-DIWALINEXT','Diwali Holiday',                  '2025-10-21', 0, 0, 2025),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-CHRISTMAS', 'Christmas Day',                   '2025-12-25', 0, 1, NULL);

-- Maharashtra-specific
INSERT INTO attendance.Holiday (Id, HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-MH-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-MH-DAY',    'Maharashtra Day',          '2025-05-01', 0, 1),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-MH-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-CHHATH',    'Chhath Puja',              '2025-10-28', 0, 0);

-- Karnataka-specific
INSERT INTO attendance.Holiday (Id, HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-KA-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-KA-RAJ',    'Karnataka Rajyotsava',     '2025-11-01', 0, 1);

-- Tamil Nadu-specific
INSERT INTO attendance.Holiday (Id, HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-TN-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-PONGAL',    'Pongal',                   '2025-01-14', 0, 1),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-TN-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-PONGAL2',   'Thiruvalluvar Day',        '2025-01-15', 0, 1);

-- West Bengal-specific
INSERT INTO attendance.Holiday (Id, HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-WB-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-DURGA',     'Durga Puja (Maha Ashtami)','2025-10-01', 0, 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-WB-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-DURGA2',    'Durga Puja (Navami)',      '2025-10-02', 0, 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-WB-STATE'), (SELECT Id FROM attendance.HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-DURGA3',    'Durga Puja (Dashami)',     '2025-10-03', 0, 0);


PRINT 'Inserting HolidayCalendarAssignment...';
-- National calendar - All offices globally
INSERT INTO attendance.HolidayCalendarAssignment (Id, HolidayCalendarId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, MergeStrategy, IsPrimary) VALUES
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='COUNTRY'), (SELECT Id FROM time.Country WHERE CountryCode='IN'), '2012-01-01', 1, 'MERGE', 1);

-- State calendars - specific offices
INSERT INTO attendance.HolidayCalendarAssignment (Id, HolidayCalendarId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, MergeStrategy, IsPrimary) VALUES
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-MH-STATE'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '2012-01-01', 2, 'MERGE', 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-MH-STATE'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), '2012-01-01', 2, 'MERGE', 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-DL-STATE'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), '2012-01-01', 2, 'MERGE', 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-KA-STATE'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), '2012-01-01', 2, 'MERGE', 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-TN-STATE'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), '2012-01-01', 2, 'MERGE', 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-TS-STATE'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), '2012-01-01', 2, 'MERGE', 0),
(NEWID(), (SELECT Id FROM attendance.HolidayCalendar WHERE CalendarCode='HC-WB-STATE'),
 (SELECT Id FROM time.ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), '2012-01-01', 2, 'MERGE', 0);


-- ATTENDANCE MANAGEMENT

PRINT 'Inserting AttendanceStatus...';
INSERT INTO attendance.AttendanceStatus (Id, StatusCode, StatusName, IsPresent, IsAbsent, IsPaid, CountsAsWorkingDay, DisplayOrder, IsSystemStatus) VALUES
(NEWID(), 'PRESENT',         'Present',                              1, 0, 1, 1, 1, 1),
(NEWID(), 'ABSENT',          'Absent',                               0, 1, 0, 0, 2, 1),
(NEWID(), 'ON_LEAVE',        'On Approved Leave',                    0, 0, 1, 0, 3, 1),
(NEWID(), 'WORK_FROM_HOME',  'Work From Home',                       1, 0, 1, 1, 4, 1),
(NEWID(), 'HALF_DAY',        'Half Day Present',                     1, 0, 1, 1, 5, 1),
(NEWID(), 'LATE',            'Late Arrival',                         1, 0, 1, 1, 6, 1),
(NEWID(), 'HOLIDAY',         'Public Holiday',                       0, 0, 1, 0, 7, 1),
(NEWID(), 'WEEKEND',         'Weekend / Off Day',                    0, 0, 0, 0, 8, 1),
(NEWID(), 'ON_DUTY',         'On Official Duty',                     1, 0, 1, 1, 9, 1),
(NEWID(), 'COMP_OFF',        'Compensatory Off',                     0, 0, 1, 0, 10, 1),
(NEWID(), 'REGULARIZED',     'Attendance Regularized',               1, 0, 1, 1, 11, 1);

PRINT 'Inserting AttendanceRecord (processed attendance)...';
INSERT INTO attendance.AttendanceRecord (Id, EmployeeId, AttendanceDate, ShiftId, AttendanceStatusId, CheckInTime, CheckOutTime, LateByMinutes, EarlyExitMinutes, WorkedMinutes, OvertimeMinutes, IsManualEntry) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2025-04-01',
 (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM attendance.AttendanceStatus WHERE StatusCode='PRESENT'),
 '2025-04-01 08:52:00', '2025-04-01 18:07:00', 0, 0, 495, 7, 0),

(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2025-04-01',
 (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM attendance.AttendanceStatus WHERE StatusCode='LATE'),
 '2025-04-01 09:11:00', '2025-04-01 18:03:00', 11, 0, 472, 0, 0),

(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), '2025-04-01',
 (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM attendance.AttendanceStatus WHERE StatusCode='PRESENT'),
 '2025-04-01 06:55:00', '2025-04-01 15:05:00', 0, 0, 490, 10, 0),

(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), '2025-04-01',
 (SELECT Id FROM attendance.Shift WHERE ShiftCode='SHF-EMER-D'),
 (SELECT Id FROM attendance.AttendanceStatus WHERE StatusCode='PRESENT'),
 '2025-04-01 07:52:00', '2025-04-01 20:10:00', 0, 0, 730, 10, 0);

PRINT 'Inserting AttendanceLog (sample biometric punches)...';
INSERT INTO attendance.AttendanceLog (Id, EmployeeId, PunchTime, PunchType, DeviceId, Location, IsProcessed) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2025-04-01 08:52:00', 'IN',  'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2025-04-01 18:07:00', 'OUT', 'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2025-04-01 09:11:00', 'IN',  'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2025-04-01 18:03:00', 'OUT', 'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), '2025-04-01 06:55:00', 'IN',  'BIO-MUM-02', 'Mumbai HQ - Ward Entrance', 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), '2025-04-01 15:05:00', 'OUT', 'BIO-MUM-02', 'Mumbai HQ - Ward Entrance', 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), '2025-04-01 07:52:00', 'IN',  'BIO-DEL-01', 'Delhi - Emergency Entrance', 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), '2025-04-01 20:10:00', 'OUT', 'BIO-DEL-01', 'Delhi - Emergency Entrance', 1);

PRINT 'Inserting MobileAttendanceLog (sample GPS punches)...';
INSERT INTO attendance.MobileAttendanceLog (Id, EmployeeId, GeoFenceId, PunchTime, Latitude, Longitude, IsInsideGeoFence, DeviceInfo) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 (SELECT Id FROM time.GeoFence WHERE GeoFenceCode='GEO-BLR-01'),
 '2025-04-01 09:58:00', 12.97162000, 77.59461000, 1, 'Samsung Galaxy S24 | Android 14'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 (SELECT Id FROM time.GeoFence WHERE GeoFenceCode='GEO-BLR-01'),
 '2025-04-01 19:02:00', 12.97161000, 77.59460000, 1, 'Samsung Galaxy S24 | Android 14'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM time.GeoFence WHERE GeoFenceCode='GEO-CHN-01'),
 '2025-04-01 09:05:00', 13.08275000, 80.27074000, 1, 'iPhone 15 | iOS 17'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM time.GeoFence WHERE GeoFenceCode='GEO-CHN-01'),
 '2025-04-01 18:00:00', 13.08270000, 80.27072000, 1, 'iPhone 15 | iOS 17');

PRINT 'Attendance core data inserted successfully.';
GO