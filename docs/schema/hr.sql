-- =============================================================================================================
-- ENTERPRISE HRMS — HR MODULES EXTENSION
-- SQL SERVER DATABASE SCHEMA
-- Schema: hr
-- Compatible: SQL Server 2016+
-- =============================================================================================================
-- PURPOSE:
--   Extends the core HRMS platform (dbo), payroll, and workflow schemas with dedicated HR lifecycle
--   modules covering the complete employee journey from onboarding through exit, plus supporting
--   modules for policy documents, salary slips, performance reviews, and training records.
--
-- DESIGN PRINCIPLES:
--   - All tables reside in the [hr] schema to isolate HR lifecycle concerns from core HRMS (dbo),
--     payroll, and workflow schemas.
--   - dbo.StatusLookup is reused as the single cross-schema master for ALL workflow status codes.
--     Status columns carry a persisted computed group column enabling composite FK domain isolation.
--   - Foreign keys reference dbo.Employee, dbo.Department, dbo.Designation, dbo.OfficeLocation,
--     dbo.LegalEntity, and payroll.PayrollDisbursementTransaction wherever normalization applies.
--   - hr.SalarySlipPublication is intentionally thin: it records only the PDF artefact lifecycle
--     (FileUrl, SlipStatus, download timestamps). All financial figures (gross, deductions, net,
--     currency, month, year, component breakdown) are owned by payroll.PayrollDisbursementTransaction
--     and payroll.EmployeeSalaryComponent — no duplication.
--   - The workflow schema (workflow.WorkflowInstance) is used for approval routing on onboarding
--     tasks, policy acknowledgements, performance reviews, and exit clearances — no inline approval
--     logic is hardcoded in this schema.
--   - Computed columns are used for derived figures (IsPassed, RemainingNoticeDays).
--   - Audit columns (CreatedAt, UpdatedAt) on every table for change tracking.
--   - Soft-delete via IsActive rather than physical DELETE to preserve audit trails.
--
-- STATUS GROUPS SEEDED INTO dbo.StatusLookup FOR THIS SCHEMA:
--   ONBOARDING_TASK_STATUS   -> PENDING | IN_PROGRESS | COMPLETED | WAIVED
--   DOC_VERIFY_STATUS        -> PENDING | SUBMITTED | UNDER_REVIEW | VERIFIED | REJECTED | RESUBMITTED | EXPIRED | WAIVED
--   BGV_STATUS               -> PENDING | IN_PROGRESS | COMPLETED | DISCREPANCY_FOUND | FAILED | WAIVED
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
--
-- TABLE CREATION ORDER (respects FK dependencies):
--   MODULE A — RECRUITMENT & SELECTION
--     A1.  hr.InterviewType
--     A2.  hr.InterviewRound
--     A3.  hr.PanelRole
--     A4.  hr.InterviewPurpose
--     A5.  hr.JobPosting
--     A6.  hr.Candidate
--     A7.  hr.Application
--     A8.  hr.ApplicationStatusHistory
--     A9.  hr.InterviewRoundConfig
--     A10. hr.Interview
--     A11. hr.InterviewPanel
--     A12. hr.InterviewFeedback
--     A13. hr.PackageNegotiation
--     A14. hr.OfferLetter
--
--   MODULE B — ONBOARDING
--     B1.  hr.OnboardingChecklist
--     B2.  hr.OnboardingChecklistItem
--     B3.  hr.OnboardingTask
--     B4.  dbo.DocumentType
--     B5.  hr.DocumentVerification
--     B6.  hr.BGVAgency
--     B7.  hr.BackgroundVerification
--
--   MODULE C — POLICY DOCUMENTS
--     C1.  hr.PolicyCategory
--     C2.  hr.PolicyDocument
--     C3.  hr.PolicyVersion
--     C4.  hr.PolicyAcknowledgement
--
--   MODULE D — SALARY SLIPS
--     D1.  hr.SalarySlipPublication
--           (links to payroll.PayrollDisbursementTransaction; no duplicate component table)
--
--   MODULE E — PERFORMANCE REVIEWS
--     E1.  hr.PerformanceCycle
--     E2.  hr.Goal
--     E3.  hr.GoalKeyResult
--     E4.  hr.PerformanceReview
--     E5.  hr.PerformanceReviewHistory
--
--   MODULE F — TRAINING RECORDS
--     F1.  hr.TrainingCategory
--     F2.  hr.TrainingProgram
--     F3.  hr.TrainingBatch
--     F4.  hr.EmployeeTrainingRecord
--
--   MODULE G — EXIT MANAGEMENT
--     G1.  hr.ExitReason
--     G2.  hr.ExitRecord
--     G3.  hr.ExitClearanceItem
--
--   INDEXES
-- =============================================================================================================


-- =============================================================================================================
-- SCHEMA CREATION
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'hr')
    EXEC('CREATE SCHEMA hr');
GO


-- =============================================================================================================
-- MODULE A: RECRUITMENT & SELECTION
-- Manages the full hiring pipeline from job requisition through offer acceptance.
-- =============================================================================================================


-- -------------------------------------------------------
-- INTERVIEW TYPE
-- Master lookup for interview delivery formats.
-- e.g. Phone Screen, Video Call, In-Person, Take-Home Assignment, Panel.
-- Decouples format from round definition so the same round
-- can be delivered in different modes per job posting.
-- -------------------------------------------------------
CREATE TABLE hr.InterviewType (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    InterviewTypeCode   NVARCHAR(50)    NOT NULL UNIQUE,
    InterviewTypeName   NVARCHAR(150)   NOT NULL,
    Description         NVARCHAR(1000)  NULL,
    DisplayOrder        TINYINT         NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- INTERVIEW ROUND
-- Master sequence of named interview rounds used across
-- all job postings (e.g. HR Screen, Technical Round 1,
-- Manager, Culture Fit, Final).
-- RoundNumber enforces a canonical ordering; individual
-- job postings can override or skip rounds via
-- hr.InterviewRoundConfig.
-- DefaultInterviewTypeId: suggested format for this round
-- (overrideable at job-posting level).
-- -------------------------------------------------------
CREATE TABLE hr.InterviewRound (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    RoundNumber             INT             NOT NULL UNIQUE,
    RoundCode               NVARCHAR(50)    NOT NULL UNIQUE,
    RoundName               NVARCHAR(150)   NOT NULL,
    Description             NVARCHAR(1000)  NULL,
    DefaultInterviewTypeId  BIGINT          NULL,
    IsMandatory             BIT             NOT NULL DEFAULT 1,
    DisplayOrder            TINYINT         NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_InterviewRound_DefaultType
        FOREIGN KEY (DefaultInterviewTypeId)
        REFERENCES hr.InterviewType(Id)
);


-- -------------------------------------------------------
-- PANEL ROLE
-- Defines the capacity in which each panelist participates
-- in an interview (e.g. Panel Lead, Interviewer, Observer).
-- CanSubmitFeedback = 0 for observer/note-taker roles
-- so the application layer suppresses the feedback form.
-- -------------------------------------------------------
CREATE TABLE hr.PanelRole (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    RoleCode            NVARCHAR(50)    NOT NULL UNIQUE,
    RoleName            NVARCHAR(150)   NOT NULL,
    Description         NVARCHAR(1000)  NULL,
    CanSubmitFeedback   BIT             NOT NULL DEFAULT 1,
    DisplayOrder        TINYINT         NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- INTERVIEW PURPOSE
-- Defines the evaluation area each panelist is assigned to
-- within a session (e.g. Technical Depth, System Design,
-- Culture Fit, HR Fitment).
-- Enables structured, purpose-driven feedback collection
-- rather than free-form overall assessments.
-- -------------------------------------------------------
CREATE TABLE hr.InterviewPurpose (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    PurposeCode     NVARCHAR(50)    NOT NULL UNIQUE,
    PurposeName     NVARCHAR(150)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    DisplayOrder    TINYINT         NOT NULL DEFAULT 0,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- JOB POSTING
-- Tracks every open or closed job requisition with full
-- details including location, experience band, salary range,
-- and lifecycle status.
-- References dbo.Department, dbo.Designation, and
-- dbo.OfficeLocation for consistent master-data reuse.
-- JobPostingStatus references dbo.StatusLookup (JOB_POSTING_STATUS).
-- -------------------------------------------------------
CREATE TABLE hr.JobPosting (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    Title               NVARCHAR(200)   NOT NULL,
    DepartmentId        BIGINT          NOT NULL,
    DesignationId       BIGINT          NOT NULL,
    LocationId          BIGINT          NULL,
    LegalEntityId       BIGINT          NULL,
    EmploymentType      NVARCHAR(50)    NOT NULL DEFAULT 'FULL_TIME',
    EmploymentTypeGroup AS CAST('EMPLOYMENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    ExperienceMinYrs    DECIMAL(4,1)    NULL,
    ExperienceMaxYrs    DECIMAL(4,1)    NULL,
    SalaryMin           DECIMAL(18,2)   NULL,
    SalaryMax           DECIMAL(18,2)   NULL,
    CurrencyCode        NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    Description         NVARCHAR(MAX)   NULL,
    Requirements        NVARCHAR(MAX)   NULL,
    OpeningsCount       INT             NOT NULL DEFAULT 1,
    JobPostingStatus    NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    JobPostingStatusGroup AS CAST('JOB_POSTING_STATUS' AS NVARCHAR(50)) PERSISTED,
    PostedByEmployeeId  BIGINT          NULL,
    PostedDate          DATE            NULL,
    ClosingDate         DATE            NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_JobPosting_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES dbo.Department(Id),

    CONSTRAINT FK_JobPosting_Designation
        FOREIGN KEY (DesignationId)
        REFERENCES dbo.Designation(Id),

    CONSTRAINT FK_JobPosting_Location
        FOREIGN KEY (LocationId)
        REFERENCES dbo.OfficeLocation(Id),

    CONSTRAINT FK_JobPosting_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES dbo.LegalEntity(Id),

    CONSTRAINT FK_JobPosting_PostedBy
        FOREIGN KEY (PostedByEmployeeId)
        REFERENCES dbo.Employee(Id),
    
    CONSTRAINT FK_Employee_EmploymentType
        FOREIGN KEY (EmploymentType, EmploymentTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_JobPosting_Status
        FOREIGN KEY (JobPostingStatus, JobPostingStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- CANDIDATE
-- Master profile of every applicant, independent of any
-- specific job application. One candidate can apply to
-- multiple postings. Stores resume URL, current employment
-- details, notice period, and referral linkage.
-- -------------------------------------------------------
CREATE TABLE hr.Candidate (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    FirstName               NVARCHAR(100)   NOT NULL,
    MiddleName              NVARCHAR(100)   NULL,
    LastName                NVARCHAR(100)   NOT NULL,
    Email                   NVARCHAR(255)   NOT NULL UNIQUE,
    Phone                   NVARCHAR(30)    NULL,
    DateOfBirth             DATE            NULL,
    Gender                  NVARCHAR(20)    NULL,
    CurrentCompany          NVARCHAR(200)   NULL,
    CurrentTitle            NVARCHAR(200)   NULL,
    TotalExpYrs             DECIMAL(4,1)    NULL,
    NoticePeriodDays        INT             NULL,
    CurrentSalary           DECIMAL(18,2)   NULL,
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    LinkedInUrl             NVARCHAR(500)   NULL,
    ResumeUrl               NVARCHAR(1000)  NULL,
    Source                  NVARCHAR(100)   NULL,
    ReferredByEmployeeId    BIGINT          NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_Candidate_ReferredBy
        FOREIGN KEY (ReferredByEmployeeId)
        REFERENCES dbo.Employee(Id)
);


-- -------------------------------------------------------
-- APPLICATION
-- Junction between Candidate and JobPosting. Tracks the
-- full pipeline status from applied through hired or rejected.
-- ApplicationStatus references dbo.StatusLookup (APPLICATION_STATUS).
-- -------------------------------------------------------
CREATE TABLE hr.Application (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    JobPostingId            BIGINT          NOT NULL,
    CandidateId             BIGINT          NOT NULL,
    ApplicationStatus       NVARCHAR(50)    NOT NULL DEFAULT 'APPLIED',
    ApplicationStatusGroup    AS CAST('APPLICATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    CoverLetter             NVARCHAR(MAX)   NULL,
    ReviewedByEmployeeId    BIGINT          NULL,
    RejectionReason         NVARCHAR(2000)  NULL,
    AppliedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    StatusUpdatedAt         DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_Application_JobCandidate
        UNIQUE (JobPostingId, CandidateId),

    CONSTRAINT FK_Application_JobPosting
        FOREIGN KEY (JobPostingId)
        REFERENCES hr.JobPosting(Id),

    CONSTRAINT FK_Application_Candidate
        FOREIGN KEY (CandidateId)
        REFERENCES hr.Candidate(Id),

    CONSTRAINT FK_Application_ReviewedBy
        FOREIGN KEY (ReviewedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_Application_Status
        FOREIGN KEY (ApplicationStatus, ApplicationStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- APPLICATION STATUS HISTORY
-- Immutable audit trail of every status transition an
-- application goes through. Enables full funnel analytics
-- and time-in-stage reporting without modifying the
-- Application record itself.
-- -------------------------------------------------------
CREATE TABLE hr.ApplicationStatusHistory (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId           BIGINT          NOT NULL,
    FromStatus              NVARCHAR(50)    NULL,
    ToStatus                NVARCHAR(50)    NOT NULL,
    ChangedByEmployeeId     BIGINT          NULL,
    Remarks                 NVARCHAR(2000)  NULL,
    ChangedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AppStatusHistory_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES hr.Application(Id),

    CONSTRAINT FK_AppStatusHistory_ChangedBy
        FOREIGN KEY (ChangedByEmployeeId)
        REFERENCES dbo.Employee(Id)
);


-- -------------------------------------------------------
-- INTERVIEW ROUND CONFIG
-- Job-posting-level override of the master round definitions.
-- Allows a posting to include only specific rounds, change
-- the default interview type, and set a custom duration.
-- Unique on (JobPostingId, InterviewRoundId) to prevent
-- duplicate round assignments per posting.
-- -------------------------------------------------------
CREATE TABLE hr.InterviewRoundConfig (
    Id                  BIGINT  PRIMARY KEY IDENTITY(1,1),
    JobPostingId        BIGINT  NOT NULL,
    InterviewRoundId    BIGINT  NOT NULL,
    InterviewTypeId     BIGINT  NOT NULL,
    DurationMins        INT     NOT NULL DEFAULT 60,
    IsMandatory         BIT     NOT NULL DEFAULT 1,
    IsActive            BIT     NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_InterviewRoundConfig_JobRound
        UNIQUE (JobPostingId, InterviewRoundId),

    CONSTRAINT FK_IRC_JobPosting
        FOREIGN KEY (JobPostingId)
        REFERENCES hr.JobPosting(Id),

    CONSTRAINT FK_IRC_InterviewRound
        FOREIGN KEY (InterviewRoundId)
        REFERENCES hr.InterviewRound(Id),

    CONSTRAINT FK_IRC_InterviewType
        FOREIGN KEY (InterviewTypeId)
        REFERENCES hr.InterviewType(Id)
);


-- -------------------------------------------------------
-- INTERVIEW
-- Represents a single scheduled interview session for an
-- application, linked to a round configuration.
-- InterviewStatus references dbo.StatusLookup (INTERVIEW_STATUS).
-- RescheduledToInterviewId self-references to chain the
-- rescheduling history without losing the original record.
-- -------------------------------------------------------
CREATE TABLE hr.Interview (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId               BIGINT          NOT NULL,
    InterviewRoundConfigId      BIGINT          NOT NULL,
    ScheduledAt                 DATETIME2       NULL,
    DurationMins                INT             NOT NULL DEFAULT 60,
    MeetingLink                 NVARCHAR(1000)  NULL,
    Venue                       NVARCHAR(500)   NULL,
    InterviewStatus             NVARCHAR(50)    NOT NULL DEFAULT 'SCHEDULED',
    InterviewStatusGroup          AS CAST('INTERVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
    RescheduledToInterviewId    BIGINT          NULL,
    CreatedByEmployeeId         BIGINT          NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_Interview_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES hr.Application(Id),

    CONSTRAINT FK_Interview_RoundConfig
        FOREIGN KEY (InterviewRoundConfigId)
        REFERENCES hr.InterviewRoundConfig(Id),

    CONSTRAINT FK_Interview_Rescheduled
        FOREIGN KEY (RescheduledToInterviewId)
        REFERENCES hr.Interview(Id),

    CONSTRAINT FK_Interview_CreatedBy
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_Interview_Status
        FOREIGN KEY (InterviewStatus, InterviewStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- INTERVIEW PANEL
-- Maps multiple interviewers to a single interview session.
-- Each row represents one panelist seat with an assigned
-- PanelRole (capacity) and InterviewPurpose (evaluation area).
-- UQ on (InterviewId, InterviewPurposeId) ensures each
-- evaluation area is owned by exactly one panelist per session.
-- -------------------------------------------------------
CREATE TABLE hr.InterviewPanel (
    Id                      BIGINT      PRIMARY KEY IDENTITY(1,1),
    InterviewId             BIGINT      NOT NULL,
    InterviewerEmployeeId   BIGINT      NOT NULL,
    PanelRoleId             BIGINT      NOT NULL,
    InterviewPurposeId      BIGINT      NOT NULL,
    EvaluationTopics        NVARCHAR(MAX) NULL,
    IsLead                  BIT         NOT NULL DEFAULT 0,
    CanSubmitFeedback       BIT         NOT NULL DEFAULT 1,
    ConfirmedAt             DATETIME2   NULL,
    IsActive                BIT         NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2   NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_InterviewPanel_Interviewer
        UNIQUE (InterviewId, InterviewerEmployeeId),

    CONSTRAINT UQ_InterviewPanel_Purpose
        UNIQUE (InterviewId, InterviewPurposeId),

    CONSTRAINT FK_InterviewPanel_Interview
        FOREIGN KEY (InterviewId)
        REFERENCES hr.Interview(Id),

    CONSTRAINT FK_InterviewPanel_Interviewer
        FOREIGN KEY (InterviewerEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_InterviewPanel_PanelRole
        FOREIGN KEY (PanelRoleId)
        REFERENCES hr.PanelRole(Id),

    CONSTRAINT FK_InterviewPanel_Purpose
        FOREIGN KEY (InterviewPurposeId)
        REFERENCES hr.InterviewPurpose(Id)
);


-- -------------------------------------------------------
-- INTERVIEW FEEDBACK
-- One feedback record per panelist seat (InterviewPanelId).
-- Captures structured scores across multiple dimensions plus
-- an overall recommendation.
-- Keyed to InterviewPanelId so feedback is automatically
-- scoped to the interviewer's role and evaluation purpose.
-- RecommendationStatus references dbo.StatusLookup (RECOMMENDATION_STATUS).
-- -------------------------------------------------------
CREATE TABLE hr.InterviewFeedback (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    InterviewPanelId        BIGINT          NOT NULL UNIQUE,
    OverallRating           DECIMAL(3,1)    NULL,
    TechnicalScore          DECIMAL(3,1)    NULL,
    CommunicationScore      DECIMAL(3,1)    NULL,
    CulturalFitScore        DECIMAL(3,1)    NULL,
    PurposeSpecificScore    DECIMAL(3,1)    NULL,
    Strengths               NVARCHAR(MAX)   NULL,
    Concerns                NVARCHAR(MAX)   NULL,
    RecommendationStatus    NVARCHAR(50)    NOT NULL,
    RecommendationStatusGroup AS CAST('RECOMMENDATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    AdditionalNotes         NVARCHAR(MAX)   NULL,
    SubmittedAt             DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_InterviewFeedback_Panel
        FOREIGN KEY (InterviewPanelId)
        REFERENCES hr.InterviewPanel(Id),

    CONSTRAINT FK_InterviewFeedback_Recommendation
        FOREIGN KEY (RecommendationStatus, RecommendationStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- PACKAGE NEGOTIATION
-- Captures the salary and benefits negotiation thread
-- between HR and the candidate. Each counter-offer is a
-- new row, preserving the full negotiation history.
-- NegotiationStatus references dbo.StatusLookup (NEGOTIATION_STATUS).
-- -------------------------------------------------------
CREATE TABLE hr.PackageNegotiation (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId           BIGINT          NOT NULL,
    HREmployeeId            BIGINT          NOT NULL,
    RoundNumber             INT             NOT NULL DEFAULT 1,
    OfferedCTC              DECIMAL(18,2)   NOT NULL,
    CandidateAsk            DECIMAL(18,2)   NULL,
    FinalCTC                DECIMAL(18,2)   NULL,
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    VariablePct             DECIMAL(5,2)    NULL,
    JoiningBonus            DECIMAL(18,2)   NULL,
    OtherBenefits           NVARCHAR(MAX)   NULL,
    NegotiationStatus       NVARCHAR(50)    NOT NULL DEFAULT 'IN_PROGRESS',
    NegotiationStatusGroup    AS CAST('NEGOTIATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    Notes                   NVARCHAR(MAX)   NULL,
    NegotiatedAt            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_PackageNegotiation_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES hr.Application(Id),

    CONSTRAINT FK_PackageNegotiation_HREmployee
        FOREIGN KEY (HREmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PackageNegotiation_Status
        FOREIGN KEY (NegotiationStatus, NegotiationStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- OFFER LETTER
-- Represents the formal offer document issued to a candidate
-- after negotiation completes. Tracks issuance, acceptance
-- or rejection, and expiry.
-- OfferStatus references dbo.StatusLookup (OFFER_STATUS).
-- LetterFileUrl points to secure blob/S3 storage.
-- -------------------------------------------------------
CREATE TABLE hr.OfferLetter (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId           BIGINT          NOT NULL,
    PackageNegotiationId    BIGINT          NULL,
    LetterFileUrl           NVARCHAR(1000)  NOT NULL,
    IssuedDate              DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    ExpiryDate              DATE            NOT NULL,
    OfferedPosition         NVARCHAR(200)   NULL,
    ProposedJoiningDate     DATE            NULL,
    OfferStatus             NVARCHAR(50)    NOT NULL DEFAULT 'ISSUED',
    OfferStatusGroup          AS CAST('OFFER_STATUS' AS NVARCHAR(50)) PERSISTED,
    AcceptedAt              DATETIME2       NULL,
    RevokedReason           NVARCHAR(2000)  NULL,
    IssuedByEmployeeId      BIGINT          NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_OfferLetter_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES hr.Application(Id),

    CONSTRAINT FK_OfferLetter_PackageNegotiation
        FOREIGN KEY (PackageNegotiationId)
        REFERENCES hr.PackageNegotiation(Id),

    CONSTRAINT FK_OfferLetter_IssuedBy
        FOREIGN KEY (IssuedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_OfferLetter_Status
        FOREIGN KEY (OfferStatus, OfferStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- MODULE B: ONBOARDING
-- Manages pre- and post-joining task tracking, document verification, and background checks.
-- =============================================================================================================


-- -------------------------------------------------------
-- ONBOARDING CHECKLIST
-- Reusable template-level checklist for a given onboarding
-- phase and employment type (Full-Time, Intern, Contract).
-- A checklist is instantiated into employee-specific
-- OnboardingTask records when the employee record is created.
-- Phase: PRE_ONBOARDING | DAY_ONE | FIRST_WEEK | POST_ONBOARDING
-- -------------------------------------------------------
CREATE TABLE hr.OnboardingChecklist (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    ChecklistName   NVARCHAR(200)   NOT NULL,
    Phase           NVARCHAR(50)    NOT NULL,
    EmploymentType  NVARCHAR(50)    NOT NULL DEFAULT 'FULL_TIME',
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt       DATETIME2       NULL
);


-- -------------------------------------------------------
-- ONBOARDING CHECKLIST ITEM
-- Individual task definitions within a checklist template.
-- OwnerRole identifies the responsible party (HR, IT,
-- Manager, Employee) for UI assignment and escalation.
-- IsMandatory distinguishes blocking tasks from optional ones.
-- -------------------------------------------------------
CREATE TABLE hr.OnboardingChecklistItem (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    OnboardingChecklistId   BIGINT          NOT NULL,
    TaskName                NVARCHAR(250)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    OwnerRole               NVARCHAR(50)    NULL,
    SequenceOrder           INT             NOT NULL DEFAULT 0,
    IsMandatory             BIT             NOT NULL DEFAULT 1,
    IsActive                BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_OnboardingChecklistItem_Checklist
        FOREIGN KEY (OnboardingChecklistId)
        REFERENCES hr.OnboardingChecklist(Id)
);


-- -------------------------------------------------------
-- ONBOARDING TASK
-- Employee-specific task instances generated from a
-- checklist template when a new joiner record is created.
-- TaskStatus references dbo.StatusLookup (ONBOARDING_TASK_STATUS).
-- OnboardingChecklistItemId is nullable to support ad-hoc
-- tasks added outside the template.
-- -------------------------------------------------------
CREATE TABLE hr.OnboardingTask (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL,
    OnboardingChecklistItemId   BIGINT          NULL,
    TaskName                    NVARCHAR(250)   NOT NULL,
    Phase                       NVARCHAR(50)    NOT NULL,
    OwnerRole                   NVARCHAR(50)    NULL,
    TaskStatus                  NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    TaskStatusGroup               AS CAST('ONBOARDING_TASK_STATUS' AS NVARCHAR(50)) PERSISTED,
    DueDate                     DATE            NULL,
    CompletedDate               DATE            NULL,
    CompletedByEmployeeId       BIGINT          NULL,
    Remarks                     NVARCHAR(2000)  NULL,
    WorkflowInstanceId          BIGINT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_OnboardingTask_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_OnboardingTask_ChecklistItem
        FOREIGN KEY (OnboardingChecklistItemId)
        REFERENCES hr.OnboardingChecklistItem(Id),

    CONSTRAINT FK_OnboardingTask_CompletedBy
        FOREIGN KEY (CompletedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_OnboardingTask_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_OnboardingTask_Status
        FOREIGN KEY (TaskStatus, TaskStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- DOCUMENT VERIFICATION
-- Tracks every document submitted by an employee across
-- pre- and post-onboarding phases, including verification
-- outcome and reviewer details.
-- DocVerifyStatus references dbo.StatusLookup (DOC_VERIFY_STATUS).
-- OnboardingPhase references dbo.StatusLookup (ONBOARDING_PHASE).
-- FileUrl must point to secure blob/S3 storage.
-- -------------------------------------------------------
CREATE TABLE hr.DocumentVerification (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    DocumentTypeId          BIGINT          NOT NULL,
    OnboardingPhase         NVARCHAR(50)    NOT NULL DEFAULT 'PRE_ONBOARDING',
    OnboardingPhaseGroup      AS CAST('ONBOARDING_PHASE' AS NVARCHAR(50)) PERSISTED,
    FileUrl                 NVARCHAR(1000)  NULL,
    DocumentNumber          NVARCHAR(100)   NULL,
    IssuedBy                NVARCHAR(200)   NULL,
    IssueDate               DATE            NULL,
    ExpiryDate              DATE            NULL,
    DocVerifyStatus         NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    DocVerifyStatusGroup      AS CAST('DOC_VERIFY_STATUS' AS NVARCHAR(50)) PERSISTED,
    SubmittedDate           DATE            NULL,
    VerifiedDate            DATE            NULL,
    VerifiedByEmployeeId    BIGINT          NULL,
    RejectionReason         NVARCHAR(2000)  NULL,
    Remarks                 NVARCHAR(2000)  NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_DocVerification_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_DocVerification_DocumentType
        FOREIGN KEY (DocumentTypeId)
        REFERENCES dbo.DocumentType(Id),

    CONSTRAINT FK_DocVerification_VerifiedBy
        FOREIGN KEY (VerifiedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_DocVerification_Status
        FOREIGN KEY (DocVerifyStatus, DocVerifyStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_DocVerification_Phase
        FOREIGN KEY (OnboardingPhase, OnboardingPhaseGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- BGV AGENCY
-- Master list of third-party background verification
-- agencies engaged by the organisation. Stored centrally
-- so agency metadata is maintained in one place.
-- -------------------------------------------------------
CREATE TABLE hr.BGVAgency (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    AgencyName      NVARCHAR(200)   NOT NULL UNIQUE,
    ContactPerson   NVARCHAR(200)   NULL,
    Email           NVARCHAR(255)   NULL,
    Phone           NVARCHAR(30)    NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- BACKGROUND VERIFICATION
-- Tracks each type of background check per employee across
-- pre- and post-onboarding phases.
-- BGVCheckType references dbo.StatusLookup (BGV_CHECK_TYPE).
-- BGVStatus references dbo.StatusLookup (BGV_STATUS).
-- BGVResult references dbo.StatusLookup (BGV_RESULT).
-- OnboardingPhase references dbo.StatusLookup (ONBOARDING_PHASE).
-- One employee can have multiple checks (Criminal + Education
-- + Employment History) each as a separate row.
-- -------------------------------------------------------
CREATE TABLE hr.BackgroundVerification (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    BGVAgencyId             BIGINT          NULL,
    BGVCheckType            NVARCHAR(50)    NOT NULL,
    BGVCheckTypeGroup         AS CAST('BGV_CHECK_TYPE' AS NVARCHAR(50)) PERSISTED,
    OnboardingPhase         NVARCHAR(50)    NOT NULL DEFAULT 'PRE_ONBOARDING',
    OnboardingPhaseGroup      AS CAST('ONBOARDING_PHASE' AS NVARCHAR(50)) PERSISTED,
    ReferenceName           NVARCHAR(200)   NULL,
    ReferenceContact        NVARCHAR(200)   NULL,
    InitiatedByEmployeeId   BIGINT          NULL,
    InitiatedDate           DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    ExpectedDate            DATE            NULL,
    CompletedDate           DATE            NULL,
    BGVStatus               NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    BGVStatusGroup            AS CAST('BGV_STATUS' AS NVARCHAR(50)) PERSISTED,
    BGVResult               NVARCHAR(50)    NULL,
    BGVResultGroup            AS CAST('BGV_RESULT' AS NVARCHAR(50)) PERSISTED,
    Findings                NVARCHAR(MAX)   NULL,
    ReportUrl               NVARCHAR(1000)  NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_BGV_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_BGV_Agency
        FOREIGN KEY (BGVAgencyId)
        REFERENCES hr.BGVAgency(Id),

    CONSTRAINT FK_BGV_InitiatedBy
        FOREIGN KEY (InitiatedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_BGV_CheckType
        FOREIGN KEY (BGVCheckType, BGVCheckTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_BGV_Phase
        FOREIGN KEY (OnboardingPhase, OnboardingPhaseGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_BGV_Status
        FOREIGN KEY (BGVStatus, BGVStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_BGV_Result
        FOREIGN KEY (BGVResult, BGVResultGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- MODULE C: POLICY DOCUMENTS
-- Manages the full lifecycle of company policy documents including versioning and employee acknowledgement.
-- =============================================================================================================


-- -------------------------------------------------------
-- POLICY CATEGORY
-- Top-level grouping for policy documents
-- (e.g. HR Policies, IT Security, Finance, Compliance).
-- Enables filtered browsing and mandatory-acknowledgement
-- rules per category.
-- -------------------------------------------------------
CREATE TABLE hr.PolicyCategory (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode    NVARCHAR(50)    NOT NULL UNIQUE,
    CategoryName    NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- POLICY DOCUMENT
-- Master record for each company policy. A policy has one
-- active version at any time; historical versions are
-- retained in hr.PolicyVersion.
-- Scope controls applicability: GLOBAL, COUNTRY, LEGAL_ENTITY,
-- DEPARTMENT, or LOCATION, resolved via ScopeTypeId +
-- ScopeReferenceId (mirrors dbo.ScopeType pattern).
-- AcknowledgementRequired flags policies that mandate
-- employee sign-off.
-- -------------------------------------------------------
CREATE TABLE hr.PolicyDocument (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyCategoryId            BIGINT          NOT NULL,
    PolicyCode                  NVARCHAR(50)    NOT NULL UNIQUE,
    PolicyName                  NVARCHAR(300)   NOT NULL,
    Description                 NVARCHAR(MAX)   NULL,
    ScopeTypeId                 BIGINT          NULL,
    ScopeReferenceId            BIGINT          NULL,
    AcknowledgementRequired     BIT             NOT NULL DEFAULT 1,
    AcknowledgementDeadlineDays INT             NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedByEmployeeId         BIGINT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_PolicyDocument_Category
        FOREIGN KEY (PolicyCategoryId)
        REFERENCES hr.PolicyCategory(Id),

    CONSTRAINT FK_PolicyDocument_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES dbo.ScopeType(Id),

    CONSTRAINT FK_PolicyDocument_CreatedBy
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES dbo.Employee(Id)
);


-- -------------------------------------------------------
-- POLICY VERSION
-- Stores each published revision of a policy document.
-- VersionNumber is monotonically increasing per policy.
-- FileUrl points to the uploaded PDF/document in blob storage.
-- PolicyStatus references dbo.StatusLookup (POLICY_STATUS):
--   DRAFT -> ACTIVE -> ARCHIVED | SUPERSEDED
-- EffectiveDate marks when the version comes into force.
-- SupersededByVersionId links to the newer version on
-- supersession for forward-navigation in the UI.
-- -------------------------------------------------------
CREATE TABLE hr.PolicyVersion (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyDocumentId        BIGINT          NOT NULL,
    VersionNumber           INT             NOT NULL,
    VersionLabel            NVARCHAR(50)    NULL,
    FileUrl                 NVARCHAR(1000)  NOT NULL,
    OriginalFileName        NVARCHAR(500)   NULL,
    ChangeNotes             NVARCHAR(MAX)   NULL,
    PolicyStatus            NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    PolicyStatusGroup         AS CAST('POLICY_STATUS' AS NVARCHAR(50)) PERSISTED,
    EffectiveDate           DATE            NULL,
    SupersededByVersionId   BIGINT          NULL,
    PublishedByEmployeeId   BIGINT          NULL,
    PublishedAt             DATETIME2       NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_PolicyVersion
        UNIQUE (PolicyDocumentId, VersionNumber),

    CONSTRAINT FK_PolicyVersion_Document
        FOREIGN KEY (PolicyDocumentId)
        REFERENCES hr.PolicyDocument(Id),

    CONSTRAINT FK_PolicyVersion_SupersededBy
        FOREIGN KEY (SupersededByVersionId)
        REFERENCES hr.PolicyVersion(Id),

    CONSTRAINT FK_PolicyVersion_PublishedBy
        FOREIGN KEY (PublishedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PolicyVersion_Status
        FOREIGN KEY (PolicyStatus, PolicyStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- POLICY ACKNOWLEDGEMENT
-- Records each employee's acknowledgement of a specific
-- policy version. One row per employee per version.
-- AckStatus references dbo.StatusLookup (POLICY_ACK_STATUS):
--   PENDING -> ACKNOWLEDGED | OVERDUE
-- AcknowledgedAt is populated on employee sign-off.
-- DeadlineDate is computed at assignment time based on
-- PolicyDocument.AcknowledgementDeadlineDays.
-- -------------------------------------------------------
CREATE TABLE hr.PolicyAcknowledgement (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    PolicyVersionId     BIGINT          NOT NULL,
    EmployeeId          BIGINT          NOT NULL,
    AckStatus           NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    AckStatusGroup        AS CAST('POLICY_ACK_STATUS' AS NVARCHAR(50)) PERSISTED,
    DeadlineDate        DATE            NULL,
    AcknowledgedAt      DATETIME2       NULL,
    IPAddress           NVARCHAR(50)    NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_PolicyAcknowledgement
        UNIQUE (PolicyVersionId, EmployeeId),

    CONSTRAINT FK_PolicyAck_PolicyVersion
        FOREIGN KEY (PolicyVersionId)
        REFERENCES hr.PolicyVersion(Id),

    CONSTRAINT FK_PolicyAck_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PolicyAck_Status
        FOREIGN KEY (AckStatus, AckStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- MODULE D: SALARY SLIPS
-- Manages the presentation and delivery layer of monthly payslips.
--
-- DESIGN RATIONALE — why no duplicate component table:
--   All financial source-of-truth data already exists in the payroll schema:
--     • payroll.PayrollDisbursementTransaction — per-employee monthly net credit
--       (GrossAmount, TotalDeductions, NetAmountCredited, CurrencyCode, PayrollMonth, PayrollYear)
--     • payroll.EmployeeSalaryComponent       — component-level breakdown (earnings & deductions)
--       with FinalAmount = COALESCE(OverrideAmount, ComputedAmount)
--     • payroll.EmployeeTaxDeduction          — TDS and tax breakdown per month
--     • payroll.PayrollAttendanceSummary      — working days, present days, leave, overtime
--
--   hr.SalarySlipPublication adds ONLY what payroll does not own:
--     the rendered document artefact (PDF URL), its lifecycle status, and download audit.
--   All numeric fields on the payslip are read at query time from payroll tables via
--   DisbursementTransactionId — no duplication of financials.
-- =============================================================================================================


-- -------------------------------------------------------
-- SALARY SLIP PUBLICATION
-- Tracks the generated payslip PDF artefact for an employee
-- for a given payroll disbursement transaction.
-- All monetary figures (gross, deductions, net, currency,
-- month, year) are sourced at query time from
-- payroll.PayrollDisbursementTransaction and
-- payroll.EmployeeSalaryComponent — nothing is duplicated here.
--
-- SlipStatus references dbo.StatusLookup (SALARY_SLIP_STATUS):
--   DRAFT -> PUBLISHED -> DOWNLOADED | REVISED
-- FileUrl points to the rendered, password-protected PDF
-- in blob/S3 storage. IsPasswordProtected signals the
-- application layer to apply the employee's DOB-based PIN.
-- FirstDownloadedAt is populated on the first employee
-- access for audit and SLA reporting.
-- -------------------------------------------------------
CREATE TABLE hr.SalarySlipPublication (
    Id                              BIGINT          PRIMARY KEY IDENTITY(1,1),
    DisbursementTransactionId       BIGINT          NOT NULL UNIQUE,
    SlipStatus                      NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    SlipStatusGroup                   AS CAST('SALARY_SLIP_STATUS' AS NVARCHAR(50)) PERSISTED,
    FileUrl                         NVARCHAR(1000)  NULL,
    IsPasswordProtected             BIT             NOT NULL DEFAULT 1,
    GeneratedAt                     DATETIME2       NULL,
    PublishedAt                     DATETIME2       NULL,
    FirstDownloadedAt               DATETIME2       NULL,
    Remarks                         NVARCHAR(1000)  NULL,
    CreatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                       DATETIME2       NULL,

    CONSTRAINT FK_SalarySlipPub_DisbursementTransaction
        FOREIGN KEY (DisbursementTransactionId)
        REFERENCES payroll.PayrollDisbursementTransaction(Id),

    CONSTRAINT FK_SalarySlipPub_Status
        FOREIGN KEY (SlipStatus, SlipStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- MODULE E: PERFORMANCE REVIEWS
-- Manages appraisal cycles, individual goal setting (OKR-style), and formal review records.
-- =============================================================================================================


-- -------------------------------------------------------
-- PERFORMANCE CYCLE
-- Defines appraisal periods (Annual, Bi-Annual, Quarterly,
-- Probation) within which goal setting and reviews occur.
-- CycleType references dbo.StatusLookup (PERF_CYCLE_TYPE).
-- CycleStatus references dbo.StatusLookup (PERF_CYCLE_STATUS).
-- GoalSettingDeadline and ReviewStartDate allow the cycle
-- to be split into discrete phases.
-- -------------------------------------------------------
CREATE TABLE hr.PerformanceCycle (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    CycleName               NVARCHAR(150)   NOT NULL UNIQUE,
    CycleType               NVARCHAR(50)    NOT NULL DEFAULT 'ANNUAL',
    CycleTypeGroup            AS CAST('PERF_CYCLE_TYPE' AS NVARCHAR(50)) PERSISTED,
    StartDate               DATE            NOT NULL,
    EndDate                 DATE            NOT NULL,
    GoalSettingDeadline     DATE            NULL,
    ReviewStartDate         DATE            NULL,
    ReviewEndDate           DATE            NULL,
    CycleStatus             NVARCHAR(50)    NOT NULL DEFAULT 'UPCOMING',
    CycleStatusGroup          AS CAST('PERF_CYCLE_STATUS' AS NVARCHAR(50)) PERSISTED,
    LegalEntityId           BIGINT          NULL,
    CreatedByEmployeeId     BIGINT          NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_PerfCycle_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES dbo.LegalEntity(Id),

    CONSTRAINT FK_PerfCycle_CreatedBy
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PerfCycle_CycleType
        FOREIGN KEY (CycleType, CycleTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_PerfCycle_Status
        FOREIGN KEY (CycleStatus, CycleStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- GOAL
-- Individual goals set by an employee for a performance
-- cycle. Supports OKR-style structure via GoalKeyResult.
-- GoalStatus references dbo.StatusLookup (GOAL_STATUS).
-- WeightagePct allows weighted aggregation of ratings
-- across goals for final score computation.
-- -------------------------------------------------------
CREATE TABLE hr.Goal (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    PerformanceCycleId      BIGINT          NOT NULL,
    Title                   NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    Category                NVARCHAR(100)   NULL,
    WeightagePct            DECIMAL(5,2)    NOT NULL DEFAULT 0
        CONSTRAINT CK_Goal_Weightage CHECK (WeightagePct BETWEEN 0 AND 100),
    TargetDate              DATE            NULL,
    GoalStatus              NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    GoalStatusGroup           AS CAST('GOAL_STATUS' AS NVARCHAR(50)) PERSISTED,
    ProgressPct             INT             NOT NULL DEFAULT 0
        CONSTRAINT CK_Goal_Progress CHECK (ProgressPct BETWEEN 0 AND 100),
    EmployeeRating          DECIMAL(3,1)    NULL,
    ManagerRating           DECIMAL(3,1)    NULL,
    ApprovedByEmployeeId    BIGINT          NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_Goal_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_Goal_PerfCycle
        FOREIGN KEY (PerformanceCycleId)
        REFERENCES hr.PerformanceCycle(Id),

    CONSTRAINT FK_Goal_ApprovedBy
        FOREIGN KEY (ApprovedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_Goal_Status
        FOREIGN KEY (GoalStatus, GoalStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- GOAL KEY RESULT
-- Measurable outcomes or milestones under a parent goal
-- to support OKR-style tracking.
-- KRStatus references dbo.StatusLookup (GOAL_KR_STATUS).
-- TargetValue and ActualValue are NVARCHAR to support
-- both numeric and descriptive metrics (e.g. "10 articles"
-- or "Achieved CSAT > 4.5").
-- -------------------------------------------------------
CREATE TABLE hr.GoalKeyResult (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    GoalId          BIGINT          NOT NULL,
    Description     NVARCHAR(MAX)   NOT NULL,
    TargetValue     NVARCHAR(200)   NULL,
    ActualValue     NVARCHAR(200)   NULL,
    KRStatus        NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    KRStatusGroup     AS CAST('GOAL_KR_STATUS' AS NVARCHAR(50)) PERSISTED,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt       DATETIME2       NULL,

    CONSTRAINT FK_GoalKR_Goal
        FOREIGN KEY (GoalId)
        REFERENCES hr.Goal(Id),

    CONSTRAINT FK_GoalKR_Status
        FOREIGN KEY (KRStatus, KRStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- PERFORMANCE REVIEW
-- Formal review record for each employee in a cycle,
-- capturing self-assessment, manager evaluation, HRBP
-- comments, and final rating.
-- ReviewStatus references dbo.StatusLookup (PERF_REVIEW_STATUS).
-- PerformanceBand: Exceeds | Meets | Below | Critical
-- (stored as a free-text band label rather than a FK to
-- allow flexible band definitions per cycle without schema
-- changes; enforce via application-layer validation).
-- -------------------------------------------------------
CREATE TABLE hr.PerformanceReview (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL,
    PerformanceCycleId          BIGINT          NOT NULL,
    ReviewerEmployeeId          BIGINT          NOT NULL,
    SelfRating                  DECIMAL(3,1)    NULL,
    ManagerRating               DECIMAL(3,1)    NULL,
    FinalRating                 DECIMAL(3,1)    NULL,
    PerformanceBand             NVARCHAR(50)    NULL,
    SelfComments                NVARCHAR(MAX)   NULL,
    ManagerComments             NVARCHAR(MAX)   NULL,
    HRBPComments                NVARCHAR(MAX)   NULL,
    ReviewStatus                NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ReviewStatusGroup             AS CAST('PERF_REVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
    SelfSubmittedAt             DATETIME2       NULL,
    ManagerSubmittedAt          DATETIME2       NULL,
    CompletedAt                 DATETIME2       NULL,
    WorkflowInstanceId          BIGINT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT UQ_PerformanceReview_EmployeeCycle
        UNIQUE (EmployeeId, PerformanceCycleId),

    CONSTRAINT FK_PerfReview_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PerfReview_PerfCycle
        FOREIGN KEY (PerformanceCycleId)
        REFERENCES hr.PerformanceCycle(Id),

    CONSTRAINT FK_PerfReview_Reviewer
        FOREIGN KEY (ReviewerEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_PerfReview_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_PerfReview_Status
        FOREIGN KEY (ReviewStatus, ReviewStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- PERFORMANCE REVIEW HISTORY
-- Append-only audit trail of every status change on a
-- performance review record. Enables escalation tracking
-- and SLA reporting on review completion times.
-- -------------------------------------------------------
CREATE TABLE hr.PerformanceReviewHistory (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    PerformanceReviewId     BIGINT          NOT NULL,
    FromStatus              NVARCHAR(50)    NULL,
    ToStatus                NVARCHAR(50)    NOT NULL,
    ChangedByEmployeeId     BIGINT          NULL,
    Remarks                 NVARCHAR(2000)  NULL,
    ChangedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_PerfReviewHistory_Review
        FOREIGN KEY (PerformanceReviewId)
        REFERENCES hr.PerformanceReview(Id),

    CONSTRAINT FK_PerfReviewHistory_ChangedBy
        FOREIGN KEY (ChangedByEmployeeId)
        REFERENCES dbo.Employee(Id)
);


-- =============================================================================================================
-- MODULE F: TRAINING RECORDS
-- Manages training catalogue, batch scheduling, and per-employee enrollment and completion tracking.
-- =============================================================================================================


-- -------------------------------------------------------
-- TRAINING CATEGORY
-- Top-level grouping of training programs
-- (e.g. Technical, Compliance, Leadership, Soft Skills).
-- -------------------------------------------------------
CREATE TABLE hr.TrainingCategory (
    Id              BIGINT          PRIMARY KEY IDENTITY(1,1),
    CategoryName    NVARCHAR(150)   NOT NULL UNIQUE,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- TRAINING PROGRAM
-- Defines individual courses within a training category.
-- TrainingMode references dbo.StatusLookup (TRAINING_MODE).
-- IsMandatory drives automatic enrollment for applicable
-- employee groups (controlled via ApplicableTo).
-- CertificateProvided flags programs that issue completion
-- certificates stored in hr.EmployeeTrainingRecord.
-- -------------------------------------------------------
CREATE TABLE hr.TrainingProgram (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    TrainingCategoryId      BIGINT          NOT NULL,
    ProgramCode             NVARCHAR(50)    NOT NULL UNIQUE,
    Title                   NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    TrainingMode            NVARCHAR(50)    NOT NULL DEFAULT 'ONLINE',
    TrainingModeGroup         AS CAST('TRAINING_MODE' AS NVARCHAR(50)) PERSISTED,
    DurationHours           DECIMAL(6,2)    NULL,
    Provider                NVARCHAR(200)   NULL,
    IsMandatory             BIT             NOT NULL DEFAULT 0,
    ApplicableTo            NVARCHAR(100)   NULL,
    MaxParticipants         INT             NULL,
    CertificateProvided     BIT             NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_TrainingProgram_Category
        FOREIGN KEY (TrainingCategoryId)
        REFERENCES hr.TrainingCategory(Id),

    CONSTRAINT FK_TrainingProgram_Mode
        FOREIGN KEY (TrainingMode, TrainingModeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- TRAINING BATCH
-- Represents a scheduled cohort of a training program with
-- defined dates, venue or meeting link, facilitator, and
-- capacity.
-- BatchStatus references dbo.StatusLookup (TRAINING_BATCH_STATUS).
-- -------------------------------------------------------
CREATE TABLE hr.TrainingBatch (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    TrainingProgramId       BIGINT          NOT NULL,
    BatchName               NVARCHAR(200)   NULL,
    FacilitatorEmployeeId   BIGINT          NULL,
    StartDate               DATE            NOT NULL,
    EndDate                 DATE            NULL,
    VenueOrLink             NVARCHAR(1000)  NULL,
    MaxSeats                INT             NULL,
    BatchStatus             NVARCHAR(50)    NOT NULL DEFAULT 'UPCOMING',
    BatchStatusGroup          AS CAST('TRAINING_BATCH_STATUS' AS NVARCHAR(50)) PERSISTED,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_TrainingBatch_Program
        FOREIGN KEY (TrainingProgramId)
        REFERENCES hr.TrainingProgram(Id),

    CONSTRAINT FK_TrainingBatch_Facilitator
        FOREIGN KEY (FacilitatorEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_TrainingBatch_Status
        FOREIGN KEY (BatchStatus, BatchStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- EMPLOYEE TRAINING RECORD
-- Tracks each employee's enrollment and completion for
-- every training program and batch. One row per enrollment.
-- RecordStatus references dbo.StatusLookup (TRAINING_RECORD_STATUS).
-- IsPassed is a persisted computed column derived from
-- Score vs PassingScore to avoid redundant storage.
-- CertificateUrl points to the issued certificate document
-- in blob/S3 storage.
-- -------------------------------------------------------
CREATE TABLE hr.EmployeeTrainingRecord (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    TrainingProgramId       BIGINT          NOT NULL,
    TrainingBatchId         BIGINT          NULL,
    EnrolledDate            DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    CompletedDate           DATE            NULL,
    RecordStatus            NVARCHAR(50)    NOT NULL DEFAULT 'ENROLLED',
    RecordStatusGroup         AS CAST('TRAINING_RECORD_STATUS' AS NVARCHAR(50)) PERSISTED,
    Score                   DECIMAL(5,2)    NULL,
    PassingScore            DECIMAL(5,2)    NULL,
    IsPassed                AS (CAST(CASE
                                    WHEN Score IS NOT NULL
                                     AND PassingScore IS NOT NULL
                                     AND Score >= PassingScore THEN 1
                                    ELSE 0
                            END AS BIT)) PERSISTED,
    CertificateUrl          NVARCHAR(1000)  NULL,
    CertificateIssuedDate   DATE            NULL,
    Feedback                NVARCHAR(MAX)   NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_EmpTrainingRecord_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_EmpTrainingRecord_Program
        FOREIGN KEY (TrainingProgramId)
        REFERENCES hr.TrainingProgram(Id),

    CONSTRAINT FK_EmpTrainingRecord_Batch
        FOREIGN KEY (TrainingBatchId)
        REFERENCES hr.TrainingBatch(Id),

    CONSTRAINT FK_EmpTrainingRecord_Status
        FOREIGN KEY (RecordStatus, RecordStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- MODULE G: EXIT MANAGEMENT
-- Manages the end-to-end employee exit process from resignation through final settlement.
-- =============================================================================================================


-- -------------------------------------------------------
-- EXIT REASON
-- Standardised master list of exit reason categories to
-- ensure consistent attrition reporting. Category:
-- VOLUNTARY | INVOLUNTARY distinguishes resignation from
-- termination for analytics.
-- -------------------------------------------------------
CREATE TABLE hr.ExitReason (
    Id          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ReasonText  NVARCHAR(200)   NOT NULL UNIQUE,
    Category    NVARCHAR(20)    NOT NULL
        CONSTRAINT CK_ExitReason_Category CHECK (Category IN ('VOLUNTARY', 'INVOLUNTARY')),
    IsActive    BIT             NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);


-- -------------------------------------------------------
-- EXIT RECORD
-- Central record for an employee's departure capturing
-- exit type, notice period, exit interview outcome,
-- clearance status, and final settlement status.
-- ExitType references dbo.StatusLookup (EXIT_TYPE).
-- ExitInterviewStatus references dbo.StatusLookup (EXIT_INTERVIEW_STATUS).
-- ClearanceStatus references dbo.StatusLookup (CLEARANCE_STATUS).
-- FinalSettlementStatus references dbo.StatusLookup (FINAL_SETTLEMENT_STATUS).
-- One record per employee (UQ enforced); updated in place
-- as the exit progresses through workflow stages.
-- -------------------------------------------------------
CREATE TABLE hr.ExitRecord (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                  BIGINT          NOT NULL UNIQUE,
    ExitReasonId                BIGINT          NULL,
    ExitType                    NVARCHAR(50)    NOT NULL DEFAULT 'RESIGNATION',
    ExitTypeGroup                 AS CAST('EXIT_TYPE' AS NVARCHAR(50)) PERSISTED,
    AdditionalReason            NVARCHAR(MAX)   NULL,
    ResignationDate             DATE            NULL,
    LastWorkingDate             DATE            NULL,
    NoticePeriodDays            INT             NULL,
    IsNoticeWaived              BIT             NOT NULL DEFAULT 0,
    ExitInterviewStatus         NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ExitInterviewStatusGroup      AS CAST('EXIT_INTERVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
    ExitInterviewDate           DATE            NULL,
    ConductedByEmployeeId       BIGINT          NULL,
    ExitFeedback                NVARCHAR(MAX)   NULL,
    IsRehireEligible            BIT             NOT NULL DEFAULT 1,
    ClearanceStatus             NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ClearanceStatusGroup          AS CAST('CLEARANCE_STATUS' AS NVARCHAR(50)) PERSISTED,
    FinalSettlementStatus       NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    FinalSettlementStatusGroup    AS CAST('FINAL_SETTLEMENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    FinalSettlementDate         DATE            NULL,
    WorkflowInstanceId          BIGINT          NULL,
    CreatedByEmployeeId         BIGINT          NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_ExitRecord_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ExitRecord_ExitReason
        FOREIGN KEY (ExitReasonId)
        REFERENCES hr.ExitReason(Id),

    CONSTRAINT FK_ExitRecord_ConductedBy
        FOREIGN KEY (ConductedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ExitRecord_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExitRecord_CreatedBy
        FOREIGN KEY (CreatedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ExitRecord_ExitType
        FOREIGN KEY (ExitType, ExitTypeGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExitRecord_ExitInterviewStatus
        FOREIGN KEY (ExitInterviewStatus, ExitInterviewStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExitRecord_ClearanceStatus
        FOREIGN KEY (ClearanceStatus, ClearanceStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExitRecord_SettlementStatus
        FOREIGN KEY (FinalSettlementStatus, FinalSettlementStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- -------------------------------------------------------
-- EXIT CLEARANCE ITEM
-- Per-employee checklist of clearance tasks that must be
-- completed before the exit is fully processed (e.g.
-- Laptop Returned, ID Card Collected, Access Revoked,
-- Knowledge Transfer Completed).
-- ItemStatus references dbo.StatusLookup (CLEARANCE_ITEM_STATUS).
-- OwnerDepartment identifies which team owns the clearance step.
-- -------------------------------------------------------
CREATE TABLE hr.ExitClearanceItem (
    Id                          BIGINT          PRIMARY KEY IDENTITY(1,1),
    ExitRecordId                BIGINT          NOT NULL,
    ItemName                    NVARCHAR(200)   NOT NULL,
    OwnerDepartment             NVARCHAR(100)   NULL,
    ItemStatus                  NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ItemStatusGroup               AS CAST('CLEARANCE_ITEM_STATUS' AS NVARCHAR(50)) PERSISTED,
    CompletedByEmployeeId       BIGINT          NULL,
    CompletedAt                 DATETIME2       NULL,
    Remarks                     NVARCHAR(2000)  NULL,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt                   DATETIME2       NULL,

    CONSTRAINT FK_ExitClearanceItem_ExitRecord
        FOREIGN KEY (ExitRecordId)
        REFERENCES hr.ExitRecord(Id),

    CONSTRAINT FK_ExitClearanceItem_CompletedBy
        FOREIGN KEY (CompletedByEmployeeId)
        REFERENCES dbo.Employee(Id),

    CONSTRAINT FK_ExitClearanceItem_Status
        FOREIGN KEY (ItemStatus, ItemStatusGroup)
        REFERENCES dbo.StatusLookup (StatusCode, StatusGroup)
);


-- =============================================================================================================
-- INDEXES
-- =============================================================================================================

-- -------------------------------------------------------
-- MODULE A: RECRUITMENT
-- -------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_JobPosting_Department
    ON hr.JobPosting (DepartmentId);

CREATE NONCLUSTERED INDEX IX_JobPosting_Status
    ON hr.JobPosting (JobPostingStatus);

CREATE NONCLUSTERED INDEX IX_Candidate_Email
    ON hr.Candidate (Email);

CREATE NONCLUSTERED INDEX IX_Application_JobPosting
    ON hr.Application (JobPostingId);

CREATE NONCLUSTERED INDEX IX_Application_Candidate
    ON hr.Application (CandidateId);

CREATE NONCLUSTERED INDEX IX_Application_Status
    ON hr.Application (ApplicationStatus);

CREATE NONCLUSTERED INDEX IX_AppStatusHistory_Application
    ON hr.ApplicationStatusHistory (ApplicationId, ChangedAt);

CREATE NONCLUSTERED INDEX IX_Interview_Application
    ON hr.Interview (ApplicationId);

CREATE NONCLUSTERED INDEX IX_InterviewPanel_Interview
    ON hr.InterviewPanel (InterviewId);

CREATE NONCLUSTERED INDEX IX_InterviewPanel_Interviewer
    ON hr.InterviewPanel (InterviewerEmployeeId);

CREATE NONCLUSTERED INDEX IX_InterviewFeedback_Panel
    ON hr.InterviewFeedback (InterviewPanelId);

CREATE NONCLUSTERED INDEX IX_PackageNegotiation_Application
    ON hr.PackageNegotiation (ApplicationId);

CREATE NONCLUSTERED INDEX IX_OfferLetter_Application
    ON hr.OfferLetter (ApplicationId);

-- -------------------------------------------------------
-- MODULE B: ONBOARDING
-- -------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OnboardingTask_Employee
    ON hr.OnboardingTask (EmployeeId, Phase)
    INCLUDE (TaskStatus, DueDate);

CREATE NONCLUSTERED INDEX IX_OnboardingTask_Status
    ON hr.OnboardingTask (TaskStatus)
    WHERE TaskStatus = 'PENDING';

CREATE NONCLUSTERED INDEX IX_DocVerification_Employee
    ON hr.DocumentVerification (EmployeeId, OnboardingPhase)
    INCLUDE (DocVerifyStatus);

CREATE NONCLUSTERED INDEX IX_DocVerification_Status
    ON hr.DocumentVerification (DocVerifyStatus);

CREATE NONCLUSTERED INDEX IX_BGV_Employee
    ON hr.BackgroundVerification (EmployeeId, OnboardingPhase)
    INCLUDE (BGVStatus, BGVResult);

-- -------------------------------------------------------
-- MODULE C: POLICY DOCUMENTS
-- -------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_PolicyDocument_Category
    ON hr.PolicyDocument (PolicyCategoryId);

CREATE NONCLUSTERED INDEX IX_PolicyDocument_Scope
    ON hr.PolicyDocument (ScopeTypeId, ScopeReferenceId);

CREATE NONCLUSTERED INDEX IX_PolicyVersion_Document
    ON hr.PolicyVersion (PolicyDocumentId, VersionNumber)
    INCLUDE (PolicyStatus, EffectiveDate);

CREATE NONCLUSTERED INDEX IX_PolicyVersion_Status
    ON hr.PolicyVersion (PolicyStatus);

CREATE NONCLUSTERED INDEX IX_PolicyAck_Employee
    ON hr.PolicyAcknowledgement (EmployeeId, AckStatus)
    INCLUDE (DeadlineDate);

CREATE NONCLUSTERED INDEX IX_PolicyAck_Pending
    ON hr.PolicyAcknowledgement (AckStatus)
    WHERE AckStatus = 'PENDING';

-- -------------------------------------------------------
-- MODULE D: SALARY SLIPS
-- -------------------------------------------------------
-- DisbursementTransactionId is already the PK/UQ — no additional index needed.
-- Status-based filtering for bulk publish operations:
CREATE NONCLUSTERED INDEX IX_SalarySlipPub_Status
    ON hr.SalarySlipPublication (SlipStatus)
    INCLUDE (DisbursementTransactionId, PublishedAt)
    WHERE SlipStatus IN ('DRAFT', 'PUBLISHED');

-- -------------------------------------------------------
-- MODULE E: PERFORMANCE REVIEWS
-- -------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_PerfCycle_Status
    ON hr.PerformanceCycle (CycleStatus);

CREATE NONCLUSTERED INDEX IX_Goal_Employee_Cycle
    ON hr.Goal (EmployeeId, PerformanceCycleId)
    INCLUDE (GoalStatus, WeightagePct, EmployeeRating, ManagerRating);

CREATE NONCLUSTERED INDEX IX_GoalKR_Goal
    ON hr.GoalKeyResult (GoalId)
    INCLUDE (KRStatus);

CREATE NONCLUSTERED INDEX IX_PerfReview_Employee_Cycle
    ON hr.PerformanceReview (EmployeeId, PerformanceCycleId)
    INCLUDE (ReviewStatus, FinalRating);

CREATE NONCLUSTERED INDEX IX_PerfReview_Status
    ON hr.PerformanceReview (ReviewStatus);

CREATE NONCLUSTERED INDEX IX_PerfReviewHistory_Review
    ON hr.PerformanceReviewHistory (PerformanceReviewId, ChangedAt);

-- -------------------------------------------------------
-- MODULE F: TRAINING RECORDS
-- -------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_TrainingProgram_Category
    ON hr.TrainingProgram (TrainingCategoryId);

CREATE NONCLUSTERED INDEX IX_TrainingBatch_Program
    ON hr.TrainingBatch (TrainingProgramId, BatchStatus);

CREATE NONCLUSTERED INDEX IX_EmpTrainingRecord_Employee
    ON hr.EmployeeTrainingRecord (EmployeeId, RecordStatus)
    INCLUDE (TrainingProgramId, CompletedDate, IsPassed);

CREATE NONCLUSTERED INDEX IX_EmpTrainingRecord_Program
    ON hr.EmployeeTrainingRecord (TrainingProgramId);

-- -------------------------------------------------------
-- MODULE G: EXIT MANAGEMENT
-- -------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_ExitRecord_Employee
    ON hr.ExitRecord (EmployeeId)
    INCLUDE (ExitType, ClearanceStatus, FinalSettlementStatus);

CREATE NONCLUSTERED INDEX IX_ExitRecord_ClearanceStatus
    ON hr.ExitRecord (ClearanceStatus);

CREATE NONCLUSTERED INDEX IX_ExitClearanceItem_ExitRecord
    ON hr.ExitClearanceItem (ExitRecordId, ItemStatus);


-- =============================================================================================================
-- VIEWS
-- =============================================================================================================

-- -------------------------------------------------------
-- vw_SalarySlipDetail
-- Assembles the complete payslip for display or PDF
-- generation by joining hr.SalarySlipPublication with the
-- payroll schema tables that own all financial data.
-- This view is the single query path for the payslip UI
-- and the PDF renderer — no application-layer joins needed.
-- -------------------------------------------------------
GO
CREATE OR ALTER VIEW hr.vw_SalarySlipDetail AS
SELECT
    ssp.Id                              AS SlipPublicationId,
    ssp.SlipStatus,
    sl.Label                            AS SlipStatusLabel,
    sl.IsTerminal                       AS IsSlipLocked,
    ssp.FileUrl,
    ssp.IsPasswordProtected,
    ssp.GeneratedAt,
    ssp.PublishedAt,
    ssp.FirstDownloadedAt,

    -- Employee identity (from dbo.Employee)
    e.Id                                AS EmployeeId,
    e.EmployeeCode,
    e.FirstName,
    e.LastName,
    e.DisplayName,
    e.Email,

    -- Payroll period & financial totals (from payroll.PayrollDisbursementTransaction)
    pdt.PayrollMonth,
    pdt.PayrollYear,
    pdt.GrossAmount                     AS GrossEarnings,
    pdt.TotalDeductions,
    pdt.NetAmountCredited               AS NetPayable,
    pdt.CurrencyCode,
    pdt.PaymentMode,
    pdt.BankTransactionId,

    -- Attendance summary (from payroll.PayrollAttendanceSummary)
    pas.TotalWorkingDays,
    pas.PresentDays,
    pas.LeaveDays,
    pas.AbsentDays,
    pas.OvertimeMinutes,

    -- Salary structure reference (from payroll.EmployeeSalary)
    es.AnnualCTC,
    es.MonthlyCTC,
    es.MonthlyGross,
    es.MonthlyNet

FROM hr.SalarySlipPublication ssp

INNER JOIN payroll.PayrollDisbursementTransaction pdt
    ON pdt.Id = ssp.DisbursementTransactionId

INNER JOIN dbo.Employee e
    ON e.Id = pdt.EmployeeId

INNER JOIN dbo.StatusLookup sl
    ON  sl.StatusCode  = ssp.SlipStatus
    AND sl.StatusGroup = 'SALARY_SLIP_STATUS'

LEFT JOIN payroll.PayrollAttendanceSummary pas
    ON  pas.EmployeeId    = pdt.EmployeeId
    AND pas.PayrollMonth  = pdt.PayrollMonth
    AND pas.PayrollYear   = pdt.PayrollYear

LEFT JOIN payroll.EmployeeSalary es
    ON  es.EmployeeId = pdt.EmployeeId
    AND es.IsActive   = 1;
GO
-- Note: Component-level line items (earnings/deductions breakdown) are queried
-- separately via payroll.EmployeeSalaryComponent filtered on
-- (EmployeeSalaryId, PayrollMonth, PayrollYear) and joined to
-- payroll.SalaryStructureComponent for ComponentCode, ComponentName, and IsEarning/IsDeduction.


-- =============================================================================================================
-- END OF SCHEMA: hr
-- =============================================================================================================