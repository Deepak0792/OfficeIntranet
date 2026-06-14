-- ============================================================
-- shared.StatusLookup - FULL SEED DATA
-- Grouped by consuming schema (derived from schema-table-column mapping)
-- ============================================================

-- ============================================================
-- SCHEMA: workflow
-- Groups: WORKFLOW_STEP_TYPE, WORKFLOW_APPROVER_TYPE, WORKFLOW_STATUS,
--         WORKFLOW_TASK_STATUS, WORKFLOW_ACTION_TYPE
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- WORKFLOW_STEP_TYPE
('APPROVAL',      'WORKFLOW_STEP_TYPE', 'Approval',      'Manual approval step',          1, 0),
('REVIEW',        'WORKFLOW_STEP_TYPE', 'Review',         'Review step',                  2, 0),
('NOTIFICATION',  'WORKFLOW_STEP_TYPE', 'Notification',   'Notification step',            3, 0),
('AUTO_APPROVAL', 'WORKFLOW_STEP_TYPE', 'Auto Approval',  'Automatic approval step',      4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- WORKFLOW_APPROVER_TYPE
('EMPLOYEE',          'WORKFLOW_APPROVER_TYPE', 'Fixed Employee',     'Specific fixed employee approver',  1, 0),
('ROLE',              'WORKFLOW_APPROVER_TYPE', 'By Role',            'Approver resolved by role',         2, 0),
('DESIGNATION',       'WORKFLOW_APPROVER_TYPE', 'By Designation',     'Approver resolved by designation',  3, 0),
('REPORTING_MANAGER', 'WORKFLOW_APPROVER_TYPE', 'Reporting Manager',  'Direct reporting manager',          4, 0),
('SKIP_MANAGER',      'WORKFLOW_APPROVER_TYPE', 'Skip Level Manager', 'Skip-level manager',                5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- WORKFLOW_STATUS (Terminal: APPROVED, REJECTED, CANCELLED, WITHDRAWN)
('DRAFT',       'WORKFLOW_STATUS', 'Draft',            'Workflow not yet submitted',   1, 0),
('PENDING',     'WORKFLOW_STATUS', 'Pending Approval', 'Awaiting first approval',      2, 0),
('IN_PROGRESS', 'WORKFLOW_STATUS', 'In Progress',      'Approval chain in progress',   3, 0),
('APPROVED',    'WORKFLOW_STATUS', 'Approved',         'Fully approved',               4, 1),
('REJECTED',    'WORKFLOW_STATUS', 'Rejected',         'Rejected by an approver',      5, 1),
('CANCELLED',   'WORKFLOW_STATUS', 'Cancelled',        'Cancelled by initiator',       6, 1),
('WITHDRAWN',   'WORKFLOW_STATUS', 'Withdrawn',        'Withdrawn before completion',  7, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- WORKFLOW_ACTION_TYPE
('SUBMIT',   'WORKFLOW_ACTION_TYPE', 'Submitted',                 'Request submitted to workflow',       1, 0),
('APPROVE',  'WORKFLOW_ACTION_TYPE', 'Approved',                  'Approved at this step',               2, 0),
('REJECT',   'WORKFLOW_ACTION_TYPE', 'Rejected',                  'Rejected at this step',               3, 0),
('DELEGATE', 'WORKFLOW_ACTION_TYPE', 'Delegated',                 'Task delegated to another',           4, 0),
('ESCALATE', 'WORKFLOW_ACTION_TYPE', 'Escalated',                 'Escalated due to SLA breach',         5, 0),
('CANCEL',   'WORKFLOW_ACTION_TYPE', 'Cancelled',                 'Cancelled by initiator',              6, 0),
('WITHDRAW', 'WORKFLOW_ACTION_TYPE', 'Withdrawn',                 'Withdrawn by initiator',              7, 0),
('REASSIGN', 'WORKFLOW_ACTION_TYPE', 'Reassigned',                'Task reassigned to another approver', 8, 0),
('RETURN',   'WORKFLOW_ACTION_TYPE', 'Return for Clarification',  'Returned for more information',       9, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- WORKFLOW_TASK_STATUS (Terminal: COMPLETED, DELEGATED, CANCELLED)
('PENDING',   'WORKFLOW_TASK_STATUS', 'Pending',   'Task awaiting action',          1, 0),
('COMPLETED', 'WORKFLOW_TASK_STATUS', 'Completed', 'Task completed by approver',    2, 1),
('DELEGATED', 'WORKFLOW_TASK_STATUS', 'Delegated', 'Task delegated to another',     3, 1),
('CANCELLED', 'WORKFLOW_TASK_STATUS', 'Cancelled', 'Task cancelled',                4, 1),
('ESCALATED', 'WORKFLOW_TASK_STATUS', 'Escalated', 'Task escalated',                5, 0);
GO


-- ============================================================
-- SCHEMA: employee
-- Groups: EMPLOYMENT_TYPE, RELATIONSHIP_TYPE, CONTACT_TYPE, ADDRESS_TYPE
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EMPLOYMENT_TYPE
('FULL_TIME', 'EMPLOYMENT_TYPE', 'Full Time', 'Regular full-time employee',   1, 0),
('PART_TIME', 'EMPLOYMENT_TYPE', 'Part Time', 'Part-time employee',           2, 0),
('CONTRACT',  'EMPLOYMENT_TYPE', 'Contract',  'Contractual employee',         3, 0),
('INTERIM',   'EMPLOYMENT_TYPE', 'Interim',   'Interim or temporary',         4, 0),
('INTERN',    'EMPLOYMENT_TYPE', 'Intern',    'Intern or trainee',            5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- RELATIONSHIP_TYPE
('DIRECT_MANAGER',       'RELATIONSHIP_TYPE', 'Direct Manager',       'Primary reporting manager',        1, 0),
('DOTTED_LINE_MANAGER',  'RELATIONSHIP_TYPE', 'Dotted Line Manager',  'Secondary reporting manager',      2, 0),
('HEAD_DEPARTMENT',      'RELATIONSHIP_TYPE', 'Head of Department',   'Head of department oversight',     3, 0),
('SKADOWN_MANAGER',      'RELATIONSHIP_TYPE', 'Skip-Level Manager',   'Skip-level manager',               4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- CONTACT_TYPE
('WORK_PHONE',     'CONTACT_TYPE', 'Work Phone',    'Office telephone',          1, 0),
('PERSONAL_EMAIL', 'CONTACT_TYPE', 'Personal Email','Personal email address',    2, 0),
('SLACK',          'CONTACT_TYPE', 'Slack',         'Slack username',            3, 0),
('SKYPE',          'CONTACT_TYPE', 'Skype',         'Skype ID',                  4, 0),
('TEAMS',          'CONTACT_TYPE', 'Microsoft Teams','Teams ID',                 5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- ADDRESS_TYPE
('PERMANENT', 'ADDRESS_TYPE', 'Permanent Address', 'Permanent or home address registered with the organization. Used for official correspondence and background verification.', 1, 0),
('CURRENT',   'ADDRESS_TYPE', 'Current Address',   'Current residential address where the employee is presently staying. May differ from permanent address.',                  2, 0),
('MAILING',   'ADDRESS_TYPE', 'Mailing Address',   'Preferred postal or mailing address for sending documents, letters, and physical communications.',                        3, 0),
('EMERGENCY', 'ADDRESS_TYPE', 'Emergency Address', 'Address of the emergency contact person. Used when the employee cannot be reached directly.',                             4, 0),
('WORK',      'ADDRESS_TYPE', 'Work Address',      'On-site or client work location address. Used when an employee is deployed at a location different from their office.',   5, 0);
GO


-- ============================================================
-- SCHEMA: attendance
-- Groups: LEAVE_STATUS, ATTENDANCE_REGULARIZATION_STATUS,
--         OUTBOX_STATUS, SHIFT_SWAP_STATUS, ROSTER_GENERATION_TYPE
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- LEAVE_STATUS
('PENDING',   'LEAVE_STATUS', 'Pending',   'Awaiting approval',  1, 0),
('APPROVED',  'LEAVE_STATUS', 'Approved',  'Leave approved',     2, 1),
('REJECTED',  'LEAVE_STATUS', 'Rejected',  'Leave rejected',     3, 1),
('CANCELLED', 'LEAVE_STATUS', 'Cancelled', 'Leave cancelled',    4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- ATTENDANCE_REGULARIZATION_STATUS
('PENDING',  'ATTENDANCE_REGULARIZATION_STATUS', 'Pending',  'Awaiting approval',             1, 0),
('APPROVED', 'ATTENDANCE_REGULARIZATION_STATUS', 'Approved', 'Regularization approved',       2, 1),
('REJECTED', 'ATTENDANCE_REGULARIZATION_STATUS', 'Rejected', 'Regularization rejected',       3, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- OUTBOX_STATUS
('PENDING',      'OUTBOX_STATUS', 'Pending',      'Message created and waiting to be processed/published.',  1, 0),
('PUBLISHED',    'OUTBOX_STATUS', 'Published',    'Message successfully published to the exchange.',         2, 1),
('RETRYING',     'OUTBOX_STATUS', 'Retrying',     'Message processing failed but will be retried.',          3, 0),
('DEAD_LETTERED','OUTBOX_STATUS', 'Dead Lettered','Message moved to dead-letter queue after max retries.',   4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- SHIFT_SWAP_STATUS
('PENDING',   'SHIFT_SWAP_STATUS', 'Pending',   'Awaiting approval',  1, 0),
('APPROVED',  'SHIFT_SWAP_STATUS', 'Approved',  'Swap approved',      2, 1),
('REJECTED',  'SHIFT_SWAP_STATUS', 'Rejected',  'Swap rejected',      3, 1),
('CANCELLED', 'SHIFT_SWAP_STATUS', 'Cancelled', 'Swap cancelled',     4, 1);

-- NOTE: ROSTER_GENERATION_TYPE is referenced in attendance.EmployeeRosterGenerationTracker
-- but no seed values were defined in the original seed file. Add here when values are known.
-- INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
-- VALUES ('MANUAL', 'ROSTER_GENERATION_TYPE', 'Manual', 'Manually generated roster', 1, 0),
--        ('AUTO',   'ROSTER_GENERATION_TYPE', 'Automatic', 'System-generated roster', 2, 0);
GO


-- ============================================================
-- SCHEMA: hr
-- Groups: INTERVIEW_TYPE, JOB_POSTING_STATUS, APPLICATION_STATUS,
--         INTERVIEW_STATUS, INTERVIEW_PURPOSE, RECOMMENDATION_STATUS,
--         NEGOTIATION_STATUS, OFFER_STATUS, ONBOARDING_TASK_STATUS,
--         ONBOARDING_PHASE, DOC_VERIFY_STATUS, BGV_CHECK_TYPE,
--         BGV_STATUS, BGV_RESULT, POLICY_STATUS, POLICY_ACK_STATUS,
--         PERF_CYCLE_TYPE, PERF_CYCLE_STATUS, GOAL_STATUS,
--         GOAL_KR_STATUS, PERF_REVIEW_STATUS, TRAINING_CATEGORY,
--         TRAINING_MODE, TRAINING_BATCH_STATUS, TRAINING_RECORD_STATUS,
--         EXIT_TYPE, EXIT_INTERVIEW_STATUS, CLEARANCE_STATUS,
--         FINAL_SETTLEMENT_STATUS, CLEARANCE_ITEM_STATUS
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- INTERVIEW_TYPE
('PHONE_SCREEN', 'INTERVIEW_TYPE', 'Phone Screen',          'Initial telephone screening',          1, 0),
('VIDEO_CALL',   'INTERVIEW_TYPE', 'Video Call',            'Video conference interview',           2, 0),
('IN_PERSON',    'INTERVIEW_TYPE', 'In Person',             'Face-to-face interview',               3, 0),
('TAKE_HOME',    'INTERVIEW_TYPE', 'Take Home Assignment',  'Coding or written assignment',         4, 0),
('PANEL',        'INTERVIEW_TYPE', 'Panel Interview',       'Multiple interviewers',                5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- JOB_POSTING_STATUS
('DRAFT',      'JOB_POSTING_STATUS', 'Draft',     'Not published',                 1, 0),
('OPEN',       'JOB_POSTING_STATUS', 'Open',      'Open for applications',         2, 0),
('ON_HOLD',    'JOB_POSTING_STATUS', 'On Hold',   'Temporarily paused',            3, 0),
('CLOSED',     'JOB_POSTING_STATUS', 'Closed',    'Closed',                        4, 1),
('CANCELLED',  'JOB_POSTING_STATUS', 'Cancelled', 'Cancelled',                     5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- APPLICATION_STATUS
('APPLIED',      'APPLICATION_STATUS', 'Applied',      'Just applied',                 1, 0),
('SCREENING',    'APPLICATION_STATUS', 'Screening',    'Under screening',              2, 0),
('INTERVIEW',    'APPLICATION_STATUS', 'Interview',    'In interview stage',           3, 0),
('OFFER',        'APPLICATION_STATUS', 'Offer',        'Offer extended',               4, 0),
('NEGOTIATION',  'APPLICATION_STATUS', 'Negotiation',  'Salary negotiation',           5, 0),
('HIRED',        'APPLICATION_STATUS', 'Hired',        'Offer accepted',               6, 1),
('REJECTED',     'APPLICATION_STATUS', 'Rejected',     'Application rejected',         7, 1),
('WITHDRAWN',    'APPLICATION_STATUS', 'Withdrawn',    'Withdrawn by candidate',       8, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- INTERVIEW_STATUS
('SCHEDULED',    'INTERVIEW_STATUS', 'Scheduled',    'Interview scheduled',           1, 0),
('COMPLETED',    'INTERVIEW_STATUS', 'Completed',    'Interview completed',           2, 1),
('CANCELLED',    'INTERVIEW_STATUS', 'Cancelled',    'Cancelled',                     3, 1),
('RESCHEDULED',  'INTERVIEW_STATUS', 'Rescheduled',  'Rescheduled',                   4, 0),
('NO_SHOW',      'INTERVIEW_STATUS', 'No Show',      'Candidate no-show',             5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- INTERVIEW_PURPOSE
('TECHNICAL_DEPTH',  'INTERVIEW_PURPOSE', 'Technical Depth',    'Technical skills and knowledge',                             1, 0),
('SYSTEM_DESIGN',    'INTERVIEW_PURPOSE', 'System Design',      'Architecture and system design',                             2, 0),
('CULTURE_FIT',      'INTERVIEW_PURPOSE', 'Culture Fit',        'Cultural alignment',                                         3, 0),
('HR_FITMENT',       'INTERVIEW_PURPOSE', 'HR Fitment',         'HR and soft skills assessment',                              4, 0),
('LEADERSHIP',       'INTERVIEW_PURPOSE', 'Leadership',         'Leadership potential',                                       5, 0),
('CLINICAL_KNOWLEDGE','INTERVIEW_PURPOSE','Clinical Knowledge',  'Clinical expertise and medical knowledge assessment',        6, 0),
('PROBLEM_SOLVING',  'INTERVIEW_PURPOSE', 'Problem Solving',    'Analytical thinking and problem-solving capability',         7, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- RECOMMENDATION_STATUS
('STRONG_YES', 'RECOMMENDATION_STATUS', 'Strong Yes', 'Strong hire recommendation',   1, 0),
('YES',        'RECOMMENDATION_STATUS', 'Yes',        'Yes recommendation',           2, 0),
('MAYBE',      'RECOMMENDATION_STATUS', 'Maybe',      'Neutral',                      3, 0),
('NO',         'RECOMMENDATION_STATUS', 'No',         'No recommendation',            4, 0),
('STRONG_NO',  'RECOMMENDATION_STATUS', 'Strong No',  'Strong no recommendation',     5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- NEGOTIATION_STATUS
('IN_PROGRESS', 'NEGOTIATION_STATUS', 'In Progress', 'Negotiation ongoing',       1, 0),
('ACCEPTED',    'NEGOTIATION_STATUS', 'Accepted',    'Negotiation accepted',      2, 1),
('REJECTED',    'NEGOTIATION_STATUS', 'Rejected',    'Negotiation rejected',      3, 1),
('COUNTERED',   'NEGOTIATION_STATUS', 'Countered',   'Counter offer made',        4, 0),
('WITHDRAWN',   'NEGOTIATION_STATUS', 'Withdrawn',   'Negotiation withdrawn',     5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- OFFER_STATUS
('ISSUED',   'OFFER_STATUS', 'Issued',   'Offer letter issued',   1, 0),
('ACCEPTED', 'OFFER_STATUS', 'Accepted', 'Offer accepted',        2, 1),
('REJECTED', 'OFFER_STATUS', 'Rejected', 'Offer rejected',        3, 1),
('EXPIRED',  'OFFER_STATUS', 'Expired',  'Offer expired',         4, 1),
('REVOKED',  'OFFER_STATUS', 'Revoked',  'Offer revoked',         5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- ONBOARDING_TASK_STATUS
('PENDING',     'ONBOARDING_TASK_STATUS', 'Pending',     'Task not started',      1, 0),
('IN_PROGRESS', 'ONBOARDING_TASK_STATUS', 'In Progress', 'Task in progress',      2, 0),
('COMPLETED',   'ONBOARDING_TASK_STATUS', 'Completed',   'Task completed',        3, 1),
('WAIVED',      'ONBOARDING_TASK_STATUS', 'Waived',      'Task waived',           4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- ONBOARDING_PHASE
('PRE_ONBOARDING',  'ONBOARDING_PHASE', 'Pre-Onboarding',  'Before joining',    1, 0),
('POST_ONBOARDING', 'ONBOARDING_PHASE', 'Post-Onboarding', 'After joining',     2, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- DOC_VERIFY_STATUS
('PENDING',      'DOC_VERIFY_STATUS', 'Pending',      'Not submitted',     1, 0),
('SUBMITTED',    'DOC_VERIFY_STATUS', 'Submitted',    'Document submitted',2, 0),
('UNDER_REVIEW', 'DOC_VERIFY_STATUS', 'Under Review', 'Being reviewed',    3, 0),
('VERIFIED',     'DOC_VERIFY_STATUS', 'Verified',     'Verified',          4, 1),
('REJECTED',     'DOC_VERIFY_STATUS', 'Rejected',     'Rejected',          5, 1),
('RESUBMITTED',  'DOC_VERIFY_STATUS', 'Resubmitted',  'Resubmitted',       6, 0),
('EXPIRED',      'DOC_VERIFY_STATUS', 'Expired',      'Expired',           7, 1),
('WAIVED',       'DOC_VERIFY_STATUS', 'Waived',       'Waived',            8, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- BGV_CHECK_TYPE
('CRIMINAL',          'BGV_CHECK_TYPE', 'Criminal',          'Criminal background check',         1, 0),
('EMPLOYMENT_HISTORY','BGV_CHECK_TYPE', 'Employment History','Previous employment verification',   2, 0),
('EDUCATION',         'BGV_CHECK_TYPE', 'Education',         'Education verification',            3, 0),
('IDENTITY',          'BGV_CHECK_TYPE', 'Identity',          'Identity verification',             4, 0),
('CREDIT',            'BGV_CHECK_TYPE', 'Credit',            'Credit check',                      5, 0),
('REFERENCE',         'BGV_CHECK_TYPE', 'Reference',         'Reference check',                   6, 0),
('DRUG_TEST',         'BGV_CHECK_TYPE', 'Drug Test',         'Drug screening',                    7, 0),
('ADDRESS',           'BGV_CHECK_TYPE', 'Address',           'Address verification',              8, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- BGV_STATUS
('PENDING',           'BGV_STATUS', 'Pending',           'Not started',                  1, 0),
('IN_PROGRESS',       'BGV_STATUS', 'In Progress',       'Verification in progress',     2, 0),
('COMPLETED',         'BGV_STATUS', 'Completed',         'Completed',                    3, 1),
('DISCREPANCY_FOUND', 'BGV_STATUS', 'Discrepancy Found', 'Discrepancy found',            4, 1),
('FAILED',            'BGV_STATUS', 'Failed',            'Verification failed',          5, 1),
('WAIVED',            'BGV_STATUS', 'Waived',            'Waived',                       6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- BGV_RESULT
('CLEAR',           'BGV_RESULT', 'Clear',           'All clear',              1, 0),
('DISCREPANCY',     'BGV_RESULT', 'Discrepancy',     'Discrepancy found',      2, 0),
('UNABLE_TO_VERIFY','BGV_RESULT', 'Unable to Verify','Could not verify',       3, 0),
('FAILED',          'BGV_RESULT', 'Failed',          'Verification failed',    4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- POLICY_STATUS
('DRAFT',      'POLICY_STATUS', 'Draft',      'Policy draft',                   1, 0),
('ACTIVE',     'POLICY_STATUS', 'Active',     'Active policy',                  2, 0),
('ARCHIVED',   'POLICY_STATUS', 'Archived',   'Archived',                       3, 1),
('SUPERSEDED', 'POLICY_STATUS', 'Superseded', 'Superseded by new version',      4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- POLICY_ACK_STATUS
('PENDING',      'POLICY_ACK_STATUS', 'Pending',      'Not acknowledged',              1, 0),
('ACKNOWLEDGED', 'POLICY_ACK_STATUS', 'Acknowledged', 'Acknowledged',                 2, 1),
('OVERDUE',      'POLICY_ACK_STATUS', 'Overdue',      'Acknowledgement overdue',       3, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- PERF_CYCLE_TYPE
('ANNUAL',     'PERF_CYCLE_TYPE', 'Annual',    'Annual cycle',       1, 0),
('BI_ANNUAL',  'PERF_CYCLE_TYPE', 'Bi-Annual', 'Twice a year',       2, 0),
('QUARTERLY',  'PERF_CYCLE_TYPE', 'Quarterly', 'Quarterly',          3, 0),
('PROBATION',  'PERF_CYCLE_TYPE', 'Probation', 'Probation review',   4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- PERF_CYCLE_STATUS
('UPCOMING',     'PERF_CYCLE_STATUS', 'Upcoming',     'Cycle not started',           1, 0),
('GOAL_SETTING', 'PERF_CYCLE_STATUS', 'Goal Setting', 'Employee setting goals',      2, 0),
('IN_REVIEW',    'PERF_CYCLE_STATUS', 'In Review',    'Manager reviewing',           3, 0),
('COMPLETED',    'PERF_CYCLE_STATUS', 'Completed',    'Cycle completed',             4, 1),
('ARCHIVED',     'PERF_CYCLE_STATUS', 'Archived',     'Archived',                    5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- GOAL_STATUS
('DRAFT',       'GOAL_STATUS', 'Draft',       'Goal draft',                    1, 0),
('SUBMITTED',   'GOAL_STATUS', 'Submitted',   'Submitted for approval',        2, 0),
('APPROVED',    'GOAL_STATUS', 'Approved',    'Approved by manager',           3, 1),
('IN_PROGRESS', 'GOAL_STATUS', 'In Progress', 'In progress',                   4, 0),
('COMPLETED',   'GOAL_STATUS', 'Completed',   'Completed',                     5, 1),
('CANCELLED',   'GOAL_STATUS', 'Cancelled',   'Cancelled',                     6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- GOAL_KR_STATUS
('PENDING',      'GOAL_KR_STATUS', 'Pending',      'Not started',   1, 0),
('ON_TRACK',     'GOAL_KR_STATUS', 'On Track',     'On track',      2, 0),
('AT_RISK',      'GOAL_KR_STATUS', 'At Risk',      'At risk',       3, 0),
('ACHIEVED',     'GOAL_KR_STATUS', 'Achieved',     'Achieved',      4, 1),
('NOT_ACHIEVED', 'GOAL_KR_STATUS', 'Not Achieved', 'Not achieved',  5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- PERF_REVIEW_STATUS
('PENDING',        'PERF_REVIEW_STATUS', 'Pending',        'Review not started',         1, 0),
('SELF_SUBMITTED', 'PERF_REVIEW_STATUS', 'Self Submitted', 'Self assessment done',       2, 0),
('MANAGER_REVIEW', 'PERF_REVIEW_STATUS', 'Manager Review', 'Manager reviewing',          3, 0),
('HRBP_REVIEW',    'PERF_REVIEW_STATUS', 'HRBP Review',    'HRBP reviewing',             4, 0),
('COMPLETED',      'PERF_REVIEW_STATUS', 'Completed',      'Review completed',           5, 1),
('ACKNOWLEDGED',   'PERF_REVIEW_STATUS', 'Acknowledged',   'Acknowledged by employee',   6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TRAINING_CATEGORY
('TECHNICAL',   'TRAINING_CATEGORY', 'Technical',   'Technical skills and certifications',          1, 0),
('COMPLIANCE',  'TRAINING_CATEGORY', 'Compliance',  'Compliance and regulatory training',           2, 0),
('LEADERSHIP',  'TRAINING_CATEGORY', 'Leadership',  'Leadership development',                       3, 0),
('SOFT_SKILLS', 'TRAINING_CATEGORY', 'Soft Skills', 'Communication and interpersonal skills',       4, 0),
('DOMAIN',      'TRAINING_CATEGORY', 'Domain',      'Industry and domain-specific knowledge',       5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TRAINING_MODE
('ONLINE',      'TRAINING_MODE', 'Online',     'Online training',        1, 0),
('OFFLINE',     'TRAINING_MODE', 'Offline',    'In-person training',     2, 0),
('HYBRID',      'TRAINING_MODE', 'Hybrid',     'Mixed mode',             3, 0),
('SELF_PACED',  'TRAINING_MODE', 'Self Paced', 'Self-paced learning',    4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TRAINING_BATCH_STATUS
('UPCOMING',  'TRAINING_BATCH_STATUS', 'Upcoming',  'Batch not started',       1, 0),
('ONGOING',   'TRAINING_BATCH_STATUS', 'Ongoing',   'Currently ongoing',       2, 0),
('COMPLETED', 'TRAINING_BATCH_STATUS', 'Completed', 'Batch completed',         3, 1),
('CANCELLED', 'TRAINING_BATCH_STATUS', 'Cancelled', 'Cancelled',               4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TRAINING_RECORD_STATUS
('ENROLLED',    'TRAINING_RECORD_STATUS', 'Enrolled',    'Enrolled',       1, 0),
('IN_PROGRESS', 'TRAINING_RECORD_STATUS', 'In Progress', 'In progress',    2, 0),
('COMPLETED',   'TRAINING_RECORD_STATUS', 'Completed',   'Completed',      3, 1),
('FAILED',      'TRAINING_RECORD_STATUS', 'Failed',      'Failed',         4, 1),
('DROPPED',     'TRAINING_RECORD_STATUS', 'Dropped',     'Dropped out',    5, 1),
('ABSENT',      'TRAINING_RECORD_STATUS', 'Absent',      'Absent',         6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EXIT_TYPE
('RESIGNATION',  'EXIT_TYPE', 'Resignation',  'Voluntary resignation',             1, 0),
('TERMINATION',  'EXIT_TYPE', 'Termination',  'Company-initiated termination',     2, 0),
('RETIREMENT',   'EXIT_TYPE', 'Retirement',   'Retirement',                        3, 0),
('CONTRACT_END', 'EXIT_TYPE', 'Contract End', 'Contract expiration',               4, 0),
('ABSCONDING',   'EXIT_TYPE', 'Absconding',   'Absconded',                         5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EXIT_INTERVIEW_STATUS
('PENDING',   'EXIT_INTERVIEW_STATUS', 'Pending',   'Not scheduled',           1, 0),
('SCHEDULED', 'EXIT_INTERVIEW_STATUS', 'Scheduled', 'Interview scheduled',     2, 0),
('COMPLETED', 'EXIT_INTERVIEW_STATUS', 'Completed', 'Interview completed',     3, 1),
('SKIPPED',   'EXIT_INTERVIEW_STATUS', 'Skipped',   'Interview skipped',       4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- CLEARANCE_STATUS
('PENDING',     'CLEARANCE_STATUS', 'Pending',     'Clearance not started',     1, 0),
('IN_PROGRESS', 'CLEARANCE_STATUS', 'In Progress', 'Clearance in progress',     2, 0),
('COMPLETED',   'CLEARANCE_STATUS', 'Completed',   'Clearance completed',       3, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- FINAL_SETTLEMENT_STATUS
('PENDING',   'FINAL_SETTLEMENT_STATUS', 'Pending',   'Settlement not processed',  1, 0),
('PROCESSED', 'FINAL_SETTLEMENT_STATUS', 'Processed', 'Settlement processed',      2, 0),
('PAID',      'FINAL_SETTLEMENT_STATUS', 'Paid',      'Settlement paid',           3, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- CLEARANCE_ITEM_STATUS
('PENDING',   'CLEARANCE_ITEM_STATUS', 'Pending',   'Item not completed',  1, 0),
('COMPLETED', 'CLEARANCE_ITEM_STATUS', 'Completed', 'Item completed',      2, 1),
('WAIVED',    'CLEARANCE_ITEM_STATUS', 'Waived',    'Item waived',         3, 1);
GO


-- ============================================================
-- SCHEMA: payroll
-- Groups: CALC_TYPE, SALARY_REVISION_TYPE, BANK_ACCOUNT_TYPE,
--         DISBURSEMENT_STATUS, TRANSACTION_STATUS, PAYMENT_MODE_TYPE,
--         DECLARATION_STATUS, PROOF_REVIEW_STATUS, DEDUCTION_CATEGORY,
--         SALARY_SLIP_STATUS
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- CALC_TYPE
('FIXED',      'CALC_TYPE', 'Fixed',      'Fixed amount',      1, 0),
('PERCENTAGE', 'CALC_TYPE', 'Percentage', 'Percentage of base',2, 0),
('FORMULA',    'CALC_TYPE', 'Formula',    'Custom formula',    3, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- SALARY_REVISION_TYPE
('ANNUAL_INCREMENT',  'SALARY_REVISION_TYPE', 'Annual Increment',  'Annual salary review',         1, 0),
('PROMOTION',         'SALARY_REVISION_TYPE', 'Promotion',         'Promotion-based increase',     2, 0),
('CORRECTION',        'SALARY_REVISION_TYPE', 'Correction',        'Salary correction',            3, 0),
('JOINING',           'SALARY_REVISION_TYPE', 'Joining',           'New hire salary',              4, 0),
('MARKET_CORRECTION', 'SALARY_REVISION_TYPE', 'Market Correction', 'Market-aligned salary',        5, 0),
('OTHER',             'SALARY_REVISION_TYPE', 'Other',             'Other revision type',          6, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- BANK_ACCOUNT_TYPE
('SAVINGS', 'BANK_ACCOUNT_TYPE', 'Savings', 'Savings account', 1, 0),
('CURRENT', 'BANK_ACCOUNT_TYPE', 'Current', 'Current account', 2, 0),
('SALARY',  'BANK_ACCOUNT_TYPE', 'Salary',  'Salary account',  3, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- DISBURSEMENT_STATUS
('DRAFT',      'DISBURSEMENT_STATUS', 'Draft',      'Draft status',              1, 0),
('APPROVED',   'DISBURSEMENT_STATUS', 'Approved',   'Approved for processing',   2, 0),
('PROCESSING', 'DISBURSEMENT_STATUS', 'Processing', 'Being processed',           3, 0),
('COMPLETED',  'DISBURSEMENT_STATUS', 'Completed',  'Successfully completed',    4, 1),
('FAILED',     'DISBURSEMENT_STATUS', 'Failed',     'Processing failed',         5, 1),
('CANCELLED',  'DISBURSEMENT_STATUS', 'Cancelled',  'Cancelled',                 6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TRANSACTION_STATUS
('PENDING',   'TRANSACTION_STATUS', 'Pending',   'Awaiting processing',       1, 0),
('INITIATED', 'TRANSACTION_STATUS', 'Initiated', 'Transaction initiated',     2, 0),
('SUCCESS',   'TRANSACTION_STATUS', 'Success',   'Transaction successful',    3, 1),
('FAILED',    'TRANSACTION_STATUS', 'Failed',    'Transaction failed',        4, 1),
('REVERSED',  'TRANSACTION_STATUS', 'Reversed',  'Transaction reversed',      5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- PAYMENT_MODE_TYPE
('NEFT',   'PAYMENT_MODE_TYPE', 'NEFT',   'National Electronic Fund Transfer', 1, 0),
('RTGS',   'PAYMENT_MODE_TYPE', 'RTGS',   'Real Time Gross Settlement',        2, 0),
('IMPS',   'PAYMENT_MODE_TYPE', 'IMPS',   'Immediate Payment Service',         3, 0),
('CHEQUE', 'PAYMENT_MODE_TYPE', 'Cheque', 'Cheque payment',                    4, 0),
('CASH',   'PAYMENT_MODE_TYPE', 'Cash',   'Cash payment',                      5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- DECLARATION_STATUS
('DRAFT',     'DECLARATION_STATUS', 'Draft',     'Draft declaration',        1, 0),
('SUBMITTED', 'DECLARATION_STATUS', 'Submitted', 'Submitted for review',     2, 0),
('VERIFIED',  'DECLARATION_STATUS', 'Verified',  'Verified by finance',      3, 1),
('REJECTED',  'DECLARATION_STATUS', 'Rejected',  'Rejected',                 4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- PROOF_REVIEW_STATUS
('PENDING',  'PROOF_REVIEW_STATUS', 'Pending',  'Awaiting review',  1, 0),
('APPROVED', 'PROOF_REVIEW_STATUS', 'Approved', 'Proof approved',   2, 1),
('REJECTED', 'PROOF_REVIEW_STATUS', 'Rejected', 'Proof rejected',   3, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- DEDUCTION_CATEGORY
('EXEMPTION', 'DEDUCTION_CATEGORY', 'Exemption', 'Tax exempt income',      1, 0),
('DEDUCTION', 'DEDUCTION_CATEGORY', 'Deduction', 'Qualifying deduction',   2, 0),
('TAX',       'DEDUCTION_CATEGORY', 'Tax',       'Tax liability',          3, 0),
('CESS',      'DEDUCTION_CATEGORY', 'Cess',      'Education/Health cess',  4, 0),
('REBATE',    'DEDUCTION_CATEGORY', 'Rebate',    'Tax rebate',             5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- SALARY_SLIP_STATUS
('DRAFT',      'SALARY_SLIP_STATUS', 'Draft',      'Payslip not generated',           1, 0),
('PUBLISHED',  'SALARY_SLIP_STATUS', 'Published',  'Published to employee',           2, 0),
('DOWNLOADED', 'SALARY_SLIP_STATUS', 'Downloaded', 'Downloaded by employee',          3, 1),
('REVISED',    'SALARY_SLIP_STATUS', 'Revised',    'Revised payslip',                 4, 0);
GO


-- ============================================================
-- SCHEMA: helpdesk
-- Groups: HELPDESK_TICKET_STATUS, HELPDESK_TICKET_PRIORITY,
--         HELPDESK_ASSET_STATUS, HELPDESK_LICENSE_TYPE
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- HELPDESK_TICKET_STATUS
('OPEN',             'HELPDESK_TICKET_STATUS', 'Open',             'Newly created ticket',          1, 0),
('IN_PROGRESS',      'HELPDESK_TICKET_STATUS', 'In Progress',      'Being worked on',               2, 0),
('PENDING_CUSTOMER', 'HELPDESK_TICKET_STATUS', 'Pending Customer', 'Awaiting customer response',    3, 0),
('RESOLVED',         'HELPDESK_TICKET_STATUS', 'Resolved',         'Issue resolved',                4, 1),
('CLOSED',           'HELPDESK_TICKET_STATUS', 'Closed',           'Ticket closed',                 5, 1),
('CANCELLED',        'HELPDESK_TICKET_STATUS', 'Cancelled',        'Ticket cancelled',              6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- HELPDESK_TICKET_PRIORITY
('CRITICAL', 'HELPDESK_TICKET_PRIORITY', 'Critical', 'System down or major impact',   1, 0),
('HIGH',     'HELPDESK_TICKET_PRIORITY', 'High',     'Significant impact',            2, 0),
('MEDIUM',   'HELPDESK_TICKET_PRIORITY', 'Medium',   'Moderate impact',               3, 0),
('LOW',      'HELPDESK_TICKET_PRIORITY', 'Low',      'Minor impact',                  4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- HELPDESK_ASSET_STATUS
('AVAILABLE',    'HELPDESK_ASSET_STATUS', 'Available',    'Ready for assignment',  1, 0),
('IN_USE',       'HELPDESK_ASSET_STATUS', 'In Use',       'Assigned to employee',  2, 0),
('UNDER_REPAIR', 'HELPDESK_ASSET_STATUS', 'Under Repair', 'Being serviced',        3, 0),
('RETIRED',      'HELPDESK_ASSET_STATUS', 'Retired',      'Decommissioned',        4, 1),
('LOST',         'HELPDESK_ASSET_STATUS', 'Lost',         'Lost or missing',       5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- HELPDESK_LICENSE_TYPE
('PERPETUAL',   'HELPDESK_LICENSE_TYPE', 'Perpetual',   'One-time purchase, perpetual use',  1, 0),
('SUBSCRIPTION','HELPDESK_LICENSE_TYPE', 'Subscription','Recurring subscription',             2, 0),
('FREE',        'HELPDESK_LICENSE_TYPE', 'Free',        'Free software',                      3, 0),
('OPEN_SOURCE', 'HELPDESK_LICENSE_TYPE', 'Open Source', 'Open source software',               4, 0);
GO


-- ============================================================
-- SCHEMA: auth
-- Groups: AUTH_EFFECT, AUTH_DECISION, PERMISSION_CATEGORY,
--         PERMISSION_ACTION, RECORD_ACCESS_SCOPE, CONDITION_OPERATOR,
--         FIELD_MASK_TYPE, HTTP_METHOD, DELEGATED_ACCESS_STATUS
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- AUTH_EFFECT
('ALLOW', 'AUTH_EFFECT', 'Allow', 'Permit the action',              1, 0),
('DENY',  'AUTH_EFFECT', 'Deny',  'Deny the action (always wins)',  2, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- AUTH_DECISION
('PERMITTED',      'AUTH_DECISION', 'Permitted',      'Access granted',                1, 0),
('DENIED',         'AUTH_DECISION', 'Denied',         'Access denied',                 2, 0),
('NOT_APPLICABLE', 'AUTH_DECISION', 'Not Applicable', 'No matching policy found',      3, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- PERMISSION_CATEGORY
('READ',     'PERMISSION_CATEGORY', 'Read',     'Read-only access',                          1, 0),
('WRITE',    'PERMISSION_CATEGORY', 'Write',    'Create / Update / Delete access',            2, 0),
('APPROVAL', 'PERMISSION_CATEGORY', 'Approval', 'Workflow approval / rejection',              3, 0),
('EXPORT',   'PERMISSION_CATEGORY', 'Export',   'Download or export data',                    4, 0),
('ADMIN',    'PERMISSION_CATEGORY', 'Admin',    'Administrative configuration access',        5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- PERMISSION_ACTION
('VIEW',             'PERMISSION_ACTION', 'View',             'Read records',                                    1, 0),
('CREATE',           'PERMISSION_ACTION', 'Create',           'Create new records',                              2, 0),
('UPDATE',           'PERMISSION_ACTION', 'Update',           'Modify existing records',                         3, 0),
('DELETE',           'PERMISSION_ACTION', 'Delete',           'Remove records',                                  4, 0),
('APPROVE',          'PERMISSION_ACTION', 'Approve',          'Approve a workflow request',                      5, 0),
('REJECT',           'PERMISSION_ACTION', 'Reject',           'Reject a workflow request',                       6, 0),
('EXPORT',           'PERMISSION_ACTION', 'Export',           'Export / download records',                       7, 0),
('ASSIGN',           'PERMISSION_ACTION', 'Assign',           'Assign records to others',                        8, 0),
('VIEW_CONFIDENTIAL','PERMISSION_ACTION', 'View Confidential','Bypass masking on confidential fields',           9, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- RECORD_ACCESS_SCOPE
('GLOBAL',       'RECORD_ACCESS_SCOPE', 'Global',       'All records across the system',       1, 0),
('COUNTRY',      'RECORD_ACCESS_SCOPE', 'Country',      'Records scoped to a country',         2, 0),
('LEGAL_ENTITY', 'RECORD_ACCESS_SCOPE', 'Legal Entity', 'Records scoped to a legal entity',   3, 0),
('OFFICE',       'RECORD_ACCESS_SCOPE', 'Office',       'Records scoped to an office',        4, 0),
('DEPARTMENT',   'RECORD_ACCESS_SCOPE', 'Department',   'Records scoped to a department',     5, 0),
('TEAM',         'RECORD_ACCESS_SCOPE', 'Team',         'Records scoped to a team',           6, 0),
('EMPLOYEE',     'RECORD_ACCESS_SCOPE', 'Employee',     'Own records only (self)',             7, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- CONDITION_OPERATOR
('EQUALS',       'CONDITION_OPERATOR', 'Equals',       '=',           1, 0),
('NOT_EQUALS',   'CONDITION_OPERATOR', 'Not Equals',   '!=',          2, 0),
('IN',           'CONDITION_OPERATOR', 'In',           'IN',          3, 0),
('NOT_IN',       'CONDITION_OPERATOR', 'Not In',       'NOT IN',      4, 0),
('CONTAINS',     'CONDITION_OPERATOR', 'Contains',     'LIKE %x%',    5, 0),
('GREATER_THAN', 'CONDITION_OPERATOR', 'Greater Than', '>',           6, 0),
('LESS_THAN',    'CONDITION_OPERATOR', 'Less Than',    '<',           7, 0),
('BETWEEN',      'CONDITION_OPERATOR', 'Between',      'BETWEEN',     8, 0),
('IS_NULL',      'CONDITION_OPERATOR', 'Is Null',      'IS NULL',     9, 0),
('IS_NOT_NULL',  'CONDITION_OPERATOR', 'Is Not Null',  'IS NOT NULL', 10, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- FIELD_MASK_TYPE
('FULL_MASK',    'FIELD_MASK_TYPE', 'Full Mask',    'Replace entire value',                 1, 0),
('PARTIAL_MASK', 'FIELD_MASK_TYPE', 'Partial Mask', 'Show partial value, mask the rest',    2, 0),
('REDACT',       'FIELD_MASK_TYPE', 'Redact',       'Replace with [REDACTED]',              3, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- HTTP_METHOD
('GET',    'HTTP_METHOD', 'GET',    'HTTP GET',    1, 0),
('POST',   'HTTP_METHOD', 'POST',   'HTTP POST',   2, 0),
('PUT',    'HTTP_METHOD', 'PUT',    'HTTP PUT',    3, 0),
('PATCH',  'HTTP_METHOD', 'PATCH',  'HTTP PATCH',  4, 0),
('DELETE', 'HTTP_METHOD', 'DELETE', 'HTTP DELETE', 5, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- DELEGATED_ACCESS_STATUS
('PENDING',  'DELEGATED_ACCESS_STATUS', 'Pending',  'Awaiting delegatee acceptance',       1, 0),
('ACTIVE',   'DELEGATED_ACCESS_STATUS', 'Active',   'Delegation is live and in effect',    2, 0),
('EXPIRED',  'DELEGATED_ACCESS_STATUS', 'Expired',  'Delegation window has passed',        3, 1),
('REVOKED',  'DELEGATED_ACCESS_STATUS', 'Revoked',  'Manually revoked before expiry',      4, 1),
('DECLINED', 'DELEGATED_ACCESS_STATUS', 'Declined', 'Declined by the delegatee',           5, 1);
GO


-- ============================================================
-- SCHEMA: event
-- Groups: EVENT_CATEGORY, EVENT_STATUS, RSVP_STATUS,
--         EVENT_ATTENDANCE_STATUS, NOTIFICATION_CHANNEL,
--         NOTIFICATION_STATUS, CELEBRATION_TYPE, GREETING_STATUS,
--         REACTION_TYPE, SURVEY_STATUS, TARGET_TYPE, QUESTION_TYPE
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EVENT_CATEGORY
('ANNUAL_FUNCTION', 'EVENT_CATEGORY', 'Annual Function', 'Company annual day celebrations',      1, 0),
('FESTIVAL',        'EVENT_CATEGORY', 'Festival',        'Cultural and religious festivals',     2, 0),
('TEAM_OUTING',     'EVENT_CATEGORY', 'Team Outing',     'Team building and outings',            3, 0),
('HACKATHON',       'EVENT_CATEGORY', 'Hackathon',       'Technology hackathons',                4, 0),
('SPORTS',          'EVENT_CATEGORY', 'Sports',          'Sports activities and competitions',   5, 0),
('TOWNHALL',        'EVENT_CATEGORY', 'Townhall',        'Company-wide townhall meetings',       6, 0),
('TRAINING',        'EVENT_CATEGORY', 'Training',        'Workshops and training sessions',      7, 0),
('SEMINAR',         'EVENT_CATEGORY', 'Seminar',         'Seminars and presentations',           8, 0),
('MEETUP',          'EVENT_CATEGORY', 'Meetup',          'Social meetups and networking',        9, 0),
('OTHER',           'EVENT_CATEGORY', 'Other',           'Other event types',                   10, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EVENT_STATUS
('DRAFT',                'EVENT_STATUS', 'Draft',                'Event created but not published',        1, 0),
('PUBLISHED',            'EVENT_STATUS', 'Published',            'Event published, open for registration', 2, 0),
('REGISTRATION_CLOSED',  'EVENT_STATUS', 'Registration Closed',  'Registration period ended',              3, 0),
('ONGOING',              'EVENT_STATUS', 'Ongoing',              'Event is currently in progress',         4, 0),
('COMPLETED',            'EVENT_STATUS', 'Completed',            'Event finished',                         5, 1),
('CANCELLED',            'EVENT_STATUS', 'Cancelled',            'Event cancelled',                        6, 1),
('ARCHIVED',             'EVENT_STATUS', 'Archived',             'Event archived for reference',           7, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- RSVP_STATUS
('PENDING',    'RSVP_STATUS', 'Pending',    'Awaiting response',                      1, 0),
('ACCEPTED',   'RSVP_STATUS', 'Accepted',   'Employee will attend',                   2, 0),
('DECLINED',   'RSVP_STATUS', 'Declined',   'Employee cannot attend',                 3, 0),
('MAYBE',      'RSVP_STATUS', 'Maybe',      'Employee may attend',                    4, 0),
('WAITLISTED', 'RSVP_STATUS', 'Waitlisted', 'Added to waitlist due to capacity',      5, 0),
('CANCELLED',  'RSVP_STATUS', 'Cancelled',  'Registration cancelled',                 6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EVENT_ATTENDANCE_STATUS
('CHECKED_IN',  'EVENT_ATTENDANCE_STATUS', 'Checked In',  'Employee has checked in',              1, 0),
('CHECKED_OUT', 'EVENT_ATTENDANCE_STATUS', 'Checked Out', 'Employee has checked out',             2, 1),
('NO_SHOW',     'EVENT_ATTENDANCE_STATUS', 'No Show',     'Registered but did not attend',        3, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- NOTIFICATION_CHANNEL
('EMAIL',  'NOTIFICATION_CHANNEL', 'Email',  'Email notification',              1, 0),
('PUSH',   'NOTIFICATION_CHANNEL', 'Push',   'Push notification (mobile/web)',  2, 0),
('SMS',    'NOTIFICATION_CHANNEL', 'SMS',    'SMS notification',                3, 0),
('SLACK',  'NOTIFICATION_CHANNEL', 'Slack',  'Slack notification',              4, 0),
('TEAMS',  'NOTIFICATION_CHANNEL', 'Teams',  'Microsoft Teams notification',    5, 0),
('IN_APP', 'NOTIFICATION_CHANNEL', 'In-App', 'In-app notification',             6, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- NOTIFICATION_STATUS
('PENDING', 'NOTIFICATION_STATUS', 'Pending', 'Notification to be sent',         1, 0),
('SENT',    'NOTIFICATION_STATUS', 'Sent',    'Notification sent successfully',   2, 0),
('FAILED',  'NOTIFICATION_STATUS', 'Failed',  'Notification failed to send',      3, 1),
('READ',    'NOTIFICATION_STATUS', 'Read',    'Notification viewed by recipient', 4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- CELEBRATION_TYPE
('BIRTHDAY',        'CELEBRATION_TYPE', 'Birthday',        'Employee birthday celebration',    1, 0),
('WORK_ANNIVERSARY','CELEBRATION_TYPE', 'Work Anniversary','Work anniversary celebration',     2, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- GREETING_STATUS
('GENERATED', 'GREETING_STATUS', 'Generated', 'Greeting card generated',       1, 0),
('SENT',      'GREETING_STATUS', 'Sent',      'Greeting sent successfully',     2, 0),
('VIEWED',    'GREETING_STATUS', 'Viewed',    'Greeting viewed by recipient',   3, 1),
('FAILED',    'GREETING_STATUS', 'Failed',    'Failed to send greeting',        4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- REACTION_TYPE
('LIKE',      'REACTION_TYPE', 'Like',      'Like the celebration',       1, 0),
('LOVE',      'REACTION_TYPE', 'Love',      'Love the celebration',       2, 0),
('CELEBRATE', 'REACTION_TYPE', 'Celebrate', 'Celebrate achievement',      3, 0),
('CONGRATS',  'REACTION_TYPE', 'Congrats',  'Congratulations',            4, 0),
('FIRE',      'REACTION_TYPE', 'Fire',      'On fire!',                   5, 0),
('PARTY',     'REACTION_TYPE', 'Party',     'Party time!',                6, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- SURVEY_STATUS
('DRAFT',     'SURVEY_STATUS', 'Draft',     'Survey created but not published',        1, 0),
('PUBLISHED', 'SURVEY_STATUS', 'Published', 'Survey published, open for responses',    2, 0),
('CLOSED',    'SURVEY_STATUS', 'Closed',    'Survey closed for responses',             3, 1),
('ARCHIVED',  'SURVEY_STATUS', 'Archived',  'Survey archived',                         4, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TARGET_TYPE
('ALL',        'TARGET_TYPE', 'All',               'All employees',                1, 0),
('DEPARTMENT', 'TARGET_TYPE', 'Department',        'Target by department',         2, 0),
('LOCATION',   'TARGET_TYPE', 'Location',          'Target by office location',    3, 0),
('EMPLOYEE',   'TARGET_TYPE', 'Specific Employee', 'Target specific employees',    4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- QUESTION_TYPE
('RATING_SCALE',    'QUESTION_TYPE', 'Rating Scale',    '1-5 or 1-10 rating',         1, 0),
('MULTIPLE_CHOICE', 'QUESTION_TYPE', 'Multiple Choice', 'Select one from options',     2, 0),
('MULTI_SELECT',    'QUESTION_TYPE', 'Multi-Select',    'Select multiple options',     3, 0),
('TEXT',            'QUESTION_TYPE', 'Text',            'Free text response',          4, 0),
('YES_NO',          'QUESTION_TYPE', 'Yes/No',          'Binary yes/no question',      5, 0),
('EMOJI_SENTIMENT', 'QUESTION_TYPE', 'Emoji Sentiment', 'Emoji-based sentiment',       6, 0),
('DATE',            'QUESTION_TYPE', 'Date',            'Date picker response',        7, 0),
('NUMBER',          'QUESTION_TYPE', 'Number',          'Numeric input',               8, 0);
GO


-- ============================================================
-- SCHEMA: survey
-- Groups: POLL_TYPE, POLL_STATUS, TARGET_TYPE (shared with event),
--         FEEDBACK_CATEGORY, FEEDBACK_STATUS
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- POLL_TYPE
('SINGLE_CHOICE',   'POLL_TYPE', 'Single Choice',   'Vote for one option',       1, 0),
('MULTIPLE_CHOICE', 'POLL_TYPE', 'Multiple Choice', 'Vote for multiple options',  2, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- POLL_STATUS
('ACTIVE',   'POLL_STATUS', 'Active',   'Poll is open for voting', 1, 0),
('CLOSED',   'POLL_STATUS', 'Closed',   'Poll voting closed',      2, 1),
('ARCHIVED', 'POLL_STATUS', 'Archived', 'Poll archived',           3, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- FEEDBACK_CATEGORY
('WORKPLACE_CULTURE',  'FEEDBACK_CATEGORY', 'Workplace Culture',  'Issues related to work environment',   1, 0),
('MANAGER_CONCERNS',   'FEEDBACK_CATEGORY', 'Manager Concerns',   'Issues with direct manager',           2, 0),
('HARASSMENT',         'FEEDBACK_CATEGORY', 'Harassment',         'Harassment complaints',                3, 0),
('POLICY_IMPROVEMENT', 'FEEDBACK_CATEGORY', 'Policy Improvement', 'Suggestions for policy changes',       4, 0),
('INFRASTRUCTURE',     'FEEDBACK_CATEGORY', 'Infrastructure',     'Facilities and equipment issues',      5, 0),
('GENERAL_SUGGESTION', 'FEEDBACK_CATEGORY', 'General Suggestion', 'General improvement suggestions',      6, 0),
('ETHICS_VIOLATION',   'FEEDBACK_CATEGORY', 'Ethics Violation',   'Ethics and compliance issues',         7, 0),
('OTHER',              'FEEDBACK_CATEGORY', 'Other',              'Other feedback',                       8, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- FEEDBACK_STATUS
('SUBMITTED',    'FEEDBACK_STATUS', 'Submitted',    'Feedback submitted',                   1, 0),
('UNDER_REVIEW', 'FEEDBACK_STATUS', 'Under Review', 'Being reviewed by admin',              2, 0),
('IN_PROGRESS',  'FEEDBACK_STATUS', 'In Progress',  'Action being taken',                   3, 0),
('RESOLVED',     'FEEDBACK_STATUS', 'Resolved',     'Feedback resolved',                    4, 1),
('ESCALATED',    'FEEDBACK_STATUS', 'Escalated',    'Escalated to higher authority',        5, 0),
('REJECTED',     'FEEDBACK_STATUS', 'Rejected',     'Feedback rejected',                    6, 1);
GO


-- ============================================================
-- SCHEMA: expense
-- Groups: EXPENSE_POLICY_GROUP, TRAVEL_TYPE, TRAVEL_REQUEST_STATUS,
--         ADVANCE_REQUEST_STATUS, ASSET_TYPE, POLICY_VALIDATION_STATUS,
--         ASSET_REIMBURSEMENT_STATUS, EXPENSE_CLAIM_STATUS,
--         REIMBURSEMENT_TYPE, REIMBURSEMENT_STATUS,
--         EXPENSE_APPROVAL_REFERENCE, AUDIT_EVENT_TYPE
-- (PAYMENT_MODE_TYPE, TRANSACTION_STATUS, WORKFLOW_ACTION_TYPE
--  are shared with payroll/workflow — seeded above)
-- ============================================================

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EXPENSE_POLICY_GROUP
('TRAVEL',  'EXPENSE_POLICY_GROUP', 'Travel',  'Travel expenses: flights, trains, cabs, fuel.',       1, 0),
('ASSET',   'EXPENSE_POLICY_GROUP', 'Asset',   'Asset purchases: laptops, monitors, peripherals.',    2, 0),
('WFH',     'EXPENSE_POLICY_GROUP', 'WFH',     'Work from home: internet, phone, electricity.',       3, 0),
('MEDICAL', 'EXPENSE_POLICY_GROUP', 'Medical', 'Medical reimbursement limits.',                       4, 0),
('ADVANCE', 'EXPENSE_POLICY_GROUP', 'Advance', 'Advance request limits and recovery rules.',          5, 0),
('GENERAL', 'EXPENSE_POLICY_GROUP', 'General', 'General office and miscellaneous expenses.',          6, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TRAVEL_TYPE
('FLIGHT', 'TRAVEL_TYPE', 'Flight', 'Domestic or international air travel.',               1, 0),
('TRAIN',  'TRAVEL_TYPE', 'Train',  'Train travel (class per policy).',                    2, 0),
('CAB',    'TRAVEL_TYPE', 'Cab',    'Taxi, cab, or ride-share.',                           3, 0),
('FUEL',   'TRAVEL_TYPE', 'Fuel',   'Personal vehicle — fuel or mileage reimbursement.',  4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- TRAVEL_REQUEST_STATUS
('DRAFT',     'TRAVEL_REQUEST_STATUS', 'Draft',     'Employee planning trip details.',                         1, 0),
('SUBMITTED', 'TRAVEL_REQUEST_STATUS', 'Submitted', 'Submitted for approval.',                                 2, 0),
('APPROVED',  'TRAVEL_REQUEST_STATUS', 'Approved',  'Approved. Employee can proceed with booking.',            3, 0),
('REJECTED',  'TRAVEL_REQUEST_STATUS', 'Rejected',  'Denied. Can be edited and resubmitted.',                 4, 1),
('COMPLETED', 'TRAVEL_REQUEST_STATUS', 'Completed', 'Travel completed. Expense claims can now be filed.',      5, 1),
('CANCELLED', 'TRAVEL_REQUEST_STATUS', 'Cancelled', 'Cancelled by employee before travel.',                    6, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- ADVANCE_REQUEST_STATUS
('DRAFT',     'ADVANCE_REQUEST_STATUS', 'Draft',     'Draft being prepared by employee.',              1, 0),
('SUBMITTED', 'ADVANCE_REQUEST_STATUS', 'Submitted', 'Submitted for manager approval.',               2, 0),
('APPROVED',  'ADVANCE_REQUEST_STATUS', 'Approved',  'Approved. Ready for disbursement.',             3, 0),
('REJECTED',  'ADVANCE_REQUEST_STATUS', 'Rejected',  'Denied by approver.',                          4, 1),
('PAID',      'ADVANCE_REQUEST_STATUS', 'Paid',      'Amount disbursed to employee account.',        5, 0),
('ADJUSTED',  'ADVANCE_REQUEST_STATUS', 'Adjusted',  'Settled against a submitted expense claim.',   6, 1),
('CANCELLED', 'ADVANCE_REQUEST_STATUS', 'Cancelled', 'Cancelled by employee before payment.',        7, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- ASSET_TYPE
('LAPTOP',     'ASSET_TYPE', 'Laptop',       'Personal laptop (requires IT validation).',   1, 0),
('MONITOR',    'ASSET_TYPE', 'Monitor',      'External monitor for home office.',           2, 0),
('KEYBOARD',   'ASSET_TYPE', 'Keyboard',     'Keyboard and input devices.',                3, 0),
('MOUSE',      'ASSET_TYPE', 'Mouse',        'Mouse and pointing devices.',                4, 0),
('HEADPHONES', 'ASSET_TYPE', 'Headphones',   'Headphones for calls and meetings.',         5, 0),
('CHAIR',      'ASSET_TYPE', 'Office Chair', 'Ergonomic office chair for WFH.',            6, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- POLICY_VALIDATION_STATUS
('PENDING', 'POLICY_VALIDATION_STATUS', 'Pending', 'Validation not yet run. Triggered on submission.',           1, 0),
('PASS',    'POLICY_VALIDATION_STATUS', 'Pass',    'Complies with all policy rules.',                            2, 0),
('FAIL',    'POLICY_VALIDATION_STATUS', 'Fail',    'Violates policy. Requires approver override or claim edit.', 3, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- ASSET_REIMBURSEMENT_STATUS
('DRAFT',            'ASSET_REIMBURSEMENT_STATUS', 'Draft',            'Request being prepared.',                              1, 0),
('SUBMITTED',        'ASSET_REIMBURSEMENT_STATUS', 'Submitted',        'Submitted. Awaiting IT validation.',                   2, 0),
('IT_VALIDATED',     'ASSET_REIMBURSEMENT_STATUS', 'IT Validated',     'IT confirmed eligibility. Pending manager approval.',  3, 0),
('MANAGER_APPROVED', 'ASSET_REIMBURSEMENT_STATUS', 'Manager Approved', 'Manager approved. Pending finance review.',            4, 0),
('FINANCE_APPROVED', 'ASSET_REIMBURSEMENT_STATUS', 'Finance Approved', 'Finance approved. Ready for payment.',                5, 0),
('REJECTED',         'ASSET_REIMBURSEMENT_STATUS', 'Rejected',         'Rejected at any stage.',                              6, 1),
('PAID',             'ASSET_REIMBURSEMENT_STATUS', 'Paid',             'Reimbursement transferred to employee.',              7, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EXPENSE_CLAIM_STATUS
('DRAFT',            'EXPENSE_CLAIM_STATUS', 'Draft',            'Employee is building the claim. Not yet submitted.',              1, 0),
('SUBMITTED',        'EXPENSE_CLAIM_STATUS', 'Submitted',        'Submitted to workflow. Pending manager review.',                  2, 0),
('MANAGER_APPROVED', 'EXPENSE_CLAIM_STATUS', 'Manager Approved', 'Approved by direct manager. Pending finance review.',            3, 0),
('FINANCE_APPROVED', 'EXPENSE_CLAIM_STATUS', 'Finance Approved', 'Approved by finance team. Eligible for reimbursement.',          4, 0),
('REJECTED',         'EXPENSE_CLAIM_STATUS', 'Rejected',         'Rejected by approver. Employee can edit and resubmit.',          5, 1),
('PAID',             'EXPENSE_CLAIM_STATUS', 'Paid',             'Reimbursement disbursed to employee bank account.',              6, 1),
('CLOSED',           'EXPENSE_CLAIM_STATUS', 'Closed',           'Claim finalized. No further actions possible.',                  7, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- REIMBURSEMENT_TYPE
('CLAIM',   'REIMBURSEMENT_TYPE', 'Claim',   'Reimbursement for an approved expense claim.',      1, 0),
('ADVANCE', 'REIMBURSEMENT_TYPE', 'Advance', 'Settlement of an advance against a filed claim.',   2, 0),
('ASSET',   'REIMBURSEMENT_TYPE', 'Asset',   'Reimbursement for an approved asset purchase.',     3, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- REIMBURSEMENT_STATUS
('PENDING',    'REIMBURSEMENT_STATUS', 'Pending',    'Awaiting payment processing.',                              1, 0),
('PROCESSING', 'REIMBURSEMENT_STATUS', 'Processing', 'Payment being processed through bank/finance system.',     2, 0),
('PAID',       'REIMBURSEMENT_STATUS', 'Paid',       'Successfully disbursed to employee bank account.',         3, 1),
('FAILED',     'REIMBURSEMENT_STATUS', 'Failed',     'Payment failed. Can be retried or manually processed.',    4, 1),
('CANCELLED',  'REIMBURSEMENT_STATUS', 'Cancelled',  'Cancelled by finance. Claim may need reprocessing.',       5, 1);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- EXPENSE_APPROVAL_REFERENCE
('EXPENSE_CLAIM',       'EXPENSE_APPROVAL_REFERENCE', 'Expense Claim',       'References expense.ExpenseClaim.',         1, 0),
('TRAVEL_REQUEST',      'EXPENSE_APPROVAL_REFERENCE', 'Travel Request',      'References expense.TravelRequest.',        2, 0),
('ASSET_REIMBURSEMENT', 'EXPENSE_APPROVAL_REFERENCE', 'Asset Reimbursement', 'References expense.AssetReimbursement.',   3, 0),
('ADVANCE_REQUEST',     'EXPENSE_APPROVAL_REFERENCE', 'Advance Request',     'References expense.ExpenseAdvance.',       4, 0);

INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
VALUES
-- AUDIT_EVENT_TYPE
('CLAIM_CREATED',     'AUDIT_EVENT_TYPE', 'Claim Created',     'New expense claim created by employee.',            1, 0),
('CLAIM_SUBMITTED',   'AUDIT_EVENT_TYPE', 'Claim Submitted',   'Claim submitted to approval workflow.',             2, 0),
('CLAIM_APPROVED',    'AUDIT_EVENT_TYPE', 'Claim Approved',    'Claim approved at a workflow stage.',               3, 0),
('CLAIM_REJECTED',    'AUDIT_EVENT_TYPE', 'Claim Rejected',    'Claim rejected by an approver.',                   4, 0),
('PAYMENT_PROCESSED', 'AUDIT_EVENT_TYPE', 'Payment Processed', 'Reimbursement payment initiated or completed.',     5, 0),
('POLICY_VALIDATED',  'AUDIT_EVENT_TYPE', 'Policy Validated',  'Automated policy validation executed on claim.',    6, 0);
GO


PRINT 'shared.StatusLookup seed complete — all groups inserted, grouped by consuming schema.';
GO