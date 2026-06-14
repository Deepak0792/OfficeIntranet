-- ============================================================
-- shared.LookupDefinition — FULL SEED DATA
-- Pattern A : StatusLookup-backed  → STATIC_SQL, IdType = 'string'
-- Pattern B : Table-backed          → STATIC_SQL, IdType = 'int', SourceObjectName set
-- Grouped by consuming schema
-- ============================================================


-- ============================================================
-- SCHEMA: workflow
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'WORKFLOW_STEP_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'WORKFLOW_STEP_TYPE', 'Workflow Step Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''WORKFLOW_STEP_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'WORKFLOW_APPROVER_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'WORKFLOW_APPROVER_TYPE', 'Workflow Approver Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''WORKFLOW_APPROVER_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'WORKFLOW_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'WORKFLOW_STATUS', 'Workflow Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''WORKFLOW_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'WORKFLOW_ACTION_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'WORKFLOW_ACTION_TYPE', 'Workflow Action Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''WORKFLOW_ACTION_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'WORKFLOW_TASK_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'WORKFLOW_TASK_STATUS', 'Workflow Task Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''WORKFLOW_TASK_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: employee
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EMPLOYMENT_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EMPLOYMENT_TYPE', 'Employment Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EMPLOYMENT_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'RELATIONSHIP_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'RELATIONSHIP_TYPE', 'Relationship Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''RELATIONSHIP_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'CONTACT_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'CONTACT_TYPE', 'Contact Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''CONTACT_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ADDRESS_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ADDRESS_TYPE', 'Address Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ADDRESS_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: attendance
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'LEAVE_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'LEAVE_STATUS', 'Leave Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''LEAVE_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ATTENDANCE_REGULARIZATION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ATTENDANCE_REGULARIZATION_STATUS', 'Attendance Regularization Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ATTENDANCE_REGULARIZATION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'OUTBOX_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'OUTBOX_STATUS', 'Outbox Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''OUTBOX_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'SHIFT_SWAP_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'SHIFT_SWAP_STATUS', 'Shift Swap Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''SHIFT_SWAP_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ROSTER_GENERATION_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ROSTER_GENERATION_TYPE', 'Roster Generation Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ROSTER_GENERATION_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: hr
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'INTERVIEW_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'INTERVIEW_TYPE', 'Interview Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''INTERVIEW_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'JOB_POSTING_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'JOB_POSTING_STATUS', 'Job Posting Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''JOB_POSTING_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'APPLICATION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'APPLICATION_STATUS', 'Application Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''APPLICATION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'INTERVIEW_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'INTERVIEW_STATUS', 'Interview Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''INTERVIEW_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'INTERVIEW_PURPOSE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'INTERVIEW_PURPOSE', 'Interview Purpose', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''INTERVIEW_PURPOSE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'RECOMMENDATION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'RECOMMENDATION_STATUS', 'Recommendation Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''RECOMMENDATION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'NEGOTIATION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'NEGOTIATION_STATUS', 'Negotiation Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''NEGOTIATION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'OFFER_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'OFFER_STATUS', 'Offer Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''OFFER_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ONBOARDING_TASK_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ONBOARDING_TASK_STATUS', 'Onboarding Task Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ONBOARDING_TASK_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ONBOARDING_PHASE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ONBOARDING_PHASE', 'Onboarding Phase', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ONBOARDING_PHASE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'DOC_VERIFY_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'DOC_VERIFY_STATUS', 'Document Verification Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''DOC_VERIFY_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'BGV_CHECK_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'BGV_CHECK_TYPE', 'BGV Check Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''BGV_CHECK_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'BGV_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'BGV_STATUS', 'BGV Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''BGV_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'BGV_RESULT')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'BGV_RESULT', 'BGV Result', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''BGV_RESULT'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'POLICY_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'POLICY_STATUS', 'Policy Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''POLICY_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'POLICY_ACK_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'POLICY_ACK_STATUS', 'Policy Acknowledgement Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''POLICY_ACK_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'PERF_CYCLE_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'PERF_CYCLE_TYPE', 'Performance Cycle Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''PERF_CYCLE_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'PERF_CYCLE_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'PERF_CYCLE_STATUS', 'Performance Cycle Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''PERF_CYCLE_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'GOAL_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'GOAL_STATUS', 'Goal Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''GOAL_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'GOAL_KR_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'GOAL_KR_STATUS', 'Goal Key Result Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''GOAL_KR_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'PERF_REVIEW_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'PERF_REVIEW_STATUS', 'Performance Review Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''PERF_REVIEW_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TRAINING_CATEGORY')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TRAINING_CATEGORY', 'Training Category', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TRAINING_CATEGORY'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TRAINING_MODE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TRAINING_MODE', 'Training Mode', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TRAINING_MODE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TRAINING_BATCH_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TRAINING_BATCH_STATUS', 'Training Batch Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TRAINING_BATCH_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TRAINING_RECORD_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TRAINING_RECORD_STATUS', 'Training Record Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TRAINING_RECORD_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EXIT_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EXIT_TYPE', 'Exit Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EXIT_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EXIT_INTERVIEW_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EXIT_INTERVIEW_STATUS', 'Exit Interview Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EXIT_INTERVIEW_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'CLEARANCE_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'CLEARANCE_STATUS', 'Clearance Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''CLEARANCE_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'FINAL_SETTLEMENT_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'FINAL_SETTLEMENT_STATUS', 'Final Settlement Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''FINAL_SETTLEMENT_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'CLEARANCE_ITEM_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'CLEARANCE_ITEM_STATUS', 'Clearance Item Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''CLEARANCE_ITEM_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: payroll
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'CALC_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'CALC_TYPE', 'Calculation Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''CALC_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'SALARY_REVISION_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'SALARY_REVISION_TYPE', 'Salary Revision Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''SALARY_REVISION_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'BANK_ACCOUNT_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'BANK_ACCOUNT_TYPE', 'Bank Account Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''BANK_ACCOUNT_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'DISBURSEMENT_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'DISBURSEMENT_STATUS', 'Disbursement Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''DISBURSEMENT_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TRANSACTION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TRANSACTION_STATUS', 'Transaction Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TRANSACTION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'PAYMENT_MODE_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'PAYMENT_MODE_TYPE', 'Payment Mode', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''PAYMENT_MODE_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'DECLARATION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'DECLARATION_STATUS', 'Declaration Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''DECLARATION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'PROOF_REVIEW_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'PROOF_REVIEW_STATUS', 'Proof Review Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''PROOF_REVIEW_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'DEDUCTION_CATEGORY')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'DEDUCTION_CATEGORY', 'Deduction Category', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''DEDUCTION_CATEGORY'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'SALARY_SLIP_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'SALARY_SLIP_STATUS', 'Salary Slip Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''SALARY_SLIP_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: helpdesk
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'HELPDESK_TICKET_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'HELPDESK_TICKET_STATUS', 'Helpdesk Ticket Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''HELPDESK_TICKET_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'HELPDESK_TICKET_PRIORITY')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'HELPDESK_TICKET_PRIORITY', 'Helpdesk Ticket Priority', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''HELPDESK_TICKET_PRIORITY'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'HELPDESK_ASSET_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'HELPDESK_ASSET_STATUS', 'Helpdesk Asset Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''HELPDESK_ASSET_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'HELPDESK_LICENSE_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'HELPDESK_LICENSE_TYPE', 'Helpdesk License Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''HELPDESK_LICENSE_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: auth
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'AUTH_EFFECT')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'AUTH_EFFECT', 'Auth Effect', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''AUTH_EFFECT'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'AUTH_DECISION')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'AUTH_DECISION', 'Auth Decision', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''AUTH_DECISION'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'PERMISSION_CATEGORY')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'PERMISSION_CATEGORY', 'Permission Category', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''PERMISSION_CATEGORY'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'PERMISSION_ACTION')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'PERMISSION_ACTION', 'Permission Action', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''PERMISSION_ACTION'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'RECORD_ACCESS_SCOPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'RECORD_ACCESS_SCOPE', 'Record Access Scope', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''RECORD_ACCESS_SCOPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'CONDITION_OPERATOR')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'CONDITION_OPERATOR', 'Condition Operator', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''CONDITION_OPERATOR'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'FIELD_MASK_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'FIELD_MASK_TYPE', 'Field Mask Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''FIELD_MASK_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'HTTP_METHOD')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'HTTP_METHOD', 'HTTP Method', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''HTTP_METHOD'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'DELEGATED_ACCESS_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'DELEGATED_ACCESS_STATUS', 'Delegated Access Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''DELEGATED_ACCESS_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: event
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EVENT_CATEGORY')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EVENT_CATEGORY', 'Event Category', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EVENT_CATEGORY'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EVENT_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EVENT_STATUS', 'Event Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EVENT_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'RSVP_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'RSVP_STATUS', 'RSVP Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''RSVP_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EVENT_ATTENDANCE_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EVENT_ATTENDANCE_STATUS', 'Event Attendance Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EVENT_ATTENDANCE_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'NOTIFICATION_CHANNEL')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'NOTIFICATION_CHANNEL', 'Notification Channel', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''NOTIFICATION_CHANNEL'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'NOTIFICATION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'NOTIFICATION_STATUS', 'Notification Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''NOTIFICATION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'CELEBRATION_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'CELEBRATION_TYPE', 'Celebration Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''CELEBRATION_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'GREETING_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'GREETING_STATUS', 'Greeting Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''GREETING_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'REACTION_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'REACTION_TYPE', 'Reaction Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''REACTION_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'SURVEY_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'SURVEY_STATUS', 'Survey Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''SURVEY_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TARGET_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TARGET_TYPE', 'Target Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TARGET_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'QUESTION_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'QUESTION_TYPE', 'Question Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''QUESTION_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: survey
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'POLL_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'POLL_TYPE', 'Poll Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''POLL_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'POLL_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'POLL_STATUS', 'Poll Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''POLL_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'FEEDBACK_CATEGORY')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'FEEDBACK_CATEGORY', 'Feedback Category', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''FEEDBACK_CATEGORY'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'FEEDBACK_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'FEEDBACK_STATUS', 'Feedback Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''FEEDBACK_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- SCHEMA: expense
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EXPENSE_POLICY_GROUP')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EXPENSE_POLICY_GROUP', 'Expense Policy Group', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EXPENSE_POLICY_GROUP'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TRAVEL_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TRAVEL_TYPE', 'Travel Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TRAVEL_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'TRAVEL_REQUEST_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'TRAVEL_REQUEST_STATUS', 'Travel Request Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''TRAVEL_REQUEST_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ADVANCE_REQUEST_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ADVANCE_REQUEST_STATUS', 'Advance Request Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ADVANCE_REQUEST_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ASSET_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ASSET_TYPE', 'Asset Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ASSET_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'POLICY_VALIDATION_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'POLICY_VALIDATION_STATUS', 'Policy Validation Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''POLICY_VALIDATION_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'ASSET_REIMBURSEMENT_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'ASSET_REIMBURSEMENT_STATUS', 'Asset Reimbursement Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''ASSET_REIMBURSEMENT_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EXPENSE_CLAIM_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EXPENSE_CLAIM_STATUS', 'Expense Claim Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EXPENSE_CLAIM_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'REIMBURSEMENT_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'REIMBURSEMENT_TYPE', 'Reimbursement Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''REIMBURSEMENT_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'REIMBURSEMENT_STATUS')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'REIMBURSEMENT_STATUS', 'Reimbursement Status', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''REIMBURSEMENT_STATUS'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'EXPENSE_APPROVAL_REFERENCE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'EXPENSE_APPROVAL_REFERENCE', 'Expense Approval Reference', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''EXPENSE_APPROVAL_REFERENCE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'AUDIT_EVENT_TYPE')
BEGIN
    INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SqlStatement, ValueField, TextField, IsSystem)
    VALUES (NEWID(), 'AUDIT_EVENT_TYPE', 'Audit Event Type', 'STATIC_SQL',
    'SELECT StatusCode AS Id, Label AS Name, DisplayOrder FROM shared.StatusLookup WHERE StatusGroup = ''AUDIT_EVENT_TYPE'' ORDER BY DisplayOrder',
    'Id', 'Name', 1);
END
GO


-- ============================================================
-- HIERARCHICAL LOOKUPS (table-backed, IdType = 'int')
-- ============================================================

-- COUNTRY
IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'COUNTRY')
BEGIN
    INSERT INTO shared.LookupDefinition(LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SourceObjectName, SqlStatement, ValueField, TextField, SupportsParentFilter, IsSystem, IsActive)
    VALUES (NEWID(), 'COUNTRY', 'Country Lookup', 'STATIC_SQL', 'time.Country', 
	'SELECT Id, CountryName AS Name, 0 AS DisplayOrder FROM time.Country ORDER BY CountryName', 'Id', 'Name', 0, 1, 1);
END
GO

-- STATE (parent = COUNTRY)
IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'STATE')
BEGIN
	INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SourceObjectName, ParentLookupDefinitionId, SqlStatement, ValueField, TextField, ParentValueField, SupportsParentFilter, IsSystem, IsActive)
	VALUES (NEWID(), 'STATE', 'State Lookup', 'STATIC_SQL', 'time.Region', (SELECT LookupDefinitionId FROM shared.LookupDefinition WHERE LookupCode = 'COUNTRY'), 'SELECT Id, r.RegionName AS Name, 0 AS DisplayOrder FROM time.Region r WHERE r.RegionType = ''State'' AND (@ParentId IS NULL OR r.CountryId = @ParentId) ORDER BY r.RegionName', 'Id', 'Name', 'ParentId', 1, 1, 1);
END
GO

-- CITY (parent = STATE)
IF NOT EXISTS (SELECT 1 FROM shared.LookupDefinition WHERE LookupCode = 'CITY')
BEGIN
	INSERT INTO shared.LookupDefinition (LookupDefinitionId, LookupCode, LookupName, LookupSourceType, SourceObjectName, ParentLookupDefinitionId, SqlStatement, ValueField, TextField, ParentValueField, SupportsParentFilter, IsSystem, IsActive)
	VALUES (NEWID(), 'CITY', 'City Lookup', 'STATIC_SQL', 'time.Region', (SELECT LookupDefinitionId FROM shared.LookupDefinition WHERE LookupCode = 'STATE'), 'SELECT Id, r.RegionName AS Name, 0 AS DisplayOrder FROM time.Region r WHERE r.RegionType = ''City'' AND (@ParentId IS NULL OR r.ParentRegionId = @ParentId) ORDER BY r.RegionName', 'Id', 'Name', 'ParentId', 1, 1, 1);
END
GO


PRINT 'shared.LookupDefinition seed complete.';
GO