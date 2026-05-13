-- =============================================================================================================
-- SHARED SCHEMA - Cross-Cutting Lookup Tables
-- SQL Server Database Schema
-- Schema: shared
-- Purpose: Universal status codes used by ALL microservices for domain isolation
-- Dependencies: None (foundational)
-- =============================================================================================================
-- STATUS GROUPS SEEDED INTO shared.StatusLookup:
--   EMPLOYMENT_TYPE         -> FULL_TIME | PART_TIME | CONTRACT | INTERIM | INTERN
--   CONTACT_TYPE            -> WORK_PHONE | PERSONAL_EMAIL | SLACK | SKYPE | TEAMS
--   LEAVE_REQUEST_STATUS    -> PENDING | APPROVED | REJECTED | CANCELLED
--   ATTENDANCE_STATUS       -> PRESENT | ABSENT | ON_LEAVE | WORK_FROM_HOME | LATE
--   SHIFT_SWAP_STATUS       -> PENDING | APPROVED | REJECTED | CANCELLED
--   ATTENDANCE_REGULARIZATION_STATUS -> PENDING | APPROVED | REJECTED
--   HELPDESK_TICKET_STATUS  -> OPEN | IN_PROGRESS | PENDING_CUSTOMER | RESOLVED | CLOSED | CANCELLED
--   HELPDESK_TICKET_PRIORITY-> CRITICAL | HIGH | MEDIUM | LOW
--   HELPDESK_ASSET_STATUS   -> AVAILABLE | IN_USE | UNDER_REPAIR | RETIRED | LOST
--   HELPDESK_LICENSE_TYPE   -> PERPETUAL | SUBSCRIPTION | FREE | OPEN_SOURCE
--   ONBOARDING_TASK_STATUS  -> PENDING | IN_PROGRESS | COMPLETED | WAIVED
--   DOC_VERIFY_STATUS       -> PENDING | SUBMITTED | UNDER_REVIEW | VERIFIED | REJECTED | RESUBMITTED | EXPIRED | WAIVED
--   BGV_STATUS              -> PENDING | IN_PROGRESS | COMPLETED | DISCREPANCY_FOUND | FAILED | WAIVED
--   BGV_RESULT               -> CLEAR | DISCREPANCY | UNABLE_TO_VERIFY | FAILED
--   BGV_CHECK_TYPE           -> CRIMINAL | EMPLOYMENT_HISTORY | EDUCATION | IDENTITY | CREDIT | REFERENCE | DRUG_TEST | ADDRESS
--   ONBOARDING_PHASE         -> PRE_ONBOARDING | POST_ONBOARDING
--   EXIT_TYPE                -> RESIGNATION | TERMINATION | RETIREMENT | CONTRACT_END | ABSCONDING
--   EXIT_INTERVIEW_STATUS    -> PENDING | SCHEDULED | COMPLETED | SKIPPED
--   CLEARANCE_STATUS         -> PENDING | IN_PROGRESS | COMPLETED
--   FINAL_SETTLEMENT_STATUS  -> PENDING | PROCESSED | PAID
--   CLEARANCE_ITEM_STATUS    -> PENDING | COMPLETED | WAIVED
--   POLICY_STATUS            -> DRAFT | ACTIVE | ARCHIVED | SUPERSEDED
--   POLICY_ACK_STATUS        -> PENDING | ACKNOWLEDGED | OVERDUE
--   SALARY_SLIP_STATUS       -> DRAFT | PUBLISHED | DOWNLOADED | REVISED
--   PERF_CYCLE_TYPE          -> ANNUAL | BI_ANNUAL | QUARTERLY | PROBATION
--   PERF_CYCLE_STATUS        -> UPCOMING | GOAL_SETTING | IN_REVIEW | COMPLETED | ARCHIVED
--   PERF_REVIEW_STATUS       -> PENDING | SELF_SUBMITTED | MANAGER_REVIEW | HRBP_REVIEW | COMPLETED | ACKNOWLEDGED
--   GOAL_STATUS              -> DRAFT | SUBMITTED | APPROVED | IN_PROGRESS | COMPLETED | CANCELLED
--   GOAL_KR_STATUS           -> PENDING | ON_TRACK | AT_RISK | ACHIEVED | NOT_ACHIEVED
--   TRAINING_MODE            -> ONLINE | OFFLINE | HYBRID | SELF_PACED
--   TRAINING_BATCH_STATUS    -> UPCOMING | ONGOING | COMPLETED | CANCELLED
--   TRAINING_RECORD_STATUS   -> ENROLLED | IN_PROGRESS | COMPLETED | FAILED | DROPPED | ABSENT
--   RECOMMENDATION_STATUS    -> STRONG_YES | YES | MAYBE | NO | STRONG_NO
--   INTERVIEW_STATUS         -> SCHEDULED | COMPLETED | CANCELLED | RESCHEDULED | NO_SHOW
--   JOB_POSTING_STATUS       -> DRAFT | OPEN | ON_HOLD | CLOSED | CANCELLED
--   APPLICATION_STATUS       -> APPLIED | SCREENING | INTERVIEW | OFFER | NEGOTIATION | HIRED | REJECTED | WITHDRAWN
--   OFFER_STATUS             -> ISSUED | ACCEPTED | REJECTED | EXPIRED | REVOKED
--   NEGOTIATION_STATUS       -> IN_PROGRESS | ACCEPTED | REJECTED | COUNTERED | WITHDRAWN
--   DECLARATION_STATUS       -> DRAFT | SUBMITTED | VERIFIED | REJECTED
--   PROOF_REVIEW_STATUS      -> PENDING | APPROVED | REJECTED
--   DISBURSEMENT_STATUS      -> DRAFT | APPROVED | PROCESSING | COMPLETED | FAILED | CANCELLED
--   TRANSACTION_STATUS       -> PENDING | INITIATED | SUCCESS | FAILED | REVERSED
--   SALARY_REVISION_TYPE     -> ANNUAL_INCREMENT | PROMOTION | CORRECTION | JOINING | MARKET_CORRECTION | OTHER
--   BANK_ACCOUNT_TYPE        -> SAVINGS | CURRENT | SALARY
--   CALC_TYPE                -> FIXED | PERCENTAGE | FORMULA
--   DEDUCTION_CATEGORY       -> EXEMPTION | DEDUCTION | TAX | CESS | REBATE
--   PAYMENT_MODE_TYPE        -> NEFT | RTGS | IMPS | CHEQUE | CASH
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'shared')
BEGIN
    EXEC('CREATE SCHEMA shared');
END
GO


-- =============================================================================================================
-- STATUS LOOKUP - Universal status codes with domain isolation
-- =============================================================================================================
CREATE TABLE shared.StatusLookup (
    StatusCode      NVARCHAR(50)    NOT NULL,
    StatusGroup     NVARCHAR(50)    NOT NULL,
    Label           NVARCHAR(100)  NOT NULL,
    Description     NVARCHAR(500)  NULL,
    DisplayOrder    TINYINT         NOT NULL DEFAULT 0,
    IsTerminal      BIT             NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_StatusLookup PRIMARY KEY (StatusCode, StatusGroup)
);
GO


-- =============================================================================================================
-- SEED DATA - Common Status Codes
-- =============================================================================================================

-- Employment Types
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('FULL_TIME', 'EMPLOYMENT_TYPE', 'Full Time', 'Regular full-time employee', 1, 0),
('PART_TIME', 'EMPLOYMENT_TYPE', 'Part Time', 'Part-time employee', 2, 0),
('CONTRACT', 'EMPLOYMENT_TYPE', 'Contract', 'Contractual employee', 3, 0),
('INTERIM', 'EMPLOYMENT_TYPE', 'Interim', 'Interim or temporary', 4, 0),
('INTERN', 'EMPLOYMENT_TYPE', 'Intern', 'Intern or trainee', 5, 0);

-- Contact Types
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('WORK_PHONE', 'CONTACT_TYPE', 'Work Phone', 'Office telephone', 1, 0),
('PERSONAL_EMAIL', 'CONTACT_TYPE', 'Personal Email', 'Personal email address', 2, 0),
('SLACK', 'CONTACT_TYPE', 'Slack', 'Slack username', 3, 0),
('SKYPE', 'CONTACT_TYPE', 'Skype', 'Skype ID', 4, 0),
('TEAMS', 'CONTACT_TYPE', 'Microsoft Teams', 'Teams ID', 5, 0);

-- Helpdesk Ticket Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('OPEN', 'HELPDESK_TICKET_STATUS', 'Open', 'Newly created ticket', 1, 0),
('IN_PROGRESS', 'HELPDESK_TICKET_STATUS', 'In Progress', 'Being worked on', 2, 0),
('PENDING_CUSTOMER', 'HELPDESK_TICKET_STATUS', 'Pending Customer', 'Awaiting customer response', 3, 0),
('RESOLVED', 'HELPDESK_TICKET_STATUS', 'Resolved', 'Issue resolved', 4, 1),
('CLOSED', 'HELPDESK_TICKET_STATUS', 'Closed', 'Ticket closed', 5, 1),
('CANCELLED', 'HELPDESK_TICKET_STATUS', 'Cancelled', 'Ticket cancelled', 6, 1);

-- Helpdesk Ticket Priority
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('CRITICAL', 'HELPDESK_TICKET_PRIORITY', 'Critical', 'System down or major impact', 1, 0),
('HIGH', 'HELPDESK_TICKET_PRIORITY', 'High', 'Significant impact', 2, 0),
('MEDIUM', 'HELPDESK_TICKET_PRIORITY', 'Medium', 'Moderate impact', 3, 0),
('LOW', 'HELPDESK_TICKET_PRIORITY', 'Low', 'Minor impact', 4, 0);

-- Helpdesk Asset Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('AVAILABLE', 'HELPDESK_ASSET_STATUS', 'Available', 'Ready for assignment', 1, 0),
('IN_USE', 'HELPDESK_ASSET_STATUS', 'In Use', 'Assigned to employee', 2, 0),
('UNDER_REPAIR', 'HELPDESK_ASSET_STATUS', 'Under Repair', 'Being serviced', 3, 0),
('RETIRED', 'HELPDESK_ASSET_STATUS', 'Retired', 'Decommissioned', 4, 1),
('LOST', 'HELPDESK_ASSET_STATUS', 'Lost', 'Lost or missing', 5, 1);

-- Helpdesk License Type
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PERPETUAL', 'HELPDESK_LICENSE_TYPE', 'Perpetual', 'One-time purchase, perpetual use', 1, 0),
('SUBSCRIPTION', 'HELPDESK_LICENSE_TYPE', 'Subscription', 'Recurring subscription', 2, 0),
('FREE', 'HELPDESK_LICENSE_TYPE', 'Free', 'Free or open source', 3, 0),
('OPEN_SOURCE', 'HELPDESK_LICENSE_TYPE', 'Open Source', 'Open source software', 4, 0);

-- Calculation Type
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('FIXED', 'CALC_TYPE', 'Fixed', 'Fixed amount', 1, 0),
('PERCENTAGE', 'CALC_TYPE', 'Percentage', 'Percentage of base', 2, 0),
('FORMULA', 'CALC_TYPE', 'Formula', 'Custom formula', 3, 0);

-- Bank Account Type
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('SAVINGS', 'BANK_ACCOUNT_TYPE', 'Savings', 'Savings account', 1, 0),
('CURRENT', 'BANK_ACCOUNT_TYPE', 'Current', 'Current account', 2, 0),
('SALARY', 'BANK_ACCOUNT_TYPE', 'Salary', 'Salary account', 3, 0);

-- Payment Mode
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('NEFT', 'PAYMENT_MODE_TYPE', 'NEFT', 'National Electronic Fund Transfer', 1, 0),
('RTGS', 'PAYMENT_MODE_TYPE', 'RTGS', 'Real Time Gross Settlement', 2, 0),
('IMPS', 'PAYMENT_MODE_TYPE', 'IMPS', 'Immediate Payment Service', 3, 0),
('CHEQUE', 'PAYMENT_MODE_TYPE', 'Cheque', 'Cheque payment', 4, 0),
('CASH', 'PAYMENT_MODE_TYPE', 'Cash', 'Cash payment', 5, 0);

-- Deduction Category
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('EXEMPTION', 'DEDUCTION_CATEGORY', 'Exemption', 'Tax exempt income', 1, 0),
('DEDUCTION', 'DEDUCTION_CATEGORY', 'Deduction', 'Qualifying deduction', 2, 0),
('TAX', 'DEDUCTION_CATEGORY', 'Tax', 'Tax liability', 3, 0),
('CESS', 'DEDUCTION_CATEGORY', 'Cess', 'Education/Health cess', 4, 0),
('REBATE', 'DEDUCTION_CATEGORY', 'Rebate', 'Tax rebate', 5, 0);

-- Salary Revision Type
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('ANNUAL_INCREMENT', 'SALARY_REVISION_TYPE', 'Annual Increment', 'Annual salary review', 1, 0),
('PROMOTION', 'SALARY_REVISION_TYPE', 'Promotion', 'Promotion-based increase', 2, 0),
('CORRECTION', 'SALARY_REVISION_TYPE', 'Correction', 'Salary correction', 3, 0),
('JOINING', 'SALARY_REVISION_TYPE', 'Joining', 'New hire salary', 4, 0),
('MARKET_CORRECTION', 'SALARY_REVISION_TYPE', 'Market Correction', 'Market-aligned salary', 5, 0),
('OTHER', 'SALARY_REVISION_TYPE', 'Other', 'Other revision type', 6, 0);

-- Disbursement Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('DRAFT', 'DISBURSEMENT_STATUS', 'Draft', 'Draft status', 1, 0),
('APPROVED', 'DISBURSEMENT_STATUS', 'Approved', 'Approved for processing', 2, 0),
('PROCESSING', 'DISBURSEMENT_STATUS', 'Processing', 'Being processed', 3, 0),
('COMPLETED', 'DISBURSEMENT_STATUS', 'Completed', 'Successfully completed', 4, 1),
('FAILED', 'DISBURSEMENT_STATUS', 'Failed', 'Processing failed', 5, 1),
('CANCELLED', 'DISBURSEMENT_STATUS', 'Cancelled', 'Cancelled', 6, 1);

-- Transaction Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PENDING', 'TRANSACTION_STATUS', 'Pending', 'Awaiting processing', 1, 0),
('INITIATED', 'TRANSACTION_STATUS', 'Initiated', 'Transaction initiated', 2, 0),
('SUCCESS', 'TRANSACTION_STATUS', 'Success', 'Transaction successful', 3, 1),
('FAILED', 'TRANSACTION_STATUS', 'Failed', 'Transaction failed', 4, 1),
('REVERSED', 'TRANSACTION_STATUS', 'Reversed', 'Transaction reversed', 5, 1);

-- Declaration Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('DRAFT', 'DECLARATION_STATUS', 'Draft', 'Draft declaration', 1, 0),
('SUBMITTED', 'DECLARATION_STATUS', 'Submitted', 'Submitted for review', 2, 0),
('VERIFIED', 'DECLARATION_STATUS', 'Verified', 'Verified by finance', 3, 1),
('REJECTED', 'DECLARATION_STATUS', 'Rejected', 'Rejected', 4, 1);

-- Proof Review Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PENDING', 'PROOF_REVIEW_STATUS', 'Pending', 'Awaiting review', 1, 0),
('APPROVED', 'PROOF_REVIEW_STATUS', 'Approved', 'Proof approved', 2, 1),
('REJECTED', 'PROOF_REVIEW_STATUS', 'Rejected', 'Proof rejected', 3, 1);

-- Leave Request Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PENDING', 'LEAVE_REQUEST_STATUS', 'Pending', 'Awaiting approval', 1, 0),
('APPROVED', 'LEAVE_REQUEST_STATUS', 'Approved', 'Leave approved', 2, 1),
('REJECTED', 'LEAVE_REQUEST_STATUS', 'Rejected', 'Leave rejected', 3, 1),
('CANCELLED', 'LEAVE_REQUEST_STATUS', 'Cancelled', 'Leave cancelled', 4, 1);

-- Attendance Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PRESENT', 'ATTENDANCE_STATUS', 'Present', 'Present at work', 1, 0),
('ABSENT', 'ATTENDANCE_STATUS', 'Absent', 'Absent from work', 2, 0),
('ON_LEAVE', 'ATTENDANCE_STATUS', 'On Leave', 'On approved leave', 3, 0),
('WORK_FROM_HOME', 'ATTENDANCE_STATUS', 'Work From Home', 'Working remotely', 4, 0),
('LATE', 'ATTENDANCE_STATUS', 'Late', 'Arrived late', 5, 0);

-- Shift Swap Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PENDING', 'SHIFT_SWAP_STATUS', 'Pending', 'Awaiting approval', 1, 0),
('APPROVED', 'SHIFT_SWAP_STATUS', 'Approved', 'Swap approved', 2, 1),
('REJECTED', 'SHIFT_SWAP_STATUS', 'Rejected', 'Swap rejected', 3, 1),
('CANCELLED', 'SHIFT_SWAP_STATUS', 'Cancelled', 'Swap cancelled', 4, 1);

-- Attendance Regularization Status
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PENDING', 'ATTENDANCE_REGULARIZATION_STATUS', 'Pending', 'Awaiting approval', 1, 0),
('APPROVED', 'ATTENDANCE_REGULARIZATION_STATUS', 'Approved', 'Regularization approved', 2, 1),
('REJECTED', 'ATTENDANCE_REGULARIZATION_STATUS', 'Rejected', 'Regularization rejected', 3, 1);

-- HR Status Groups (seeded for hr schema)
INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
('PENDING', 'ONBOARDING_TASK_STATUS', 'Pending', 'Task not started', 1, 0),
('IN_PROGRESS', 'ONBOARDING_TASK_STATUS', 'In Progress', 'Task in progress', 2, 0),
('COMPLETED', 'ONBOARDING_TASK_STATUS', 'Completed', 'Task completed', 3, 1),
('WAIVED', 'ONBOARDING_TASK_STATUS', 'Waived', 'Task waived', 4, 1),

('PENDING', 'DOC_VERIFY_STATUS', 'Pending', 'Not submitted', 1, 0),
('SUBMITTED', 'DOC_VERIFY_STATUS', 'Submitted', 'Document submitted', 2, 0),
('UNDER_REVIEW', 'DOC_VERIFY_STATUS', 'Under Review', 'Being reviewed', 3, 0),
('VERIFIED', 'DOC_VERIFY_STATUS', 'Verified', 'Verified', 4, 1),
('REJECTED', 'DOC_VERIFY_STATUS', 'Rejected', 'Rejected', 5, 1),
('RESUBMITTED', 'DOC_VERIFY_STATUS', 'Resubmitted', 'Resubmitted', 6, 0),
('EXPIRED', 'DOC_VERIFY_STATUS', 'Expired', 'Expired', 7, 1),
('WAIVED', 'DOC_VERIFY_STATUS', 'Waived', 'Waived', 8, 1),

('PENDING', 'BGV_STATUS', 'Pending', 'Not started', 1, 0),
('IN_PROGRESS', 'BGV_STATUS', 'In Progress', 'Verification in progress', 2, 0),
('COMPLETED', 'BGV_STATUS', 'Completed', 'Completed', 3, 1),
('DISCREPANCY_FOUND', 'BGV_STATUS', 'Discrepancy Found', 'Discrepancy found', 4, 1),
('FAILED', 'BGV_STATUS', 'Failed', 'Verification failed', 5, 1),
('WAIVED', 'BGV_STATUS', 'Waived', 'Waived', 6, 1),

('CLEAR', 'BGV_RESULT', 'Clear', 'All clear', 1, 0),
('DISCREPANCY', 'BGV_RESULT', 'Discrepancy', 'Discrepancy found', 2, 0),
('UNABLE_TO_VERIFY', 'BGV_RESULT', 'Unable to Verify', 'Could not verify', 3, 0),
('FAILED', 'BGV_RESULT', 'Failed', 'Verification failed', 4, 0),

('CRIMINAL', 'BGV_CHECK_TYPE', 'Criminal', 'Criminal background check', 1, 0),
('EMPLOYMENT_HISTORY', 'BGV_CHECK_TYPE', 'Employment History', 'Previous employment verification', 2, 0),
('EDUCATION', 'BGV_CHECK_TYPE', 'Education', 'Education verification', 3, 0),
('IDENTITY', 'BGV_CHECK_TYPE', 'Identity', 'Identity verification', 4, 0),
('CREDIT', 'BGV_CHECK_TYPE', 'Credit', 'Credit check', 5, 0),
('REFERENCE', 'BGV_CHECK_TYPE', 'Reference', 'Reference check', 6, 0),
('DRUG_TEST', 'BGV_CHECK_TYPE', 'Drug Test', 'Drug screening', 7, 0),
('ADDRESS', 'BGV_CHECK_TYPE', 'Address', 'Address verification', 8, 0),

('PRE_ONBOARDING', 'ONBOARDING_PHASE', 'Pre-Onboarding', 'Before joining', 1, 0),
('POST_ONBOARDING', 'ONBOARDING_PHASE', 'Post-Onboarding', 'After joining', 2, 0),

('RESIGNATION', 'EXIT_TYPE', 'Resignation', 'Voluntary resignation', 1, 0),
('TERMINATION', 'EXIT_TYPE', 'Termination', 'Company-initiated termination', 2, 0),
('RETIREMENT', 'EXIT_TYPE', 'Retirement', 'Retirement', 3, 0),
('CONTRACT_END', 'EXIT_TYPE', 'Contract End', 'Contract expiration', 4, 0),
('ABSCONDING', 'EXIT_TYPE', 'Absconding', 'Absconded', 5, 1),

('PENDING', 'EXIT_INTERVIEW_STATUS', 'Pending', 'Not scheduled', 1, 0),
('SCHEDULED', 'EXIT_INTERVIEW_STATUS', 'Scheduled', 'Interview scheduled', 2, 0),
('COMPLETED', 'EXIT_INTERVIEW_STATUS', 'Completed', 'Interview completed', 3, 1),
('SKIPPED', 'EXIT_INTERVIEW_STATUS', 'Skipped', 'Interview skipped', 4, 1),

('PENDING', 'CLEARANCE_STATUS', 'Pending', 'Clearance not started', 1, 0),
('IN_PROGRESS', 'CLEARANCE_STATUS', 'In Progress', 'Clearance in progress', 2, 0),
('COMPLETED', 'CLEARANCE_STATUS', 'Completed', 'Clearance completed', 3, 1),

('PENDING', 'FINAL_SETTLEMENT_STATUS', 'Pending', 'Settlement not processed', 1, 0),
('PROCESSED', 'FINAL_SETTLEMENT_STATUS', 'Processed', 'Settlement processed', 2, 0),
('PAID', 'FINAL_SETTLEMENT_STATUS', 'Paid', 'Settlement paid', 3, 1),

('PENDING', 'CLEARANCE_ITEM_STATUS', 'Pending', 'Item not completed', 1, 0),
('COMPLETED', 'CLEARANCE_ITEM_STATUS', 'Completed', 'Item completed', 2, 1),
('WAIVED', 'CLEARANCE_ITEM_STATUS', 'Waived', 'Item waived', 3, 1),

('DRAFT', 'POLICY_STATUS', 'Draft', 'Policy draft', 1, 0),
('ACTIVE', 'POLICY_STATUS', 'Active', 'Active policy', 2, 0),
('ARCHIVED', 'POLICY_STATUS', 'Archived', 'Archived', 3, 1),
('SUPERSEDED', 'POLICY_STATUS', 'Superseded', 'Superseded by new version', 4, 1),

('PENDING', 'POLICY_ACK_STATUS', 'Pending', 'Not acknowledged', 1, 0),
('ACKNOWLEDGED', 'POLICY_ACK_STATUS', 'Acknowledged', 'Acknowledged', 2, 1),
('OVERDUE', 'POLICY_ACK_STATUS', 'Overdue', 'Acknowledgement overdue', 3, 0),

('DRAFT', 'SALARY_SLIP_STATUS', 'Draft', 'Payslip not generated', 1, 0),
('PUBLISHED', 'SALARY_SLIP_STATUS', 'Published', 'Published to employee', 2, 0),
('DOWNLOADED', 'SALARY_SLIP_STATUS', 'Downloaded', 'Downloaded by employee', 3, 1),
('REVISED', 'SALARY_SLIP_STATUS', 'Revised', 'Revised payslip', 4, 0),

('ANNUAL', 'PERF_CYCLE_TYPE', 'Annual', 'Annual cycle', 1, 0),
('BI_ANNUAL', 'PERF_CYCLE_TYPE', 'Bi-Annual', 'Twice a year', 2, 0),
('QUARTERLY', 'PERF_CYCLE_TYPE', 'Quarterly', 'Quarterly', 3, 0),
('PROBATION', 'PERF_CYCLE_TYPE', 'Probation', 'Probation review', 4, 0),

('UPCOMING', 'PERF_CYCLE_STATUS', 'Upcoming', 'Cycle not started', 1, 0),
('GOAL_SETTING', 'PERF_CYCLE_STATUS', 'Goal Setting', 'Employee setting goals', 2, 0),
('IN_REVIEW', 'PERF_CYCLE_STATUS', 'In Review', 'Manager reviewing', 3, 0),
('COMPLETED', 'PERF_CYCLE_STATUS', 'Completed', 'Cycle completed', 4, 1),
('ARCHIVED', 'PERF_CYCLE_STATUS', 'Archived', 'Archived', 5, 1),

('PENDING', 'PERF_REVIEW_STATUS', 'Pending', 'Review not started', 1, 0),
('SELF_SUBMITTED', 'PERF_REVIEW_STATUS', 'Self Submitted', 'Self assessment done', 2, 0),
('MANAGER_REVIEW', 'PERF_REVIEW_STATUS', 'Manager Review', 'Manager reviewing', 3, 0),
('HRBP_REVIEW', 'PERF_REVIEW_STATUS', 'HRBP Review', 'HRBP reviewing', 4, 0),
('COMPLETED', 'PERF_REVIEW_STATUS', 'Completed', 'Review completed', 5, 1),
('ACKNOWLEDGED', 'PERF_REVIEW_STATUS', 'Acknowledged', 'Acknowledged by employee', 6, 1),

('DRAFT', 'GOAL_STATUS', 'Draft', 'Goal draft', 1, 0),
('SUBMITTED', 'GOAL_STATUS', 'Submitted', 'Submitted for approval', 2, 0),
('APPROVED', 'GOAL_STATUS', 'Approved', 'Approved by manager', 3, 1),
('IN_PROGRESS', 'GOAL_STATUS', 'In Progress', 'In progress', 4, 0),
('COMPLETED', 'GOAL_STATUS', 'Completed', 'Completed', 5, 1),
('CANCELLED', 'GOAL_STATUS', 'Cancelled', 'Cancelled', 6, 1),

('PENDING', 'GOAL_KR_STATUS', 'Pending', 'Not started', 1, 0),
('ON_TRACK', 'GOAL_KR_STATUS', 'On Track', 'On track', 2, 0),
('AT_RISK', 'GOAL_KR_STATUS', 'At Risk', 'At risk', 3, 0),
('ACHIEVED', 'GOAL_KR_STATUS', 'Achieved', 'Achieved', 4, 1),
('NOT_ACHIEVED', 'GOAL_KR_STATUS', 'Not Achieved', 'Not achieved', 5, 1),

('ONLINE', 'TRAINING_MODE', 'Online', 'Online training', 1, 0),
('OFFLINE', 'TRAINING_MODE', 'Offline', 'In-person training', 2, 0),
('HYBRID', 'TRAINING_MODE', 'Hybrid', 'Mixed mode', 3, 0),
('SELF_PACED', 'TRAINING_MODE', 'Self Paced', 'Self-paced learning', 4, 0),

('UPCOMING', 'TRAINING_BATCH_STATUS', 'Upcoming', 'Batch not started', 1, 0),
('ONGOING', 'TRAINING_BATCH_STATUS', 'Ongoing', 'Currently ongoing', 2, 0),
('COMPLETED', 'TRAINING_BATCH_STATUS', 'Completed', 'Batch completed', 3, 1),
('CANCELLED', 'TRAINING_BATCH_STATUS', 'Cancelled', 'Cancelled', 4, 1),

('ENROLLED', 'TRAINING_RECORD_STATUS', 'Enrolled', 'Enrolled', 1, 0),
('IN_PROGRESS', 'TRAINING_RECORD_STATUS', 'In Progress', 'In progress', 2, 0),
('COMPLETED', 'TRAINING_RECORD_STATUS', 'Completed', 'Completed', 3, 1),
('FAILED', 'TRAINING_RECORD_STATUS', 'Failed', 'Failed', 4, 1),
('DROPPED', 'TRAINING_RECORD_STATUS', 'Dropped', 'Dropped out', 5, 1),
('ABSENT', 'TRAINING_RECORD_STATUS', 'Absent', 'Absent', 6, 1),

('STRONG_YES', 'RECOMMENDATION_STATUS', 'Strong Yes', 'Strong hire recommendation', 1, 0),
('YES', 'RECOMMENDATION_STATUS', 'Yes', 'Yes recommendation', 2, 0),
('MAYBE', 'RECOMMENDATION_STATUS', 'Maybe', 'Neutral', 3, 0),
('NO', 'RECOMMENDATION_STATUS', 'No', 'No recommendation', 4, 0),
('STRONG_NO', 'RECOMMENDATION_STATUS', 'Strong No', 'Strong no recommendation', 5, 0),

('SCHEDULED', 'INTERVIEW_STATUS', 'Scheduled', 'Interview scheduled', 1, 0),
('COMPLETED', 'INTERVIEW_STATUS', 'Completed', 'Interview completed', 2, 1),
('CANCELLED', 'INTERVIEW_STATUS', 'Cancelled', 'Cancelled', 3, 1),
('RESCHEDULED', 'INTERVIEW_STATUS', 'Rescheduled', 'Rescheduled', 4, 0),
('NO_SHOW', 'INTERVIEW_STATUS', 'No Show', 'Candidate no-show', 5, 1),

('DRAFT', 'JOB_POSTING_STATUS', 'Draft', 'Not published', 1, 0),
('OPEN', 'JOB_POSTING_STATUS', 'Open', 'Open for applications', 2, 0),
('ON_HOLD', 'JOB_POSTING_STATUS', 'On Hold', 'Temporarily paused', 3, 0),
('CLOSED', 'JOB_POSTING_STATUS', 'Closed', 'Closed', 4, 1),
('CANCELLED', 'JOB_POSTING_STATUS', 'Cancelled', 'Cancelled', 5, 1),

('APPLIED', 'APPLICATION_STATUS', 'Applied', 'Just applied', 1, 0),
('SCREENING', 'APPLICATION_STATUS', 'Screening', 'Under screening', 2, 0),
('INTERVIEW', 'APPLICATION_STATUS', 'Interview', 'In interview stage', 3, 0),
('OFFER', 'APPLICATION_STATUS', 'Offer', 'Offer extended', 4, 0),
('NEGOTIATION', 'APPLICATION_STATUS', 'Negotiation', 'Salary negotiation', 5, 0),
('HIRED', 'APPLICATION_STATUS', 'Hired', 'Offer accepted', 6, 1),
('REJECTED', 'APPLICATION_STATUS', 'Rejected', 'Application rejected', 7, 1),
('WITHDRAWN', 'APPLICATION_STATUS', 'Withdrawn', 'Withdrawn by candidate', 8, 1),

('ISSUED', 'OFFER_STATUS', 'Issued', 'Offer letter issued', 1, 0),
('ACCEPTED', 'OFFER_STATUS', 'Accepted', 'Offer accepted', 2, 1),
('REJECTED', 'OFFER_STATUS', 'Rejected', 'Offer rejected', 3, 1),
('EXPIRED', 'OFFER_STATUS', 'Expired', 'Offer expired', 4, 1),
('REVOKED', 'OFFER_STATUS', 'Revoked', 'Offer revoked', 5, 1),

('IN_PROGRESS', 'NEGOTIATION_STATUS', 'In Progress', 'Negotiation ongoing', 1, 0),
('ACCEPTED', 'NEGOTIATION_STATUS', 'Accepted', 'Negotiation accepted', 2, 1),
('REJECTED', 'NEGOTIATION_STATUS', 'Rejected', 'Negotiation rejected', 3, 1),
('COUNTERED', 'NEGOTIATION_STATUS', ' Countered', 'Counter offer', 4, 0),
('WITHDRAWN', 'NEGOTIATION_STATUS', 'Withdrawn', 'Negotiation withdrawn', 5, 1),

('PENDING',   'LEAVE_STATUS', 'Pending'  , 'Pending', 1, 0),
('APPROVED',  'LEAVE_STATUS', 'Approved' , 'Approved', 2, 0),
('REJECTED',  'LEAVE_STATUS', 'Rejected' , 'Rejected', 3, 0),
('CANCELLED', 'LEAVE_STATUS', 'Cancelled', 'Cancelled', 4, 0),

('DIRECT_MANAGER', 'RELATIONSHIP_TYPE', 'Primary reporting manager', 'Primary reporting manager', 1, 0),
('DOTTED_LINE_MANAGER', 'RELATIONSHIP_TYPE', 'Secondary reporting manager', 'Secondary reporting manager', 2, 0),
('MENTOR', 'RELATIONSHIP_TYPE', 'Mentor or coach', 'Mentor or coach', 3, 0),
('SKADOWN_MANAGER', 'RELATIONSHIP_TYPE', 'Skip-level manager', 'Skip-level manager', 4, 0),

('PHONE_SCREEN', 'INTERVIEW_TYPE', 'Phone Screen', 'Initial telephone screening', 1, 0),
('VIDEO_CALL', 'INTERVIEW_TYPE', 'Video Call', 'Video conference interview', 2, 0),
('IN_PERSON', 'INTERVIEW_TYPE', 'In Person', 'Face-to-face interview', 3, 0),
('TAKE_HOME', 'INTERVIEW_TYPE', 'Take Home Assignment', 'Coding or written assignment', 4, 0),
('PANEL', 'INTERVIEW_TYPE', 'Panel Interview', 'Multiple interviewers', 5, 0),

('TECHNICAL_DEPTH', 'INTERVIEW_PURPOSE', 'Technical Depth', 'Technical skills and knowledge', 1, 0),
('SYSTEM_DESIGN', 'INTERVIEW_PURPOSE', 'System Design', 'Architecture and system design', 2, 0),
('CULTURE_FIT', 'INTERVIEW_PURPOSE', 'Culture Fit', 'Cultural alignment', 3, 0),
('HR_FITMENT', 'INTERVIEW_PURPOSE', 'HR Fitment', 'HR and soft skills assessment', 4, 0),
('LEADERSHIP', 'INTERVIEW_PURPOSE', 'Leadership', 'Leadership potential', 5, 0),

('TECHNICAL',   'TRAINING_CATEGORY', 'Technical skills and certifications', 'Technical skills and certifications', 1, 0),
('COMPLIANCE',  'TRAINING_CATEGORY', 'Compliance and regulatory training', 'Compliance and regulatory training', 1, 0),
('LEADERSHIP',  'TRAINING_CATEGORY', 'Leadership development', 'Leadership development', 1, 0),
('SOFT_SKILLS', 'TRAINING_CATEGORY', 'Communication and interpersonal skills', 'Communication and interpersonal skills', 1, 0),
('DOMAIN',      'TRAINING_CATEGORY', 'Industry and domain-specific knowledge', 'Industry and domain-specific knowledge', 1, 0),

('Better Opportunity','EXIT_REASON', 'VOLUNTARY', 'Better Opportunity', 1, 0),
('Higher Education', 'EXIT_REASON', 'VOLUNTARY', 'Higher Education', 2, 0),
('Career Change', 'EXIT_REASON', 'VOLUNTARY', 'Career Change', 3, 0),
('Relocation', 'EXIT_REASON', 'VOLUNTARY', 'Relocation', 4, 0),
('Work Life Balance', 'EXIT_REASON', 'VOLUNTARY', 'Work Life Balance', 5, 0),
('Salary', 'EXIT_REASON', 'VOLUNTARY', 'Salary',  6, 0),
('Manager/Work Environment', 'EXIT_REASON', 'VOLUNTARY', 'Manager/Work Environment', 7, 0),
('Performance', 'EXIT_REASON', 'INVOLUNTARY', 'Performance',  8, 0),
('Conduct', 'EXIT_REASON', 'INVOLUNTARY', 'Conduct',  9, 0),
('Redundancy', 'EXIT_REASON', 'INVOLUNTARY', 'Redundancy', 10, 0),
('Absconding', 'EXIT_REASON', 'INVOLUNTARY', 'Absconding', 11, 0),
('Death', 'EXIT_REASON', 'INVOLUNTARY', 'Death', 12, 0),

('APPROVAL', 'WORKFLOW_STEP_TYPE', 'Approval', 'Approval', 1, 0),
('REVIEW', 'WORKFLOW_STEP_TYPE', 'Review', 'Approval', 2, 0),
('NOTIFICATION', 'WORKFLOW_STEP_TYPE', 'Notification', 'Notification', 3, 0),
('AUTO_APPROVAL', 'WORKFLOW_STEP_TYPE', 'Auto Approval', 'Auto Approval', 4, 0),

('REPORTING_MANAGER', 'WORKFLOW_APPROVER_TYPE', 'Reporting Manager', 'Reporting Manager', 1, 0),
('ROLE_BASED', 'WORKFLOW_APPROVER_TYPE', 'Role-Based Approver', 'Role-Based Approver', 2, 0),
('SPECIFIC_USER', 'WORKFLOW_APPROVER_TYPE', 'Specific User', 'Specific User', 3, 0),
('DEPARTMENT_HEAD', 'WORKFLOW_APPROVER_TYPE', 'Department Head', 'Department Head', 4, 0),
('HR_MANAGER', 'WORKFLOW_APPROVER_TYPE', 'HR Manager', 'HR Manager', 5, 0),

('PENDING', 'WORKFLOW_STATUS', 'Pending', 'Pending', 1, 0),
('IN_PROGRESS', 'WORKFLOW_STATUS', 'In Progress', 'In Progress', 2, 0),
('APPROVED', 'WORKFLOW_STATUS', 'Approved' , 'Approved', 3, 0),
('REJECTED', 'WORKFLOW_STATUS', 'Rejected' , 'Rejected', 4, 0),
('CANCELLED', 'WORKFLOW_STATUS', 'Cancelled', 'Cancelled', 5, 0),

('SUBMIT', 'WORKFLOW_ACTION_TYPE', 'Submit', 'Submit', 1, 0),
('APPROVE', 'WORKFLOW_ACTION_TYPE', 'Approve', 'Approve', 2, 0),
('REJECT', 'WORKFLOW_ACTION_TYPE', 'Reject', 'Reject', 3, 0),
('RETURN', 'WORKFLOW_ACTION_TYPE', 'Return for Correction', 'Return for Correction', 4, 0),
('ESCALATE', 'WORKFLOW_ACTION_TYPE', 'Escalate', 'Escalate', 5, 0),
('CANCEL', 'WORKFLOW_ACTION_TYPE', 'Cancel', 'Cancel', 6, 0);

GO

PRINT 'Shared schema created with StatusLookup table and seed data';
GO