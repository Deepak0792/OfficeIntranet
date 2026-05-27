-- ============================================================
-- WORKFLOW SEED DATA
-- Configurations for LeaveRequest, CompOffBalance, AttendanceRegularization,
-- ShiftSwapRequest, EmployeeDocument, EmployeeAddress.
-- ============================================================
SET IDENTITY_INSERT workflow.WorkflowModule ON;

-- Insert Modules
INSERT INTO workflow.WorkflowModule (Id, ModuleCode, ModuleName, EntityName) VALUES
(1, 'LEAVE_REQUEST', 'Leave Request', 'LeaveRequest'),
(2, 'COMP_OFF', 'Comp Off Balance', 'CompOffBalance'),
(3, 'ATTENDANCE_REG', 'Attendance Regularization', 'AttendanceRegularization'),
(4, 'SHIFT_SWAP', 'Shift Swap Request', 'ShiftSwapRequest'),
(5, 'EMP_DOCUMENT', 'Employee Document Verification', 'EmployeeDocument'),
(6, 'EMP_ADDRESS', 'Employee Address Verification', 'EmployeeAddress');

SET IDENTITY_INSERT workflow.WorkflowModule OFF;

SET IDENTITY_INSERT workflow.WorkflowDefinition ON;

-- Insert Definitions
INSERT INTO workflow.WorkflowDefinition (Id, WorkflowModuleId, WorkflowCode, WorkflowName, VersionNo) VALUES
(1, 1, 'LEAVE_STD', 'Standard Leave Workflow', 1),
(2, 2, 'COMP_OFF_STD', 'Standard Comp Off Workflow', 1),
(3, 3, 'ATT_REG_STD', 'Standard Attendance Workflow', 1),
(4, 4, 'SHIFT_SWAP_STD', 'Standard Shift Swap Workflow', 1),
(5, 5, 'EMP_DOC_VERIFY', 'Document Verification Workflow', 1),
(6, 6, 'EMP_ADDR_VERIFY', 'Address Verification Workflow', 1);

SET IDENTITY_INSERT workflow.WorkflowDefinition OFF;

SET IDENTITY_INSERT workflow.WorkflowStep ON;

-- Insert Steps
-- LeaveRequest (3 Steps: Direct Manager -> HOD -> HR)
INSERT INTO workflow.WorkflowStep (Id, WorkflowDefinitionId, StepNo, StepName, WorkflowStepType, IsFinalStep) VALUES
(1, 1, 1, 'Manager Approval', 'APPROVAL', 0),
(2, 1, 2, 'HOD Approval', 'APPROVAL', 0),
(3, 1, 3, 'HR Final Approval', 'APPROVAL', 1),

-- CompOffBalance (2 Steps: Direct Manager -> HR)
(4, 2, 1, 'Manager Approval', 'APPROVAL', 0),
(5, 2, 2, 'HR Approval', 'APPROVAL', 1),

-- AttendanceRegularization (2 Steps: Direct Manager -> HR)
(6, 3, 1, 'Manager Approval', 'APPROVAL', 0),
(7, 3, 2, 'HR Approval', 'APPROVAL', 1),

-- ShiftSwapRequest (2 Steps: Direct Manager -> HR)
(8, 4, 1, 'Manager Approval', 'APPROVAL', 0),
(9, 4, 2, 'HR Approval', 'APPROVAL', 1),

-- EmployeeDocument (1 Step: HR)
(10, 5, 1, 'HR Verification', 'APPROVAL', 1),

-- EmployeeAddress (1 Step: HR)
(11, 6, 1, 'HR Verification', 'APPROVAL', 1);

SET IDENTITY_INSERT workflow.WorkflowStep OFF;

SET IDENTITY_INSERT workflow.WorkflowStepApprover ON;

-- Insert Step Approvers (Rules)
-- Assume: 
-- WORKFLOW_APPROVER_TYPE: REPORTING_MANAGER (resolves from employee hierarchy)
-- WORKFLOW_APPROVER_TYPE: DESIGNATION (resolves via Scope & Designation mapping)

-- LeaveRequest
INSERT INTO workflow.WorkflowStepApprover (Id, WorkflowStepId, WorkflowApproverType, PriorityOrder) VALUES
(1, 1, 'REPORTING_MANAGER', 1), -- Step 1: Direct Manager
(2, 2, 'DESIGNATION', 1),       -- Step 2: HOD (Requires Designation mapping)
(3, 3, 'DESIGNATION', 1),       -- Step 3: HR (Requires Designation mapping)

-- CompOffBalance
(4, 4, 'REPORTING_MANAGER', 1), -- Step 1
(5, 5, 'DESIGNATION', 1),       -- Step 2: HR

-- AttendanceRegularization
(6, 6, 'REPORTING_MANAGER', 1), -- Step 1
(7, 7, 'DESIGNATION', 1),       -- Step 2: HR

-- ShiftSwapRequest
(8, 8, 'REPORTING_MANAGER', 1), -- Step 1
(9, 9, 'DESIGNATION', 1),       -- Step 2: HR

-- EmployeeDocument
(10, 10, 'DESIGNATION', 1),     -- Step 1: HR

-- EmployeeAddress
(11, 11, 'DESIGNATION', 1);     -- Step 1: HR

SET IDENTITY_INSERT workflow.WorkflowStepApprover OFF;

PRINT 'Workflow Data seeded successfully';
