-- Recruitment
-- ---------------
-- job_postings — open positions with department, location, and status
-- candidates — applicant profiles with contact and resume info
-- applications — links candidates to job postings; tracks application status

-- Interview Process
-- -------------------
-- interviews — individual interview rounds with type, schedule, and interviewer; supports unlimited rounds via round_number
-- interview_feedback — per-interviewer feedback for each interview, with rating and recommendation

-- Offer & Joining
-- --------------------
-- package_negotiations — HR-managed salary negotiation trail from offer to final figure
-- offer_letters — issued offer documents linked to the final negotiated package

-- Onboarding
-- ---------------------
-- employees — master employee record, created when an applicant accepts the offer
-- onboarding_tasks — checklist of onboarding steps with phase (pre/post) and completion tracking
-- document_verification — tracks document submissions and verification status across pre- and post-onboarding phases
-- background_verification — tracks background check types (criminal, employment, education, etc.) by phase and agency

-- Performance
-- -----------------------
-- performance_cycles — annual or quarterly review cycles
-- goals — individual goals set by employees against a cycle
-- performance_reviews — manager and self-ratings with comments, tied to a cycle

-- Training
-- ------------------------
-- training_categories — top-level groupings (technical, compliance, leadership, etc.)
-- training_programs — specific courses under each category with mode and duration
-- employee_training_records — enrollment, completion, scores, and certificates per employee

-- Exit
-- -------------------------
-- exit_records — departure reason, notice period, exit interview status, and clearance tracking

-- =============================================================================
-- HR MANAGEMENT SYSTEM — COMPLETE DATABASE SCHEMA
-- Convention : BIGINT PRIMARY KEY IDENTITY(1,1)
--              All FK constraints named explicitly as CONSTRAINT FK_<Table>_<Ref>
--              All PK constraints named explicitly as CONSTRAINT PK_<Table>
-- =============================================================================


-- =============================================================================
-- SECTION 0 : FOUNDATION / LOOKUP TABLES
-- =============================================================================

-- Department
-- Purpose : Master list of all company departments.
-- CREATE TABLE Department (
--     DepartmentId        BIGINT          NOT NULL,
--     DepartmentName      NVARCHAR(150)   NOT NULL,
--     DepartmentCode      NVARCHAR(20)    NOT NULL,
--     ParentDepartmentId  BIGINT          NULL,
--     HeadEmployeeId      BIGINT          NULL,       -- FK to Employee (added after Employee table)
--     IsActive            BIT             NOT NULL DEFAULT 1,
--     CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
--     UpdatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

--     CONSTRAINT PK_Department
--         PRIMARY KEY (DepartmentId),

--     CONSTRAINT UQ_Department_Code
--         UNIQUE (DepartmentCode),

--     CONSTRAINT FK_Department_ParentDepartment
--         FOREIGN KEY (ParentDepartmentId)
--         REFERENCES Department(DepartmentId)
-- );


-- -- Designation
-- -- Purpose : Job titles / grades used across recruitment and employee records.
-- CREATE TABLE Designation (
--     DesignationId       BIGINT          NOT NULL IDENTITY(1,1),
--     DesignationTitle    NVARCHAR(150)   NOT NULL,
--     Level               NVARCHAR(50)    NULL,       -- e.g. L1, L2, Senior, Lead
--     DepartmentId        BIGINT          NULL,
--     IsActive            BIT             NOT NULL DEFAULT 1,
--     CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

--     CONSTRAINT PK_Designation
--         PRIMARY KEY (DesignationId),

--     CONSTRAINT FK_Designation_Department
--         FOREIGN KEY (DepartmentId)
--         REFERENCES Department(DepartmentId)
-- );


-- -- =============================================================================
-- -- SECTION 1 : EMPLOYEE (CENTRAL TABLE)
-- -- =============================================================================

-- -- Employee
-- -- Purpose : Central employee master record. Created when an offer is accepted.
-- --           All HR processes (onboarding, performance, training, exit) link here.
-- CREATE TABLE Employee (
--     EmployeeId          BIGINT          NOT NULL IDENTITY(1,1),
--     EmployeeCode        NVARCHAR(50)    NOT NULL,
--     FullName            NVARCHAR(200)   NOT NULL,
--     Email               NVARCHAR(255)   NOT NULL,
--     PersonalEmail       NVARCHAR(255)   NULL,
--     Phone               NVARCHAR(20)    NULL,
--     DateOfBirth         DATE            NULL,
--     Gender              NVARCHAR(20)    NULL,
--     BloodGroup          NVARCHAR(5)     NULL,
--     DepartmentId        BIGINT          NOT NULL,
--     DesignationId       BIGINT          NOT NULL,
--     ManagerId           BIGINT          NULL,       -- self-ref to Employee
--     EmploymentType      NVARCHAR(50)    NOT NULL DEFAULT 'FullTime',
--     WorkLocation        NVARCHAR(150)   NULL,
--     JoiningDate         DATE            NOT NULL,
--     ConfirmationDate    DATE            NULL,
--     ProbationEndDate    DATE            NULL,
--     EmploymentStatus    NVARCHAR(30)    NOT NULL DEFAULT 'Active',
--                                                     -- Active | Probation | NoticePeriod | OnLeave | Separated | Terminated
--     PANNumber           NVARCHAR(20)    NULL,
--     AadhaarNumber       NVARCHAR(20)    NULL,
--     BankAccountNo       NVARCHAR(30)    NULL,
--     BankIFSC            NVARCHAR(15)    NULL,
--     IsActive            BIT             NOT NULL DEFAULT 1,
--     CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
--     UpdatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

--     CONSTRAINT PK_Employee
--         PRIMARY KEY (EmployeeId),

--     CONSTRAINT UQ_Employee_Code
--         UNIQUE (EmployeeCode),

--     CONSTRAINT UQ_Employee_Email
--         UNIQUE (Email),

--     CONSTRAINT FK_Employee_Department
--         FOREIGN KEY (DepartmentId)
--         REFERENCES Department(DepartmentId),

--     CONSTRAINT FK_Employee_Designation
--         FOREIGN KEY (DesignationId)
--         REFERENCES Designation(DesignationId),

--     CONSTRAINT FK_Employee_Manager
--         FOREIGN KEY (ManagerId)
--         REFERENCES Employee(EmployeeId)
-- );


-- -- Add deferred FK back on Department for HeadEmployee (now Employee exists)
-- ALTER TABLE Department
--     ADD CONSTRAINT FK_Department_HeadEmployee
--         FOREIGN KEY (HeadEmployeeId)
--         REFERENCES Employee(EmployeeId);


-- =============================================================================
-- SECTION 2 : RECRUITMENT
-- =============================================================================
-- Status
CREATE TABLE Status (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    StatusCategory      NVARCHAR(100)   NOT NULL,
    StatusCode          NVARCHAR(50)    NOT NULL,
    StatusName          NVARCHAR(100)   NOT NULL,
    Description         NVARCHAR(500)   NULL,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Status
        PRIMARY KEY (Id),

    CONSTRAINT UQ_StatusMaster
        UNIQUE (StatusCategory, StatusCode)
);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('OfferLetterStatus', 'ISSUED', 'Issued', 1),
-- ('OfferLetterStatus', 'ACCEPTED', 'Accepted', 2),
-- ('OfferLetterStatus', 'REJECTED', 'Rejected', 3),
-- ('OfferLetterStatus', 'EXPIRED', 'Expired', 4),
-- ('OfferLetterStatus', 'REVOKED', 'Revoked', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('PackageNegotiationStatus', 'INPROGRESS', 'InProgress', 1),
-- ('PackageNegotiationStatus', 'ACCEPTED', 'Accepted', 2),
-- ('PackageNegotiationStatus', 'REJECTED', 'Rejected', 3),
-- ('PackageNegotiationStatus', 'COUNTERED', 'Countered', 4),
-- ('PackageNegotiationStatus', 'WITHDRAWN', 'Withdrawn', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('OnboardingTaskStatus', 'PENDING', 'Pending', 1),
-- ('OnboardingTaskStatus', 'INPROGRESS', 'InProgress', 2),
-- ('OnboardingTaskStatus', 'COMPLETED', 'Completed', 3),
-- ('OnboardingTaskStatus', 'WAIVED', 'Waived', 4);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('BackgroundVerification', 'PENDING', 'Pending', 1),
-- ('BackgroundVerification', 'INPROGRESS', 'InProgress', 2),
-- ('BackgroundVerification', 'COMPLETED', 'Completed', 3),
-- ('BackgroundVerification', 'DISCREPANCYFOUND', 'DiscrepancyFound', 4),
-- ('BackgroundVerification', 'FAILED', 'Failed', 5),
-- ('BackgroundVerification', 'WAIVED', 'Waived', 6);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('CaseStatus', 'DRAFT', 'Draft', 1),
-- ('CaseStatus', 'OPEN', 'Open', 2),
-- ('CaseStatus', 'ONHOLD', 'OnHold', 3),
-- ('CaseStatus', 'CLOSED', 'Closed', 4),
-- ('CaseStatus', 'CANCELLED', 'Cancelled', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('RecommendationStatus', 'STRONGYES', 'StrongYes', 1),
-- ('RecommendationStatus', 'YES', 'Yes', 2),
-- ('RecommendationStatus', 'MAYBE', 'Maybe', 3),
-- ('RecommendationStatus', 'NO', 'No', 4),
-- ('RecommendationStatus', 'STRONGNO', 'StrongNo', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('GoalStatus', 'PENDING', 'Pending', 1),
-- ('GoalStatus', 'ONTRACK', 'OnTrack', 2),
-- ('GoalStatus', 'ATRISK', 'AtRisk', 3),
-- ('GoalStatus', 'ACHIEVED', 'Achieved', 4),
-- ('GoalStatus', 'NOTACHIEVED', 'NotAchieved', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('PerformanceReviewStatus', 'PENDING', 'Pending', 1),
-- ('PerformanceReviewStatus', 'SELFSUBMITTED', 'SelfSubmitted', 2),
-- ('PerformanceReviewStatus', 'MANAGERREVIEW', 'ManagerReview', 3),
-- ('PerformanceReviewStatus', 'HRBPREVIEW', 'HRBPReview', 4),
-- ('PerformanceReviewStatus', 'COMPLETED', 'Completed', 5),
-- ('PerformanceReviewStatus', 'ACKNOWLEDGED', 'Acknowledged', 6);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('InterviewStatus', 'SCHEDULED', 'Scheduled', 1),
-- ('InterviewStatus', 'COMPLETED', 'Completed', 2),
-- ('InterviewStatus', 'CANCELLED', 'Cancelled', 3),
-- ('InterviewStatus', 'RESCHEDULED', 'Rescheduled', 4),
-- ('InterviewStatus', 'NOSHOW', 'NoShow', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('OnboardingPhaseStatus', 'PREONBOARDING', 'PreOnboarding', 1),
-- ('OnboardingPhaseStatus', 'POSTONBOARDING', 'PostOnboarding', 2);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('BGVCheckTypeStatus', 'CRIMINAL', 'Criminal', 1),
-- ('BGVCheckTypeStatus', 'EMPLOYMENTHISTORY', 'EmploymentHistory', 2),
-- ('BGVCheckTypeStatus', 'EDUCATION', 'Education', 3),
-- ('BGVCheckTypeStatus', 'IDENTITY', 'Identity', 4),
-- ('BGVCheckTypeStatus', 'CREDIT', 'Credit', 5),
-- ('BGVCheckTypeStatus', 'REFERENCE', 'Reference', 6),
-- ('BGVCheckTypeStatus', 'DRUGTEST', 'DrugTest', 7),
-- ('BGVCheckTypeStatus', 'ADDRESS', 'Address', 8);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('BGVResultStstus', 'CLEAR', 'Clear', 1),
-- ('BGVResultStstus', 'DISCREPANCY', 'Discrepancy', 2),
-- ('BGVResultStstus', 'UNABLETOVERIFY', 'UnableToVerify', 3),
-- ('BGVResultStstus', 'FAILED', 'Failed', 4);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('PerformanceCycleStatus', 'UPCOMING', 'Upcoming', 1),
-- ('PerformanceCycleStatus', 'GOALSETTING', 'GoalSetting', 2),
-- ('PerformanceCycleStatus', 'INREVIEW', 'InReview', 3),
-- ('PerformanceCycleStatus', 'COMPLETED', 'Completed', 4),
-- ('PerformanceCycleStatus', 'ARCHIVED', 'Archived', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('PerformanceCycleType', 'ANNUAL', 'Annual', 1),
-- ('PerformanceCycleType', 'BIANNUAL', 'BiAnnual', 2),
-- ('PerformanceCycleType', 'QUARTERLY', 'Quarterly', 3),
-- ('PerformanceCycleType', 'PROBATION', 'Probation', 4);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('GoalKeyResultStatus', 'PENDING', 'Pending', 1),
-- ('GoalKeyResultStatus', 'ONTRACK', 'OnTrack', 2),
-- ('GoalKeyResultStatus', 'ATRISK', 'AtRisk', 3),
-- ('GoalKeyResultStatus', 'ACHIEVED', 'Achieved', 4),
-- ('GoalKeyResultStatus', 'NOTACHIEVED', 'NotAchieved', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('PerformanceReviewStatus', 'PENDING', 'Pending', 1),
-- ('PerformanceReviewStatus', 'SELFSUBMITTED', 'SelfSubmitted', 2),
-- ('PerformanceReviewStatus', 'MANAGERREVIEW', 'ManagerReview', 3),
-- ('PerformanceReviewStatus', 'HRBPREVIEW', 'HRBPReview', 4),
-- ('PerformanceReviewStatus', 'COMPLETED', 'Completed', 5),
-- ('PerformanceReviewStatus', 'ACKNOWLEDGED', 'Acknowledged', 6);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('TrainingModeStatus', 'ONLINE', 'Online', 1),
-- ('TrainingModeStatus', 'OFFLINE', 'Offline', 2),
-- ('TrainingModeStatus', 'HYBRID', 'Hybrid', 3),
-- ('TrainingModeStatus', 'SELFPACED', 'SelfPaced', 4);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('TrainingBatchStatus', 'UPCOMING', 'Upcoming', 1),
-- ('TrainingBatchStatus', 'ONGOING', 'Ongoing', 2),
-- ('TrainingBatchStatus', 'COMPLETED', 'Completed', 3),
-- ('TrainingBatchStatus', 'CANCELLED', 'Cancelled', 4);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('EmployeeTrainingRecordStatus', 'ENROLLED', 'Enrolled', 1),
-- ('EmployeeTrainingRecordStatus', 'INPROGRESS', 'InProgress', 2),
-- ('EmployeeTrainingRecordStatus', 'COMPLETED', 'Completed', 3),
-- ('EmployeeTrainingRecordStatus', 'FAILED', 'Failed', 4),
-- ('EmployeeTrainingRecordStatus', 'DROPPED', 'Dropped', 5),
-- ('EmployeeTrainingRecordStatus', 'ABSENT', 'Absent', 6);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('ExitInterviewStatus', 'PENDING', 'Pending', 1),
-- ('ExitInterviewStatus', 'SCHEDULED', 'Scheduled', 2),
-- ('ExitInterviewStatus', 'COMPLETED', 'Completed', 3),
-- ('ExitInterviewStatus', 'SKIPPED', 'Skipped', 4);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('ClearanceStatus', 'PENDING', 'Pending', 1),
-- ('ClearanceStatus', 'INPROGRESS', 'InProgress', 2),
-- ('ClearANCESTATUS', 'COMPLETED', 'Completed', 3);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('FinalSettlementStatus', 'PENDING', 'Pending', 1),
-- ('FinalSettlementStatus', 'PROCESSED', 'Processed', 2),
-- ('FinalSettlementStatus', 'PAID', 'Paid', 3);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('ExitTypeStatus', 'RESIGNATION', 'Resignation', 1),
-- ('ExitTypeStatus', 'TERMINATION', 'Termination', 2),
-- ('ExitTypeStatus', 'RETIREMENT', 'Retirement', 3),
-- ('ExitTypeStatus', 'CONTRACTEND', 'ContractEnd', 4),
-- ('ExitTypeStatus', 'ABSCONDING', 'Absconding', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('ExitClearanceItemStatus', 'PENDING', 'Pending', 1),
-- ('ExitClearanceItemStatus', 'COMPLETED', 'Completed', 2),
-- ('ExitClearanceItemStatus', 'WAIVED', 'Waived', 3);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('JobPostingStatus', 'DRAFT', 'Draft', 1),
-- ('JobPostingStatus', 'OPEN', 'Open', 2),
-- ('JobPostingStatus', 'ON_HOLD', 'OnHold', 3),
-- ('JobPostingStatus', 'CLOSED', 'Closed', 4),
-- ('JobPostingStatus', 'CANCELLED', 'Cancelled', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('ApplicationStatus', 'APPLIED', 'Applied', 1),
-- ('ApplicationStatus', 'SCREENING', 'Screening', 2),
-- ('ApplicationStatus', 'INTERVIEW', 'Interview', 3),
-- ('ApplicationStatus', 'OFFER', 'Offer', 4),
-- ('ApplicationStatus', 'NEGOTIATION', 'Negotiation', 5),
-- ('ApplicationStatus', 'HIRED', 'Hired', 6),
-- ('ApplicationStatus', 'REJECTED', 'Rejected', 7),
-- ('ApplicationStatus', 'WITHDRAWN', 'Withdrawn', 8);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('InterviewStatus', 'SCHEDULED', 'Scheduled', 1),
-- ('InterviewStatus', 'COMPLETED', 'Completed', 2),
-- ('InterviewStatus', 'CANCELLED', 'Cancelled', 3),
-- ('InterviewStatus', 'RESCHEDULED', 'Rescheduled', 4),
-- ('InterviewStatus', 'NOSHOW', 'NoShow', 5);

-- INSERT INTO StatusMaster
-- (StatusCategory, StatusCode, StatusName, DisplayOrder)
-- VALUES
-- ('DocumentVerificationStatus', 'PENDING', 'Pending', 1),
-- ('DocumentVerificationStatus', 'SUBMITTED', 'Submitted', 2),
-- ('DocumentVerificationStatus', 'UNDERREVIEW', 'UnderReview', 3),
-- ('DocumentVerificationStatus', 'VERIFIED', 'Verified', 4),
-- ('DocumentVerificationStatus', 'REJECTED', 'Rejected', 5),
-- ('DocumentVerificationStatus', 'RESUBMITTED', 'Resubmitted', 6),
-- ('DocumentVerificationStatus', 'EXPIRED', 'Expired', 7),
-- ('DocumentVerificationStatus', 'WAIVED', 'Waived', 8);

-- JobPosting
-- Purpose : Tracks every open or closed job requisition with full details
--           including location, required experience, and approval status.
CREATE TABLE JobPosting (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    Title               NVARCHAR(200)   NOT NULL,
    DepartmentId        BIGINT          NOT NULL,
    DesignationId       BIGINT          NOT NULL,
    LocationId          NVARCHAR(150)   NULL,
    EmploymentType      NVARCHAR(50)    NOT NULL DEFAULT 'FullTime',
    ExperienceMinYrs    DECIMAL(4,1)    NULL,
    ExperienceMaxYrs    DECIMAL(4,1)    NULL,
    SalaryMin           DECIMAL(14,2)   NULL,
    SalaryMax           DECIMAL(14,2)   NULL,
    CurrencyId          BIGINT          NOT NULL,
    Description         NVARCHAR(MAX)   NULL,
    Requirements        NVARCHAR(MAX)   NULL,
    OpeningsCount       INT             NOT NULL DEFAULT 1,
    JobPostingStatusId  BIGINT          NOT NULL
    PostedByEmployeeId  BIGINT          NULL,
    PostedDate          DATE            NULL,
    ClosingDate         DATE            NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_JobPosting
        PRIMARY KEY (Id),

    CONSTRAINT FK_JobPosting_Location
        FOREIGN KEY (LocationId)
        REFERENCES Location(Id),

    CONSTRAINT FK_JobPosting_Currency
        FOREIGN KEY (CurrencyId)
        REFERENCES Currency(Id),

    CONSTRAINT FK_JobPosting_JobPostingStatus
        FOREIGN KEY (JobPostingStatusId)
        REFERENCES Status(Id),    

    CONSTRAINT FK_JobPosting_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES Department(Id),

    CONSTRAINT FK_JobPosting_Designation
        FOREIGN KEY (DesignationId)
        REFERENCES Designation(Id),

    CONSTRAINT FK_JobPosting_PostedByEmployee
        FOREIGN KEY (PostedByEmployeeId)
        REFERENCES Employee(Id)
);


-- Candidate
-- Purpose : Master profile of every applicant, independent of any specific
--           job application. One candidate can apply to multiple postings.
CREATE TABLE Candidate (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    FirstName           NVARCHAR(200)   NOT NULL,
    MiddleName          NVARCHAR(200)   NOT NULL,
    LastName            NVARCHAR(200)   NOT NULL,
    Email               NVARCHAR(255)   NOT NULL,
    Phone               NVARCHAR(20)    NULL,
    DateOfBirth         DATE            NULL,
    Gender              NVARCHAR(20)    NULL,
    CurrentCompany      NVARCHAR(200)   NULL,
    CurrentTitle        NVARCHAR(200)   NULL,
    TotalExpYrs         DECIMAL(4,1)    NULL,
    NoticePeriodDays    INT             NULL,
    CurrentSalary       DECIMAL(14,2)   NULL,
    LinkedInUrl         NVARCHAR(500)   NULL,
    ResumeUrl           NVARCHAR(MAX)   NOT NULL,
    Source              NVARCHAR(100)   NULL,       -- LinkedIn | Referral | JobPortal | etc.
    ReferredByEmployeeId BIGINT         NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Candidate
        PRIMARY KEY (Id),

    CONSTRAINT UQ_Candidate_Email
        UNIQUE (Email),

    CONSTRAINT FK_Candidate_ReferredByEmployee
        FOREIGN KEY (ReferredByEmployeeId)
        REFERENCES Employee(EmployeeId)
);


-- Application
-- Purpose : Junction between Candidate and JobPosting. Tracks pipeline
--           status from applied through hired or rejected.
CREATE TABLE Application (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    JobPostingId        BIGINT          NOT NULL,
    CandidateId         BIGINT          NOT NULL,
    ApplicationStatusId  BIGINT NOT NULL, -- 'applied', 'screening', 'interview', 'offer', 'negotiation', 'hired', 'rejected', 'withdrawn'
    CoverLetter         NVARCHAR(MAX)   NULL,
    ReviewedByEmployeeId BIGINT         NULL,
    RejectionReason     NVARCHAR(MAX)   NULL,
    AppliedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
    StatusUpdatedAt     DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Application
        PRIMARY KEY (Id),

    CONSTRAINT UQ_Application_JobCandidate
        UNIQUE (JobPostingId, CandidateId),

    CONSTRAINT FK_Application_JobPosting
        FOREIGN KEY (JobPostingId)
        REFERENCES JobPosting(Id),

    CONSTRAINT FK_Application_Candidate
        FOREIGN KEY (CandidateId)
        REFERENCES Candidate(Id),

    CONSTRAINT FK_Application_ApplicationStatus
        FOREIGN KEY (ApplicationStatusId)
        REFERENCES Status(Id),     

    CONSTRAINT FK_Application_ReviewedByEmployee
        FOREIGN KEY (ReviewedByEmployeeId)
        REFERENCES Employee(Id)
);


-- ApplicationStatusHistory
-- Purpose : Immutable audit trail of every status transition an application
--           goes through, enabling full funnel analytics.
CREATE TABLE ApplicationStatusHistory (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    ApplicationId               BIGINT          NOT NULL,
    OldStatus                   NVARCHAR(50)    NULL,
    NewStatus                   NVARCHAR(50)    NOT NULL,
    ChangedByEmployeeId         BIGINT          NULL,
    Remarks                     NVARCHAR(MAX)   NULL,
    ChangedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_ApplicationStatusHistory
        PRIMARY KEY (Id),

    CONSTRAINT FK_ApplicationStatusHistory_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES Application(Id),

    CONSTRAINT FK_ApplicationStatusHistory_ChangedByEmployee
        FOREIGN KEY (ChangedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- SECTION 3 : INTERVIEW PROCESS
-- =============================================================================

-- InterviewType
-- Purpose : Master lookup of all interview format types.
--           Governs the InterviewType column across Interview and
--           InterviewRoundConfig tables.
CREATE TABLE InterviewType (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    InterviewTypeCode   NVARCHAR(50)    NOT NULL,   -- Phone | Video | InPerson | Assignment | Panel
    InterviewTypeName   NVARCHAR(150)   NOT NULL,   -- e.g. "Video Call", "In-Person", "Take-Home Assignment"
    Description         NVARCHAR(MAX)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_InterviewType
        PRIMARY KEY (Id),
 
    CONSTRAINT UQ_InterviewType_Code
        UNIQUE (InterviewTypeCode)
);

-- InterviewRound
-- Purpose : Master lookup of all possible interview round definitions.
--           Governs RoundNumber and RoundName across Interview and
--           InterviewRoundConfig tables. Each round has a fixed sequence
--           number and an associated default interview type.
CREATE TABLE InterviewRound (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    RoundNumber         INT             NOT NULL,
    RoundCode           NVARCHAR(50)    NOT NULL,   -- HR_SCREEN | TECH_1 | TECH_2 | MANAGER | CULTURE | FINAL
    RoundName           NVARCHAR(150)   NOT NULL,   -- HR Screening | Technical Round 1 | etc.
    Description         NVARCHAR(MAX)   NULL,
    DefaultInterviewTypeId BIGINT       NULL,       -- suggested default type for this round
    IsMandatory         BIT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_InterviewRound
        PRIMARY KEY (Id),
 
    CONSTRAINT UQ_InterviewRound_RoundNumber
        UNIQUE (RoundNumber),
 
    CONSTRAINT UQ_InterviewRound_Code
        UNIQUE (RoundCode),
 
    CONSTRAINT FK_InterviewRound_DefaultInterviewType
        FOREIGN KEY (DefaultInterviewTypeId)
        REFERENCES InterviewType(Id)
);

-- =============================================================================
-- UPDATED : InterviewRoundConfig
-- Purpose : Job-posting-level override of the master round definitions.
--           Replaces free-text RoundName / InterviewType with FK references
--           to the master tables above.
-- =============================================================================
 
CREATE TABLE InterviewRoundConfig (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    JobPostingId            BIGINT          NOT NULL,
    InterviewRoundId        BIGINT          NOT NULL,   -- FK → InterviewRound (carries RoundNumber + RoundName)
    InterviewTypeId         BIGINT          NOT NULL,   -- FK → InterviewType  (can override the default)
    DurationMins            INT             NOT NULL DEFAULT 60,
    IsMandatory             BIT             NOT NULL DEFAULT 1,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_InterviewRoundConfig
        PRIMARY KEY (Id),
 
    CONSTRAINT UQ_InterviewRoundConfig_JobRound
        UNIQUE (JobPostingId, InterviewRoundId),
 
    CONSTRAINT FK_InterviewRoundConfig_JobPosting
        FOREIGN KEY (JobPostingId)
        REFERENCES JobPosting(Id),
 
    CONSTRAINT FK_InterviewRoundConfig_InterviewRound
        FOREIGN KEY (InterviewRoundId)
        REFERENCES InterviewRound(Id),
 
    CONSTRAINT FK_InterviewRoundConfig_InterviewType
        FOREIGN KEY (InterviewTypeId)
        REFERENCES InterviewType(Id)
);
 
 
-- =============================================================================
-- UPDATED : Interview
-- Purpose : Replaces free-text RoundNumber / InterviewType columns with
--           FK references to master tables.
-- =============================================================================
 
CREATE TABLE Interview (
    Id                       BIGINT          NOT NULL IDENTITY(1,1),
    ApplicationId            BIGINT          NOT NULL,
    InterviewRoundConfigId   BIGINT          NOT NULL,
    ScheduledAt              DATETIME        NULL,
    DurationMins             INT             NOT NULL DEFAULT 60,
    MeetingLink              NVARCHAR(MAX)   NULL,
    Venue                    NVARCHAR(MAX)   NULL,
    InterviewStatusId        BIGINT          NOT NULL,  -- Scheduled | Completed | Cancelled | Rescheduled | NoShow
    RescheduledToInterviewId BIGINT          NULL,
    CreatedByEmployeeId      BIGINT          NULL,
    IsActive                 BIT             NOT NULL DEFAULT 1,
    CreatedAt                DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt                DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_Interview
        PRIMARY KEY (Id),
 
    CONSTRAINT FK_Interview_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES Application(Id),
 
    CONSTRAINT FK_Interview_InterviewRoundConfig
        FOREIGN KEY (InterviewRoundConfigId)
        REFERENCES InterviewRoundConfig(Id),

    CONSTRAINT FK_Interview_InterviewStatus
        FOREIGN KEY (InterviewStatusId)
        REFERENCES StatusId(Id),        
 
    CONSTRAINT FK_Interview_RescheduledToInterview
        FOREIGN KEY (RescheduledToInterviewId)
        REFERENCES Interview(Id),
 
    CONSTRAINT FK_Interview_CreatedByEmployee
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- MASTER : PanelRole
-- Purpose : Governs what capacity each interviewer sits in within a panel.
-- =============================================================================
 
CREATE TABLE PanelRole (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    RoleCode        NVARCHAR(50)    NOT NULL,
    RoleName        NVARCHAR(150)   NOT NULL,
    Description     NVARCHAR(MAX)   NULL,
    CanSubmitFeedback BIT           NOT NULL DEFAULT 1,   -- Observers may be 0
    IsActive        BIT             NOT NULL DEFAULT 1,
    DisplayOrder    INT             NOT NULL DEFAULT 0,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_PanelRole
        PRIMARY KEY (Id),
 
    CONSTRAINT UQ_PanelRole_Code
        UNIQUE (RoleCode)
);
 
-- INSERT INTO PanelRole (RoleCode, RoleName, CanSubmitFeedback, DisplayOrder) VALUES
-- ('PANEL_LEAD',       'Panel Lead',          1, 1),
-- ('INTERVIEWER',      'Interviewer',          1, 2),
-- ('TECHNICAL_EXPERT', 'Technical Expert',     1, 3),
-- ('DOMAIN_EXPERT',    'Domain Expert',        1, 4),
-- ('HR_COORDINATOR',   'HR Coordinator',       1, 5),
-- ('OBSERVER',         'Observer',             0, 6),
-- ('NOTE_TAKER',       'Note Taker',           0, 7);


-- =============================================================================
-- MASTER : InterviewPurpose
-- Purpose : Governs the evaluation area each interviewer is responsible for.
--           Multiple interviewers in the same panel each own a different purpose.
-- =============================================================================
 
CREATE TABLE InterviewPurpose (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    PurposeCode         NVARCHAR(50)    NOT NULL,
    PurposeName         NVARCHAR(150)   NOT NULL,
    Description         NVARCHAR(MAX)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_InterviewPurpose
        PRIMARY KEY (Id),
 
    CONSTRAINT UQ_InterviewPurpose_Code
        UNIQUE (PurposeCode)
);
 
-- INSERT INTO InterviewPurpose (PurposeCode, PurposeName, DisplayOrder) VALUES
-- ('TECHNICAL_DEPTH',  'Technical Depth',       1),
-- ('SYSTEM_DESIGN',    'System Design',          2),
-- ('PROBLEM_SOLVING',  'Problem Solving',        3),
-- ('DOMAIN_KNOWLEDGE', 'Domain Knowledge',       4),
-- ('CULTURE_FIT',      'Culture Fit',            5),
-- ('COMMUNICATION',    'Communication Skills',   6),
-- ('LEADERSHIP',       'Leadership & Ownership', 7),
-- ('HR_FITMENT',       'HR Fitment',             8);


-- =============================================================================
-- InterviewPanel
-- Purpose : Maps MULTIPLE interviewers to a SINGLE Interview session.
--           Each row = one interviewer seat in the panel.
--           Each seat has its own PanelRole (capacity) and InterviewPurpose
--           (evaluation area), allowing a panel like:
--
--   InterviewId 101  (Technical Round 2, Video, 90 mins)
--   ┌───────────────────────────────────────────────────────────────────┐
--   │ Seat 1 │ Ravi Kumar   │ PanelLead       │ Technical Depth        │
--   │ Seat 2 │ Sneha Iyer   │ TechnicalExpert │ System Design          │
--   │ Seat 3 │ Arjun Mehta  │ DomainExpert    │ Domain Knowledge       │
--   │ Seat 4 │ Priya Nair   │ HRCoordinator   │ HR Fitment             │
--   │ Seat 5 │ Kiran Das    │ Observer        │ Culture Fit            │
--   └───────────────────────────────────────────────────────────────────┘
-- =============================================================================
 
CREATE TABLE InterviewPanel (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    InterviewId             BIGINT          NOT NULL,
    InterviewerEmployeeId   BIGINT          NOT NULL,
    PanelRoleId             BIGINT          NOT NULL,
    InterviewPurposeId      BIGINT          NOT NULL,
    EvaluationTopics        NVARCHAR(MAX)   NULL,
    IsLead                  BIT             NOT NULL DEFAULT 0,
    CanSubmitFeedback       BIT             NOT NULL DEFAULT 1,
    ConfirmedAt             DATETIME        NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_InterviewPanel
        PRIMARY KEY (Id),
 
    CONSTRAINT UQ_InterviewPanel_InterviewInterviewer
        UNIQUE (InterviewId, InterviewerEmployeeId),
 
    CONSTRAINT UQ_InterviewPanel_InterviewPurpose
        UNIQUE (InterviewId, InterviewPurposeId),
 
    CONSTRAINT FK_InterviewPanel_Interview
        FOREIGN KEY (InterviewId)
        REFERENCES Interview(Id),
 
    CONSTRAINT FK_InterviewPanel_InterviewerEmployee
        FOREIGN KEY (InterviewerEmployeeId)
        REFERENCES Employee(Id),
 
    CONSTRAINT FK_InterviewPanel_PanelRole
        FOREIGN KEY (PanelRoleId)
        REFERENCES PanelRole(Id),
 
    CONSTRAINT FK_InterviewPanel_InterviewPurpose
        FOREIGN KEY (InterviewPurposeId)
        REFERENCES InterviewPurpose(Id)
);


-- =============================================================================
-- InterviewFeedback
-- Purpose : One feedback record per InterviewPanel seat (per interviewer per
--           session). Keyed to InterviewPanelId so feedback is automatically
--           scoped to the interviewer's assigned role and purpose.
-- =============================================================================
 
CREATE TABLE InterviewFeedback (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    InterviewPanelId        BIGINT          NOT NULL,
    OverallRating           DECIMAL(3,1)    NULL,           -- 1.0 to 10.0
    TechnicalScore          DECIMAL(3,1)    NULL,
    CommunicationScore      DECIMAL(3,1)    NULL,
    CulturalFitScore        DECIMAL(3,1)    NULL,
    PurposeSpecificScore    DECIMAL(3,1)    NULL,
    Strengths               NVARCHAR(MAX)   NULL,
    Concerns                NVARCHAR(MAX)   NULL,
    RecommendationStatusId  BIGINT          NOT NULL,  -- StrongYes | Yes | Maybe | No | StrongNo
    AdditionalNotes         NVARCHAR(MAX)   NULL,
    SubmittedAt             DATETIME        NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT PK_InterviewFeedback
        PRIMARY KEY (Id),
 
    CONSTRAINT UQ_InterviewFeedback_PanelSeat
        UNIQUE (InterviewPanelId),

    CONSTRAINT FK_InterviewPanel_RecommendationStatus
        FOREIGN KEY (RecommendationStatusId)
        REFERENCES Status(Id),
 
    CONSTRAINT FK_InterviewFeedback_InterviewPanel
        FOREIGN KEY (InterviewPanelId)
        REFERENCES InterviewPanel(Id)
);

-- =============================================================================
-- SECTION 4 : OFFER & NEGOTIATION
-- =============================================================================

-- PackageNegotiation
-- Purpose : Captures the full salary and benefits negotiation thread between
--           HR and the candidate, with each counter-offer as a new row.
CREATE TABLE PackageNegotiation (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    ApplicationId           BIGINT          NOT NULL,
    HREmployeeId            BIGINT          NOT NULL,
    RoundNumber             INT             NOT NULL DEFAULT 1,
    OfferedCTC              DECIMAL(14,2)   NOT NULL,
    CandidateAsk            DECIMAL(14,2)   NULL,
    FinalCTC                DECIMAL(14,2)   NULL,
    CurrencyId              BIGINT          NOT NULL,,
    VariablePct             DECIMAL(5,2)    NULL,
    JoiningBonus            DECIMAL(14,2)   NULL,
    OtherBenefits           NVARCHAR(MAX)   NULL,
    PackageNegotiationStatusId BIGINT          NOT NULL,  -- InProgress | Accepted | Rejected | Countered | Withdrawn
    Notes                   NVARCHAR(MAX)   NULL,
    NegotiatedAt            DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_PackageNegotiation
        PRIMARY KEY (Id),

    CONSTRAINT FK_PackageNegotiation_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES Application(Id),

    CONSTRAINT FK_PackageNegotiation_PackageNegotiationStatus
        FOREIGN KEY (PackageNegotiationStatusId)
        REFERENCES Status(Id),        

    CONSTRAINT FK_PackageNegotiation_HREmployee
        FOREIGN KEY (HREmployeeId)
        REFERENCES Employee(Id)
);


-- OfferLetter
-- Purpose : Represents the formal offer document sent to a candidate after
--           negotiation is complete. Tracks acceptance/rejection and expiry.
CREATE TABLE OfferLetter (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    ApplicationId       BIGINT          NOT NULL,
    PackageNegotiationId BIGINT         NULL,
    LetterUrl           NVARCHAR(MAX)   NOT NULL,
    IssuedDate          DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    ExpiryDate          DATE            NOT NULL,
    OfferedPosition     NVARCHAR(200)   NULL,
    JoiningDate         DATE            NULL,
    OfferLetterStatusId BIGINT          NOT NULL,
    AcceptedAt          DATETIME        NULL,
    RevokedReason       NVARCHAR(MAX)   NULL,
    IssuedByEmployeeId  BIGINT          NULL,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_OfferLetter
        PRIMARY KEY (Id),

    CONSTRAINT FK_OfferLetter_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES Application(Id),

    CONSTRAINT FK_OfferLetter_PackageNegotiation
        FOREIGN KEY (PackageNegotiationId)
        REFERENCES PackageNegotiation(Id),

    CONSTRAINT FK_OfferLetter_OfferLetterStatus
        FOREIGN KEY (OfferLetterStatus)
        REFERENCES Status(Id),    

    CONSTRAINT FK_OfferLetter_IssuedByEmployee
        FOREIGN KEY (IssuedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- SECTION 5 : ONBOARDING
-- =============================================================================

-- OnboardingChecklist
-- Purpose : Template-level checklists defining standard tasks for a given
--           phase and employment type (reusable across all new joiners).
-- | Id | ChecklistName               | Phase         | EmploymentType |
-- | -- | --------------------------- | ------------- | -------------- |
-- | 1  | Full-Time Day One Checklist | DayOne        | FullTime       |
-- | 2  | Intern Joining Checklist    | PreOnboarding | Intern         |

CREATE TABLE OnboardingChecklist (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    ChecklistName           NVARCHAR(200)   NOT NULL,
    Phase                   NVARCHAR(30)    NOT NULL,   -- PreOnboarding | DayOne | FirstWeek | PostOnboarding
    EmploymentType          NVARCHAR(50)    NOT NULL DEFAULT 'FullTime',
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_OnboardingChecklist
        PRIMARY KEY (Id)
);


-- OnboardingChecklistItem
-- Purpose : Individual task definitions within each onboarding checklist template.
-- | Id | OnboardingChecklistId | TaskName                | OwnerRole |
-- | -- | --------------------- | ----------------------- | --------- |
-- | 1  | 1                     | Create official email   | IT        |
-- | 2  | 1                     | Allocate laptop         | IT        |
-- | 3  | 1                     | Conduct HR induction    | HR        |
-- | 4  | 1                     | Submit signed documents | Employee  |

CREATE TABLE OnboardingChecklistItem (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    OnboardingChecklistId       BIGINT          NOT NULL,
    TaskName                    NVARCHAR(250)   NOT NULL,
    Description                 NVARCHAR(MAX)   NULL,
    OwnerRole                   NVARCHAR(50)    NULL,   -- HR | Manager | Employee | IT
    SequenceOrder               INT             NOT NULL DEFAULT 0,
    IsMandatory                 BIT             NOT NULL DEFAULT 1,

    CONSTRAINT PK_OnboardingChecklistItem
        PRIMARY KEY (Id),

    CONSTRAINT FK_OnboardingChecklistItem_OnboardingChecklist
        FOREIGN KEY (OnboardingChecklistId)
        REFERENCES OnboardingChecklist(Id)
);


-- OnboardingTask
-- Purpose : Employee-specific onboarding task instances generated from a
--           checklist template. Tracks completion per employee per task.
-- | EmployeeId | TaskName        | Status  |
-- | ---------- | --------------- | ------- |
-- | 101        | Allocate laptop | Pending |

CREATE TABLE OnboardingTask (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL,
    OnboardingChecklistItemId   BIGINT          NULL,
    TaskName                    NVARCHAR(250)   NOT NULL,
    Phase                       NVARCHAR(30)    NOT NULL,
    OwnerRole                   NVARCHAR(50)    NULL,
    OnboardingTaskStatusId      BIGINT          NOT NULL,
    DueDate                     DATE            NULL,
    CompletedDate               DATE            NULL,
    CompletedByEmployeeId       BIGINT          NULL,
    Remarks                     NVARCHAR(MAX)   NULL,
    CreatedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_OnboardingTask
        PRIMARY KEY (Id),

    CONSTRAINT FK_OnboardingTask_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_OnboardingTask_OnboardingChecklistItem
        FOREIGN KEY (OnboardingChecklistItemId)
        REFERENCES OnboardingChecklistItem(Id),

    CONSTRAINT FK_OnboardingTask_OnboardingTaskStatus
        FOREIGN KEY (OnboardingTaskStatusId)
        REFERENCES Status(Id),        

    CONSTRAINT FK_OnboardingTask_CompletedByEmployee
        FOREIGN KEY (CompletedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- SECTION 6 : DOCUMENT VERIFICATION
-- =============================================================================

-- DocumentType
-- Purpose : Master catalog of accepted document types with rules on which
--           phase they are required in (PreOnboarding, PostOnboarding, or Both).
CREATE TABLE DocumentType (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    DocumentTypeName    NVARCHAR(150)   NOT NULL,   -- Aadhaar | PAN | Degree Certificate | etc.
    Category            NVARCHAR(100)   NULL,       -- Identity | Address | Educational | Experience
    IsMandatory         BIT             NOT NULL DEFAULT 1,
    Description         NVARCHAR(MAX)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,

    CONSTRAINT PK_DocumentType
        PRIMARY KEY (Id),

    CONSTRAINT UQ_DocumentType_Name
        UNIQUE (DocumentTypeName)
);


-- DocumentVerification
-- Purpose : Tracks every document submitted by an employee and its verification
--           status across both pre- and post-onboarding phases.
CREATE TABLE DocumentVerification (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    DocumentTypeId          BIGINT          NOT NULL,
    OnboardingPhaseStatusId BIGINT          NOT NULL,   -- PreOnboarding | PostOnboarding
    FileUrl                 NVARCHAR(MAX)   NULL,
    DocumentNumber          NVARCHAR(100)   NULL,
    IssuedBy                NVARCHAR(200)   NULL,
    IssueDate               DATE            NULL,
    ExpiryDate              DATE            NULL,
    DocumentVerificationStatusId BIGINT          NOT NULL,
    SubmittedDate           DATE            NULL,
    VerifiedDate            DATE            NULL,
    VerifiedByEmployeeId    BIGINT          NULL,
    RejectionReason         NVARCHAR(MAX)   NULL,
    Remarks                 NVARCHAR(MAX)   NULL,
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_DocumentVerification
        PRIMARY KEY (Id),

    CONSTRAINT FK_DocumentVerification_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_DocumentVerification_DocumentType
        FOREIGN KEY (DocumentTypeId)
        REFERENCES DocumentType(Id),

    CONSTRAINT FK_DocumentVerification_OnboardingPhaseStatus
        FOREIGN KEY (OnboardingPhaseStatusId)
        REFERENCES Status(Id),          

    CONSTRAINT FK_DocumentVerification_DocumentVerificationStatusId
        FOREIGN KEY (DocumentVerificationStatusId)
        REFERENCES Status(Id),        

    CONSTRAINT FK_DocumentVerification_VerifiedByEmployee
        FOREIGN KEY (VerifiedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- SECTION 7 : BACKGROUND VERIFICATION
-- =============================================================================

-- BGVAgency
-- Purpose : Master list of third-party background verification agencies
--           used by the organisation.
CREATE TABLE BGVAgency (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    AgencyName      NVARCHAR(200)   NOT NULL,
    ContactPerson   NVARCHAR(200)   NULL,
    Email           NVARCHAR(255)   NULL,
    Phone           NVARCHAR(20)    NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_BGVAgency
        PRIMARY KEY (Id)
);


-- BackgroundVerification
-- Purpose : Tracks each type of background check (criminal, employment history,
--           education, reference) per employee across pre- and post-onboarding.
CREATE TABLE BackgroundVerification (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL,
    BGVAgencyId                 BIGINT          NULL,
    BGVCheckTypeStatusId        BIGINT          NOT NULL,  -- Criminal | EmploymentHistory | Education | Identity | Credit | Reference | DrugTest | Address
    OnboardingPhaseStatusId     BIGINT          NOT NULL,   -- PreOnboarding | PostOnboarding
    ReferenceName               NVARCHAR(200)   NULL,
    ReferenceContact            NVARCHAR(200)   NULL,
    InitiatedByEmployeeId       BIGINT          NULL,
    InitiatedDate               DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    ExpectedDate                DATE            NULL,
    CompletedDate               DATE            NULL,
    BackgroundVerificationStatusId BIGINT          NOT NULL,   -- Pending | InProgress | Completed | DiscrepancyFound | Failed | Waived
    BGVResultStatusId           BIGINT          NOT NULL,       -- Clear | Discrepancy | UnableToVerify | Failed
    Findings                    NVARCHAR(MAX)   NULL,
    ReportUrl                   NVARCHAR(MAX)   NULL,
    CreatedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_BackgroundVerification
        PRIMARY KEY (Id),

    CONSTRAINT FK_BackgroundVerification_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_BackgroundVerification_BGVAgency
        FOREIGN KEY (BGVAgencyId)
        REFERENCES BGVAgency(Id),

    CONSTRAINT FK_DocumentVerification_BGVCheckTypeStatus
        FOREIGN KEY (BGVCheckTypeStatusId)
        REFERENCES Status(Id),         

    CONSTRAINT FK_DocumentVerification_OnboardingPhaseStatus
        FOREIGN KEY (OnboardingPhaseStatusId)
        REFERENCES Status(Id),  

    CONSTRAINT FK_DocumentVerification_BGVResultStatus
        FOREIGN KEY (BGVResultStatusId)
        REFERENCES Status(Id), 

    CONSTRAINT FK_BackgroundVerification_BackgroundVerificationStatus
        FOREIGN KEY (BackgroundVerificationStatusId)
        REFERENCES Status(Id),        

    CONSTRAINT FK_BackgroundVerification_InitiatedByEmployee
        FOREIGN KEY (InitiatedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- SECTION 8 : PERFORMANCE MANAGEMENT
-- =============================================================================

-- PerformanceCycle
-- Purpose : Defines appraisal periods (annual, bi-annual, quarterly) during
--           which goal setting and performance reviews are conducted.
CREATE TABLE PerformanceCycle (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    CycleName               NVARCHAR(150)   NOT NULL,
    PerformanceCycleTypeStatusId BIGINT          NOT NULL,  -- Annual | BiAnnual | Quarterly | Probation
    StartDate               DATE            NOT NULL,
    EndDate                 DATE            NOT NULL,
    GoalSettingDeadline     DATE            NULL,
    ReviewStartDate         DATE            NULL,
    ReviewEndDate           DATE            NULL,
    PerformanceCycleStatusId BIGINT          NOT NULL,  -- Upcoming | GoalSetting | InReview | Completed | Archived
    CreatedByEmployeeId     BIGINT          NULL,
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_PerformanceCycle
        PRIMARY KEY (Id),

    CONSTRAINT UQ_PerformanceCycle_Name
        UNIQUE (CycleName),

    CONSTRAINT FK_PerformanceCycle_PerformanceCycleTypeStatus
        FOREIGN KEY (PerformanceCycleTypeStatusId)
        REFERENCES Status(Id), 

    CONSTRAINT FK_PerformanceCycle_Status
        FOREIGN KEY (PerformanceCycleStatusId)
        REFERENCES Status(Id),  

    CONSTRAINT FK_PerformanceCycle_CreatedByEmployee
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES Employee(Id)
);


-- Goal
-- Purpose : Individual goals set by an employee for a given performance cycle.
CREATE TABLE Goal (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    PerformanceCycleId      BIGINT          NOT NULL,
    Title                   NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    Category                NVARCHAR(100)   NULL,       -- Business | Learning | Behavioural
    WeightagePct            DECIMAL(5,2)    NOT NULL DEFAULT 0,
    TargetDate              DATE            NULL,
    GoalStatusId            BIGINT          NOT NULL,  -- Draft | Submitted | Approved | InProgress | Completed | Cancelled
    ProgressPct             INT             NOT NULL DEFAULT 0,
    EmployeeRating          DECIMAL(3,1)    NULL,
    ManagerRating           DECIMAL(3,1)    NULL,
    ApprovedByEmployeeId    BIGINT          NULL,
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Goal
        PRIMARY KEY (Id),

    CONSTRAINT FK_Goal_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_Goal_PerformanceCycle
        FOREIGN KEY (PerformanceCycleId)
        REFERENCES PerformanceCycle(Id),

    CONSTRAINT FK_Goal_StatusId
        FOREIGN KEY (GoalStatusId)
        REFERENCES Status(Id),        

    CONSTRAINT FK_Goal_ApprovedByEmployee
        FOREIGN KEY (ApprovedByEmployeeId)
        REFERENCES Employee(Id)
);


-- GoalKeyResult
-- Purpose : Measurable key results or milestones under each goal (OKR support).
CREATE TABLE GoalKeyResult (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    GoalId          BIGINT          NOT NULL,
    Description     NVARCHAR(MAX)   NOT NULL,
    TargetValue     NVARCHAR(200)   NULL,
    ActualValue     NVARCHAR(200)   NULL,
    GoalKeyResultStatusId BIGINT          NOT NULL,  -- Pending | OnTrack | AtRisk | Achieved | NotAchieved

    CONSTRAINT PK_GoalKeyResult
        PRIMARY KEY (Id),

    CONSTRAINT FK_GoalKeyResult_GoalKeyResultStatusId
        FOREIGN KEY (GoalKeyResultStatusId)
        REFERENCES Status(Id),        

    CONSTRAINT FK_GoalKeyResult_Goal
        FOREIGN KEY (GoalId)
        REFERENCES Goal(Id)
);


-- PerformanceReview
-- Purpose : Formal review record for each employee in a cycle, capturing
--           self-assessment and manager evaluation with final rating.
CREATE TABLE PerformanceReview (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    PerformanceCycleId      BIGINT          NOT NULL,
    ReviewerEmployeeId      BIGINT          NOT NULL,
    SelfRating              DECIMAL(3,1)    NULL,
    ManagerRating           DECIMAL(3,1)    NULL,
    FinalRating             DECIMAL(3,1)    NULL,
    PerformanceBand         NVARCHAR(50)    NULL,       -- Exceeds | Meets | Below | Critical
    SelfComments            NVARCHAR(MAX)   NULL,
    ManagerComments         NVARCHAR(MAX)   NULL,
    HRBPComments            NVARCHAR(MAX)   NULL,
    PerformanceReviewStatusId   BIGINT          NOT NULL,  -- Pending | SelfSubmitted | ManagerReview | HRBPReview | Completed | Acknowledged
    SelfSubmittedAt         DATETIME        NULL,
    ManagerSubmittedAt      DATETIME        NULL,
    CompletedAt             DATETIME        NULL,

    CONSTRAINT PK_PerformanceReview
        PRIMARY KEY (Id),

    CONSTRAINT UQ_PerformanceReview_EmployeeCycle
        UNIQUE (EmployeeId, PerformanceCycleId),

    CONSTRAINT FK_PerformanceReview_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_PerformanceReview_PerformanceReviewStatus
        FOREIGN KEY (PerformanceReviewStatusId)
        REFERENCES Status(Id),    

    CONSTRAINT FK_PerformanceReview_PerformanceCycle
        FOREIGN KEY (PerformanceCycleId)
        REFERENCES PerformanceCycle(Id),

    CONSTRAINT FK_PerformanceReview_ReviewerEmployee
        FOREIGN KEY (ReviewerEmployeeId)
        REFERENCES Employee(Id)
);


-- PerformanceReviewHistory
-- Purpose : Tracks every status change in a review for audit and escalation.
CREATE TABLE PerformanceReviewHistory (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    PerformanceReviewId         BIGINT          NOT NULL,
    OldStatus                   NVARCHAR(30)    NULL,
    NewStatus                   NVARCHAR(30)    NOT NULL,
    ChangedByEmployeeId         BIGINT          NULL,
    Remarks                     NVARCHAR(MAX)   NULL,
    ChangedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_PerformanceReviewHistory
        PRIMARY KEY (Id),

    CONSTRAINT FK_PerformanceReviewHistory_PerformanceReview
        FOREIGN KEY (PerformanceReviewId)
        REFERENCES PerformanceReview(Id),

    CONSTRAINT FK_PerformanceReviewHistory_ChangedByEmployee
        FOREIGN KEY (ChangedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- SECTION 9 : TRAINING
-- =============================================================================

-- TrainingCategory
-- Purpose : Top-level grouping of all training programs
--           (e.g. Technical, Compliance, Leadership, Soft Skills).
CREATE TABLE TrainingCategory (
    Id                  BIGINT          NOT NULL IDENTITY(1,1),
    CategoryName        NVARCHAR(150)   NOT NULL,
    Description         NVARCHAR(MAX)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_TrainingCategory
        PRIMARY KEY (Id),

    CONSTRAINT UQ_TrainingCategory_Name
        UNIQUE (CategoryName)
);


-- TrainingProgram
-- Purpose : Individual courses or training modules within a category.
--           Tracks delivery mode, duration, and whether it is mandatory.
CREATE TABLE TrainingProgram (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    TrainingCategoryId      BIGINT          NOT NULL,
    Title                   NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    TrainingProgramModeStatusId BIGINT          NOT NULL,  -- Online | Offline | Hybrid | SelfPaced
    DurationHours           DECIMAL(6,2)    NULL,
    Provider                NVARCHAR(200)   NULL,
    IsMandatory             BIT             NOT NULL DEFAULT 0,
    ApplicableTo            NVARCHAR(100)   NULL,   -- All | NewJoiner | DepartmentName
    MaxParticipants         INT             NULL,
    CertificateProvided     BIT             NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_TrainingProgram
        PRIMARY KEY (Id),

    CONSTRAINT FK_TrainingProgram_TrainingCategory
        FOREIGN KEY (TrainingCategoryId)
        REFERENCES TrainingCategory(Id)
);


-- TrainingBatch
-- Purpose : Scheduled batch/cohort of a training program with dates,
--           venue/link, and facilitator information.
CREATE TABLE TrainingBatch (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    TrainingProgramId       BIGINT          NOT NULL,
    BatchName               NVARCHAR(200)   NULL,
    FacilitatorEmployeeId   BIGINT          NULL,
    StartDate               DATE            NOT NULL,
    EndDate                 DATE            NULL,
    VenueOrLink             NVARCHAR(MAX)   NULL,
    MaxSeats                INT             NULL,
    TrainingBatchStatusId   BIGINT          NOT NULL,  -- Upcoming | Ongoing | Completed | Cancelled
    CreatedAt               DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_TrainingBatch
        PRIMARY KEY (Id),

    CONSTRAINT FK_TrainingBatch_TrainingProgram
        FOREIGN KEY (TrainingProgramId)
        REFERENCES TrainingProgram(Id),

    CONSTRAINT FK_TrainingBatch_TrainingBatchStatus
        FOREIGN KEY (TrainingBatchStatusId)
        REFERENCES Status(Id),

    CONSTRAINT FK_TrainingBatch_FacilitatorEmployee
        FOREIGN KEY (FacilitatorEmployeeId)
        REFERENCES Employee(Id)
);


-- EmployeeTrainingRecord
-- Purpose : Tracks each employee's enrollment and completion status for
--           every training program/batch they participate in.
CREATE TABLE EmployeeTrainingRecord (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL,
    TrainingProgramId           BIGINT          NOT NULL,
    TrainingBatchId             BIGINT          NULL,
    EnrolledDate                DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CompletedDate               DATE            NULL,
    EmployeeTrainingRecordStatusId   BIGINT          NOT NULL,  -- Enrolled | InProgress | Completed | Failed | Dropped | Absent
    Score                       DECIMAL(5,2)    NULL,
    PassingScore                DECIMAL(5,2)    NULL,
    IsPassed                    AS (CASE WHEN Score IS NOT NULL AND PassingScore IS NOT NULL
                                         AND Score >= PassingScore THEN 1 ELSE 0 END) PERSISTED,
    CertificateUrl              NVARCHAR(MAX)   NULL,
    CertificateIssuedDate       DATE            NULL,
    Feedback                    NVARCHAR(MAX)   NULL,
    CreatedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_EmployeeTrainingRecord
        PRIMARY KEY (Id),

    CONSTRAINT FK_EmployeeTrainingRecord_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_EmployeeTrainingRecord_TrainingProgram
        FOREIGN KEY (TrainingProgramId)
        REFERENCES TrainingProgram(Id),

    CONSTRAINT FK_EmployeeTrainingRecord_EmployeeTrainingRecordStatus
        FOREIGN KEY (EmployeeTrainingRecordStatusId)
        REFERENCES Status(Id),

    CONSTRAINT FK_EmployeeTrainingRecord_TrainingBatch
        FOREIGN KEY (TrainingBatchId)
        REFERENCES TrainingBatch(Id)
);


-- =============================================================================
-- SECTION 10 : EXIT MANAGEMENT
-- =============================================================================

-- ExitReason
-- Purpose : Master lookup of standardised exit reason categories to ensure
--           consistent reporting across voluntary and involuntary departures.
CREATE TABLE ExitReason (
    Id              BIGINT          NOT NULL IDENTITY(1,1),
    ReasonText      NVARCHAR(200)   NOT NULL,    -- Better Opportunity | Personal | Relocation | etc.
    Category        NVARCHAR(50)    NOT NULL,    -- Voluntary | Involuntary
    IsActive        BIT             NOT NULL DEFAULT 1,

    CONSTRAINT PK_ExitReason
        PRIMARY KEY (Id),

    CONSTRAINT UQ_ExitReason_ReasonText
        UNIQUE (ReasonText)
);


-- ExitRecord
-- Purpose : Captures everything about an employee's departure — reason, dates,
--           exit interview outcome, clearance, and final settlement status.
CREATE TABLE ExitRecord (
    Id                          BIGINT          NOT NULL IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL,
    ExitReasonId                BIGINT          NULL,
    ExitTypeStatusId            BIGINT          NOT NULL,  -- Resignation | Termination | Retirement | ContractEnd | Absconding
    AdditionalReason            NVARCHAR(30)    NULL,
    ResignationDate             DATE            NULL,
    LastWorkingDate             DATE            NULL,
    NoticePeriodDays            INT             NULL,
    IsNoticeWaived              BIT             NOT NULL DEFAULT 0,
    ExitInterviewStatusId       BIGINT          NOT NULL,  -- Pending | Scheduled | Completed | Skipped
    ExitInterviewDate           DATE            NULL,
    ConductedByEmployeeId       BIGINT          NULL,
    ExitFeedback                NVARCHAR(MAX)   NULL,
    IsRehireEligible            BIT             NOT NULL DEFAULT 1,
    ClearanceStatusId           BIGINT          NOT NULL,  -- Pending | InProgress | Completed
    FinalSettlementStatusId     BIGINT          NOT NULL,  -- Pending | Processed | Paid
    FinalSettlementDate         DATE            NULL,
    CreatedByEmployeeId         BIGINT          NULL,
    CreatedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedAt                   DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_ExitRecord
        PRIMARY KEY (Id),

    CONSTRAINT UQ_ExitRecord_Employee
        UNIQUE (EmployeeId),

    CONSTRAINT FK_ExitRecord_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_ExitRecord_ExitReason
        FOREIGN KEY (ExitReasonId)
        REFERENCES ExitReason(Id),

    CONSTRAINT FK_ExitRecord_ExitTypeStatus
        FOREIGN KEY (ExitTypeStatusId)
        REFERENCES Status(Id),

    CONSTRAINT FK_ExitRecord_ExitInterviewStatus
        FOREIGN KEY (ExitInterviewStatusId)
        REFERENCES Status(Id),

    CONSTRAINT FK_ExitRecord_ClearanceStatusId
        FOREIGN KEY (ClearanceStatusId)
        REFERENCES Status(Id),

    CONSTRAINT FK_ExitRecord_FinalSettlementStatusId
        FOREIGN KEY (FinalSettlementStatusId)
        REFERENCES Status(Id),

    CONSTRAINT FK_ExitRecord_ConductedByEmployee
        FOREIGN KEY (ConductedByEmployeeId)
        REFERENCES Employee(Id),

    CONSTRAINT FK_ExitRecord_CreatedByEmployee
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES Employee(Id)
);


-- ExitClearanceItem
-- Purpose : Per-employee checklist of clearance tasks (asset return, access
--           revocation, knowledge transfer) tracked against each exit record.
CREATE TABLE ExitClearanceItem (
    Id                      BIGINT          NOT NULL IDENTITY(1,1),
    ExitRecordId            BIGINT          NOT NULL,
    ItemName                NVARCHAR(200)   NOT NULL,   -- Laptop Returned | ID Card Collected | etc.
    OwnerDepartment         NVARCHAR(100)   NULL,
    ExitClearanceItemStatusId BIGINT          NOT NULL,  -- Pending | Completed | Waived
    CompletedByEmployeeId   BIGINT          NULL,
    CompletedAt             DATETIME        NULL,
    Remarks                 NVARCHAR(MAX)   NULL,

    CONSTRAINT PK_ExitClearanceItem
        PRIMARY KEY (Id),

    CONSTRAINT FK_ExitClearanceItem_ExitRecord
        FOREIGN KEY (ExitRecordId)
        REFERENCES ExitRecord(Id),

    CONSTRAINT FK_ExitClearanceItem_ExitClearanceItemStatus
        FOREIGN KEY (ExitClearanceItemStatusId)
        REFERENCES Status(Id),

    CONSTRAINT FK_ExitClearanceItem_CompletedByEmployee
        FOREIGN KEY (CompletedByEmployeeId)
        REFERENCES Employee(Id)
);


-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX IX_Application_CandidateId         ON Application(CandidateId);
CREATE INDEX IX_Application_JobPostingId        ON Application(JobPostingId);
CREATE INDEX IX_Application_Status              ON Application(Status);
CREATE INDEX IX_Interview_ApplicationId         ON Interview(ApplicationId);
CREATE INDEX IX_InterviewFeedback_InterviewId   ON InterviewFeedback(InterviewId);
CREATE INDEX IX_Employee_DepartmentId           ON Employee(DepartmentId);
CREATE INDEX IX_Employee_ManagerId              ON Employee(ManagerId);
CREATE INDEX IX_Employee_EmploymentStatus       ON Employee(EmploymentStatus);
CREATE INDEX IX_DocVerification_EmployeePhase   ON DocumentVerification(EmployeeId, Phase);
CREATE INDEX IX_BGV_EmployeePhase               ON BackgroundVerification(EmployeeId, Phase);
CREATE INDEX IX_Goal_EmployeeCycle              ON Goal(EmployeeId, PerformanceCycleId);
CREATE INDEX IX_PerformanceReview_EmployeeCycle ON PerformanceReview(EmployeeId, PerformanceCycleId);
CREATE INDEX IX_EmpTrainingRecord_EmployeeId    ON EmployeeTrainingRecord(EmployeeId);
CREATE INDEX IX_EmpTrainingRecord_ProgramId     ON EmployeeTrainingRecord(TrainingProgramId);
CREATE INDEX IX_ExitRecord_EmployeeId           ON ExitRecord(EmployeeId);
CREATE INDEX IX_AuditLog_TableRecord            ON AuditLog(TableName, RecordId);
 
CREATE INDEX IX_InterviewPanel_InterviewId            ON InterviewPanel(InterviewId);
CREATE INDEX IX_InterviewPanel_InterviewerEmployeeId  ON InterviewPanel(InterviewerEmployeeId);
CREATE INDEX IX_InterviewPanel_PanelRoleId            ON InterviewPanel(PanelRoleId);
CREATE INDEX IX_InterviewPanel_InterviewPurposeId     ON InterviewPanel(InterviewPurposeId);
CREATE INDEX IX_InterviewFeedback_InterviewPanelId    ON InterviewFeedback(InterviewPanelId);

-- =============================================================================
-- END OF SCHEMA
-- =============================================================================