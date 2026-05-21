-- HR SCHEMA - Seed Data (Part 1: Recruitment)
-- Organization: MedCare India Pvt. Ltd. (India)
-- Dependencies: shared, time, employee
-- Note: Status codes are already seeded in shared/01-shared.sql

-- MODULE: RECRUITMENT & SELECTION

PRINT 'Inserting hr.InterviewRound...';
INSERT INTO hr.InterviewRound (RoundNumber, RoundCode, RoundName, Description, InterviewType, IsMandatory, DisplayOrder) VALUES
(1, 'HR_SCREEN',    'HR Screening',             'Initial HR fitment and culture check',                             'PHONE_SCREEN',      1, 1),
(2, 'TECH_1',       'Technical Round 1',        'Core technical or clinical knowledge assessment',                  'VIDEO_CALL',      1, 2),
(3, 'TECH_2',       'Technical Round 2',        'Advanced technical depth or case-based assessment',                'VIDEO_CALL',      0, 3),
(4, 'DOMAIN_EXPERT','Domain Expert Review',     'Specialist domain evaluation by senior clinician or lead',         'IN_PERSON', 0, 4),
(5, 'MANAGER',      'Hiring Manager Round',     'Evaluation by direct reporting manager',                           'IN_PERSON', 1, 5),
(6, 'PANEL',        'Panel Interview',          'Cross-functional panel assessment for senior roles',               'PANEL',     0, 6),
(7, 'FINAL_HR',     'Final HR & Offer',         'Compensation discussion and offer formulation',                    'IN_PERSON', 1, 7);


PRINT 'Inserting hr.PanelRole...';
INSERT INTO hr.PanelRole (RoleCode, RoleName, Description, CanSubmitFeedback, DisplayOrder) VALUES
('PANEL_LEAD',      'Panel Lead',           'Leads the panel and consolidates feedback',         1, 1),
('INTERVIEWER',     'Interviewer',          'Core interviewer responsible for primary questions', 1, 2),
('TECH_EXPERT',     'Technical Expert',     'Assesses technical or clinical depth',              1, 3),
('DOMAIN_EXPERT',   'Domain Expert',        'Evaluates domain-specific knowledge',               1, 4),
('HR_COORD',        'HR Coordinator',       'Facilitates process and covers HR fitment',         1, 5),
('OBSERVER',        'Observer',             'Shadows the interview for calibration or training',  0, 6),
('NOTE_TAKER',      'Note Taker',           'Records interview proceedings',                     0, 7);


PRINT 'Inserting hr.JobPosting...';
INSERT INTO hr.JobPosting (Title, DepartmentId, DesignationId, LocationId, LegalEntityId, EmploymentType, ExperienceMinYrs, ExperienceMaxYrs, SalaryMin, SalaryMax, 
                            CurrencyCode, Description, Requirements, OpeningsCount, JobPostingStatus, CreatedBy, CreatedAt, ClosingDate) VALUES
(
    'Senior Staff Nurse - ICU',
    (SELECT Id FROM time.Department WHERE DepartmentCode='ICU'),
    (SELECT Id FROM time.Designation WHERE DesignationCode='SRNURSE'),
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    'FULL_TIME', 5.0, 10.0, 700000.00, 1000000.00, 'INR',
    'We are seeking an experienced Senior Staff Nurse for our ICU unit at Mumbai HQ. The candidate will be responsible for critical care patient management, ventilator support, and team supervision.',
    'B.Sc. Nursing or GNM; minimum 5 years ICU experience; BLS/ACLS certified; strong ventilator management skills.',
    2, 'OPEN',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    '2025-02-01', '2025-04-30'
),
(
    'Resident Doctor - Cardiology',
    (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),
    (SELECT Id FROM time.Designation WHERE DesignationCode='RESIDENTDR'),
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'),
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    'FULL_TIME', 1.0, 3.0, 600000.00, 900000.00, 'INR',
    'Resident Doctor position in Cardiology department at MedCare Pune. Opportunity to work under senior cardiologist Dr. Namrata Deshpande.',
    'MBBS from MCI-recognised institution; completed internship; USMLE/PG entrance cleared preferred; cardiology interest essential.',
    1, 'OPEN',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    '2025-02-15', '2025-05-15'
),
(
    'HR Executive - South India Operations',
    (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),
    (SELECT Id FROM time.Designation WHERE DesignationCode='HREXEC'),
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'),
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    'FULL_TIME', 2.0, 5.0, 400000.00, 600000.00, 'INR',
    'HR Executive to support Bengaluru hospital HR operations including recruitment, onboarding, and employee lifecycle management.',
    'MBA-HR or equivalent; 2–5 years HRIS experience; knowledge of labour laws; proficiency in HRMS software.',
    1, 'CLOSED',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
    '2024-09-01', '2024-12-31'
),
(
    'Pharmacist - Oncology Drug Management',
    (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),
    (SELECT Id FROM time.Designation WHERE DesignationCode='PHARMACIST'),
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'),
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    'FULL_TIME', 3.0, 8.0, 500000.00, 750000.00, 'INR',
    'Pharmacist specialising in chemotherapy drug preparation, handling, and patient counseling at Hyderabad hospital.',
    'B.Pharm / M.Pharm; registered with State Pharmacy Council; oncology or chemo drug handling experience preferred.',
    1, 'OPEN',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
    '2025-03-01', '2025-06-30'
),
(
    'Systems Administrator - EHR & Network',
    (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),
    (SELECT Id FROM time.Designation WHERE DesignationCode='SYSADMIN'),
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'),
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    'FULL_TIME', 3.0, 7.0, 500000.00, 800000.00, 'INR',
    'Systems Administrator to manage EHR platform, hospital network, and server infrastructure at Delhi hospital.',
    'B.Tech / BCA or equivalent; experience with hospital EHR systems (preferably Cerner/Epic); network admin skills; MCSA/CCNA preferred.',
    1, 'OPEN',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
    '2025-01-15', '2025-04-30'
);

PRINT 'Inserting hr.Candidate...';
INSERT INTO hr.Candidate (FirstName, MiddleName, LastName, Email, Phone, DateOfBirth, Gender, CurrentCompany, CurrentTitle, TotalExpYrs, NoticePeriodDays, CurrentSalary, CurrencyCode, LinkedInUrl, ResumeUrl, Source, ReferredByEmployeeId) VALUES
('Poornima',    NULL,       'Hegde',        'poornima.hegde@gmail.com',         '9845100201', '1992-05-14', 'Female',   'Manipal Hospitals',        'Senior Nurse ICU',         7.0,  30,  720000.00,  'INR', 'https://linkedin.com/in/poornimahegde',     'https://storage.medcareindia.com/resumes/poornima_hegde.pdf',     'LinkedIn',  NULL),
('Siddharth',   NULL,       'Joshi',        'siddharth.joshi@gmail.com',        '9920100202', '1997-11-03', 'Male',     'Kokilaben Hospital',       'Junior Resident',          2.0,  15,  550000.00,  'INR', 'https://linkedin.com/in/siddharthjoshi',    'https://storage.medcareindia.com/resumes/siddharth_joshi.pdf',    'JobPortal', NULL),
('Nandita',     'Rao',      'Krishnamurthy','nandita.krishnamurthy@gmail.com',  '9886100203', '1995-07-22', 'Female',   'Apollo Hospitals',         'HR Executive',             4.0,  30,  480000.00,  'INR', NULL,                                        'https://storage.medcareindia.com/resumes/nandita_krishnamurthy.pdf','Referral',  (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021')),
('Abhijit',     NULL,       'Pawar',        'abhijit.pawar@gmail.com',          '9823100204', '1991-03-08', 'Male',     'Cipla Ltd.',               'Clinical Pharmacist',      6.5,  60,  620000.00,  'INR', 'https://linkedin.com/in/abhijitpawar',      'https://storage.medcareindia.com/resumes/abhijit_pawar.pdf',      'LinkedIn',  NULL),
('Rashida',     NULL,       'Shaikh',       'rashida.shaikh@gmail.com',         '9849100205', '1993-09-17', 'Female',   'Max Healthcare',           'Systems Administrator',    5.0,  45,  560000.00,  'INR', 'https://linkedin.com/in/rashidashaikh',     'https://storage.medcareindia.com/resumes/rashida_shaikh.pdf',     'JobPortal', NULL),
('Kiran',       NULL,       'Bhat',         'kiran.bhat@gmail.com',             '9845100206', '1990-12-25', 'Male',     'Fortis Healthcare',        'Senior Staff Nurse ICU',   9.0,  30,  850000.00,  'INR', 'https://linkedin.com/in/kiranbhat',         'https://storage.medcareindia.com/resumes/kiran_bhat.pdf',         'LinkedIn',  NULL),
('Trisha',      NULL,       'Nambiar',      'trisha.nambiar@gmail.com',         '9446100207', '1994-04-11', 'Female',   NULL,                       NULL,                       1.5,  0,   NULL,       'INR', NULL,                                        'https://storage.medcareindia.com/resumes/trisha_nambiar.pdf',     'CampusDrive',NULL);

PRINT 'Inserting hr.Application...';
INSERT INTO hr.Application (JobPostingId, CandidateId, ApplicationStatus, ReviewedByEmployeeId, AppliedAt, StatusUpdatedAt) VALUES
-- Poornima Hegde - Senior Staff Nurse ICU (Mumbai) - Hired
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU'),
    (SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com'),
    'HIRED',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    '2025-02-05 10:00:00', '2025-03-20 14:00:00'
),
-- Kiran Bhat - Senior Staff Nurse ICU (Mumbai) - Interview stage
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU'),
    (SELECT Id FROM hr.Candidate WHERE Email='kiran.bhat@gmail.com'),
    'INTERVIEW',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    '2025-02-18 09:30:00', '2025-03-10 11:00:00'
),
-- Siddharth Joshi - Resident Doctor Cardiology (Pune) - Offer stage
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor - Cardiology'),
    (SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com'),
    'OFFER',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    '2025-02-20 14:00:00', '2025-03-25 10:00:00'
),
-- Nandita Krishnamurthy - HR Executive Bengaluru - Hired (closed posting)
(
    (SELECT Id FROM hr.JobPosting WHERE Title='HR Executive - South India Operations'),
    (SELECT Id FROM hr.Candidate WHERE Email='nandita.krishnamurthy@gmail.com'),
    'HIRED',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
    '2024-09-10 09:00:00', '2024-11-15 16:00:00'
),
-- Abhijit Pawar - Pharmacist Hyderabad - Screening
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Pharmacist - Oncology Drug Management'),
    (SELECT Id FROM hr.Candidate WHERE Email='abhijit.pawar@gmail.com'),
    'SCREENING',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
    '2025-03-05 11:00:00', '2025-03-08 09:00:00'
),
-- Rashida Shaikh - Systems Administrator Delhi - Interview
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator - EHR & Network'),
    (SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com'),
    'INTERVIEW',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
    '2025-01-20 15:00:00', '2025-02-12 10:00:00'
),
-- Trisha Nambiar - Resident Doctor Cardiology - Rejected
(
    (SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor - Cardiology'),
    (SELECT Id FROM hr.Candidate WHERE Email='trisha.nambiar@gmail.com'),
    'REJECTED',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    '2025-03-01 10:00:00', '2025-03-12 14:00:00'
);

PRINT 'Inserting hr.ApplicationStatusHistory...';
-- Poornima Hegde pipeline
INSERT INTO hr.ApplicationStatusHistory (ApplicationId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')), NULL,         'APPLIED',     (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Application received via LinkedIn',            '2025-02-05 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')), 'APPLIED',    'SCREENING',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Shortlisted for telephonic screening',         '2025-02-08 09:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')), 'SCREENING',  'INTERVIEW',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Cleared screening; technical round scheduled', '2025-02-15 11:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')), 'INTERVIEW',  'OFFER',       (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Cleared all rounds; offer approved',           '2025-03-10 14:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')), 'OFFER',      'NEGOTIATION', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Candidate negotiating CTC',                    '2025-03-12 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')), 'NEGOTIATION','HIRED',       (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Offer accepted; joining date confirmed',       '2025-03-20 14:00:00');

-- Siddharth Joshi pipeline
INSERT INTO hr.ApplicationStatusHistory (ApplicationId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), NULL,        'APPLIED',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Application received via job portal', '2025-02-20 14:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), 'APPLIED',   'SCREENING', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Shortlisted; HR screen call done',    '2025-02-25 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), 'SCREENING', 'INTERVIEW', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Cleared screening; technical round',  '2025-03-05 11:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')), 'INTERVIEW', 'OFFER',     (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Cleared technical; offer in progress','2025-03-25 10:00:00');

-- Trisha Nambiar pipeline
INSERT INTO hr.ApplicationStatusHistory (ApplicationId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='trisha.nambiar@gmail.com')), NULL,      'APPLIED',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Application received',                            '2025-03-01 10:00:00'),
((SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='trisha.nambiar@gmail.com')), 'APPLIED', 'REJECTED',  (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Insufficient clinical experience for the role',   '2025-03-12 14:00:00');

PRINT 'Inserting hr.InterviewRoundConfig...';
-- Senior Staff Nurse ICU - 4 rounds
INSERT INTO hr.InterviewRoundConfig (JobPostingId, InterviewRoundId, InterviewType, DurationMins, IsMandatory) VALUES
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN'),    'PHONE_SCREEN',      30,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1'),       'VIDEO_CALL',      60,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='MANAGER'),      'IN_PERSON',  45,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='FINAL_HR'),     'IN_PERSON',  30,  1);

-- Resident Doctor Cardiology - 3 rounds
INSERT INTO hr.InterviewRoundConfig (JobPostingId, InterviewRoundId, InterviewType, DurationMins, IsMandatory) VALUES
((SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor - Cardiology'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN'),    'PHONE_SCREEN',      30,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor - Cardiology'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1'),       'VIDEO_CALL',      60,  1),
((SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor - Cardiology'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='DOMAIN_EXPERT'),'IN_PERSON',  60,  1);

-- Systems Administrator Delhi - 3 rounds
INSERT INTO hr.InterviewRoundConfig (JobPostingId, InterviewRoundId, InterviewType, DurationMins, IsMandatory) VALUES
((SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator - EHR & Network'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN'), 'PHONE_SCREEN',  30, 1),
((SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator - EHR & Network'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1'),    'VIDEO_CALL',  90, 1),
((SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator - EHR & Network'), (SELECT Id FROM hr.InterviewRound WHERE RoundCode='MANAGER'),   'IN_PERSON', 45, 1);


PRINT 'Inserting hr.Interview...';
-- Poornima Hegde - HR Screen (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, InterviewStatus, CreatedBy) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN')),
    '2025-02-10 11:00:00', 30, 'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
);
-- Poornima Hegde - Technical Round 1 (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedBy) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1')),
    '2025-02-18 14:00:00', 60, 'https://teams.microsoft.com/meet/medcare/poornima-tech1', 'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004')
);
-- Poornima Hegde - Manager Round (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedBy) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='MANAGER')),
    '2025-03-03 10:00:00', 45, 'MedCare Mumbai HQ - HR Conference Room B', 'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
);
-- Siddharth Joshi - HR Screen (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, InterviewStatus, CreatedBy) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor - Cardiology') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN')),
    '2025-02-27 10:30:00', 30, 'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
);
-- Siddharth Joshi - Technical Round 1 (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedBy) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Resident Doctor - Cardiology') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1')),
    '2025-03-08 11:00:00', 60, 'https://teams.microsoft.com/meet/medcare/siddharth-tech1', 'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042')
);
-- Rashida Shaikh - HR Screen (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, InterviewStatus, CreatedBy) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator - EHR & Network') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='HR_SCREEN')),
    '2025-01-24 15:00:00', 30, 'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019')
);
-- Rashida Shaikh - Technical Round 1 (completed)
INSERT INTO hr.Interview (ApplicationId, InterviewRoundConfigId, ScheduledAt, DurationMins, Venue, InterviewStatus, CreatedBy) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')),
    (SELECT Id FROM hr.InterviewRoundConfig WHERE JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Systems Administrator - EHR & Network') AND InterviewRoundId=(SELECT Id FROM hr.InterviewRound WHERE RoundCode='TECH_1')),
    '2025-02-05 14:00:00', 90, 'https://teams.microsoft.com/meet/medcare/rashida-tech1', 'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007')
);

PRINT 'Inserting hr.InterviewPanel...';
-- Poornima - Tech Round 1 panel
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurpose, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='PANEL_LEAD'),
    'CLINICAL_KNOWLEDGE',
    'ICU protocols, ventilator management, BLS/ACLS, critical care nursing', 1, 1, '2025-02-17 09:00:00'
);
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurpose, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='INTERVIEWER'),
    'PROBLEM_SOLVING',
    'Scenario-based ICU patient deterioration responses', 0, 1, '2025-02-17 09:00:00'
);

-- Siddharth - Tech Round 1 panel
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurpose, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='PANEL_LEAD'),
    'CLINICAL_KNOWLEDGE',
    'Cardiology basics, ECG interpretation, pharmacology, MBBS knowledge', 1, 1, '2025-03-07 10:00:00'
);
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurpose, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='INTERVIEWER'),
    'CULTURE_FIT',
    'Team fit, attitude, peer learning approach in residency', 0, 1, '2025-03-07 10:00:00'
);

-- Rashida - Tech Round 1 panel
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurpose, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='PANEL_LEAD'),
    'TECHNICAL_DEPTH',
    'EHR administration, Windows Server, network troubleshooting, SQL basics', 1, 1, '2025-02-04 11:00:00'
);
INSERT INTO hr.InterviewPanel (InterviewId, InterviewerEmployeeId, PanelRoleId, InterviewPurpose, EvaluationTopics, IsLead, CanSubmitFeedback, ConfirmedAt) VALUES
(
    (SELECT TOP 1 Id FROM hr.Interview WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='rashida.shaikh@gmail.com')) ORDER BY ScheduledAt DESC),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
    (SELECT Id FROM hr.PanelRole WHERE RoleCode='TECH_EXPERT'),
    'PROBLEM_SOLVING',
    'Real-world network failure scenarios and EHR downtime handling', 0, 1, '2025-02-04 11:00:00'
);

PRINT 'Inserting hr.InterviewFeedback...';
-- Poornima - CNO (EMP004) feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004') AND InterviewPurpose ='CLINICAL_KNOWLEDGE'),
    8.5, 9.0, 8.0, 8.5, 9.0,
    'Excellent ICU and ventilator management knowledge. Strong BLS/ACLS credentials. Calm under pressure.',
    'Leadership experience with junior nurses could be stronger; recommend monitoring in first 3 months.',
    'YES',
    'Strong candidate for Senior ICU Nurse role. Recommend proceeding to manager round.',
    '2025-02-19 16:00:00'
);
-- Poornima - EMP010 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010') AND InterviewPurpose = 'PROBLEM_SOLVING'),
    8.0, 8.0, 8.5, 8.0, 7.5,
    'Good scenario handling; structured thinking in patient deterioration cases.',
    'Slightly slow in one high-acuity scenario; needs to sharpen rapid response reflex.',
    'YES',
    'Overall positive. Agrees with lead panelist assessment.',
    '2025-02-19 17:00:00'
);
-- Siddharth - EMP042 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042') AND InterviewPurpose = 'CLINICAL_KNOWLEDGE'),
    7.5, 7.5, 8.0, 8.0, 7.5,
    'Good MBBS foundation; genuine interest in cardiology; enthusiastic and coachable.',
    'Limited hands-on exposure; ECG interpretation needs improvement; standard for a junior resident.',
    'YES',
    'Suitable for residency with mentoring. Recommend domain expert round.',
    '2025-03-09 15:00:00'
);
-- Rashida - EMP007 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007') AND InterviewPurpose = 'TECHNICAL_DEPTH'),
    7.0, 7.5, 7.0, 7.0, 7.5,
    'Solid Windows Server and networking skills. Familiar with hospital EHR concepts.',
    'No direct Cerner or Epic experience; would need ramp-up time; basic SQL knowledge only.',
    'MAYBE',
    'Technically adequate but not a standout. Awaiting tech expert score before deciding.',
    '2025-02-06 16:00:00'
);
-- Rashida - EMP025 feedback
INSERT INTO hr.InterviewFeedback (InterviewPanelId, OverallRating, TechnicalScore, CommunicationScore, CulturalFitScore, PurposeSpecificScore, Strengths, Concerns, RecommendationStatus, AdditionalNotes, SubmittedAt) VALUES
(
    (SELECT Id FROM hr.InterviewPanel WHERE InterviewerEmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025') AND InterviewPurpose = 'PROBLEM_SOLVING'),
    7.5, 7.0, 7.5, 7.5, 7.0,
    'Structured troubleshooting approach; handled the network failure scenario well.',
    'Hesitant on EHR downtime SOP; would benefit from healthcare IT exposure.',
    'YES',
    'Recommend proceeding. Can be trained on hospital-specific EHR.',
    '2025-02-06 17:30:00'
);

PRINT 'Inserting hr.PackageNegotiation...';
-- Poornima Hegde - Round 1 (countered) - Round 2 (accepted)
INSERT INTO hr.PackageNegotiation (ApplicationId, HREmployeeId, RoundNumber, OfferedCTC, CandidateAsk, FinalCTC, CurrencyCode, VariablePct, JoiningBonus, OtherBenefits, NegotiationStatus, Notes, NegotiatedAt) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    1, 850000.00, 950000.00, NULL, 'INR', 10.00, NULL,
    'Shift allowance, uniform allowance, group health insurance',
    'COUNTERED', 'Candidate requested higher base citing 7 years ICU experience.', '2025-03-12 10:00:00'
),
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    2, 920000.00, 920000.00, 920000.00, 'INR', 10.00, 30000.00,
    'Shift allowance, uniform allowance, group health insurance, 30K joining bonus',
    'ACCEPTED', 'Candidate accepted revised offer with joining bonus.', '2025-03-18 14:00:00'
);
-- Siddharth Joshi - Round 1 offer (in progress)
INSERT INTO hr.PackageNegotiation (ApplicationId, HREmployeeId, RoundNumber, OfferedCTC, CandidateAsk, FinalCTC, CurrencyCode, VariablePct, JoiningBonus, OtherBenefits, NegotiationStatus, Notes, NegotiatedAt) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='siddharth.joshi@gmail.com')),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    1, 650000.00, 700000.00, NULL, 'INR', 5.00, NULL,
    'Accommodation allowance, continuing medical education allowance',
    'IN_PROGRESS', 'Standard resident package offered; candidate reviewing.', '2025-03-25 11:00:00'
);


PRINT 'Inserting hr.OfferLetter...';
INSERT INTO hr.OfferLetter (ApplicationId, PackageNegotiationId, LetterFileUrl, IssuedDate, ExpiryDate, OfferedPosition, ProposedJoiningDate, OfferStatus, AcceptedAt, IssuedByEmployeeId) VALUES
(
    (SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')),
    (SELECT TOP 1 Id FROM hr.PackageNegotiation WHERE ApplicationId=(SELECT Id FROM hr.Application WHERE CandidateId=(SELECT Id FROM hr.Candidate WHERE Email='poornima.hegde@gmail.com') AND JobPostingId=(SELECT Id FROM hr.JobPosting WHERE Title='Senior Staff Nurse - ICU')) ORDER BY RoundNumber DESC),
    'https://storage.medcareindia.com/offers/OL-2025-001-poornima-hegde.pdf',
    '2025-03-19', '2025-04-02', 'Senior Staff Nurse - ICU', '2025-04-10',
    'ACCEPTED', '2025-03-20 14:00:00',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
);


-- MODULE B: ONBOARDING

PRINT 'Inserting hr.OnboardingChecklist...';
INSERT INTO hr.OnboardingChecklist (ChecklistName, Phase, EmploymentType) VALUES
('Full-Time Clinical Staff - Pre-Onboarding',       'PRE_ONBOARDING',   'FULL_TIME'),
('Full-Time Clinical Staff - Day One',              'DAY_ONE',          'FULL_TIME'),
('Full-Time Clinical Staff - First Week',           'FIRST_WEEK',       'FULL_TIME'),
('Full-Time Clinical Staff - Post-Onboarding',      'POST_ONBOARDING',  'FULL_TIME'),
('Full-Time Admin / Support Staff - Pre-Onboarding','PRE_ONBOARDING',   'FULL_TIME'),
('Full-Time Admin / Support Staff - Day One',       'DAY_ONE',          'FULL_TIME'),
('Junior Resident / Intern - Pre-Onboarding',       'PRE_ONBOARDING',   'FULL_TIME');


PRINT 'Inserting hr.OnboardingChecklistItem...';
-- Clinical Pre-Onboarding
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, DisplayOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'Collect signed offer letter',          'Obtain candidate-signed copy of the offer letter',                                     'HR',       1,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'Verify Medical License / MCI Reg.',    'Validate MCI or State Medical Council registration number',                            'HR',       2,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'Collect Aadhaar and PAN copies',       'Collect self-attested copies of government IDs',                                       'HR',       3,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'Collect educational certificates',     'Degree, diploma, and internship completion certificates',                              'HR',       4,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'Collect experience/relieving letter',  'Previous employer relieving letter or experience certificate',                         'HR',       5,  0),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'Collect bank account details',         'Cancelled cheque or bank passbook copy for salary credit',                             'HR',       6,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'Initiate BGV - Identity & Education',  'Raise background verification request with agency for identity and education checks',  'HR',       7,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding'), 'COVID-19 vaccination certificate',     'Collect proof of full COVID-19 vaccination',                                           'HR',       8,  1);

-- Clinical Day One
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, DisplayOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Day One'), 'Issue employee ID card',               'Generate and issue photo ID badge with department and floor access',   'HR',       1,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Day One'), 'Create EHR system login',             'Provision EHR (hospital system) credentials with correct role',         'IT',       2,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Day One'), 'Register biometric at device',        'Enrol fingerprint on floor biometric device',                           'IT',       3,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Day One'), 'HR induction session',                'Attend mandatory HR induction covering policies and benefits',          'HR',       4,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Day One'), 'Introduction to reporting manager',   'Formal introduction and department orientation by reporting manager',   'Manager',  5,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Day One'), 'Collect uniform and equipment',       'Issue hospital scrubs, stethoscope (where applicable), and locker',    'Admin',    6,  1);

-- Clinical First Week
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, DisplayOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - First Week'), 'Complete infection control training',      'Mandatory online module on hospital infection prevention and PPE',              'HR',       1,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - First Week'), 'Complete BLS refresher (if lapsed)',        'Basic Life Support recertification if certificate is older than 2 years',        'Training', 2,  0),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - First Week'), 'Shadow senior for department orientation',  'Spend first 2 days shadowing assigned senior staff',                           'Manager',  3,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - First Week'), 'Review patient safety and escalation SOPs', 'Read and acknowledge department-specific SOPs',                                 'Manager',  4,  1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - First Week'), 'Complete HRMS self-service setup',          'Employee to update profile, upload photo, and review leave balance in HRMS',    'Employee', 5,  1);

-- Admin / Support Pre-Onboarding
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, DisplayOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Pre-Onboarding'), 'Collect signed offer letter',      'Obtain candidate-signed copy of the offer letter',                     'HR',  1, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Pre-Onboarding'), 'Collect Aadhaar and PAN copies',   'Collect self-attested government ID copies',                           'HR',  2, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Pre-Onboarding'), 'Collect educational certificates',  'Degree and diploma certificates relevant to the role',                 'HR',  3, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Pre-Onboarding'), 'Collect bank account details',     'Cancelled cheque for salary credit setup',                             'HR',  4, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Pre-Onboarding'), 'Initiate BGV - Employment History','Raise BGV request for employment history and identity verification',  'HR',  5, 1);

-- Admin Day One
INSERT INTO hr.OnboardingChecklistItem (OnboardingChecklistId, TaskName, Description, OwnerRole, DisplayOrder, IsMandatory) VALUES
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One'), 'Issue employee ID card',           'Generate and issue photo ID with office access',                   'HR',       1, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One'), 'Create system/application login',  'Provision email, HRMS, and relevant application access',           'IT',       2, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One'), 'Register biometric at device',    'Enrol fingerprint on main entrance biometric device',              'IT',       3, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One'), 'HR induction session',            'Attend HR induction covering code of conduct and IT policies',     'HR',       4, 1),
((SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One'), 'Workstation and asset allocation', 'Allocate laptop/desktop, headset, and stationery',                'IT',       5, 1);


PRINT 'Inserting hr.OnboardingTask (for new joiners EMP030 and hired candidate Poornima)...';
-- EMP030 (Sangeetha Arumugam - HR Executive Chennai, joined 2023-03-01) - Post-Onboarding tasks
INSERT INTO hr.OnboardingTask (EmployeeId, OnboardingChecklistItemId, TaskName, Phase, OwnerRole, TaskStatus, DueDate, CompletedDate, CompletedByEmployeeId, Remarks) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Collect signed offer letter'          AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Pre-Onboarding')), 'Collect signed offer letter',      'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-02-25', '2023-02-24', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'Signed offer letter received via email and original collected on Day 1'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Collect Aadhaar and PAN copies'       AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Pre-Onboarding')), 'Collect Aadhaar and PAN copies',   'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-02-25', '2023-03-01', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'Copies collected on joining day'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Issue employee ID card'               AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One')),         'Issue employee ID card',           'DAY_ONE',        'HR',      'COMPLETED', '2023-03-01', '2023-03-01', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'ID card issued on Day 1'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Create system/application login'      AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One')),         'Create system/application login',  'DAY_ONE',        'IT',      'COMPLETED', '2023-03-01', '2023-03-02', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), 'Email and HRMS access provisioned by IT'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='HR induction session'                  AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Admin / Support Staff - Day One')),         'HR induction session',             'DAY_ONE',        'HR',      'COMPLETED', '2023-03-01', '2023-03-01', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'Attended group induction with 2 other joiners');

-- EMP043 (Rohit Patil - Junior Resident, Pune, joined 2023-08-01) - Pending tasks
INSERT INTO hr.OnboardingTask (EmployeeId, OnboardingChecklistItemId, TaskName, Phase, OwnerRole, TaskStatus, DueDate, CompletedDate, CompletedByEmployeeId, Remarks) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Collect signed offer letter'         AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding')), 'Collect signed offer letter',           'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-07-28', '2023-07-27', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Signed offer received'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Verify Medical License / MCI Reg.'   AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Pre-Onboarding')), 'Verify Medical License / MCI Reg.',     'PRE_ONBOARDING', 'HR',      'COMPLETED', '2023-07-28', '2023-07-30', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'MCI registration verified online'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Issue employee ID card'              AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - Day One')),         'Issue employee ID card',                'DAY_ONE',        'HR',      'COMPLETED', '2023-08-01', '2023-08-01', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'ID card with clinical floor access issued'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Complete infection control training' AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - First Week')),      'Complete infection control training',   'FIRST_WEEK',     'Training','COMPLETED', '2023-08-07', '2023-08-05', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), 'Completed online module with score 88%'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM hr.OnboardingChecklistItem WHERE TaskName='Complete BLS refresher (if lapsed)'  AND OnboardingChecklistId=(SELECT Id FROM hr.OnboardingChecklist WHERE ChecklistName='Full-Time Clinical Staff - First Week')),      'Complete BLS refresher (if lapsed)',    'FIRST_WEEK',     'Training','WAIVED',    '2023-08-07', NULL,         NULL,                                                  'BLS certificate within validity period; waived');


PRINT 'Inserting hr.DocumentVerification...';
INSERT INTO hr.DocumentVerification (EmployeeId, DocumentTypeId, OnboardingPhase, FileUrl, DocumentNumber, IssuedBy, IssueDate, ExpiryDate, DocVerifyStatus, SubmittedDate, VerifiedDate, VerifiedByEmployeeId, Remarks) VALUES
-- EMP030 Sangeetha - Admin documents
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='AADHAAR'),    'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP030/aadhaar.pdf',          '4567 8901 2345', 'UIDAI',                '2018-06-01', NULL,         'VERIFIED',     '2023-03-01', '2023-03-03', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'Aadhaar verified against UIDAI portal'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='PAN'),        'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP030/pan.pdf',              'BNZSA1234F',     'Income Tax Dept.',     '2016-03-15', NULL,         'VERIFIED',     '2023-03-01', '2023-03-03', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'PAN verified'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='EDUCATIONCERT'),'PRE_ONBOARDING','https://storage.medcareindia.com/docs/EMP030/mba_cert.pdf',        'MDU-MBA-2018-4521','Madurai Kamaraj Univ.','2018-05-01', NULL,         'VERIFIED',     '2023-03-01', '2023-03-05', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'MBA-HR certificate verified'),
-- EMP043 Rohit - Resident documents
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='MEDLICENSE'),  'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP043/mci_reg.pdf',         'MH-MCI-2022-8834','Maharashtra MCI',      '2022-07-01', '2027-06-30', 'VERIFIED',     '2023-07-30', '2023-08-02', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'MCI registration active and verified'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='AADHAAR'),    'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP043/aadhaar.pdf',          '9012 3456 7890', 'UIDAI',                '2019-01-10', NULL,         'VERIFIED',     '2023-07-30', '2023-08-02', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Aadhaar verified'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='EDUCATIONCERT'),'PRE_ONBOARDING','https://storage.medcareindia.com/docs/EMP043/mbbs_cert.pdf',       'MUHS-MBBS-2022-10256','Pune University',  '2022-06-15', NULL,         'VERIFIED',     '2023-07-30', '2023-08-03', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'MBBS certificate verified'),
-- EMP034 Padma - Junior Nurse documents with pending item
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='NURSINGREG'),  'PRE_ONBOARDING', 'https://storage.medcareindia.com/docs/EMP034/nursing_reg.pdf',     'TN-NMC-2022-3341','Tamil Nadu NMC',      '2022-10-01', '2027-09-30', 'VERIFIED',     '2023-01-15', '2023-01-18', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), 'Nursing council registration verified'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.DocumentType WHERE DocumentTypeCode='COVIDVACC'),   'PRE_ONBOARDING', NULL,                                                              NULL,             NULL,                   NULL,         NULL,         'PENDING',      NULL,         NULL,         NULL,                                                 'COVID vaccination certificate not yet submitted - follow up with employee');


PRINT 'Inserting hr.BGVAgency...';
INSERT INTO hr.BGVAgency (AgencyName, ContactPerson, Email, Phone) VALUES
('AuthBridge Research Services Pvt. Ltd.',  'Rajat Sharma',     'rajat.sharma@authbridge.com',      '+91-124-4399999'),
('First Advantage India',                   'Preethi Nair',     'preethi.nair@fadv.com',            '+91-80-67001000'),
('Netrika Consulting India Pvt. Ltd.',      'Sundeep Malhotra', 'sundeep@netrika.com',              '+91-11-45151515'),
('IDfy Technologies Pvt. Ltd.',             'Ananya Kapoor',    'ananya.kapoor@idfy.com',           '+91-22-62662666');


PRINT 'Inserting hr.BackgroundVerification...';
INSERT INTO hr.BackgroundVerification (EmployeeId, BGVAgencyId, BGVCheckType, OnboardingPhase, InitiatedByEmployeeId, InitiatedDate, ExpectedDate, CompletedDate, BGVStatus, BGVResult, Findings, ReportUrl) VALUES
-- EMP030 - Identity (completed, clear)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='AuthBridge Research Services Pvt. Ltd.'),
 'IDENTITY', 'PRE_ONBOARDING',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
 '2023-02-28', '2023-03-14', '2023-03-10', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP030/identity_report.pdf'),
-- EMP030 - Employment History (completed, clear)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='AuthBridge Research Services Pvt. Ltd.'),
 'EMPLOYMENT_HISTORY', 'PRE_ONBOARDING',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
 '2023-02-28', '2023-03-21', '2023-03-18', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP030/employment_report.pdf'),
-- EMP043 - Identity (completed, clear)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='First Advantage India'),
 'IDENTITY', 'PRE_ONBOARDING',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
 '2023-07-28', '2023-08-11', '2023-08-08', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP043/identity_report.pdf'),
-- EMP043 - Education (completed, clear)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='First Advantage India'),
 'EDUCATION', 'PRE_ONBOARDING',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
 '2023-07-28', '2023-08-18', '2023-08-15', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP043/education_report.pdf'),
-- EMP034 - Identity (in progress)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='IDfy Technologies Pvt. Ltd.'),
 'IDENTITY', 'PRE_ONBOARDING',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'),
 '2023-01-14', '2023-01-28', NULL, 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP034/identity_report.pdf'),
-- EMP040 - Criminal (completed, clear)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'),
 (SELECT Id FROM hr.BGVAgency WHERE AgencyName='Netrika Consulting India Pvt. Ltd.'),
 'CRIMINAL', 'PRE_ONBOARDING',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
 '2022-08-25', '2022-09-08', '2022-09-05', 'COMPLETED', 'CLEAR', NULL,
 'https://storage.medcareindia.com/bgv/EMP040/criminal_report.pdf');


-- MODULE C: POLICY DOCUMENTS

PRINT 'Inserting hr.PolicyCategory...';
INSERT INTO hr.PolicyCategory (CategoryCode, CategoryName, Description) VALUES
('HR_POLICY',       'HR Policies',              'Leave, attendance, code of conduct, and employee welfare policies'),
('CLINICAL_POLICY', 'Clinical & Patient Safety','Infection control, patient safety, medication administration policies'),
('IT_POLICY',       'IT & Data Security',       'EHR usage, data privacy, device management, and cybersecurity policies'),
('FINANCE_POLICY',  'Finance & Compliance',     'Expense claims, reimbursement, payroll, and statutory compliance policies'),
('OPERATIONS',      'Operations & Facilities',  'Housekeeping, bio-medical waste, transport, and facility management policies');


PRINT 'Inserting hr.PolicyDocument...';
INSERT INTO hr.PolicyDocument (PolicyCategoryId, PolicyCode, PolicyName, Description, ScopeTypeId, ScopeReferenceId, AcknowledgementRequired, AcknowledgementDeadlineDays, IsActive, CreatedBy) VALUES
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='HR_POLICY'),
    'POL-HR-001', 'Leave and Attendance Policy',
    'Defines leave types, entitlements, accrual rules, carry-forward norms, and attendance regularization procedures for all employees.',
    (SELECT Id FROM time.ScopeType WHERE ScopeCode='LEGAL_ENTITY'),
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    1, 30, 1,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='HR_POLICY'),
    'POL-HR-002', 'Code of Conduct Policy',
    'Defines professional behaviour standards, ethical obligations, conflict of interest disclosures, and disciplinary procedures.',
    (SELECT Id FROM time.ScopeType WHERE ScopeCode='GLOBAL'),
    1,
    1, 15, 1,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='CLINICAL_POLICY'),
    'POL-CLN-001', 'Hospital Infection Control Policy',
    'Mandatory guidelines for hand hygiene, PPE usage, isolation protocols, and bio-medical waste segregation for all clinical staff.',
    (SELECT Id FROM time.ScopeType WHERE ScopeCode='GLOBAL'),
    1,
    1, 7, 1,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='CLINICAL_POLICY'),
    'POL-CLN-002', 'Medication Administration and Dispensing Policy',
    'Protocols for safe medication ordering, verification, dispensing, and error reporting across all hospital units.',
    (SELECT Id FROM time.ScopeType WHERE ScopeCode='DEPARTMENT'),
    (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),
    1, 14, 1,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='IT_POLICY'),
    'POL-IT-001', 'EHR Access and Data Privacy Policy',
    'Governs EHR login credentials, patient data access rights, audit trails, and penalties for unauthorized data access.',
    (SELECT Id FROM time.ScopeType WHERE ScopeCode='GLOBAL'),
    1,
    1, 14, 1,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007')
),
(
    (SELECT Id FROM hr.PolicyCategory WHERE CategoryCode='FINANCE_POLICY'),
    'POL-FIN-001', 'Employee Expense Reimbursement Policy',
    'Covers eligible expense categories, claim submission process, approval hierarchy, and reimbursement timelines.',
    (SELECT Id FROM time.ScopeType WHERE ScopeCode='LEGAL_ENTITY'),
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    1, 30, 1,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006')
);


PRINT 'Inserting hr.PolicyVersion...';
INSERT INTO hr.PolicyVersion (PolicyDocumentId, VersionNumber, VersionLabel, FileUrl, OriginalFileName, ChangeNotes, PolicyStatus, EffectiveDate, PublishedByEmployeeId, PublishedAt) VALUES
-- Leave and Attendance Policy - v1 (archived), v2 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-HR-001-v1.pdf',
    'Leave_Attendance_Policy_v1.0.pdf',
    'Initial version.',
    'ARCHIVED', '2020-04-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2020-03-25 10:00:00'
),
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001'),
    2, 'v2.0',
    'https://storage.medcareindia.com/policies/POL-HR-001-v2.pdf',
    'Leave_Attendance_Policy_v2.0.pdf',
    'Updated maternity leave entitlement to 26 weeks as per Maternity Benefit (Amendment) Act. Added WFH attendance guidelines.',
    'ACTIVE', '2023-01-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2022-12-20 14:00:00'
),
-- Code of Conduct - v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-002'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-HR-002-v1.pdf',
    'Code_of_Conduct_v1.0.pdf',
    'Initial version. Applicable to all employees across all entities.',
    'ACTIVE', '2021-07-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), '2021-06-28 09:00:00'
),
-- Infection Control Policy - v1 (archived), v2 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-CLN-001-v1.pdf',
    'Infection_Control_Policy_v1.0.pdf',
    'Initial version based on WHO hospital infection prevention guidelines.',
    'ARCHIVED', '2019-06-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2019-05-30 10:00:00'
),
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001'),
    2, 'v2.0',
    'https://storage.medcareindia.com/policies/POL-CLN-001-v2.pdf',
    'Infection_Control_Policy_v2.0.pdf',
    'Revised to incorporate COVID-19 specific PPE protocols and aerosol-generating procedure guidelines. Updated hand hygiene stations matrix.',
    'ACTIVE', '2022-01-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), '2021-12-15 11:00:00'
),
-- Medication Administration Policy - v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-002'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-CLN-002-v1.pdf',
    'Medication_Administration_Policy_v1.0.pdf',
    'Initial version aligned with national pharmacy council guidelines.',
    'ACTIVE', '2020-09-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), '2020-08-25 09:00:00'
),
-- EHR Access Policy - v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-IT-001-v1.pdf',
    'EHR_Data_Privacy_Policy_v1.0.pdf',
    'Initial version. Covers all EHR user access categories and HIPAA-equivalent data privacy norms.',
    'ACTIVE', '2021-04-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), '2021-03-29 14:00:00'
),
-- Expense Reimbursement Policy - v1 (active)
(
    (SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-FIN-001'),
    1, 'v1.0',
    'https://storage.medcareindia.com/policies/POL-FIN-001-v1.pdf',
    'Expense_Reimbursement_Policy_v1.0.pdf',
    'Initial version covering travel, accommodation, and professional development reimbursements.',
    'ACTIVE', '2020-01-01',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), '2019-12-28 10:00:00'
);

-- Link superseded version
UPDATE hr.PolicyVersion
SET SupersededByVersionId = (SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001')  AND VersionNumber=2)
WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=1;

UPDATE hr.PolicyVersion
SET SupersededByVersionId = (SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2)
WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=1;

PRINT 'Inserting hr.PolicyAcknowledgement (samples)...';
-- Leave Policy v2 - select clinical and HR staff
INSERT INTO hr.PolicyAcknowledgement (PolicyVersionId, EmployeeId, AckStatus, DeadlineDate, AcknowledgedAt) VALUES
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-15 09:30:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-16 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-18 11:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-17 14:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), 'ACKNOWLEDGED', '2023-01-31', '2023-01-20 09:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), 'ACKNOWLEDGED', '2023-03-31', '2023-03-10 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), 'PENDING',      '2023-02-15', NULL),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-HR-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), 'ACKNOWLEDGED', '2023-08-31', '2023-08-10 09:00:00');

-- Infection Control Policy v2 - clinical staff
INSERT INTO hr.PolicyAcknowledgement (PolicyVersionId, EmployeeId, AckStatus, DeadlineDate, AcknowledgedAt) VALUES
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-05 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-06 09:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-07 11:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-05 14:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-07 15:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-06 16:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-CLN-001') AND VersionNumber=2), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), 'ACKNOWLEDGED', '2022-01-08', '2022-01-08 09:30:00');

-- EHR Data Privacy Policy - IT and admin staff
INSERT INTO hr.PolicyAcknowledgement (PolicyVersionId, EmployeeId, AckStatus, DeadlineDate, AcknowledgedAt) VALUES
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), 'ACKNOWLEDGED', '2021-04-15', '2021-04-03 10:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), 'ACKNOWLEDGED', '2021-04-15', '2021-04-08 11:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), 'ACKNOWLEDGED', '2021-04-15', '2021-04-10 14:00:00'),
((SELECT Id FROM hr.PolicyVersion WHERE PolicyDocumentId=(SELECT Id FROM hr.PolicyDocument WHERE PolicyCode='POL-IT-001') AND VersionNumber=1), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), 'OVERDUE',      '2021-04-15', NULL);


-- MODULE E: PERFORMANCE REVIEWS

PRINT 'Inserting hr.PerformanceCycle...';
INSERT INTO hr.PerformanceCycle (CycleName, CycleType, StartDate, EndDate, GoalSettingDeadline, ReviewStartDate, ReviewEndDate, CycleStatus, LegalEntityId, CreatedBy) VALUES
('Annual Appraisal 2023 - MedCare India',       'ANNUAL',   '2023-01-01', '2023-12-31', '2023-02-28', '2024-01-15', '2024-02-28', 'COMPLETED',    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')),
('Annual Appraisal 2024 - MedCare India',       'ANNUAL',   '2024-01-01', '2024-12-31', '2024-02-29', '2025-01-15', '2025-02-28', 'COMPLETED',    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')),
('Annual Appraisal 2024 - MedCare North',       'ANNUAL',   '2024-01-01', '2024-12-31', '2024-02-29', '2025-01-15', '2025-02-28', 'COMPLETED',    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019')),
('Annual Appraisal 2024 - MedCare South',       'ANNUAL',   '2024-01-01', '2024-12-31', '2024-02-29', '2025-01-15', '2025-02-28', 'COMPLETED',    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019')),
('Probation Review - Q3 2023 Joiners',          'PROBATION','2023-08-01', '2024-01-31', '2023-09-15', '2024-01-15', '2024-01-31', 'COMPLETED',    NULL,                                                          (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')),
('Annual Appraisal 2025 - All Entities',        'ANNUAL',   '2025-01-01', '2025-12-31', '2025-03-31', '2026-01-15', '2026-02-28', 'GOAL_SETTING', NULL,                                                          (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'));


PRINT 'Inserting hr.Goal (2024 cycle - sample employees)...';
-- EMP003 Dr. Arjun Mehta - Senior Cardiac Surgeon - 2024 Annual
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating, ApprovedByEmployeeId) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Achieve zero post-operative infection rate in Cardiac Surgery unit',
    'Implement and lead enhanced sterile technique protocols; target zero SSI cases in elective cardiac surgeries.',
    'Clinical',
    40.00, '2024-12-31', 'COMPLETED', 100, 4.5, 4.5,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002')
),
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Mentor 2 resident doctors through advanced cardiac surgical procedures',
    'Provide hands-on mentoring to EMP009 and one additional resident in CABG and valve repair procedures.',
    'Learning',
    30.00, '2024-12-31', 'COMPLETED', 100, 4.0, 4.0,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002')
),
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Publish one peer-reviewed research paper on minimally invasive cardiac surgery',
    'Co-author and submit a research paper to a national or international cardiology journal.',
    'Learning',
    30.00, '2024-12-31', 'COMPLETED', 100, 3.5, 3.5,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002')
);

-- EMP010 Meena Joshi - Senior ICU Nurse - 2024 Annual
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating, ApprovedByEmployeeId) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Achieve 100% BLS/ACLS certification compliance in ICU nursing team',
    'Ensure all 6 ICU nurses complete BLS/ACLS recertification by June 2024.',
    'Clinical',
    50.00, '2024-06-30', 'COMPLETED', 100, 4.5, 5.0,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004')
),
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Reduce ventilator-associated events by 20% compared to 2023 baseline',
    'Implement VAE prevention bundle; monitor and report monthly outcomes to CNO.',
    'Clinical',
    50.00, '2024-12-31', 'COMPLETED', 100, 4.0, 4.5,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004')
);

-- EMP005 Vikram Gupta - HR Manager - 2024 Annual
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating, ApprovedByEmployeeId) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Reduce average time-to-fill for clinical vacancies to under 45 days',
    'Streamline recruitment pipeline; improve JD quality; reduce interview scheduling lag.',
    'Business',
    40.00, '2024-12-31', 'COMPLETED', 100, 4.0, 3.5,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001')
),
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Achieve 95% policy acknowledgement compliance across all mandatory policies',
    'Track and follow up on pending policy acknowledgements; escalate overdue items monthly.',
    'Business',
    30.00, '2024-12-31', 'COMPLETED', 100, 3.5, 3.5,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001')
),
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    'Implement structured 90-day onboarding programme for new clinical joiners',
    'Design checklist-driven onboarding with phase gates for Pre-Joining, Day One, and First Month.',
    'Learning',
    30.00, '2024-06-30', 'COMPLETED', 100, 4.5, 4.5,
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001')
);

-- EMP009 Dr. Anil Khanna - Resident Doctor - 2025 Annual (in progress)
INSERT INTO hr.Goal (EmployeeId, PerformanceCycleId, Title, Description, Category, WeightagePct, TargetDate, GoalStatus, ProgressPct, EmployeeRating, ManagerRating) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 - All Entities'),
    'Complete advanced cardiac catheterisation training module',
    'Attend and complete cath lab training supervised by Dr. Arjun Mehta; achieve 20 supervised procedures.',
    'Learning',
    40.00, '2025-09-30', 'IN_PROGRESS', 35, NULL, NULL
),
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 - All Entities'),
    'Improve patient documentation accuracy score to above 90%',
    'Reduce EHR documentation errors as measured in monthly audit by medical records team.',
    'Business',
    30.00, '2025-12-31', 'APPROVED',    10, NULL, NULL
),
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 - All Entities'),
    'Present a clinical case study at the internal CME session',
    'Prepare and present a complex cardiac case to the department at the quarterly CME.',
    'Learning',
    30.00, '2025-06-30', 'SUBMITTED',   0,  NULL, NULL
);


PRINT 'Inserting hr.GoalKeyResult...';
-- EMP003 - Zero infection goal KRs
INSERT INTO hr.GoalKeyResult (GoalId, Description, TargetValue, ActualValue, KRStatus) VALUES
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003') AND Title LIKE '%infection rate%' ORDER BY Id),
    'Surgical Site Infection (SSI) rate in elective cardiac cases',
    '0 cases', '0 cases', 'ACHIEVED'
),
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003') AND Title LIKE '%infection rate%' ORDER BY Id),
    'Monthly sterile technique compliance audit score',
    '>= 95%', '97%', 'ACHIEVED'
);
-- EMP009 - Catheterisation training KRs
INSERT INTO hr.GoalKeyResult (GoalId, Description, TargetValue, ActualValue, KRStatus) VALUES
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009') AND Title LIKE '%catheterisation%' ORDER BY Id),
    'Number of supervised cath lab procedures completed',
    '20 procedures', '7 procedures', 'ON_TRACK'
),
(
    (SELECT TOP 1 Id FROM hr.Goal WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009') AND Title LIKE '%catheterisation%' ORDER BY Id),
    'Completion of theoretical module assessment',
    '80% pass score', 'Not started yet', 'PENDING'
);


PRINT 'Inserting hr.PerformanceReview (2024 Annual)...';
-- EMP003 - 2024 Annual (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, HRBPComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'),
    4.2, 4.4, 4.3, 'Exceeds',
    'Successfully achieved zero SSI target and mentored two residents through complex procedures. Research paper submission was a significant professional milestone.',
    'Dr. Mehta continues to set the benchmark for surgical excellence in our cardiac unit. Outstanding year.',
    'Consistent top performer. Recommend for merit increment and leadership responsibility expansion.',
    'COMPLETED',
    '2025-01-18 10:00:00', '2025-01-28 14:00:00', '2025-02-10 11:00:00'
);
-- EMP010 - 2024 Annual (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, HRBPComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'),
    4.5, 4.8, 4.7, 'Exceeds',
    'Proud of achieving 100% BLS/ACLS compliance in the team and measurable improvement in VAE metrics.',
    'Meena is the backbone of our ICU nursing team. Excellent leadership, exceptional clinical outcomes.',
    'Strong candidate for Senior Nurse Lead role. Recommend promotion discussion.',
    'COMPLETED',
    '2025-01-16 09:00:00', '2025-01-26 11:00:00', '2025-02-08 14:00:00'
);
-- EMP005 - 2024 Annual (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, HRBPComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'),
    3.8, 3.6, 3.7, 'Meets',
    'Delivered on most HR goals. Recruitment TAT improved significantly. Onboarding programme rolled out on time.',
    'Vikram has done a solid job on operational HR. Some room to improve strategic people initiatives.',
    'Meets expectations. Consider L&D focus for next cycle.',
    'COMPLETED',
    '2025-01-20 10:00:00', '2025-02-01 16:00:00', '2025-02-12 10:00:00'
);
-- EMP009 - 2025 Annual (Pending - just started)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, ReviewStatus) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2025 - All Entities'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'),
    'PENDING'
);
-- EMP043 - Probation Review (Completed)
INSERT INTO hr.PerformanceReview (EmployeeId, PerformanceCycleId, ReviewerEmployeeId, SelfRating, ManagerRating, FinalRating, PerformanceBand, SelfComments, ManagerComments, ReviewStatus, SelfSubmittedAt, ManagerSubmittedAt, CompletedAt) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'),
    (SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Probation Review - Q3 2023 Joiners'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'),
    3.5, 3.5, 3.5, 'Meets',
    'Good learning curve. Adapting well to hospital environment and rotating departments.',
    'Rohit has shown good attitude and learning drive. Recommend confirmation of employment.',
    'COMPLETED',
    '2024-01-18 10:00:00', '2024-01-25 14:00:00', '2024-01-30 11:00:00'
);


PRINT 'Inserting hr.PerformanceReviewHistory...';
-- EMP003 - review history
INSERT INTO hr.PerformanceReviewHistory (PerformanceReviewId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), NULL,             'PENDING',          (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Review cycle initiated for 2024',              '2025-01-15 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), 'PENDING',        'SELF_SUBMITTED',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), 'Self-assessment submitted by employee',        '2025-01-18 10:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), 'SELF_SUBMITTED', 'MANAGER_REVIEW',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), 'Manager review in progress',                   '2025-01-20 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), 'MANAGER_REVIEW', 'HRBP_REVIEW',      (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), 'Manager submitted; routed to HRBP for review', '2025-01-28 14:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), 'HRBP_REVIEW',    'COMPLETED',        (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Review finalised and rating locked',           '2025-02-10 11:00:00');

-- EMP010 - review history (abbreviated)
INSERT INTO hr.PerformanceReviewHistory (PerformanceReviewId, FromStatus, ToStatus, ChangedByEmployeeId, Remarks, ChangedAt) VALUES
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), NULL,             'PENDING',          (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'Review cycle initiated',                       '2025-01-15 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), 'PENDING',        'SELF_SUBMITTED',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), 'Self-assessment submitted',                    '2025-01-16 09:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), 'SELF_SUBMITTED', 'MANAGER_REVIEW',   (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), 'Moved to CNO for manager review',              '2025-01-18 10:00:00'),
((SELECT Id FROM hr.PerformanceReview WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010') AND PerformanceCycleId=(SELECT Id FROM hr.PerformanceCycle WHERE CycleName='Annual Appraisal 2024 - MedCare India')), 'MANAGER_REVIEW', 'COMPLETED',        (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'HRBP waived for this grade; review finalised',  '2025-02-08 14:00:00');


-- MODULE F: TRAINING RECORDS

PRINT 'Inserting hr.TrainingProgram...';
INSERT INTO hr.TrainingProgram (TrainingCategory, ProgramCode, Title, Description, TrainingMode, DurationHours, Provider, IsMandatory, ApplicableTo, MaxParticipants, CertificateProvided) VALUES
('COMPLIANCE', 'TRN-BLS-001', 'Basic Life Support (BLS) Certification', 'Hands-on BLS certification covering CPR, AED operation, and choking response for adults, children, and infants.', 'OFFLINE', 8.0, 'American Heart Association (AHA)', 1, 'All Employees', 20, 1),
('COMPLIANCE', 'TRN-CMP-002', 'Workplace Safety and Fire Prevention', 'Covers fire safety protocols, emergency evacuation procedures, and workplace hazard prevention.', 'OFFLINE', 6.0, 'National Safety Council', 1, 'All Employees', 30, 1),
('TECHNICAL', 'TRN-TECH-001', 'Advanced SQL and Database Optimization', 'Training on indexing, execution plans, query optimization, and SQL Server performance tuning.', 'ONLINE', 16.0, 'Microsoft Learn', 0, 'IT Employees', 25, 1),
('TECHNICAL', 'TRN-TECH-002', 'Cloud Computing Fundamentals', 'Introduction to cloud platforms, virtualization, storage, and deployment models.', 'ONLINE', 12.0, 'AWS Academy', 0, 'IT Employees', 40, 1),
('LEADERSHIP', 'TRN-LDR-001', 'Leadership and Team Management', 'Develops leadership, delegation, team-building, and decision-making skills.', 'HYBRID', 10.0, 'Harvard Business Publishing', 0, 'Managers', 20, 1),
('LEADERSHIP', 'TRN-LDR-002', 'Conflict Resolution and Negotiation', 'Provides strategies for resolving workplace conflicts and improving negotiation outcomes.', 'HYBRID', 8.0, 'Dale Carnegie', 0, 'Managers and Team Leads', 25, 1),
('SOFT_SKILLS', 'TRN-SFT-001', 'Effective Communication Skills', 'Improves verbal, written, and interpersonal communication skills.', 'ONLINE', 6.0, 'Coursera', 0, 'All Employees', 50, 1),
('SOFT_SKILLS', 'TRN-SFT-002', 'Time Management and Productivity', 'Focuses on prioritization, scheduling, and productivity improvement techniques.', 'ONLINE', 5.0, 'Udemy', 0, 'All Employees', 60, 1),
('DOMAIN', 'TRN-DOM-001', 'Healthcare Regulatory Standards', 'Training on healthcare compliance, patient safety, and regulatory standards.', 'OFFLINE', 10.0, 'National Healthcare Institute', 1, 'Healthcare Staff', 30, 1),
('DOMAIN', 'TRN-DOM-002', 'Banking Risk and Compliance', 'Covers banking regulations, fraud prevention, and financial risk management.', 'ONLINE', 9.0, 'Institute of Banking Studies', 1, 'Finance Employees', 35, 1);

PRINT 'Inserting hr.TrainingBatch...';

INSERT INTO hr.TrainingBatch (TrainingProgramId, BatchName, FacilitatorEmployeeId, StartDate, EndDate, VenueOrLink, MaxSeats, BatchStatus) VALUES
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-BLS-001'), 'BLS Batch - January 2025 - Mumbai', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP004'), '2025-01-18', '2025-01-18', 'MedCare Mumbai HQ - Simulation Lab, Floor 2', 20, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-CMP-002'), 'Workplace Safety Workshop - February 2025', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP003'), '2025-02-08', '2025-02-08', 'MedCare Mumbai HQ - Safety Training Hall', 30, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-TECH-001'), 'Advanced SQL Bootcamp - Q1 2025', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP007'), '2025-01-10', '2025-01-12', 'https://lms.medcareindia.com/courses/TRN-TECH-001', 25, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-TECH-002'), 'Cloud Computing Fundamentals - March 2025', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP008'), '2025-03-05', '2025-03-06', 'MedCare Mumbai HQ - IT Training Room, Floor 3', 40, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-LDR-001'), 'Leadership Excellence Program - FY2025', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP010'), '2025-02-15', '2025-02-16', 'https://lms.medcareindia.com/courses/TRN-LDR-001', 20, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-LDR-002'), 'Conflict Resolution Workshop - April 2025', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP011'), '2025-04-05', '2025-04-05', 'MedCare Mumbai HQ - Conference Room A', 25, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-SFT-001'), 'Communication Skills Enhancement - Q1 2025', NULL, '2025-01-20', '2025-01-25', 'https://lms.medcareindia.com/courses/TRN-SFT-001', 50, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-SFT-002'), 'Productivity and Time Management - May 2025', NULL, '2025-05-01', '2025-05-07', 'https://lms.medcareindia.com/courses/TRN-SFT-002', 60, 'UPCOMING'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-DOM-001'), 'Healthcare Regulatory Standards - April 2025', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP029'), '2025-04-10', '2025-04-11', 'MedCare Chennai Hospital - Training Center', 30, 'COMPLETED'),
((SELECT Id FROM hr.TrainingProgram WHERE ProgramCode = 'TRN-DOM-002'), 'Banking Risk and Compliance - June 2025', (SELECT Id FROM employee.Employee WHERE EmployeeCode = 'EMP030'), '2025-06-12', '2025-06-13', 'MedCare Finance Division - Board Room', 35, 'UPCOMING');

PRINT 'Inserting hr.EmployeeTrainingRecord...';
INSERT INTO hr.EmployeeTrainingRecord (EmployeeId, TrainingProgramId, TrainingBatchId, EnrolledDate, CompletedDate, RecordStatus, Score, PassingScore, CertificateUrl, CertificateIssuedDate, Feedback) VALUES
-- BLS Batch - January 2025 - Mumbai
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch - January 2025 - Mumbai'), '2025-01-10', '2025-01-18', 'COMPLETED', 92.00, 75.00, 'https://storage.medcareindia.com/certs/EMP010/BLS-2025-01.pdf', '2025-01-20', 'Excellent hands-on session. Refreshed emergency response interventions.'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch - January 2025 - Mumbai'), '2025-01-10', '2025-01-18', 'COMPLETED', 85.00, 75.00, 'https://storage.medcareindia.com/certs/EMP011/BLS-2025-01.pdf', '2025-01-20', 'Good refresher. CPR practicals were highly useful.'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-BLS-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='BLS Batch - January 2025 - Mumbai'), '2025-01-10', '2025-01-18', 'COMPLETED', 78.00, 75.00, 'https://storage.medcareindia.com/certs/EMP044/BLS-2025-01.pdf', '2025-01-20', NULL),
-- Workplace Safety Workshop - February 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-CMP-002'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Workplace Safety Workshop - February 2025'), '2025-02-01', '2025-02-08', 'COMPLETED', 96.00, 70.00, 'https://storage.medcareindia.com/certs/EMP003/SAFETY-2025-02.pdf', '2025-02-10', 'Very informative fire evacuation practicals.'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-CMP-002'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Workplace Safety Workshop - February 2025'), '2025-02-01', '2025-02-08', 'COMPLETED', 88.00, 70.00, 'https://storage.medcareindia.com/certs/EMP009/SAFETY-2025-02.pdf', '2025-02-10', 'Improved awareness about workplace hazards.'),
-- Advanced SQL Bootcamp - Q1 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-TECH-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Advanced SQL Bootcamp - Q1 2025'), '2025-01-05', '2025-01-12', 'COMPLETED', 98.00, 80.00, 'https://storage.medcareindia.com/certs/EMP007/SQL-2025-Q1.pdf', '2025-01-15', 'Excellent query optimization coverage.'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-TECH-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Advanced SQL Bootcamp - Q1 2025'), '2025-01-05', '2025-01-12', 'COMPLETED', 82.00, 80.00, 'https://storage.medcareindia.com/certs/EMP008/SQL-2025-Q1.pdf', '2025-01-15', 'Execution plan analysis section was very useful.'),
-- Cloud Computing Fundamentals - March 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-TECH-002'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Cloud Computing Fundamentals - March 2025'), '2025-02-25', '2025-03-06', 'COMPLETED', 90.00, 75.00, 'https://storage.medcareindia.com/certs/EMP012/CLOUD-2025-03.pdf', '2025-03-08', NULL),
-- Leadership Excellence Program - FY2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-LDR-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Leadership Excellence Program - FY2025'), '2025-02-01', '2025-02-16', 'COMPLETED', 94.00, 75.00, 'https://storage.medcareindia.com/certs/EMP020/LDR-2025.pdf', '2025-02-20', 'Excellent leadership case studies.'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-LDR-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Leadership Excellence Program - FY2025'), '2025-02-01', NULL, 'IN_PROGRESS', NULL, 75.00, NULL, NULL, NULL),
-- Conflict Resolution Workshop - April 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-LDR-002'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Conflict Resolution Workshop - April 2025'), '2025-03-28', '2025-04-05', 'COMPLETED', 89.00, 75.00, 'https://storage.medcareindia.com/certs/EMP022/NEGOTIATION-2025-04.pdf', '2025-04-07', 'Very practical negotiation scenarios.'),
-- Communication Skills Enhancement - Q1 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-SFT-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Communication Skills Enhancement - Q1 2025'), '2025-01-15', '2025-01-25', 'COMPLETED', 91.00, 70.00, 'https://storage.medcareindia.com/certs/EMP001/COMM-2025-Q1.pdf', '2025-01-27', NULL),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-SFT-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Communication Skills Enhancement - Q1 2025'), '2025-01-15', '2025-01-25', 'COMPLETED', 95.00, 70.00, 'https://storage.medcareindia.com/certs/EMP005/COMM-2025-Q1.pdf', '2025-01-27', 'Interactive communication exercises were excellent.'),
-- Productivity and Time Management - May 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-SFT-002'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Productivity and Time Management - May 2025'), '2025-05-01', NULL, 'ENROLLED', NULL, 70.00, NULL, NULL, NULL),
-- Healthcare Regulatory Standards - April 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-DOM-001'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Healthcare Regulatory Standards - April 2025'), '2025-04-01', '2025-04-11', 'COMPLETED', 91.00, 75.00, 'https://storage.medcareindia.com/certs/EMP029/HEALTHCARE-2025-04.pdf', '2025-04-15', 'Regulatory compliance section was highly detailed.'),
-- Banking Risk and Compliance - June 2025
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM hr.TrainingProgram WHERE ProgramCode='TRN-DOM-002'), (SELECT Id FROM hr.TrainingBatch WHERE BatchName='Banking Risk and Compliance - June 2025'), '2025-05-25', NULL, 'ENROLLED', NULL, 75.00, NULL, NULL, NULL);
-- MODULE G: EXIT MANAGEMENT

PRINT 'Inserting hr.ExitReason...';
INSERT INTO hr.ExitReason (ReasonText, Category) VALUES
('Better Career Opportunity',           'VOLUNTARY'),
('Higher Compensation Elsewhere',       'VOLUNTARY'),
('Relocation - Personal Reasons',       'VOLUNTARY'),
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
-- EMP015 Suresh Naidu - Front Desk - Resigned for better opportunity (Mumbai)
INSERT INTO hr.ExitRecord (EmployeeId, ExitReasonId, ExitType, AdditionalReason, ResignationDate, LastWorkingDate, NoticePeriodDays, IsNoticeWaived, ExitInterviewStatus, ExitInterviewDate, ConductedByEmployeeId, ExitFeedback, IsRehireEligible, ClearanceStatus, FinalSettlementStatus, FinalSettlementDate, CreatedBy) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'),
    (SELECT Id FROM hr.ExitReason WHERE ReasonText='Better Career Opportunity'),
    'RESIGNATION', NULL,
    '2025-03-15', '2025-04-14', 30, 0,
    'COMPLETED', '2025-04-10',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    'Employee expressed satisfaction with MedCare but was attracted by a senior role with higher compensation. Recommended for rehire. Cited positive management and team culture.',
    1, 'COMPLETED', 'PAID', '2025-04-30',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
);

-- EMP013 Manoj Verma - Pharmacist Mumbai - Resigned for higher education
INSERT INTO hr.ExitRecord (EmployeeId, ExitReasonId, ExitType, AdditionalReason, ResignationDate, LastWorkingDate, NoticePeriodDays, IsNoticeWaived, ExitInterviewStatus, ExitInterviewDate, ConductedByEmployeeId, ExitFeedback, IsRehireEligible, ClearanceStatus, FinalSettlementStatus, CreatedBy) VALUES
(
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'),
    (SELECT Id FROM hr.ExitReason WHERE ReasonText='Higher Education / Research'),
    'RESIGNATION', 'Pursuing M.Pharm from NIPER Hyderabad; full-time programme, cannot continue alongside work.',
    '2025-04-01', '2025-04-30', 30, 0,
    'SCHEDULED', '2025-04-25',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    NULL, 1, 'IN_PROGRESS', 'PENDING',
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005')
);

PRINT 'Inserting hr.ExitClearanceItem...';
-- EMP015 - All clearances completed (exit fully processed)
INSERT INTO hr.ExitClearanceItem (ExitRecordId, ItemName, OwnerDepartment, ItemStatus, CompletedByEmployeeId, CompletedAt, Remarks) VALUES
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015')), 'ID Card and Access Badge returned',        'HR',           'COMPLETED', (SELECT Id FROM  employee.Employee WHERE EmployeeCode='EMP005'), '2025-04-14 17:00:00', 'ID card collected on last working day'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015')), 'Laptop and company assets returned',        'IT',           'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), '2025-04-14 16:00:00', 'Laptop in good condition; charger returned'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015')), 'System and EHR access revoked',             'IT',           'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), '2025-04-14 18:00:00', 'All user accounts deactivated'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015')), 'Finance clearance and dues settled',        'Finance',      'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), '2025-04-18 11:00:00', 'No outstanding advances; petty cash reconciled'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015')), 'Uniform and workwear returned',             'Admin',        'COMPLETED', (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), '2025-04-14 17:30:00', '2 sets of uniform returned'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015')), 'Knowledge transfer to replacement',         'Admin',        'WAIVED',    NULL,                                                  NULL,                  'Role is being held vacant; KT waived per manager approval');

-- EMP013 - Clearances in progress
INSERT INTO hr.ExitClearanceItem (ExitRecordId, ItemName, OwnerDepartment, ItemStatus, CompletedByEmployeeId, CompletedAt, Remarks) VALUES
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013')), 'ID Card and Access Badge returned',        'HR',           'PENDING',   NULL, NULL, NULL),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013')), 'System and EHR access revoked',             'IT',           'PENDING',   NULL, NULL, 'To be done on last working day'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013')), 'Pharmacy drug register handover',           'Pharmacy',     'COMPLETED',(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), NULL, 'Chief pharmacist conducting handover with EMP013 this week'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013')), 'Finance clearance and dues settled',        'Finance',      'PENDING',   NULL, NULL, 'Full and final calculation pending payroll processing'),
((SELECT Id FROM hr.ExitRecord WHERE EmployeeId=(SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013')), 'Uniform and workwear returned',             'Admin',        'PENDING',   NULL, NULL, NULL);

PRINT 'HR recruitment seed data inserted successfully.';
GO