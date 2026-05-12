-- =============================================================================================================
-- HEALTHCARE ORGANIZATION - INDIA SEED DATA
-- Enterprise HRMS — HR Modules Extension
-- Schema: hr  |  Shared lookup: dbo.StatusLookup
-- =============================================================================================================
-- Organization  : MedCare India Pvt. Ltd.
-- Country       : India
-- Depends on    : dbo seed data (Employees EMP001–EMP045, Departments, Designations,
--                 OfficeLocations, LegalEntities, ScopeType, DocumentType must already exist)
-- =============================================================================================================
-- Run Order:
--   Module 0  → dbo.StatusLookup (hr status groups)
--   Module A  → Recruitment & Selection
--                 InterviewType, InterviewRound, PanelRole, InterviewPurpose,
--                 JobPosting, Candidate, Application, ApplicationStatusHistory,
--                 InterviewRoundConfig, Interview, InterviewPanel, InterviewFeedback,
--                 PackageNegotiation, OfferLetter
--   Module B  → Onboarding
--                 OnboardingChecklist, OnboardingChecklistItem, OnboardingTask,
--                 DocumentVerification, BGVAgency, BackgroundVerification
--   Module C  → Policy Documents
--                 PolicyCategory, PolicyDocument, PolicyVersion, PolicyAcknowledgement
--   Module D  → Salary Slips
--                 SalarySlipPublication  (stub — depends on payroll disbursement records)
--   Module E  → Performance Reviews
--                 PerformanceCycle, Goal, GoalKeyResult, PerformanceReview,
--                 PerformanceReviewHistory
--   Module F  → Training Records
--                 TrainingCategory, TrainingProgram, TrainingBatch, EmployeeTrainingRecord
--   Module G  → Exit Management
--                 ExitReason, ExitRecord, ExitClearanceItem
--   Verification Summary
-- =============================================================================================================

SET NOCOUNT ON;
BEGIN TRANSACTION;

-- =============================================================================================================
-- MODULE 0: dbo.StatusLookup — HR SCHEMA STATUS GROUPS
-- =============================================================================================================

PRINT 'Inserting StatusLookup — ONBOARDING_TASK_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',         'ONBOARDING_TASK_STATUS',   'Pending',      1, 0),
('IN_PROGRESS',     'ONBOARDING_TASK_STATUS',   'In Progress',  2, 0),
('COMPLETED',       'ONBOARDING_TASK_STATUS',   'Completed',    3, 1),
('WAIVED',          'ONBOARDING_TASK_STATUS',   'Waived',       4, 1);

PRINT 'Inserting StatusLookup — DOC_VERIFY_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',         'DOC_VERIFY_STATUS',    'Pending',          1, 0),
('SUBMITTED',       'DOC_VERIFY_STATUS',    'Submitted',        2, 0),
('UNDER_REVIEW',    'DOC_VERIFY_STATUS',    'Under Review',     3, 0),
('VERIFIED',        'DOC_VERIFY_STATUS',    'Verified',         4, 1),
('REJECTED',        'DOC_VERIFY_STATUS',    'Rejected',         5, 1),
('RESUBMITTED',     'DOC_VERIFY_STATUS',    'Resubmitted',      6, 0),
('EXPIRED',         'DOC_VERIFY_STATUS',    'Expired',          7, 1),
('WAIVED',          'DOC_VERIFY_STATUS',    'Waived',           8, 1);

PRINT 'Inserting StatusLookup — BGV_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',             'BGV_STATUS',   'Pending',              1, 0),
('IN_PROGRESS',         'BGV_STATUS',   'In Progress',          2, 0),
('COMPLETED',           'BGV_STATUS',   'Completed',            3, 1),
('DISCREPANCY_FOUND',   'BGV_STATUS',   'Discrepancy Found',    4, 1),
('FAILED',              'BGV_STATUS',   'Failed',               5, 1),
('WAIVED',              'BGV_STATUS',   'Waived',               6, 1);

PRINT 'Inserting StatusLookup — BGV_RESULT...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('CLEAR',               'BGV_RESULT',   'Clear',                1, 1),
('DISCREPANCY',         'BGV_RESULT',   'Discrepancy',          2, 1),
('UNABLE_TO_VERIFY',    'BGV_RESULT',   'Unable to Verify',     3, 1),
('FAILED',              'BGV_RESULT',   'Failed',               4, 1);

PRINT 'Inserting StatusLookup — BGV_CHECK_TYPE...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('CRIMINAL',            'BGV_CHECK_TYPE',   'Criminal',             1, 0),
('EMPLOYMENT_HISTORY',  'BGV_CHECK_TYPE',   'Employment History',   2, 0),
('EDUCATION',           'BGV_CHECK_TYPE',   'Education',            3, 0),
('IDENTITY',            'BGV_CHECK_TYPE',   'Identity',             4, 0),
('CREDIT',              'BGV_CHECK_TYPE',   'Credit',               5, 0),
('REFERENCE',           'BGV_CHECK_TYPE',   'Reference',            6, 0),
('DRUG_TEST',           'BGV_CHECK_TYPE',   'Drug Test',            7, 0),
('ADDRESS',             'BGV_CHECK_TYPE',   'Address',              8, 0);

PRINT 'Inserting StatusLookup — ONBOARDING_PHASE...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PRE_ONBOARDING',  'ONBOARDING_PHASE', 'Pre-Onboarding',   1, 0),
('POST_ONBOARDING', 'ONBOARDING_PHASE', 'Post-Onboarding',  2, 0);

PRINT 'Inserting StatusLookup — EXIT_TYPE...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('RESIGNATION',     'EXIT_TYPE',    'Resignation',      1, 0),
('TERMINATION',     'EXIT_TYPE',    'Termination',      2, 0),
('RETIREMENT',      'EXIT_TYPE',    'Retirement',       3, 0),
('CONTRACT_END',    'EXIT_TYPE',    'Contract End',     4, 0),
('ABSCONDING',      'EXIT_TYPE',    'Absconding',       5, 0);

PRINT 'Inserting StatusLookup — EXIT_INTERVIEW_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',     'EXIT_INTERVIEW_STATUS',    'Pending',      1, 0),
('SCHEDULED',   'EXIT_INTERVIEW_STATUS',    'Scheduled',    2, 0),
('COMPLETED',   'EXIT_INTERVIEW_STATUS',    'Completed',    3, 1),
('SKIPPED',     'EXIT_INTERVIEW_STATUS',    'Skipped',      4, 1);

PRINT 'Inserting StatusLookup — CLEARANCE_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',     'CLEARANCE_STATUS', 'Pending',      1, 0),
('IN_PROGRESS', 'CLEARANCE_STATUS', 'In Progress',  2, 0),
('COMPLETED',   'CLEARANCE_STATUS', 'Completed',    3, 1);

PRINT 'Inserting StatusLookup — FINAL_SETTLEMENT_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',     'FINAL_SETTLEMENT_STATUS',  'Pending',      1, 0),
('PROCESSED',   'FINAL_SETTLEMENT_STATUS',  'Processed',    2, 0),
('PAID',        'FINAL_SETTLEMENT_STATUS',  'Paid',         3, 1);

PRINT 'Inserting StatusLookup — CLEARANCE_ITEM_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',			'CLEARANCE_ITEM_STATUS',    'Pending',      1, 0),
('IN_PROGRESS',		'CLEARANCE_ITEM_STATUS',    'In Progress',  2, 0),
('COMPLETED',		'CLEARANCE_ITEM_STATUS',    'Completed',    3, 1),
('WAIVED',			'CLEARANCE_ITEM_STATUS',    'Waived',       4, 1);

PRINT 'Inserting StatusLookup — POLICY_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',       'POLICY_STATUS',    'Draft',        1, 0),
('ACTIVE',      'POLICY_STATUS',    'Active',       2, 0),
('ARCHIVED',    'POLICY_STATUS',    'Archived',     3, 1),
('SUPERSEDED',  'POLICY_STATUS',    'Superseded',   4, 1);

PRINT 'Inserting StatusLookup — POLICY_ACK_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',         'POLICY_ACK_STATUS',    'Pending',          1, 0),
('ACKNOWLEDGED',    'POLICY_ACK_STATUS',    'Acknowledged',     2, 1),
('OVERDUE',         'POLICY_ACK_STATUS',    'Overdue',          3, 0);

PRINT 'Inserting StatusLookup — SALARY_SLIP_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',       'SALARY_SLIP_STATUS',   'Draft',        1, 0),
('PUBLISHED',   'SALARY_SLIP_STATUS',   'Published',    2, 0),
('DOWNLOADED',  'SALARY_SLIP_STATUS',   'Downloaded',   3, 0),
('REVISED',     'SALARY_SLIP_STATUS',   'Revised',      4, 0);

PRINT 'Inserting StatusLookup — PERF_CYCLE_TYPE...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('ANNUAL',      'PERF_CYCLE_TYPE',  'Annual',       1, 0),
('BI_ANNUAL',   'PERF_CYCLE_TYPE',  'Bi-Annual',    2, 0),
('QUARTERLY',   'PERF_CYCLE_TYPE',  'Quarterly',    3, 0),
('PROBATION',   'PERF_CYCLE_TYPE',  'Probation',    4, 0);

PRINT 'Inserting StatusLookup — PERF_CYCLE_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('UPCOMING',        'PERF_CYCLE_STATUS',    'Upcoming',         1, 0),
('GOAL_SETTING',    'PERF_CYCLE_STATUS',    'Goal Setting',     2, 0),
('IN_REVIEW',       'PERF_CYCLE_STATUS',    'In Review',        3, 0),
('COMPLETED',       'PERF_CYCLE_STATUS',    'Completed',        4, 1),
('ARCHIVED',        'PERF_CYCLE_STATUS',    'Archived',         5, 1);

PRINT 'Inserting StatusLookup — PERF_REVIEW_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',         'PERF_REVIEW_STATUS',   'Pending',          1, 0),
('SELF_SUBMITTED',  'PERF_REVIEW_STATUS',   'Self Submitted',   2, 0),
('MANAGER_REVIEW',  'PERF_REVIEW_STATUS',   'Manager Review',   3, 0),
('HRBP_REVIEW',     'PERF_REVIEW_STATUS',   'HRBP Review',      4, 0),
('COMPLETED',       'PERF_REVIEW_STATUS',   'Completed',        5, 1),
('ACKNOWLEDGED',    'PERF_REVIEW_STATUS',   'Acknowledged',     6, 1);

PRINT 'Inserting StatusLookup — GOAL_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',       'GOAL_STATUS',  'Draft',        1, 0),
('SUBMITTED',   'GOAL_STATUS',  'Submitted',    2, 0),
('APPROVED',    'GOAL_STATUS',  'Approved',     3, 0),
('IN_PROGRESS', 'GOAL_STATUS',  'In Progress',  4, 0),
('COMPLETED',   'GOAL_STATUS',  'Completed',    5, 1),
('CANCELLED',   'GOAL_STATUS',  'Cancelled',    6, 1);

PRINT 'Inserting StatusLookup — GOAL_KR_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',         'GOAL_KR_STATUS',   'Pending',          1, 0),
('ON_TRACK',        'GOAL_KR_STATUS',   'On Track',         2, 0),
('AT_RISK',         'GOAL_KR_STATUS',   'At Risk',          3, 0),
('ACHIEVED',        'GOAL_KR_STATUS',   'Achieved',         4, 1),
('NOT_ACHIEVED',    'GOAL_KR_STATUS',   'Not Achieved',     5, 1);

PRINT 'Inserting StatusLookup — TRAINING_MODE...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('ONLINE',      'TRAINING_MODE',    'Online',       1, 0),
('OFFLINE',     'TRAINING_MODE',    'Offline',      2, 0),
('HYBRID',      'TRAINING_MODE',    'Hybrid',       3, 0),
('SELF_PACED',  'TRAINING_MODE',    'Self-Paced',   4, 0);

PRINT 'Inserting StatusLookup — TRAINING_BATCH_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('UPCOMING',    'TRAINING_BATCH_STATUS',    'Upcoming',     1, 0),
('ONGOING',     'TRAINING_BATCH_STATUS',    'Ongoing',      2, 0),
('COMPLETED',   'TRAINING_BATCH_STATUS',    'Completed',    3, 1),
('CANCELLED',   'TRAINING_BATCH_STATUS',    'Cancelled',    4, 1);

PRINT 'Inserting StatusLookup — TRAINING_RECORD_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('ENROLLED',    'TRAINING_RECORD_STATUS',   'Enrolled',     1, 0),
('IN_PROGRESS', 'TRAINING_RECORD_STATUS',   'In Progress',  2, 0),
('COMPLETED',   'TRAINING_RECORD_STATUS',   'Completed',    3, 1),
('FAILED',      'TRAINING_RECORD_STATUS',   'Failed',       4, 1),
('DROPPED',     'TRAINING_RECORD_STATUS',   'Dropped',      5, 1),
('ABSENT',      'TRAINING_RECORD_STATUS',   'Absent',       6, 1);

PRINT 'Inserting StatusLookup — RECOMMENDATION_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('STRONG_YES',  'RECOMMENDATION_STATUS',    'Strong Yes',   1, 0),
('YES',         'RECOMMENDATION_STATUS',    'Yes',          2, 0),
('MAYBE',       'RECOMMENDATION_STATUS',    'Maybe',        3, 0),
('NO',          'RECOMMENDATION_STATUS',    'No',           4, 0),
('STRONG_NO',   'RECOMMENDATION_STATUS',    'Strong No',    5, 0);

PRINT 'Inserting StatusLookup — INTERVIEW_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('SCHEDULED',   'INTERVIEW_STATUS', 'Scheduled',    1, 0),
('COMPLETED',   'INTERVIEW_STATUS', 'Completed',    2, 1),
('CANCELLED',   'INTERVIEW_STATUS', 'Cancelled',    3, 1),
('RESCHEDULED', 'INTERVIEW_STATUS', 'Rescheduled',  4, 0),
('NO_SHOW',     'INTERVIEW_STATUS', 'No Show',      5, 1);

PRINT 'Inserting StatusLookup — JOB_POSTING_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',       'JOB_POSTING_STATUS',   'Draft',        1, 0),
('OPEN',        'JOB_POSTING_STATUS',   'Open',         2, 0),
('ON_HOLD',     'JOB_POSTING_STATUS',   'On Hold',      3, 0),
('CLOSED',      'JOB_POSTING_STATUS',   'Closed',       4, 1),
('CANCELLED',   'JOB_POSTING_STATUS',   'Cancelled',    5, 1);

PRINT 'Inserting StatusLookup — APPLICATION_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('APPLIED',         'APPLICATION_STATUS',   'Applied',          1, 0),
('SCREENING',       'APPLICATION_STATUS',   'Screening',        2, 0),
('INTERVIEW',       'APPLICATION_STATUS',   'Interview',        3, 0),
('OFFER',           'APPLICATION_STATUS',   'Offer',            4, 0),
('NEGOTIATION',     'APPLICATION_STATUS',   'Negotiation',      5, 0),
('HIRED',           'APPLICATION_STATUS',   'Hired',            6, 1),
('REJECTED',        'APPLICATION_STATUS',   'Rejected',         7, 1),
('WITHDRAWN',       'APPLICATION_STATUS',   'Withdrawn',        8, 1);

PRINT 'Inserting StatusLookup — OFFER_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('ISSUED',      'OFFER_STATUS', 'Issued',   1, 0),
('ACCEPTED',    'OFFER_STATUS', 'Accepted', 2, 1),
('REJECTED',    'OFFER_STATUS', 'Rejected', 3, 1),
('EXPIRED',     'OFFER_STATUS', 'Expired',  4, 1),
('REVOKED',     'OFFER_STATUS', 'Revoked',  5, 1);

PRINT 'Inserting StatusLookup — NEGOTIATION_STATUS...';
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('IN_PROGRESS', 'NEGOTIATION_STATUS',   'In Progress',  1, 0),
('ACCEPTED',    'NEGOTIATION_STATUS',   'Accepted',     2, 1),
('REJECTED',    'NEGOTIATION_STATUS',   'Rejected',     3, 1),
('COUNTERED',   'NEGOTIATION_STATUS',   'Countered',    4, 0),
('WITHDRAWN',   'NEGOTIATION_STATUS',   'Withdrawn',    5, 1);


-- =============================================================================================================
-- MODULE A: RECRUITMENT & SELECTION
-- =============================================================================================================

PRINT 'Inserting hr.InterviewType...';
INSERT INTO hr.InterviewType (InterviewTypeCode, InterviewTypeName, Description, DisplayOrder) VALUES
('PHONE',       'Phone Screen',             'Initial telephonic screening call',                        1),
('VIDEO',       'Video Call',               'Video interview via Teams or Google Meet',                 2),
('IN_PERSON',   'In-Person',                'Face-to-face interview at office premises',                3),
('PANEL',       'Panel Interview',          'Multi-interviewer panel session',                          4),
('ASSIGNMENT',  'Take-Home Assignment',     'Skill-based assignment submitted before next round',       5),
('TECHNICAL',   'Technical Assessment',     'Online or whiteboard technical problem solving',           6);


PRINT 'Inserting hr.InterviewRound...';
INSERT INTO hr.InterviewRound (RoundNumber, RoundCode, RoundName, Description, DefaultInterviewTypeId, IsMandatory, DisplayOrder) VALUES
(1, 'HR_SCREEN',    'HR Screening',             'Initial HR fitment and culture check',                             (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='PHONE'),      1, 1),
(2, 'TECH_1',       'Technical Round 1',        'Core technical or clinical knowledge assessment',                  (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='VIDEO'),      1, 2),
(3, 'TECH_2',       'Technical Round 2',        'Advanced technical depth or case-based assessment',                (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='VIDEO'),      0, 3),
(4, 'DOMAIN_EXPERT','Domain Expert Review',     'Specialist domain evaluation by senior clinician or lead',         (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='IN_PERSON'), 0, 4),
(5, 'MANAGER',      'Hiring Manager Round',     'Evaluation by direct reporting manager',                           (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='IN_PERSON'), 1, 5),
(6, 'PANEL',        'Panel Interview',          'Cross-functional panel assessment for senior roles',               (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='PANEL'),     0, 6),
(7, 'FINAL_HR',     'Final HR & Offer',         'Compensation discussion and offer formulation',                    (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='IN_PERSON'), 1, 7);


PRINT 'Inserting hr.PanelRole...';
INSERT INTO hr.PanelRole (RoleCode, RoleName, Description, CanSubmitFeedback, DisplayOrder) VALUES
('PANEL_LEAD',      'Panel Lead',           'Leads the panel and consolidates feedback',         1, 1),
('INTERVIEWER',     'Interviewer',          'Core interviewer responsible for primary questions', 1, 2),
('TECH_EXPERT',     'Technical Expert',     'Assesses technical or clinical depth',              1, 3),
('DOMAIN_EXPERT',   'Domain Expert',        'Evaluates domain-specific knowledge',               1, 4),
('HR_COORD',        'HR Coordinator',       'Facilitates process and covers HR fitment',         1, 5),
('OBSERVER',        'Observer',             'Shadows the interview for calibration or training',  0, 6),
('NOTE_TAKER',      'Note Taker',           'Records interview proceedings',                     0, 7);


PRINT 'Inserting hr.InterviewPurpose...';
INSERT INTO hr.InterviewPurpose (PurposeCode, PurposeName, Description, DisplayOrder) VALUES
('CLINICAL_KNOWLEDGE',  'Clinical Knowledge',       'Assessment of medical/clinical subject matter expertise',          1),
('TECHNICAL_DEPTH',     'Technical Depth',          'Depth of technical skills relevant to the role',                  2),
('PROBLEM_SOLVING',     'Problem Solving',          'Analytical thinking and decision-making under pressure',           3),
('DOMAIN_KNOWLEDGE',    'Domain Knowledge',         'Specialist area knowledge (e.g. Oncology, Emergency Medicine)',    4),
('CULTURE_FIT',         'Culture Fit',              'Alignment with organisational values and team culture',            5),
('COMMUNICATION',       'Communication Skills',     'Verbal communication, articulation, and patient-handling ability', 6),
('LEADERSHIP',          'Leadership & Ownership',   'Team leadership, accountability, and initiative',                 7),
('HR_FITMENT',          'HR Fitment',               'Salary expectations, joining timeline, and overall fitment',       8);


PRINT 'Inserting hr.JobPosting...';
INSERT INTO hr.JobPosting (Title, DepartmentId, DesignationId, LocationId, LegalEntityId, EmploymentType, ExperienceMinYrs, ExperienceMaxYrs, SalaryMin, SalaryMax, CurrencyCode, Description, Requirements, OpeningsCount, JobPostingStatus, PostedByEmployeeId, PostedDate, ClosingDate) VALUES
(
    'Senior Staff Nurse — ICU',
    (SELECT Id FROM Department WHERE DepartmentCode='ICU'),
    (SELECT Id FROM Designation WHERE DesignationCode='SRNURSE'),
    (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),
    'FULL_TIME', 5.0, 10.0, 700000.00, 1000000.00, 'INR',
    'We are seeking an experienced Senior Staff Nurse for our ICU unit at Mumbai HQ. The candidate will be responsible for critical care patient management, ventilator support, and team supervision.',
    'B.Sc. Nursing or GNM; minimum 5 years ICU experience; BLS/ACLS certified; strong ventilator management skills.',
    2, 'OPEN',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    '2025-02-01', '2025-04-30'
),
(
    'Resident Doctor — Cardiology',
    (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'),
    (SELECT Id FROM Designation WHERE DesignationCode='RESIDENTDR'),
    (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'),
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),
    'FULL_TIME', 1.0, 3.0, 600000.00, 900000.00, 'INR',
    'Resident Doctor position in Cardiology department at MedCare Pune. Opportunity to work under senior cardiologist Dr. Namrata Deshpande.',
    'MBBS from MCI-recognised institution; completed internship; USMLE/PG entrance cleared preferred; cardiology interest essential.',
    1, 'OPEN',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    '2025-02-15', '2025-05-15'
),
(
    'HR Executive — South India Operations',
    (SELECT Id FROM Department WHERE DepartmentCode='HR'),
    (SELECT Id FROM Designation WHERE DesignationCode='HREXEC'),
    (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'),
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    'FULL_TIME', 2.0, 5.0, 400000.00, 600000.00, 'INR',
    'HR Executive to support Bengaluru hospital HR operations including recruitment, onboarding, and employee lifecycle management.',
    'MBA-HR or equivalent; 2–5 years HRIS experience; knowledge of labour laws; proficiency in HRMS software.',
    1, 'CLOSED',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
    '2024-09-01', '2024-12-31'
),
(
    'Pharmacist — Oncology Drug Management',
    (SELECT Id FROM Department WHERE DepartmentCode='PHARMACY'),
    (SELECT Id FROM Designation WHERE DesignationCode='PHARMACIST'),
    (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'),
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    'FULL_TIME', 3.0, 8.0, 500000.00, 750000.00, 'INR',
    'Pharmacist specialising in chemotherapy drug preparation, handling, and patient counseling at Hyderabad hospital.',
    'B.Pharm / M.Pharm; registered with State Pharmacy Council; oncology or chemo drug handling experience preferred.',
    1, 'OPEN',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
    '2025-03-01', '2025-06-30'
),
(
    'Systems Administrator — EHR & Network',
    (SELECT Id FROM Department WHERE DepartmentCode='IT'),
    (SELECT Id FROM Designation WHERE DesignationCode='SYSADMIN'),
    (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'),
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    'FULL_TIME', 3.0, 7.0, 500000.00, 800000.00, 'INR',
    'Systems Administrator to manage EHR platform, hospital network, and server infrastructure at Delhi hospital.',
    'B.Tech / BCA or equivalent; experience with hospital EHR systems (preferably Cerner/Epic); network admin skills; MCSA/CCNA preferred.',
    1, 'OPEN',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
    '2025-01-15', '2025-04-30'
);


PRINT 'Inserting hr.Candidate...';
INSERT INTO hr.Candidate (FirstName, MiddleName, LastName, Email, Phone, DateOfBirth, Gender, CurrentCompany, CurrentTitle, TotalExpYrs, NoticePeriodDays, CurrentSalary, CurrencyCode, LinkedInUrl, ResumeUrl, Source, ReferredByEmployeeId) VALUES
('Poornima',    NULL,       'Hegde',        'poornima.hegde@gmail.com',         '9845100201', '1992-05-14', 'Female',   'Manipal Hospitals',        'Senior Nurse ICU',         7.0,  30,  720000.00,  'INR', 'https://linkedin.com/in/poornimahegde',     'https://storage.medcareindia.com/resumes/poornima_hegde.pdf',     'LinkedIn',  NULL),
('Siddharth',   NULL,       'Joshi',        'siddharth.joshi@gmail.com',        '9920100202', '1997-11-03', 'Male',     'Kokilaben Hospital',       'Junior Resident',          2.0,  15,  550000.00,  'INR', 'https://linkedin.com/in/siddharthjoshi',    'https://storage.medcareindia.com/resumes/siddharth_joshi.pdf',    'JobPortal', NULL),
('Nandita',     'Rao',      'Krishnamurthy','nandita.krishnamurthy@gmail.com',  '9886100203', '1995-07-22', 'Female',   'Apollo Hospitals',         'HR Executive',             4.0,  30,  480000.00,  'INR', NULL,                                        'https://storage.medcareindia.com/resumes/nandita_krishnamurthy.pdf','Referral',  (SELECT Id FROM Employee WHERE EmployeeCode='EMP021')),
('Abhijit',     NULL,       'Pawar',        'abhijit.pawar@gmail.com',          '9823100204', '1991-03-08', 'Male',     'Cipla Ltd.',               'Clinical Pharmacist',      6.5,  60,  620000.00,  'INR', 'https://linkedin.com/in/abhijitpawar',      'https://storage.medcareindia.com/resumes/abhijit_pawar.pdf',      'LinkedIn',  NULL),
('Rashida',     NULL,       'Shaikh',       'rashida.shaikh@gmail.com',         '9849100205', '1993-09-17', 'Female',   'Max Healthcare',           'Systems Administrator',    5.0,  45,  560000.00,  'INR', 'https://linkedin.com/in/rashidashaikh',     'https://storage.medcareindia.com/resumes/rashida_shaikh.pdf',     'JobPortal', NULL),
('Kiran',       NULL,       'Bhat',         'kiran.bhat@gmail.com',             '9845100206', '1990-12-25', 'Male',     'Fortis Healthcare',        'Senior Staff Nurse ICU',   9.0,  30,  850000.00,  'INR', 'https://linkedin.com/in/kiranbhat',         'https://storage.medcareindia.com/resumes/kiran_bhat.pdf',         'LinkedIn',  NULL),
('Trisha',      NULL,       'Nambiar',      'trisha.nambiar@gmail.com',         '9446100207', '1994-04-11', 'Female',   NULL,                       NULL,                       1.5,  0,   NULL,       'INR', NULL,                                        'https://storage.medcareindia.com/resumes/trisha_nambiar.pdf',     'CampusDrive',NULL);


PRINT 'Inserting hr.Application...';
INSERT INTO hr.Application (JobPostingId, CandidateId, ApplicationStatus, ReviewedByEmployeeId, AppliedAt, StatusUpdatedAt) VALUES
-- Poornima Hegde → Senior Staff Nurse ICU (Mumbai) — Hired
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU'),
    (SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com'),
    'HIRED',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    '2025-02-05 10:00:00', '2025-03-20 14:00:00'
),
-- Kiran Bhat → Senior Staff Nurse ICU (Mumbai) — Interview stage
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU'),
    (SELECT Id FROM hr.Candidate WHERE Email='kiran.bhat@gmail.com'),
    'INTERVIEW',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    '2025-02-18 09:30:00', '2025-03-10 11:00:00'
),
-- Siddharth Joshi → Resident Doctor Cardiology (Pune) — Offer stage
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor — Cardiology'),
    (SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com'),
    'OFFER',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    '2025-02-20 14:00:00', '2025-03-25 10:00:00'
),
-- Nandita Krishnamurthy → HR Executive Bengaluru — Hired (closed posting)
(
    (SELECT Id FROM hr.JobPosting WHERE Title='HR Executive — South India Operations'),
    (SELECT Id FROM hr.Candidate WHERE Email='nandita.krishnamurthy@gmail.com'),
    'HIRED',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
    '2024-09-10 09:00:00', '2024-11-15 16:00:00'
),
-- Abhijit Pawar → Pharmacist Hyderabad — Screening
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Pharmacist — Oncology Drug Management'),
    (SELECT Id FROM hr.Candidate WHERE Email='abhijit.pawar@gmail.com'),
    'SCREENING',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
    '2025-03-05 11:00:00', '2025-03-08 09:00:00'
),
-- Rashida Shaikh → Systems Administrator Delhi — Interview
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator — EHR & Network'),
    (SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com'),
    'INTERVIEW',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
    '2025-01-20 15:00:00', '2025-02-12 10:00:00'
),
-- Trisha Nambiar → Resident Doctor Cardiology — Rejected
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor — Cardiology'),
    (SELECT Id FROM hr.Candidate WHERE Email='trisha.nambiar@gmail.com'),
    'REJECTED',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    '2025-03-01 10:00:00', '2025-03-12 14:00:00'
);


PRINT 'Inserting hr.ApplicationStatusHistory...';
-- Poornima Hegde pipeline
INSERT INTO hr.ApplicationStatusHistory (ApplicationId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')), NULL,         'APPLIED',     (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Application received via LinkedIn',            '2025-02-05 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')), 'APPLIED',    'SCREENING',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Shortlisted for telephonic screening',         '2025-02-08 09:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')), 'SCREENING',  'INTERVIEW',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Cleared screening; technical round scheduled', '2025-02-15 11:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')), 'INTERVIEW',  'OFFER',       (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Cleared all rounds; offer approved',           '2025-03-10 14:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')), 'OFFER',      'NEGOTIATION', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Candidate negotiating CTC',                    '2025-03-12 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')), 'NEGOTIATION','HIRED',       (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Offer accepted; joining date confirmed',       '2025-03-20 14:00:00');

-- Siddharth Joshi pipeline
INSERT INTO hr.ApplicationStatusHistory (ApplicationId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), NULL,        'APPLIED',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Application received via job portal', '2025-02-20 14:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), 'APPLIED',   'SCREENING', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Shortlisted; HR screen call done',    '2025-02-25 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), 'SCREENING', 'INTERVIEW', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Cleared screening; technical round',  '2025-03-05 11:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), 'INTERVIEW', 'OFFER',     (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Cleared technical; offer in progress','2025-03-25 10:00:00');

-- Trisha Nambiar pipeline
INSERT INTO hr.ApplicationStatusHistory (ApplicationId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='trisha.nambiar@gmail.com')), NULL,      'APPLIED',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Application received',                            '2025-03-01 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='trisha.nambiar@gmail.com')), 'APPLIED', 'REJECTED',  (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Insufficient clinical experience for the role',   '2025-03-12 14:00:00');


PRINT 'Inserting hr.InterviewRoundConfig...';
-- Senior Staff Nurse ICU — 4 rounds
INSERT INTO hr.InterviewRoundConfig (JobPostingId, InterviewRoundId, InterviewTypeId, DurationMins, IsMandatory) VALUES
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN'),    (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='PHONE'),      30,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1'),       (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='VIDEO'),      60,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='MANAGER'),      (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='IN_PERSON'),  45,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='FINAL_HR'),     (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='IN_PERSON'),  30,  1);

-- Resident Doctor Cardiology — 3 rounds
INSERT INTO hr.InterviewRoundConfig (JobPostingId, InterviewRoundId, InterviewTypeId, DurationMins, IsMandatory) VALUES
((SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor — Cardiology'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN'),    (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='PHONE'),      30,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor — Cardiology'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1'),       (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='VIDEO'),      60,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor — Cardiology'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='DOMAIN_EXPERT'),(SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='IN_PERSON'),  60,  1);

-- Systems Administrator Delhi — 3 rounds
INSERT INTO hr.InterviewRoundConfig (JobPostingId, InterviewRoundId, InterviewTypeId, DurationMins, IsMandatory) VALUES
((SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator — EHR & Network'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN'), (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='PHONE'),  30, 1),
((SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator — EHR & Network'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1'),    (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='VIDEO'),  90, 1),
((SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator — EHR & Network'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='MANAGER'),   (SELECT Id FROM hr.InterviewType WHERE InterviewTypeCode='IN_PERSON'), 45, 1);


PRINT 'Inserting hr.Interview...';
-- Poornima Hegde — HR Screen (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, InterviewStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN')),
    '2025-02-10 11:00:00', 30, 'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
);
-- Poornima Hegde — Technical Round 1 (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1')),
    '2025-02-18 14:00:00', 60, 'https://teams.microsoft.com/meet/medcare/poornima-tech1', 'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP004')
);
-- Poornima Hegde — Manager Round (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='MANAGER')),
    '2025-03-03 10:00:00', 45, 'MedCare Mumbai HQ — HR Conference Room B', 'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
);
-- Siddharth Joshi — HR Screen (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, InterviewStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor — Cardiology') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN')),
    '2025-02-27 10:30:00', 30, 'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
);
-- Siddharth Joshi — Technical Round 1 (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor — Cardiology') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1')),
    '2025-03-08 11:00:00', 60, 'https://teams.microsoft.com/meet/medcare/siddharth-tech1', 'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP042')
);
-- Rashida Shaikh — HR Screen (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, InterviewStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator — EHR & Network') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN')),
    '2025-01-24 15:00:00', 30, 'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019')
);
-- Rashida Shaikh — Technical Round 1 (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator — EHR & Network') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1')),
    '2025-02-05 14:00:00', 90, 'https://teams.microsoft.com/meet/medcare/rashida-tech1', 'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP007')
);


PRINT 'Inserting hr.InterviewPanel...';
-- Poornima — Tech Round 1 panel
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurposeId, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='PANEL_LEAD'),
    (SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='CLINICAL_KNOWLEDGE'),
    'ICU protocols, ventilator management, BLS/ACLS, critical care nursing', 1, 1, '2025-02-17 09:00:00'
);
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurposeId, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='INTERVIEWER'),
    (SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='PROBLEM_SOLVING'),
    'Scenario-based ICU patient deterioration responses', 0, 1, '2025-02-17 09:00:00'
);

-- Siddharth — Tech Round 1 panel
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurposeId, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP042'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='PANEL_LEAD'),
    (SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='CLINICAL_KNOWLEDGE'),
    'Cardiology basics, ECG interpretation, pharmacology, MBBS knowledge', 1, 1, '2025-03-07 10:00:00'
);
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurposeId, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='INTERVIEWER'),
    (SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='CULTURE_FIT'),
    'Team fit, attitude, peer learning approach in residency', 0, 1, '2025-03-07 10:00:00'
);

-- Rashida — Tech Round 1 panel
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurposeId, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP007'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='PANEL_LEAD'),
    (SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='TECHNICAL_DEPTH'),
    'EHR administration, Windows Server, network troubleshooting, SQL basics', 1, 1, '2025-02-04 11:00:00'
);
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurposeId, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP025'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='TECH_EXPERT'),
    (SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='PROBLEM_SOLVING'),
    'Real-world network failure scenarios and EHR downtime handling', 0, 1, '2025-02-04 11:00:00'
);


PRINT 'Inserting hr.InterviewFeedback...';
-- Poornima — CNO (EMP004) feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP004') AND InterviewPurposeId=(SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='CLINICAL_KNOWLEDGE')),
    8.5, 9.0, 8.0, 8.5, 9.0,
    'Excellent ICU and ventilator management knowledge. Strong BLS/ACLS credentials. Calm under pressure.',
    'Leadership experience with junior nurses could be stronger; recommend monitoring in first 3 months.',
    'YES',
    'Strong candidate for Senior ICU Nurse role. Recommend proceeding to manager round.',
    '2025-02-19 16:00:00'
);
-- Poornima — EMP010 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP010') AND InterviewPurposeId=(SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='PROBLEM_SOLVING')),
    8.0, 8.0, 8.5, 8.0, 7.5,
    'Good scenario handling; structured thinking in patient deterioration cases.',
    'Slightly slow in one high-acuity scenario; needs to sharpen rapid response reflex.',
    'YES',
    'Overall positive. Agrees with lead panelist assessment.',
    '2025-02-19 17:00:00'
);
-- Siddharth — EMP042 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP042') AND InterviewPurposeId=(SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='CLINICAL_KNOWLEDGE')),
    7.5, 7.5, 8.0, 8.0, 7.5,
    'Good MBBS foundation; genuine interest in cardiology; enthusiastic and coachable.',
    'Limited hands-on exposure; ECG interpretation needs improvement; standard for a junior resident.',
    'YES',
    'Suitable for residency with mentoring. Recommend domain expert round.',
    '2025-03-09 15:00:00'
);
-- Rashida — EMP007 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP007') AND InterviewPurposeId=(SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='TECHNICAL_DEPTH')),
    7.0, 7.5, 7.0, 7.0, 7.5,
    'Solid Windows Server and networking skills. Familiar with hospital EHR concepts.',
    'No direct Cerner or Epic experience; would need ramp-up time; basic SQL knowledge only.',
    'MAYBE',
    'Technically adequate but not a standout. Awaiting tech expert score before deciding.',
    '2025-02-06 16:00:00'
);
-- Rashida — EMP025 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP025') AND InterviewPurposeId=(SELECT Id FROM hr.InterviewPurpose WHERE PurposeCode='PROBLEM_SOLVING')),
    7.5, 7.0, 7.5, 7.5, 7.0,
    'Structured troubleshooting approach; handled the network failure scenario well.',
    'Hesitant on EHR downtime SOP; would benefit from healthcare IT exposure.',
    'YES',
    'Recommend proceeding. Can be trained on hospital-specific EHR.',
    '2025-02-06 17:30:00'
);


PRINT 'Inserting hr.PackageNegotiation...';
-- Poornima Hegde — Round 1 (countered) → Round 2 (accepted)
INSERT INTO hr.PackageNegotiation (ApplicationId, HREmployeeId, RoundNumber, OfferedCTC, CandidateAsk, FinalCTC, CurrencyCode, VariablePct, JoiningBonus, OtherBenefits, NegotiationStatus, Notes, NegotiatedAt) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    1, 850000.00, 950000.00, NULL, 'INR', 10.00, NULL,
    'Shift allowance, uniform allowance, group health insurance',
    'COUNTERED', 'Candidate requested higher base citing 7 years ICU experience.', '2025-03-12 10:00:00'
),
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    2, 920000.00, 920000.00, 920000.00, 'INR', 10.00, 30000.00,
    'Shift allowance, uniform allowance, group health insurance, 30K joining bonus',
    'ACCEPTED', 'Candidate accepted revised offer with joining bonus.', '2025-03-18 14:00:00'
);
-- Siddharth Joshi — Round 1 offer (in progress)
INSERT INTO hr.PackageNegotiation (ApplicationId, HREmployeeId, RoundNumber, OfferedCTC, CandidateAsk, FinalCTC, CurrencyCode, VariablePct, JoiningBonus, OtherBenefits, NegotiationStatus, Notes, NegotiatedAt) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    1, 650000.00, 700000.00, NULL, 'INR', 5.00, NULL,
    'Accommodation allowance, continuing medical education allowance',
    'IN_PROGRESS', 'Standard resident package offered; candidate reviewing.', '2025-03-25 11:00:00'
);


PRINT 'Inserting hr.OfferLetter...';
INSERT INTO hr.OfferLetter (ApplicationId, PackageNegotiationId, LetterFileUrl, IssuedDate, ExpiryDate, OfferedPosition, ProposedJoiningDate, OfferStatus, AcceptedAt, IssuedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')),
    (SELECT TOP 1 Id FROM hr.PackageNegotiation WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse — ICU')) ORDER BY RoundNumber DESC),
    'https://storage.medcareindia.com/offers/OL-2025-001-poornima-hegde.pdf',
    '2025-03-19', '2025-04-02', 'Senior Staff Nurse — ICU', '2025-04-10',
    'ACCEPTED', '2025-03-20 14:00:00',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
);


-- =============================================================================================================
-- MODULE B: ONBOARDING
-- =============================================================================================================

PRINT 'Inserting hr.OnboardingChecklist...';
INSERT INTO hr.OnboardingChecklist (ChecklistName, Phase, EmploymentType) VALUES
('Full-Time Clinical Staff — Pre-Onboarding',       'PRE_ONBOARDING',   'FULL_TIME'),
('Full-Time Clinical Staff — Day One',              'DAY_ONE',          'FULL_TIME'),
('Full-Time Clinical Staff — First Week',           'FIRST_WEEK',       'FULL_TIME'),
('Full-Time Clinical Staff — Post-Onboarding',      'POST_ONBOARDING',  'FULL_TIME'),
('Full-Time Admin / Support Staff — Pre-Onboarding','PRE_ONBOARDING',   'FULL_TIME'),
('Full-Time Admin / Support Staff — Day One',       'DAY_ONE',          'FULL_TIME'),
('Junior Resident / Intern — Pre-Onboarding',       'PRE_ONBOARDING',   'FULL_TIME');


PRINT 'Inserting hr.OnboardingChecklistItem...';
-- Clinical Pre-Onboarding
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, SequenceOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'Collect signed offer letter',          'Obtain candidate-signed copy of the offer letter',                                     'HR',       1,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'Verify Medical License / MCI Reg.',    'Validate MCI or State Medical Council registration number',                            'HR',       2,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'Collect Aadhaar and PAN copies',       'Collect self-attested copies of government IDs',                                       'HR',       3,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'Collect educational certificates',     'Degree, diploma, and internship completion certificates',                              'HR',       4,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'Collect experience/relieving letter',  'Previous employer relieving letter or experience certificate',                         'HR',       5,  0),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'Collect bank account details',         'Cancelled cheque or bank passbook copy for salary credit',                             'HR',       6,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'Initiate BGV — Identity & Education',  'Raise background verification request with agency for identity and education checks',  'HR',       7,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding'), 'COVID-19 vaccination certificate',     'Collect proof of full COVID-19 vaccination',                                           'HR',       8,  1);

-- Clinical Day One
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, SequenceOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Day One'), 'Issue employee ID card',               'Generate and issue photo ID badge with department and floor access',   'HR',       1,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Day One'), 'Create EHR system login',             'Provision EHR (hospital system) credentials with correct role',         'IT',       2,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Day One'), 'Register biometric at device',        'Enrol fingerprint on floor biometric device',                           'IT',       3,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Day One'), 'HR induction session',                'Attend mandatory HR induction covering policies and benefits',          'HR',       4,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Day One'), 'Introduction to reporting manager',   'Formal introduction and department orientation by reporting manager',   'Manager',  5,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Day One'), 'Collect uniform and equipment',       'Issue hospital scrubs, stethoscope (where applicable), and locker',    'Admin',    6,  1);

-- Clinical First Week
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, SequenceOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — First Week'), 'Complete infection control training',      'Mandatory online module on hospital infection prevention and PPE',              'HR',       1,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — First Week'), 'Complete BLS refresher (if lapsed)',        'Basic Life Support recertification if certificate is older than 2 years',        'Training', 2,  0),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — First Week'), 'Shadow senior for department orientation',  'Spend first 2 days shadowing assigned senior staff',                           'Manager',  3,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — First Week'), 'Review patient safety and escalation SOPs', 'Read and acknowledge department-specific SOPs',                                 'Manager',  4,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — First Week'), 'Complete HRMS self-service setup',          'Employee to update profile, upload photo, and review leave balance in HRMS',    'Employee', 5,  1);

-- Admin / Support Pre-Onboarding
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, SequenceOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Pre-Onboarding'), 'Collect signed offer letter',      'Obtain candidate-signed copy of the offer letter',                     'HR',  1, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Pre-Onboarding'), 'Collect Aadhaar and PAN copies',   'Collect self-attested government ID copies',                           'HR',  2, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Pre-Onboarding'), 'Collect educational certificates',  'Degree and diploma certificates relevant to the role',                 'HR',  3, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Pre-Onboarding'), 'Collect bank account details',     'Cancelled cheque for salary credit setup',                             'HR',  4, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Pre-Onboarding'), 'Initiate BGV — Employment History','Raise BGV request for employment history and identity verification',  'HR',  5, 1);

-- Admin Day One
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, SequenceOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One'), 'Issue employee ID card',           'Generate and issue photo ID with office access',                   'HR',       1, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One'), 'Create system/application login',  'Provision email, HRMS, and relevant application access',           'IT',       2, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One'), 'Register biometric at device',    'Enrol fingerprint on main entrance biometric device',              'IT',       3, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One'), 'HR induction session',            'Attend HR induction covering code of conduct and IT policies',     'HR',       4, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One'), 'Workstation and asset allocation', 'Allocate laptop/desktop, headset, and stationery',                'IT',       5, 1);


PRINT 'Inserting hr.OnboardingTask (for new joiners EMP030 and hired candidate Poornima)...';
-- EMP030 (Sangeetha Arumugam — HR Executive Chennai, joined 2023-03-01) — Post-Onboarding tasks
INSERT INTO hr.OnboardingTask (EmployeeId, OnboardingChecklistItemId, TaskName, Phase, OwnerRole, TaskStatus, DueDate, CompletedDate, CompletedByEmployeeId, Remarks) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Collect signed offer letter'          AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Pre-Onboarding')), 'Collect signed offer letter',      'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-02-25', '2023-02-24', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), 'Signed offer letter received via email and original collected on Day 1'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Collect Aadhaar and PAN copies'       AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Pre-Onboarding')), 'Collect Aadhaar and PAN copies',   'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-02-25', '2023-03-01', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), 'Copies collected on joining day'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Issue employee ID card'               AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One')),         'Issue employee ID card',           'DAY_ONE',        'HR',      'COMPLETED', '2023-03-01', '2023-03-01', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), 'ID card issued on Day 1'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Create system/application login'      AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One')),         'Create system/application login',  'DAY_ONE',        'IT',      'COMPLETED', '2023-03-01', '2023-03-02', (SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), 'Email and HRMS access provisioned by IT'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='HR induction session'                  AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff — Day One')),         'HR induction session',             'DAY_ONE',        'HR',      'COMPLETED', '2023-03-01', '2023-03-01', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), 'Attended group induction with 2 other joiners');

-- EMP043 (Rohit Patil — Junior Resident, Pune, joined 2023-08-01) — Pending tasks
INSERT INTO hr.OnboardingTask (EmployeeId, OnboardingChecklistItemId, TaskName, Phase, OwnerRole, TaskStatus, DueDate, CompletedDate, CompletedByEmployeeId, Remarks) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Collect signed offer letter'         AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding')), 'Collect signed offer letter',           'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-07-28', '2023-07-27', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Signed offer received'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Verify Medical License / MCI Reg.'   AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Pre-Onboarding')), 'Verify Medical License / MCI Reg.',     'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-07-28', '2023-07-30', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'MCI registration verified online'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Issue employee ID card'              AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — Day One')),         'Issue employee ID card',                'DAY_ONE',        'HR',      'COMPLETED', '2023-08-01', '2023-08-01', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'ID card with clinical floor access issued'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Complete infection control training' AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — First Week')),      'Complete infection control training',   'FIRST_WEEK',     'Training','COMPLETED', '2023-08-07', '2023-08-05', (SELECT Id FROM Employee WHERE EmployeeCode='EMP041'), 'Completed online module with score 88%'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Complete BLS refresher (if lapsed)'  AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff — First Week')),      'Complete BLS refresher (if lapsed)',    'FIRST_WEEK',     'Training','WAIVED',    '2023-08-07', NULL,         NULL,                                                  'BLS certificate within validity period; waived');


PRINT 'Inserting hr.DocumentVerification...';
INSERT INTO hr.DocumentVerification (EmployeeId, DocumentTypeId, OnboardingPhase, FileUrl, DocumentNumber, IssuedBy, IssueDate, ExpiryDate, DocVerifyStatus, SubmittedDate, VerifiedDate, VerifiedByEmployeeId, Remarks) VALUES
-- EMP030 Sangeetha — Admin documents
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='AADHAAR'),    'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP030/aadhaar.pdf',          '4567 8901 2345', 'UIDAI',                '2018-06-01', NULL,         'VERIFIED',     '2023-03-01', '2023-03-03', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), 'Aadhaar verified against UIDAI portal'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='PAN'),        'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP030/pan.pdf',              'BNZSA1234F',     'Income Tax Dept.',     '2016-03-15', NULL,         'VERIFIED',     '2023-03-01', '2023-03-03', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), 'PAN verified'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='EDUCATIONCERT'),'PRE_ONBOARDING','https://storage.medcareindia.com/docs/EMP030/mba_cert.pdf',        'MDU-MBA-2018-4521','Madurai Kamaraj Univ.','2018-05-01', NULL,         'VERIFIED',     '2023-03-01', '2023-03-05', (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), 'MBA-HR certificate verified'),
-- EMP043 Rohit — Resident documents
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='MEDLICENSE'),  'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP043/mci_reg.pdf',         'MH-MCI-2022-8834','Maharashtra MCI',      '2022-07-01', '2027-06-30', 'VERIFIED',     '2023-07-30', '2023-08-02', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'MCI registration active and verified'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='AADHAAR'),    'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP043/aadhaar.pdf',          '9012 3456 7890', 'UIDAI',                '2019-01-10', NULL,         'VERIFIED',     '2023-07-30', '2023-08-02', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Aadhaar verified'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='EDUCATIONCERT'),'PRE_ONBOARDING','https://storage.medcareindia.com/docs/EMP043/mbbs_cert.pdf',       'MUHS-MBBS-2022-10256','Pune University',  '2022-06-15', NULL,         'VERIFIED',     '2023-07-30', '2023-08-03', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'MBBS certificate verified'),
-- EMP034 Padma — Junior Nurse documents with pending item
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='NURSINGREG'),  'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP034/nursing_reg.pdf',     'TN-NMC-2022-3341','Tamil Nadu NMC',      '2022-10-01', '2027-09-30', 'VERIFIED',     '2023-01-15', '2023-01-18', (SELECT Id FROM Employee WHERE EmployeeCode='EMP031'), 'Nursing council registration verified'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM DocumentType WHERE DocumentTypeCode='COVIDVACC'),   'PRE_ONBOARDING', NULL,                                                              NULL,             NULL,                   NULL,         NULL,         'PENDING',      NULL,         NULL,         NULL,                                                 'COVID vaccination certificate not yet submitted — follow up with employee');


PRINT 'Inserting hr.BGVAgency...';
INSERT INTO hr.BGVAgency (AgencyName, ContactPerson, Email, Phone) VALUES
('AuthBridge Research Services Pvt. Ltd.',  'Rajat Sharma',     'rajat.sharma@authbridge.com',      '+91-124-4399999'),
('First Advantage India',                   'Preethi Nair',     'preethi.nair@fadv.com',            '+91-80-67001000'),
('Netrika Consulting India Pvt. Ltd.',      'Sundeep Malhotra', 'sundeep@netrika.com',              '+91-11-45151515'),
('IDfy Technologies Pvt. Ltd.',             'Ananya Kapoor',    'ananya.kapoor@idfy.com',           '+91-22-62662666');


PRINT 'Inserting hr.BackgroundVerification...';
INSERT INTO hr.BackgroundVerification (EmployeeId, BGVAgencyId, BGVCheckType, OnboardingPhase, InitiatedByEmployeeId, InitiatedDate, ExpectedDate, CompletedDate, BGVStatus, BGVResult, Findings, ReportUrl) VALUES
-- EMP030 — Identity (completed, clear)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='AuthBridge Research Services Pvt. Ltd.'),
 'IDENTITY', 'PRE_ONBOARDING',
 (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
 '2023-02-28', '2023-03-14', '2023-03-10', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP030/identity_report.pdf'),
-- EMP030 — Employment History (completed, clear)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='AuthBridge Research Services Pvt. Ltd.'),
 'EMPLOYMENT_HISTORY', 'PRE_ONBOARDING',
 (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
 '2023-02-28', '2023-03-21', '2023-03-18', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP030/employment_report.pdf'),
-- EMP043 — Identity (completed, clear)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='First Advantage India'),
 'IDENTITY', 'PRE_ONBOARDING',
 (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
 '2023-07-28', '2023-08-11', '2023-08-08', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP043/identity_report.pdf'),
-- EMP043 — Education (completed, clear)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='First Advantage India'),
 'EDUCATION', 'PRE_ONBOARDING',
 (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
 '2023-07-28', '2023-08-18', '2023-08-15', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP043/education_report.pdf'),
-- EMP034 — Identity (in progress)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='IDfy Technologies Pvt. Ltd.'),
 'IDENTITY', 'PRE_ONBOARDING',
 (SELECT Id FROM Employee WHERE EmployeeCode='EMP031'),
 '2023-01-14', '2023-01-28', NULL, 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP034/identity_report.pdf'),
-- EMP040 — Criminal (completed, clear)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP040'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='Netrika Consulting India Pvt. Ltd.'),
 'CRIMINAL', 'PRE_ONBOARDING',
 (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'),
 '2022-08-25', '2022-09-08', '2022-09-05', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP040/criminal_report.pdf');


-- =============================================================================================================
-- MODULE C: POLICY DOCUMENTS
-- =============================================================================================================

PRINT 'Inserting hr.PolicyCategory...';
INSERT INTO hr.PolicyCategory (CategoryCode, CategoryName, Description) VALUES
('HR_POLICY',       'HR Policies',              'Leave, attendance, code of conduct, and employee welfare policies'),
('CLINICAL_POLICY', 'Clinical & Patient Safety','Infection control, patient safety, medication administration policies'),
('IT_POLICY',       'IT & Data Security',       'EHR usage, data privacy, device management, and cybersecurity policies'),
('FINANCE_POLICY',  'Finance & Compliance',     'Expense claims, reimbursement, payroll, and statutory compliance policies'),
('OPERATIONS',      'Operations & Facilities',  'Housekeeping, bio-medical waste, transport, and facility management policies');


PRINT 'Inserting hr.PolicyDocument...';
INSERT INTO hr.PolicyDocument (PolicyCategoryId, PolicyCode, PolicyName, Description, ScopeTypeId, ScopeReferenceId, AcknowledgementRequired, AcknowledgementDeadlineDays, IsActive, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='HR_POLICY'),
    'POL-HR-001', 'Leave and Attendance Policy',
    'Defines leave types, entitlements, accrual rules, carry-forward norms, and attendance regularization procedures for all employees.',
    (SELECT Id FROM ScopeType WHERE ScopeCode='LEGAL_ENTITY'),
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),
    1, 30, 1,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='HR_POLICY'),
    'POL-HR-002', 'Code of Conduct Policy',
    'Defines professional behaviour standards, ethical obligations, conflict of interest disclosures, and disciplinary procedures.',
    (SELECT Id FROM ScopeType WHERE ScopeCode='GLOBAL'),
    1,
    1, 15, 1,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='CLINICAL_POLICY'),
    'POL-CLN-001', 'Hospital Infection Control Policy',
    'Mandatory guidelines for hand hygiene, PPE usage, isolation protocols, and bio-medical waste segregation for all clinical staff.',
    (SELECT Id FROM ScopeType WHERE ScopeCode='GLOBAL'),
    1,
    1, 7, 1,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP001')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='CLINICAL_POLICY'),
    'POL-CLN-002', 'Medication Administration and Dispensing Policy',
    'Protocols for safe medication ordering, verification, dispensing, and error reporting across all hospital units.',
    (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'),
    (SELECT Id FROM Department WHERE DepartmentCode='PHARMACY'),
    1, 14, 1,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP012')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='IT_POLICY'),
    'POL-IT-001', 'EHR Access and Data Privacy Policy',
    'Governs EHR login credentials, patient data access rights, audit trails, and penalties for unauthorized data access.',
    (SELECT Id FROM ScopeType WHERE ScopeCode='GLOBAL'),
    1,
    1, 14, 1,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP007')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='FINANCE_POLICY'),
    'POL-FIN-001', 'Employee Expense Reimbursement Policy',
    'Covers eligible expense categories, claim submission process, approval hierarchy, and reimbursement timelines.',
    (SELECT Id FROM ScopeType WHERE ScopeCode='LEGAL_ENTITY'),
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),
    1, 30, 1,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP006')
);


PRINT 'Inserting hr.PolicyVersion...';
INSERT INTO hr.PolicyVersion (PolicyDocumentId, VersionNumber, VersionLabel, FileUrl, OriginalFileName, ChangeNotes, PolicyStatus, EffectiveDate, PublishedByEmployeeId, PublishedAt) VALUES
-- Leave and Attendance Policy — v1 (archived), v2 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-HR-001-v1.pdf',
    'Leave_Attendance_Policy_v1.0.pdf',
    'Initial version.',
    'ARCHIVED', '2020-04-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2020-03-25 10:00:00'
),
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001'),
    2, 'v2.0',
    'https://storage.medcareindia.com/policies/POL-HR-001-v2.pdf',
    'Leave_Attendance_Policy_v2.0.pdf',
    'Updated maternity leave entitlement to 26 weeks as per Maternity Benefit (Amendment) Act. Added WFH attendance guidelines.',
    'ACTIVE', '2023-01-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2022-12-20 14:00:00'
),
-- Code of Conduct — v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-002'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-HR-002-v1.pdf',
    'Code_of_Conduct_v1.0.pdf',
    'Initial version. Applicable to all employees across all entities.',
    'ACTIVE', '2021-07-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2021-06-28 09:00:00'
),
-- Infection Control Policy — v1 (archived), v2 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-CLN-001-v1.pdf',
    'Infection_Control_Policy_v1.0.pdf',
    'Initial version based on WHO hospital infection prevention guidelines.',
    'ARCHIVED', '2019-06-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2019-05-30 10:00:00'
),
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001'),
    2, 'v2.0',
    'https://storage.medcareindia.com/policies/POL-CLN-001-v2.pdf',
    'Infection_Control_Policy_v2.0.pdf',
    'Revised to incorporate COVID-19 specific PPE protocols and aerosol-generating procedure guidelines. Updated hand hygiene stations matrix.',
    'ACTIVE', '2022-01-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2021-12-15 11:00:00'
),
-- Medication Administration Policy — v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-002'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-CLN-002-v1.pdf',
    'Medication_Administration_Policy_v1.0.pdf',
    'Initial version aligned with national pharmacy council guidelines.',
    'ACTIVE', '2020-09-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), '2020-08-25 09:00:00'
),
-- EHR Access Policy — v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-IT-001-v1.pdf',
    'EHR_Data_Privacy_Policy_v1.0.pdf',
    'Initial version. Covers all EHR user access categories and HIPAA-equivalent data privacy norms.',
    'ACTIVE', '2021-04-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), '2021-03-29 14:00:00'
),
-- Expense Reimbursement Policy — v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-FIN-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-FIN-001-v1.pdf',
    'Expense_Reimbursement_Policy_v1.0.pdf',
    'Initial version covering travel, accommodation, and professional development reimbursements.',
    'ACTIVE', '2020-01-01',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), '2019-12-28 10:00:00'
);

-- Link superseded version
UPDATE hr.PolicyVersion
SET SupersededByVersionId = (SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001')  AND VersionNumber=2)
WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=1;

UPDATE hr.PolicyVersion
SET SupersededByVersionId = (SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2)
WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=1;


PRINT 'Inserting hr.PolicyAcknowledgement (samples)...';
-- Leave Policy v2 — select clinical and HR staff
INSERT INTO hr.PolicyAcknowledgement (PolicyVersionId, EmployeeId, AckStatus, DeadlineDate, AcknowledgedAt) VALUES
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-15 09:30:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-16 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-18 11:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-17 14:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-20 09:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), 'ACKNOWLEDGED', '2023-03-31', '2023-03-10 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), 'PENDING',      '2023-02-15', NULL),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), 'ACKNOWLEDGED', '2023-08-31', '2023-08-10 09:00:00');

-- Infection Control Policy v2 — clinical staff
INSERT INTO hr.PolicyAcknowledgement (PolicyVersionId, EmployeeId, AckStatus, DeadlineDate, AcknowledgedAt) VALUES
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-05 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-06 09:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-07 11:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-05 14:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-07 15:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-06 16:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM Employee WHERE EmployeeCode='EMP027'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-08 09:30:00');

-- EHR Data Privacy Policy — IT and admin staff
INSERT INTO hr.PolicyAcknowledgement (PolicyVersionId, EmployeeId, AckStatus, DeadlineDate, AcknowledgedAt) VALUES
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), 'ACKNOWLEDGED', '2021-04-15', '2021-04-03 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), 'ACKNOWLEDGED', '2021-04-15', '2021-04-08 11:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM Employee WHERE EmployeeCode='EMP014'), 'ACKNOWLEDGED', '2021-04-15', '2021-04-10 14:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM Employee WHERE EmployeeCode='EMP015'), 'OVERDUE',      '2021-04-15', NULL);


-- =============================================================================================================
-- MODULE D: SALARY SLIPS
-- Note: hr.SalarySlipPublication rows depend on payroll.PayrollDisbursementTransaction records
-- which require a full payroll run to exist. This block is provided as a documented stub.
-- Once payroll disbursement transactions are created for March 2025 (PayrollMonth=3, PayrollYear=2025),
-- run the following pattern to publish salary slips:
--
--   INSERT INTO hr.SalarySlipPublication (DisbursementTransactionId, SlipStatus, FileUrl, IsPasswordProtected, GeneratedAt, PublishedAt)
--   SELECT
--       pdt.Id,
--       'PUBLISHED',
--       'https://storage.medcareindia.com/slips/' + CAST(pdt.PayrollYear AS NVARCHAR) + '/' + FORMAT(pdt.PayrollMonth,'00') + '/SLIP-' + e.EmployeeCode + '.pdf',
--       1,
--       GETUTCDATE(),
--       GETUTCDATE()
--   FROM payroll.PayrollDisbursementTransaction pdt
--   INNER JOIN dbo.Employee e ON e.Id = pdt.EmployeeId
--   WHERE pdt.PayrollMonth = 3 AND pdt.PayrollYear = 2025;
-- =============================================================================================================

PRINT 'Skipping hr.SalarySlipPublication — requires payroll disbursement transactions to exist first.';


-- =============================================================================================================
-- MODULE E: PERFORMANCE REVIEWS
-- =============================================================================================================

PRINT 'Inserting hr.PerformanceCycle...';
INSERT INTO hr.PerformanceCycle (CycleName, CycleType, StartDate, EndDate, GoalSettingDeadline, ReviewStartDate, ReviewEndDate, CycleStatus, LegalEntityId, CreatedByEmployeeId) VALUES
('Annual Appraisal 2023 — MedCare India',       'ANNUAL',   '2023-01-01', '2023-12-31', '2023-02-28', '2024-01-15', '2024-02-28', 'COMPLETED',    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')),
('Annual Appraisal 2024 — MedCare India',       'ANNUAL',   '2024-01-01', '2024-12-31', '2024-02-29', '2025-01-15', '2025-02-28', 'COMPLETED',    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')),
('Annual Appraisal 2024 — MedCare North',       'ANNUAL',   '2024-01-01', '2024-12-31', '2024-02-29', '2025-01-15', '2025-02-28', 'COMPLETED',    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP019')),
('Annual Appraisal 2024 — MedCare South',       'ANNUAL',   '2024-01-01', '2024-12-31', '2024-02-29', '2025-01-15', '2025-02-28', 'COMPLETED',    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP019')),
('Probation Review — Q3 2023 Joiners',          'PROBATION','2023-08-01', '2024-01-31', '2023-09-15', '2024-01-15', '2024-01-31', 'COMPLETED',    NULL,                                                          (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')),
('Annual Appraisal 2025 — All Entities',        'ANNUAL',   '2025-01-01', '2025-12-31', '2025-03-31', '2026-01-15', '2026-02-28', 'GOAL_SETTING', NULL,                                                          (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'));


PRINT 'Inserting hr.Goal (2024 cycle — sample employees)...';
-- EMP003 Dr. Arjun Mehta — Senior Cardiac Surgeon — 2024 Annual
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating, ApprovedByEmployeeId) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Achieve zero post-operative infection rate in Cardiac Surgery unit',
    'Implement and lead enhanced sterile technique protocols; target zero SSI cases in elective cardiac surgeries.',
    'Clinical',
    40.00, '2024-12-31', 'COMPLETED', 100, 4.5, 4.5,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP002')
),
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Mentor 2 resident doctors through advanced cardiac surgical procedures',
    'Provide hands-on mentoring to EMP009 and one additional resident in CABG and valve repair procedures.',
    'Learning',
    30.00, '2024-12-31', 'COMPLETED', 100, 4.0, 4.0,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP002')
),
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Publish one peer-reviewed research paper on minimally invasive cardiac surgery',
    'Co-author and submit a research paper to a national or international cardiology journal.',
    'Learning',
    30.00, '2024-12-31', 'COMPLETED', 100, 3.5, 3.5,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP002')
);

-- EMP010 Meena Joshi — Senior ICU Nurse — 2024 Annual
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating, ApprovedByEmployeeId) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Achieve 100% BLS/ACLS certification compliance in ICU nursing team',
    'Ensure all 6 ICU nurses complete BLS/ACLS recertification by June 2024.',
    'Clinical',
    50.00, '2024-06-30', 'COMPLETED', 100, 4.5, 5.0,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP004')
),
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Reduce ventilator-associated events by 20% compared to 2023 baseline',
    'Implement VAE prevention bundle; monitor and report monthly outcomes to CNO.',
    'Clinical',
    50.00, '2024-12-31', 'COMPLETED', 100, 4.0, 4.5,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP004')
);

-- EMP005 Vikram Gupta — HR Manager — 2024 Annual
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating, ApprovedByEmployeeId) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Reduce average time-to-fill for clinical vacancies to under 45 days',
    'Streamline recruitment pipeline; improve JD quality; reduce interview scheduling lag.',
    'Business',
    40.00, '2024-12-31', 'COMPLETED', 100, 4.0, 3.5,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP001')
),
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Achieve 95% policy acknowledgement compliance across all mandatory policies',
    'Track and follow up on pending policy acknowledgements; escalate overdue items monthly.',
    'Business',
    30.00, '2024-12-31', 'COMPLETED', 100, 3.5, 3.5,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP001')
),
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    'Implement structured 90-day onboarding programme for new clinical joiners',
    'Design checklist-driven onboarding with phase gates for Pre-Joining, Day One, and First Month.',
    'Learning',
    30.00, '2024-06-30', 'COMPLETED', 100, 4.5, 4.5,
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP001')
);

-- EMP009 Dr. Anil Khanna — Resident Doctor — 2025 Annual (in progress)
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 — All Entities'),
    'Complete advanced cardiac catheterisation training module',
    'Attend and complete cath lab training supervised by Dr. Arjun Mehta; achieve 20 supervised procedures.',
    'Learning',
    40.00, '2025-09-30', 'IN_PROGRESS', 35, NULL, NULL
),
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 — All Entities'),
    'Improve patient documentation accuracy score to above 90%',
    'Reduce EHR documentation errors as measured in monthly audit by medical records team.',
    'Business',
    30.00, '2025-12-31', 'APPROVED',    10, NULL, NULL
),
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 — All Entities'),
    'Present a clinical case study at the internal CME session',
    'Prepare and present a complex cardiac case to the department at the quarterly CME.',
    'Learning',
    30.00, '2025-06-30', 'SUBMITTED',   0,  NULL, NULL
);


PRINT 'Inserting hr.GoalKeyResult...';
-- EMP003 — Zero infection goal KRs
INSERT INTO hr.GoalKeyResult (GoalId, Description, TargetValue, ActualValue, KRStatus) VALUES
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP003') AND Title LIKE '%infection rate%' ORDER BY Id),
    'Surgical Site Infection (SSI) rate in elective cardiac cases',
    '0 cases', '0 cases', 'ACHIEVED'
),
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP003') AND Title LIKE '%infection rate%' ORDER BY Id),
    'Monthly sterile technique compliance audit score',
    '>= 95%', '97%', 'ACHIEVED'
);
-- EMP009 — Catheterisation training KRs
INSERT INTO hr.GoalKeyResult (GoalId, Description, TargetValue, ActualValue, KRStatus) VALUES
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP009') AND Title LIKE '%catheterisation%' ORDER BY Id),
    'Number of supervised cath lab procedures completed',
    '20 procedures', '7 procedures', 'ON_TRACK'
),
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP009') AND Title LIKE '%catheterisation%' ORDER BY Id),
    'Completion of theoretical module assessment',
    '80% pass score', 'Not started yet', 'PENDING'
);


PRINT 'Inserting hr.PerformanceReview (2024 Annual)...';
-- EMP003 — 2024 Annual (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, HRBPComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP002'),
    4.2, 4.4, 4.3, 'Exceeds',
    'Successfully achieved zero SSI target and mentored two residents through complex procedures. Research paper submission was a significant professional milestone.',
    'Dr. Mehta continues to set the benchmark for surgical excellence in our cardiac unit. Outstanding year.',
    'Consistent top performer. Recommend for merit increment and leadership responsibility expansion.',
    'COMPLETED',
    '2025-01-18 10:00:00', '2025-01-28 14:00:00', '2025-02-10 11:00:00'
);
-- EMP010 — 2024 Annual (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, HRBPComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'),
    4.5, 4.8, 4.7, 'Exceeds',
    'Proud of achieving 100% BLS/ACLS compliance in the team and measurable improvement in VAE metrics.',
    'Meena is the backbone of our ICU nursing team. Excellent leadership, exceptional clinical outcomes.',
    'Strong candidate for Senior Nurse Lead role. Recommend promotion discussion.',
    'COMPLETED',
    '2025-01-16 09:00:00', '2025-01-26 11:00:00', '2025-02-08 14:00:00'
);
-- EMP005 — 2024 Annual (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, HRBPComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India'),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP001'),
    3.8, 3.6, 3.7, 'Meets',
    'Delivered on most HR goals. Recruitment TAT improved significantly. Onboarding programme rolled out on time.',
    'Vikram has done a solid job on operational HR. Some room to improve strategic people initiatives.',
    'Meets expectations. Consider L&D focus for next cycle.',
    'COMPLETED',
    '2025-01-20 10:00:00', '2025-02-01 16:00:00', '2025-02-12 10:00:00'
);
-- EMP009 — 2025 Annual (Pending — just started)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, ReviewStatus) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 — All Entities'),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'),
    'PENDING'
);
-- EMP043 — Probation Review (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP043'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Probation Review — Q3 2023 Joiners'),
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP041'),
    3.5, 3.5, 3.5, 'Meets',
    'Good learning curve. Adapting well to hospital environment and rotating departments.',
    'Rohit has shown good attitude and learning drive. Recommend confirmation of employment.',
    'COMPLETED',
    '2024-01-18 10:00:00', '2024-01-25 14:00:00', '2024-01-30 11:00:00'
);


PRINT 'Inserting hr.PerformanceReviewHistory...';
-- EMP003 — review history
INSERT INTO hr.PerformanceReviewHistory (PerformanceReviewId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), NULL,             'PENDING',          (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Review cycle initiated for 2024',              '2025-01-15 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), 'PENDING',        'SELF_SUBMITTED',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), 'Self-assessment submitted by employee',        '2025-01-18 10:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), 'SELF_SUBMITTED', 'MANAGER_REVIEW',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), 'Manager review in progress',                   '2025-01-20 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), 'MANAGER_REVIEW', 'HRBP_REVIEW',      (SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), 'Manager submitted; routed to HRBP for review', '2025-01-28 14:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), 'HRBP_REVIEW',    'COMPLETED',        (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Review finalised and rating locked',           '2025-02-10 11:00:00');

-- EMP010 — review history (abbreviated)
INSERT INTO hr.PerformanceReviewHistory (PerformanceReviewId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), NULL,             'PENDING',          (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Review cycle initiated',                       '2025-01-15 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), 'PENDING',        'SELF_SUBMITTED',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), 'Self-assessment submitted',                    '2025-01-16 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), 'SELF_SUBMITTED', 'MANAGER_REVIEW',   (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), 'Moved to CNO for manager review',              '2025-01-18 10:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 — MedCare India')), 'MANAGER_REVIEW', 'COMPLETED',        (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'HRBP waived for this grade; review finalised',  '2025-02-08 14:00:00');


-- =============================================================================================================
-- MODULE F: TRAINING RECORDS
-- =============================================================================================================

PRINT 'Inserting hr.TrainingCategory...';
INSERT INTO hr.TrainingCategory (CategoryName, Description) VALUES
('Clinical Skills',         'Hands-on and knowledge-based clinical training for medical and nursing staff'),
('Infection Control',       'Hospital infection prevention, PPE, and bio-medical waste management'),
('Patient Safety',          'Mandatory patient safety, fall prevention, and adverse event reporting'),
('Emergency & Life Support','BLS, ACLS, PALS, and mass casualty response training'),
('IT & EHR Systems',        'Electronic Health Record usage, digital tools, and hospital IT platforms'),
('HR & Compliance',         'Labour law, POSH, code of conduct, and HRMS training'),
('Finance & Billing',       'Medical billing, ICD-10 coding, insurance claims, and financial compliance'),
('Leadership & Management', 'Team leadership, conflict resolution, and people management for senior staff'),
('Soft Skills',             'Communication, patient empathy, time management, and interpersonal skills'),
('Pharmacy & Medication',   'Safe medication handling, chemotherapy drug safety, and pharmacovigilance');


PRINT 'Inserting hr.TrainingProgram...';
INSERT INTO hr.TrainingProgram (TrainingCategoryId, ProgramCode, Title, Description, TrainingMode, DurationHours, Provider, IsMandatory, ApplicableTo, MaxParticipants, CertificateProvided) VALUES
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Emergency & Life Support'),
    'TRN-BLS-001', 'Basic Life Support (BLS) Certification',
    'Hands-on BLS certification covering CPR, AED operation, and choking response for adults, children, and infants.',
    'OFFLINE', 8.0, 'American Heart Association (AHA)', 1, 'All', 20, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Emergency & Life Support'),
    'TRN-ACLS-001', 'Advanced Cardiovascular Life Support (ACLS) Certification',
    'ACLS certification for clinical staff; covers advanced airway management, cardiac arrest algorithms, and pharmacology.',
    'OFFLINE', 16.0, 'American Heart Association (AHA)', 0, 'Clinical', 15, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Infection Control'),
    'TRN-IC-001', 'Hospital Infection Control — Mandatory Module',
    'Online module covering hand hygiene, PPE donning/doffing, isolation precautions, and bio-medical waste segregation.',
    'ONLINE', 4.0, 'MedCare Internal L&D Team', 1, 'All', NULL, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Patient Safety'),
    'TRN-PS-001', 'Patient Safety and Adverse Event Reporting',
    'Mandatory patient safety awareness training including NABH standards, fall prevention, and incident reporting.',
    'ONLINE', 3.0, 'MedCare Internal L&D Team', 1, 'Clinical', NULL, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='IT & EHR Systems'),
    'TRN-EHR-001', 'EHR System — New User Onboarding',
    'Hands-on training for newly joined staff on EHR login, patient registration, clinical notes, and discharge summary.',
    'OFFLINE', 6.0, 'MedCare IT Team', 1, 'NewJoiner', 12, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='HR & Compliance'),
    'TRN-POSH-001', 'Prevention of Sexual Harassment (POSH) — Annual Awareness',
    'Annual mandatory POSH awareness module covering definitions, reporting process, and ICC responsibilities.',
    'ONLINE', 2.0, 'MedCare Internal L&D Team', 1, 'All', NULL, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Pharmacy & Medication'),
    'TRN-CHEMO-001', 'Chemotherapy Drug Safety and Handling',
    'Specialised training for pharmacy and oncology nursing staff on safe handling, spill management, and disposal of cytotoxic drugs.',
    'HYBRID', 8.0, 'Oncology Pharmacy Association of India', 0, 'Pharmacy', 10, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Leadership & Management'),
    'TRN-LDR-001', 'Clinical Leadership for Senior Staff',
    'Two-day workshop on team management, conflict resolution, performance conversations, and clinical governance.',
    'OFFLINE', 16.0, 'MedCare Leadership Academy', 0, 'L5+', 15, 0
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Clinical Skills'),
    'TRN-ICU-001', 'ICU Protocols and Ventilator Management Refresher',
    'Annual refresher for ICU nurses covering updated ventilator weaning protocols, VAE prevention bundle, and sedation management.',
    'HYBRID', 8.0, 'MedCare Clinical Training Team', 1, 'Department:ICU', 10, 1
),
(
    (SELECT Id FROM hr.TrainingCategory WHERE CategoryName='Soft Skills'),
    'TRN-EMP-001', 'Patient Communication and Empathy Skills',
    'Workshop on therapeutic communication, breaking bad news, and managing distressed families in hospital settings.',
    'OFFLINE', 6.0, 'MedCare Internal L&D Team', 0, 'Clinical', 20, 0
);


PRINT 'Inserting hr.TrainingBatch...';
INSERT INTO hr.TrainingBatch (TrainingProgramId, BatchName, FacilitatorEmployeeId, StartDate, EndDate, VenueOrLink, MaxSeats, BatchStatus) VALUES
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'),
    'BLS Batch — January 2025 — Mumbai',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'),
    '2025-01-18', '2025-01-18',
    'MedCare Mumbai HQ — Simulation Lab, Floor 2', 20, 'COMPLETED'
),
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-ACLS-001'),
    'ACLS Batch — February 2025 — Mumbai',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'),
    '2025-02-08', '2025-02-09',
    'MedCare Mumbai HQ — Simulation Lab, Floor 2', 15, 'COMPLETED'
),
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-IC-001'),
    'Infection Control Online — Q1 2025',
    NULL,
    '2025-01-06', '2025-01-31',
    'https://lms.medcareindia.com/courses/TRN-IC-001', NULL, 'COMPLETED'
),
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-EHR-001'),
    'EHR Onboarding — March 2025 New Joiners',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP007'),
    '2025-03-05', '2025-03-05',
    'MedCare Mumbai HQ — IT Training Room, Floor 3', 12, 'COMPLETED'
),
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-POSH-001'),
    'POSH Annual Module — All Staff — FY2024-25',
    NULL,
    '2025-02-01', '2025-02-28',
    'https://lms.medcareindia.com/courses/TRN-POSH-001', NULL, 'COMPLETED'
),
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-ICU-001'),
    'ICU Refresher — April 2025',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'),
    '2025-04-05', '2025-04-05',
    'MedCare Mumbai HQ — ICU Conference Room, Floor 4', 10, 'COMPLETED'
),
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-CHEMO-001'),
    'Chemo Drug Safety — Chennai Pharmacy — March 2025',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP029'),
    '2025-03-15', '2025-03-15',
    'MedCare Chennai Hospital — Pharmacy Training Room', 10, 'COMPLETED'
),
(
    (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'),
    'BLS Batch — May 2025 — Pan India (Upcoming)',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'),
    '2025-05-17', '2025-05-17',
    'MedCare Mumbai HQ — Simulation Lab, Floor 2', 20, 'UPCOMING'
);


PRINT 'Inserting hr.EmployeeTrainingRecord...';
INSERT INTO hr.EmployeeTrainingRecord (EmployeeId, TrainingProgramId, TrainingBatchId, EnrolledDate, CompletedDate, RecordStatus, Score, PassingScore, CertificateUrl, CertificateIssuedDate, Feedback) VALUES
-- BLS Jan 2025 — Mumbai
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch — January 2025 — Mumbai'), '2025-01-10', '2025-01-18', 'COMPLETED', 92.00, 75.00, 'https://storage.medcareindia.com/certs/EMP010/BLS-2025-01.pdf', '2025-01-20', 'Excellent hands-on session. Refreshed ventilator-related BLS interventions.'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch — January 2025 — Mumbai'), '2025-01-10', '2025-01-18', 'COMPLETED', 85.00, 75.00, 'https://storage.medcareindia.com/certs/EMP011/BLS-2025-01.pdf', '2025-01-20', 'Good refresher. CPR technique improved after practicals.'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch — January 2025 — Mumbai'), '2025-01-10', '2025-01-18', 'COMPLETED', 78.00, 75.00, 'https://storage.medcareindia.com/certs/EMP044/BLS-2025-01.pdf', '2025-01-20', NULL),
-- ACLS Feb 2025 — Mumbai
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-ACLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='ACLS Batch — February 2025 — Mumbai'), '2025-01-25', '2025-02-09', 'COMPLETED', 98.00, 80.00, 'https://storage.medcareindia.com/certs/EMP003/ACLS-2025-02.pdf', '2025-02-12', 'Excellent content alignment with current cardiac surgery protocols.'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-ACLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='ACLS Batch — February 2025 — Mumbai'), '2025-01-25', '2025-02-09', 'COMPLETED', 82.00, 80.00, 'https://storage.medcareindia.com/certs/EMP009/ACLS-2025-02.pdf', '2025-02-12', 'Good foundational training. Helped consolidate residency learnings.'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-ACLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='ACLS Batch — February 2025 — Mumbai'), '2025-01-25', '2025-02-09', 'COMPLETED', 94.00, 80.00, 'https://storage.medcareindia.com/certs/EMP042/ACLS-2025-02.pdf', '2025-02-12', NULL),
-- Infection Control Online Q1 2025
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-IC-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Infection Control Online — Q1 2025'), '2025-01-06', '2025-01-12', 'COMPLETED', 96.00, 70.00, 'https://storage.medcareindia.com/certs/EMP001/IC-2025-Q1.pdf', '2025-01-13', NULL),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-IC-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Infection Control Online — Q1 2025'), '2025-01-06', '2025-01-14', 'COMPLETED', 100.00, 70.00, 'https://storage.medcareindia.com/certs/EMP004/IC-2025-Q1.pdf', '2025-01-15', 'Excellent refresher. New COVID appendix section is well-structured.'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-IC-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Infection Control Online — Q1 2025'), '2025-01-06', '2025-01-20', 'COMPLETED', 88.00, 70.00, 'https://storage.medcareindia.com/certs/EMP043/IC-2025-Q1.pdf', '2025-01-21', NULL),
-- EHR Onboarding March 2025
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-EHR-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='EHR Onboarding — March 2025 New Joiners'), '2025-03-03', '2025-03-05', 'COMPLETED', 80.00, 70.00, 'https://storage.medcareindia.com/certs/EMP043/EHR-2025-03.pdf', '2025-03-07', 'Very practical session. Now confident with clinical notes module.'),
-- POSH FY2024-25
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-POSH-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='POSH Annual Module — All Staff — FY2024-25'), '2025-02-01', '2025-02-10', 'COMPLETED', 90.00, 70.00, 'https://storage.medcareindia.com/certs/EMP001/POSH-2024-25.pdf', '2025-02-15', NULL),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-POSH-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='POSH Annual Module — All Staff — FY2024-25'), '2025-02-01', '2025-02-08', 'COMPLETED', 95.00, 70.00, 'https://storage.medcareindia.com/certs/EMP005/POSH-2024-25.pdf', '2025-02-15', 'Comprehensive and clearly presented. Good case studies.'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-POSH-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='POSH Annual Module — All Staff — FY2024-25'), '2025-02-01', '2025-02-15', 'COMPLETED', 88.00, 70.00, 'https://storage.medcareindia.com/certs/EMP030/POSH-2024-25.pdf', '2025-02-15', NULL),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-POSH-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='POSH Annual Module — All Staff — FY2024-25'), '2025-02-01', NULL, 'IN_PROGRESS', NULL, 70.00, NULL, NULL, NULL),
-- ICU Refresher April 2025
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-ICU-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='ICU Refresher — April 2025'), '2025-03-28', '2025-04-05', 'COMPLETED', 94.00, 75.00, 'https://storage.medcareindia.com/certs/EMP010/ICU-2025-04.pdf', '2025-04-07', 'VAE prevention bundle section was very helpful for daily practice.'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-ICU-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='ICU Refresher — April 2025'), '2025-03-28', '2025-04-05', 'COMPLETED', 80.00, 75.00, 'https://storage.medcareindia.com/certs/EMP011/ICU-2025-04.pdf', '2025-04-07', NULL),
-- Chemo Drug Safety Chennai March 2025
((SELECT Id FROM Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-CHEMO-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Chemo Drug Safety — Chennai Pharmacy — March 2025'), '2025-03-10', '2025-03-15', 'COMPLETED', 91.00, 75.00, 'https://storage.medcareindia.com/certs/EMP029/CHEMO-2025-03.pdf', '2025-03-18', 'Excellent spill management practical. New cytotoxic waste disposal procedure is clearer now.'),
-- BLS Upcoming May 2025
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch — May 2025 — Pan India (Upcoming)'), '2025-05-01', NULL, 'ENROLLED', NULL, 75.00, NULL, NULL, NULL),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch — May 2025 — Pan India (Upcoming)'), '2025-05-02', NULL, 'ENROLLED', NULL, 75.00, NULL, NULL, NULL);


-- =============================================================================================================
-- MODULE G: EXIT MANAGEMENT
-- =============================================================================================================

PRINT 'Inserting hr.ExitReason...';
INSERT INTO hr.ExitReason (ReasonText, Category) VALUES
('Better Career Opportunity',           'VOLUNTARY'),
('Higher Compensation Elsewhere',       'VOLUNTARY'),
('Relocation — Personal Reasons',       'VOLUNTARY'),
('Family Obligations',                  'VOLUNTARY'),
('Health Reasons',                      'VOLUNTARY'),
('Higher Education / Research',         'VOLUNTARY'),
('Entrepreneurship',                    'VOLUNTARY'),
('Dissatisfaction with Work Environment','VOLUNTARY'),
('Lack of Growth Opportunities',        'VOLUNTARY'),
('Performance-Based Termination',       'INVOLUNTARY'),
('Misconduct / Disciplinary Action',    'INVOLUNTARY'),
('Redundancy / Role Elimination',       'INVOLUNTARY'),
('Contract Completion',                 'INVOLUNTARY'),
('Superannuation / Retirement',         'INVOLUNTARY'),
('Absconding Without Notice',           'INVOLUNTARY');


PRINT 'Inserting hr.ExitRecord (samples)...';
-- EMP015 Suresh Naidu — Front Desk — Resigned for better opportunity (Mumbai)
INSERT INTO hr.ExitRecord (EmployeeId, ExitReasonId, ExitType, AdditionalReason, ResignationDate, LastWorkingDate, NoticePeriodDays, IsNoticeWaived, ExitInterviewStatus, ExitInterviewDate, ConductedByEmployeeId, ExitFeedback, IsRehireEligible, ClearanceStatus, FinalSettlementStatus, FinalSettlementDate, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP015'),
    (SELECT Id FROM hr.ExitReason WHERE ReasonText='Better Career Opportunity'),
    'RESIGNATION', NULL,
    '2025-03-15', '2025-04-14', 30, 0,
    'COMPLETED', '2025-04-10',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    'Employee expressed satisfaction with MedCare but was attracted by a senior role with higher compensation. Recommended for rehire. Cited positive management and team culture.',
    1, 'COMPLETED', 'PAID', '2025-04-30',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
);

-- EMP013 Manoj Verma — Pharmacist Mumbai — Resigned for higher education
INSERT INTO hr.ExitRecord (EmployeeId, ExitReasonId, ExitType, AdditionalReason, ResignationDate, LastWorkingDate, NoticePeriodDays, IsNoticeWaived, ExitInterviewStatus, ExitInterviewDate, ConductedByEmployeeId, ExitFeedback, IsRehireEligible, ClearanceStatus, FinalSettlementStatus, CreatedByEmployeeId) VALUES
(
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP013'),
    (SELECT Id FROM hr.ExitReason WHERE ReasonText='Higher Education / Research'),
    'RESIGNATION', 'Pursuing M.Pharm from NIPER Hyderabad; full-time programme, cannot continue alongside work.',
    '2025-04-01', '2025-04-30', 30, 0,
    'SCHEDULED', '2025-04-25',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'),
    NULL, 1, 'IN_PROGRESS', 'PENDING',
    (SELECT Id FROM Employee WHERE EmployeeCode='EMP005')
);


PRINT 'Inserting hr.ExitClearanceItem...';
-- EMP015 — All clearances completed (exit fully processed)
INSERT INTO hr.ExitClearanceItem (ExitRecordId, ItemName, OwnerDepartment, ItemStatus, CompletedByEmployeeId, CompletedAt, Remarks) VALUES
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP015')), 'ID Card and Access Badge returned',        'HR',           'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2025-04-14 17:00:00', 'ID card collected on last working day'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP015')), 'Laptop and company assets returned',        'IT',           'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), '2025-04-14 16:00:00', 'Laptop in good condition; charger returned'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP015')), 'System and EHR access revoked',             'IT',           'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), '2025-04-14 18:00:00', 'All user accounts deactivated'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP015')), 'Finance clearance and dues settled',        'Finance',      'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), '2025-04-18 11:00:00', 'No outstanding advances; petty cash reconciled'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP015')), 'Uniform and workwear returned',             'Admin',        'COMPLETED', (SELECT Id FROM Employee WHERE EmployeeCode='EMP014'), '2025-04-14 17:30:00', '2 sets of uniform returned'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP015')), 'Knowledge transfer to replacement',         'Admin',        'WAIVED',    NULL,                                                  NULL,                  'Role is being held vacant; KT waived per manager approval');

-- EMP013 — Clearances in progress
INSERT INTO hr.ExitClearanceItem (ExitRecordId, ItemName, OwnerDepartment, ItemStatus, CompletedByEmployeeId, CompletedAt, Remarks) VALUES
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP013')), 'ID Card and Access Badge returned',        'HR',           'PENDING',   NULL, NULL, NULL),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP013')), 'System and EHR access revoked',             'IT',           'PENDING',   NULL, NULL, 'To be done on last working day'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP013')), 'Pharmacy drug register handover',           'Pharmacy',     'COMPLETED',(SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), NULL, 'Chief pharmacist conducting handover with EMP013 this week'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP013')), 'Finance clearance and dues settled',        'Finance',      'PENDING',   NULL, NULL, 'Full and final calculation pending payroll processing'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP013')), 'Uniform and workwear returned',             'Admin',        'PENDING',   NULL, NULL, NULL);


-- =============================================================================================================
-- VERIFICATION SUMMARY
-- =============================================================================================================

PRINT '';
PRINT '=============================================================================================================';
PRINT 'SEED DATA INSERTION COMPLETE — HR SCHEMA — MedCare India Pvt. Ltd.';
PRINT '=============================================================================================================';
PRINT '';

SELECT 'hr.InterviewType'               AS TableName, COUNT(*) AS RecordCount FROM hr.InterviewType              UNION ALL
SELECT 'hr.InterviewRound',                           COUNT(*)               FROM hr.InterviewRound              UNION ALL
SELECT 'hr.PanelRole',                                COUNT(*)               FROM hr.PanelRole                   UNION ALL
SELECT 'hr.InterviewPurpose',                         COUNT(*)               FROM hr.InterviewPurpose            UNION ALL
SELECT 'hr.JobPosting',                               COUNT(*)               FROM hr.JobPosting                  UNION ALL
SELECT 'hr.Candidate',                                COUNT(*)               FROM hr.Candidate                   UNION ALL
SELECT 'hr.Application',                              COUNT(*)               FROM hr.Application                 UNION ALL
SELECT 'hr.ApplicationStatusHistory',                 COUNT(*)               FROM hr.ApplicationStatusHistory    UNION ALL
SELECT 'hr.InterviewRoundConfig',                     COUNT(*)               FROM hr.InterviewRoundConfig        UNION ALL
SELECT 'hr.Interview',                                COUNT(*)               FROM hr.Interview                   UNION ALL
SELECT 'hr.InterviewPanel',                           COUNT(*)               FROM hr.InterviewPanel              UNION ALL
SELECT 'hr.InterviewFeedback',                        COUNT(*)               FROM hr.InterviewFeedback           UNION ALL
SELECT 'hr.PackageNegotiation',                       COUNT(*)               FROM hr.PackageNegotiation          UNION ALL
SELECT 'hr.OfferLetter',                              COUNT(*)               FROM hr.OfferLetter                 UNION ALL
SELECT 'hr.OnboardingChecklist',                      COUNT(*)               FROM hr.OnboardingChecklist         UNION ALL
SELECT 'hr.OnboardingChecklistItem',                  COUNT(*)               FROM hr.OnboardingChecklistItem     UNION ALL
SELECT 'hr.OnboardingTask',                           COUNT(*)               FROM hr.OnboardingTask              UNION ALL
SELECT 'hr.DocumentVerification',                     COUNT(*)               FROM hr.DocumentVerification        UNION ALL
SELECT 'hr.BGVAgency',                                COUNT(*)               FROM hr.BGVAgency                   UNION ALL
SELECT 'hr.BackgroundVerification',                   COUNT(*)               FROM hr.BackgroundVerification      UNION ALL
SELECT 'hr.PolicyCategory',                           COUNT(*)               FROM hr.PolicyCategory              UNION ALL
SELECT 'hr.PolicyDocument',                           COUNT(*)               FROM hr.PolicyDocument              UNION ALL
SELECT 'hr.PolicyVersion',                            COUNT(*)               FROM hr.PolicyVersion               UNION ALL
SELECT 'hr.PolicyAcknowledgement',                    COUNT(*)               FROM hr.PolicyAcknowledgement       UNION ALL
SELECT 'hr.SalarySlipPublication',                    COUNT(*)               FROM hr.SalarySlipPublication       UNION ALL
SELECT 'hr.PerformanceCycle',                         COUNT(*)               FROM hr.PerformanceCycle            UNION ALL
SELECT 'hr.Goal',                                     COUNT(*)               FROM hr.Goal                        UNION ALL
SELECT 'hr.GoalKeyResult',                            COUNT(*)               FROM hr.GoalKeyResult               UNION ALL
SELECT 'hr.PerformanceReview',                        COUNT(*)               FROM hr.PerformanceReview           UNION ALL
SELECT 'hr.PerformanceReviewHistory',                 COUNT(*)               FROM hr.PerformanceReviewHistory    UNION ALL
SELECT 'hr.TrainingCategory',                         COUNT(*)               FROM hr.TrainingCategory            UNION ALL
SELECT 'hr.TrainingProgram',                          COUNT(*)               FROM hr.TrainingProgram             UNION ALL
SELECT 'hr.TrainingBatch',                            COUNT(*)               FROM hr.TrainingBatch               UNION ALL
SELECT 'hr.EmployeeTrainingRecord',                   COUNT(*)               FROM hr.EmployeeTrainingRecord      UNION ALL
SELECT 'hr.ExitReason',                               COUNT(*)               FROM hr.ExitReason                  UNION ALL
SELECT 'hr.ExitRecord',                               COUNT(*)               FROM hr.ExitRecord                  UNION ALL
SELECT 'hr.ExitClearanceItem',                        COUNT(*)               FROM hr.ExitClearanceItem;

COMMIT TRANSACTION;
PRINT 'Transaction committed successfully.';

-- =============================================================================================================
-- END OF SEED DATA SCRIPT — hr schema — MedCare India Pvt. Ltd.
-- =============================================================================================================