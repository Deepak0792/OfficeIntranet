-- HR SCHEMA - HR Lifecycle Management
-- SQL Server Database Schema
-- Schema: hr
-- Purpose: Recruitment, onboarding, policy documents, performance reviews, training, exit management
-- Dependencies: shared (StatusLookup), employee (Employee), time (DocumentType), workflow (WorkflowInstance)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'hr')
BEGIN
    EXEC('CREATE SCHEMA hr');
END
GO

-- MODULE A: RECRUITMENT & SELECTION
CREATE TABLE hr.InterviewRound (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    RoundNumber             SMALLINT             NOT NULL UNIQUE,
    RoundCode               NVARCHAR(50)    NOT NULL UNIQUE,
    RoundName               NVARCHAR(150)   NOT NULL,
    Description             NVARCHAR(1000)  NULL,
    InterviewType           NVARCHAR(50)    NULL,
    InterviewTypeGroup      AS CAST('INTERVIEW_TYPE' AS NVARCHAR(50)) PERSISTED,
    IsMandatory             BIT             NOT NULL DEFAULT 1,
    DisplayOrder            TINYINT         NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_InterviewRound_InterviewType
        FOREIGN KEY (InterviewType, InterviewTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.PanelRole (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    RoleCode            NVARCHAR(50)    NOT NULL UNIQUE,
    RoleName            NVARCHAR(150)   NOT NULL,
    Description         NVARCHAR(1000)  NULL,
    CanSubmitFeedback   BIT             NOT NULL DEFAULT 1,
    DisplayOrder        SMALLINT         NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,
);
GO

CREATE TABLE hr.JobPosting (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    Title               NVARCHAR(200)   NOT NULL,
    DepartmentId        SMALLINT          NOT NULL,
    DesignationId       SMALLINT          NOT NULL,
    LocationId          SMALLINT          NULL,
    LegalEntityId       SMALLINT          NULL,
    EmploymentType      NVARCHAR(50)    NOT NULL DEFAULT 'FULL_TIME',
    EmploymentTypeGroup AS CAST('EMPLOYMENT_TYPE' AS NVARCHAR(50)) PERSISTED,
    ExperienceMinYrs    DECIMAL(4,1)    NULL,
    ExperienceMaxYrs    DECIMAL(4,1)    NULL,
    SalaryMin           DECIMAL(18,2)   NULL,
    SalaryMax           DECIMAL(18,2)   NULL,
    CurrencyCode        NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    Description         NVARCHAR(MAX)   NULL,
    Requirements        NVARCHAR(MAX)   NULL,
    OpeningsCount       SMALLINT             NOT NULL DEFAULT 1,
    JobPostingStatus    NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    JobPostingStatusGroup AS CAST('JOB_POSTING_STATUS' AS NVARCHAR(50)) PERSISTED,
    ClosingDate         DATE            NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_JobPosting_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id),

    CONSTRAINT FK_JobPosting_Designation
        FOREIGN KEY (DesignationId)
        REFERENCES time.Designation(Id),

    CONSTRAINT FK_JobPosting_Location
        FOREIGN KEY (LocationId)
        REFERENCES time.OfficeLocation(Id),

    CONSTRAINT FK_JobPosting_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES time.LegalEntity(Id),

    CONSTRAINT FK_JobPosting_CreatedBy
        FOREIGN KEY (CreatedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Employee_EmploymentType
        FOREIGN KEY (EmploymentType, EmploymentTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_JobPosting_Status
        FOREIGN KEY (JobPostingStatus, JobPostingStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.Candidate (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
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
    NoticePeriodDays        SMALLINT             NULL,
    CurrentSalary           DECIMAL(18,2)   NULL,
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    LinkedInUrl             NVARCHAR(500)   NULL,
    ResumeUrl               NVARCHAR(1000)  NULL,
    Source                  NVARCHAR(100)   NULL,
    ReferredByEmployeeId    INT          NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_Candidate_ReferredBy
        FOREIGN KEY (ReferredByEmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

CREATE TABLE hr.Application (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    JobPostingId            INT          NOT NULL,
    CandidateId             INT          NOT NULL,
    ApplicationStatus       NVARCHAR(50)    NOT NULL DEFAULT 'APPLIED',
    ApplicationStatusGroup  AS CAST('APPLICATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    CoverLetter             NVARCHAR(MAX)   NULL,
    ReviewedByEmployeeId   INT          NULL,
    RejectionReason        NVARCHAR(2000)  NULL,
    AppliedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    AppliedBy               INT             NULL,
    StatusUpdatedAt         DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsActive                BIT             NOT NULL DEFAULT 1,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,
    
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
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Application_Status
        FOREIGN KEY (ApplicationStatus, ApplicationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.ApplicationStatusHistory (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId           INT          NOT NULL,
    FromStatus              NVARCHAR(50)    NULL,
    ToStatus                NVARCHAR(50)    NOT NULL,
    ChangedByEmployeeId     INT          NULL,
    Remarks                 NVARCHAR(2000)  NULL,
    ChangedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_AppStatusHistory_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES hr.Application(Id),

    CONSTRAINT FK_AppStatusHistory_ChangedBy
        FOREIGN KEY (ChangedByEmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

CREATE TABLE hr.InterviewRoundConfig (
    Id                  INT  PRIMARY KEY IDENTITY(1,1),
    JobPostingId        INT  NOT NULL,
    InterviewRoundId    SMALLINT  NOT NULL,
    InterviewType       NVARCHAR(50)    NULL,
    InterviewTypeGroup  AS CAST('INTERVIEW_TYPE' AS NVARCHAR(50)) PERSISTED,
    DurationMins        SMALLINT     NOT NULL DEFAULT 60,
    IsMandatory         BIT     NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT UQ_InterviewRoundConfig_JobRound
        UNIQUE (JobPostingId, InterviewRoundId),

    CONSTRAINT FK_IRC_JobPosting
        FOREIGN KEY (JobPostingId)
        REFERENCES hr.JobPosting(Id),

    CONSTRAINT FK_IRC_InterviewRound
        FOREIGN KEY (InterviewRoundId)
        REFERENCES hr.InterviewRound(Id),

    CONSTRAINT FK_InterviewRoundConfig_InterviewType
        FOREIGN KEY (InterviewType, InterviewTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.Interview (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId               INT          NOT NULL,
    InterviewRoundConfigId      INT          NOT NULL,
    ScheduledAt                 DATETIME2       NULL,
    DurationMins                SMALLINT             NOT NULL DEFAULT 60,
    MeetingLink                 NVARCHAR(1000)  NULL,
    Venue                       NVARCHAR(500)   NULL,
    InterviewStatus             NVARCHAR(50)    NOT NULL DEFAULT 'SCHEDULED',
    InterviewStatusGroup        AS CAST('INTERVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
    RescheduledToInterviewId    INT          NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

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
        FOREIGN KEY (CreatedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Interview_Status
        FOREIGN KEY (InterviewStatus, InterviewStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.InterviewPanel (
    Id                      INT      PRIMARY KEY IDENTITY(1,1),
    InterviewId             INT      NOT NULL,
    InterviewerEmployeeId   INT      NOT NULL,
    PanelRoleId             SMALLINT      NOT NULL,
    InterviewPurpose        NVARCHAR(50)    NOT NULL,
    InterviewPurposeGroup   AS CAST('INTERVIEW_PURPOSE' AS NVARCHAR(50)) PERSISTED,
    EvaluationTopics        NVARCHAR(MAX) NULL,
    IsLead                  BIT         NOT NULL DEFAULT 0,
    CanSubmitFeedback       BIT         NOT NULL DEFAULT 1,
    ConfirmedAt             DATETIME2   NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT UQ_InterviewPanel_Interviewer
        UNIQUE (InterviewId, InterviewerEmployeeId),

    CONSTRAINT FK_InterviewPanel_Interview
        FOREIGN KEY (InterviewId)
        REFERENCES hr.Interview(Id),

    CONSTRAINT FK_InterviewPanel_Interviewer
        FOREIGN KEY (InterviewerEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_InterviewPanel_PanelRole
        FOREIGN KEY (PanelRoleId)
        REFERENCES hr.PanelRole(Id),

    CONSTRAINT FK_InterviewPanel_InterviewPurpose
        FOREIGN KEY (InterviewPurpose, InterviewPurposeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.InterviewFeedback (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    InterviewPanelId        INT          NOT NULL UNIQUE,
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
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_InterviewFeedback_Panel
        FOREIGN KEY (InterviewPanelId)
        REFERENCES hr.InterviewPanel(Id),

    CONSTRAINT FK_InterviewFeedback_Recommendation
        FOREIGN KEY (RecommendationStatus, RecommendationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.PackageNegotiation (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId           INT          NOT NULL,
    HREmployeeId            INT          NOT NULL,
    RoundNumber             SMALLINT             NOT NULL DEFAULT 1,
    OfferedCTC              DECIMAL(18,2)   NOT NULL,
    CandidateAsk            DECIMAL(18,2)   NULL,
    FinalCTC                DECIMAL(18,2)   NULL,
    CurrencyCode            NVARCHAR(10)    NOT NULL DEFAULT 'INR',
    VariablePct             DECIMAL(5,2)    NULL,
    JoiningBonus            DECIMAL(18,2)   NULL,
    OtherBenefits           NVARCHAR(MAX)   NULL,
    NegotiationStatus       NVARCHAR(50)    NOT NULL DEFAULT 'IN_PROGRESS',
    NegotiationStatusGroup  AS CAST('NEGOTIATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    Notes                   NVARCHAR(MAX)   NULL,
    NegotiatedAt            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_PackageNegotiation_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES hr.Application(Id),

    CONSTRAINT FK_PackageNegotiation_HREmployee
        FOREIGN KEY (HREmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PackageNegotiation_Status
        FOREIGN KEY (NegotiationStatus, NegotiationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.OfferLetter (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    ApplicationId           INT          NOT NULL,
    PackageNegotiationId    INT          NULL,
    LetterFileUrl           NVARCHAR(1000)  NOT NULL,
    IssuedDate              DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    ExpiryDate              DATE            NOT NULL,
    OfferedPosition         NVARCHAR(200)   NULL,
    ProposedJoiningDate     DATE            NULL,
    OfferStatus             NVARCHAR(50)    NOT NULL DEFAULT 'ISSUED',
    OfferStatusGroup        AS CAST('OFFER_STATUS' AS NVARCHAR(50)) PERSISTED,
    AcceptedAt              DATETIME2       NULL,
    RevokedReason           NVARCHAR(2000)  NULL,
    IssuedByEmployeeId      INT          NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_OfferLetter_Application
        FOREIGN KEY (ApplicationId)
        REFERENCES hr.Application(Id),

    CONSTRAINT FK_OfferLetter_PackageNegotiation
        FOREIGN KEY (PackageNegotiationId)
        REFERENCES hr.PackageNegotiation(Id),

    CONSTRAINT FK_OfferLetter_IssuedBy
        FOREIGN KEY (IssuedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_OfferLetter_Status
        FOREIGN KEY (OfferStatus, OfferStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE B: ONBOARDING
CREATE TABLE hr.OnboardingChecklist (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    ChecklistName   NVARCHAR(200)   NOT NULL,
    Phase           NVARCHAR(50)    NOT NULL,
    EmploymentType  NVARCHAR(50)    NOT NULL DEFAULT 'FULL_TIME',
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL
);
GO

CREATE TABLE hr.OnboardingChecklistItem (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    OnboardingChecklistId   SMALLINT          NOT NULL,
    TaskName                NVARCHAR(250)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    OwnerRole               NVARCHAR(50)    NULL,
    DisplayOrder            SMALLINT             NOT NULL DEFAULT 0,
    IsMandatory             BIT             NOT NULL DEFAULT 1,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_OnboardingChecklistItem_Checklist
        FOREIGN KEY (OnboardingChecklistId)
        REFERENCES hr.OnboardingChecklist(Id)
);
GO

CREATE TABLE hr.OnboardingTask (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                  INT          NOT NULL,
    OnboardingChecklistItemId   SMALLINT          NULL,
    TaskName                    NVARCHAR(250)   NOT NULL,
    Phase                       NVARCHAR(50)    NOT NULL,
    OwnerRole                   NVARCHAR(50)    NULL,
    TaskStatus                  NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    TaskStatusGroup             AS CAST('ONBOARDING_TASK_STATUS' AS NVARCHAR(50)) PERSISTED,
    DueDate                     DATE            NULL,
    CompletedDate               DATE            NULL,
    CompletedByEmployeeId       INT          NULL,
    Remarks                     NVARCHAR(2000)  NULL,
    WorkflowInstanceId          INT          NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

    CONSTRAINT FK_OnboardingTask_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_OnboardingTask_ChecklistItem
        FOREIGN KEY (OnboardingChecklistItemId)
        REFERENCES hr.OnboardingChecklistItem(Id),

    CONSTRAINT FK_OnboardingTask_CompletedBy
        FOREIGN KEY (CompletedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_OnboardingTask_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_OnboardingTask_Status
        FOREIGN KEY (TaskStatus, TaskStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.DocumentVerification (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT          NOT NULL,
    DocumentTypeId          SMALLINT          NOT NULL,
    OnboardingPhase         NVARCHAR(50)    NOT NULL DEFAULT 'PRE_ONBOARDING',
    OnboardingPhaseGroup    AS CAST('ONBOARDING_PHASE' AS NVARCHAR(50)) PERSISTED,
    FileUrl                 NVARCHAR(1000)  NULL,
    DocumentNumber          NVARCHAR(100)   NULL,
    IssuedBy                NVARCHAR(200)   NULL,
    IssueDate               DATE            NULL,
    ExpiryDate              DATE            NULL,
    DocVerifyStatus         NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    DocVerifyStatusGroup    AS CAST('DOC_VERIFY_STATUS' AS NVARCHAR(50)) PERSISTED,
    SubmittedDate           DATE            NULL,
    VerifiedDate            DATE            NULL,
    VerifiedByEmployeeId    INT          NULL,
    RejectionReason         NVARCHAR(2000)  NULL,
    Remarks                 NVARCHAR(2000)  NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_DocVerification_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_DocVerification_DocumentType
        FOREIGN KEY (DocumentTypeId)
        REFERENCES time.DocumentType(Id),

    CONSTRAINT FK_DocVerification_VerifiedBy
        FOREIGN KEY (VerifiedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_DocVerification_Status
        FOREIGN KEY (DocVerifyStatus, DocVerifyStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_DocVerification_Phase
        FOREIGN KEY (OnboardingPhase, OnboardingPhaseGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.BGVAgency (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    AgencyName      NVARCHAR(200)   NOT NULL UNIQUE,
    ContactPerson   NVARCHAR(200)   NULL,
    Email           NVARCHAR(255)   NULL,
    Phone           NVARCHAR(30)    NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL
);
GO

CREATE TABLE hr.BackgroundVerification (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT          NOT NULL,
    BGVAgencyId             INT          NULL,
    BGVCheckType            NVARCHAR(50)    NOT NULL,
    BGVCheckTypeGroup       AS CAST('BGV_CHECK_TYPE' AS NVARCHAR(50)) PERSISTED,
    OnboardingPhase         NVARCHAR(50)    NOT NULL DEFAULT 'PRE_ONBOARDING',
    OnboardingPhaseGroup    AS CAST('ONBOARDING_PHASE' AS NVARCHAR(50)) PERSISTED,
    ReferenceName           NVARCHAR(200)   NULL,
    ReferenceContact        NVARCHAR(200)   NULL,
    InitiatedByEmployeeId   INT          NULL,
    InitiatedDate           DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    ExpectedDate            DATE            NULL,
    CompletedDate           DATE            NULL,
    BGVStatus               NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    BGVStatusGroup          AS CAST('BGV_STATUS' AS NVARCHAR(50)) PERSISTED,
    BGVResult               NVARCHAR(50)    NULL,
    BGVResultGroup          AS CAST('BGV_RESULT' AS NVARCHAR(50)) PERSISTED,
    Findings                NVARCHAR(MAX)   NULL,
    ReportUrl               NVARCHAR(1000)  NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_BGV_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_BGV_Agency
        FOREIGN KEY (BGVAgencyId)
        REFERENCES hr.BGVAgency(Id),

    CONSTRAINT FK_BGV_InitiatedBy
        FOREIGN KEY (InitiatedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_BGV_CheckType
        FOREIGN KEY (BGVCheckType, BGVCheckTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_BGV_Phase
        FOREIGN KEY (OnboardingPhase, OnboardingPhaseGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_BGV_Status
        FOREIGN KEY (BGVStatus, BGVStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_BGV_Result
        FOREIGN KEY (BGVResult, BGVResultGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE C: POLICY DOCUMENTS
CREATE TABLE hr.PolicyCategory (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode    NVARCHAR(50)    NOT NULL UNIQUE,
    CategoryName    NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL
);
GO

CREATE TABLE hr.PolicyDocument (
    Id                          SMALLINT          PRIMARY KEY IDENTITY(1,1),
    PolicyCategoryId            SMALLINT          NOT NULL,
    PolicyCode                  NVARCHAR(50)    NOT NULL UNIQUE,
    PolicyName                  NVARCHAR(300)   NOT NULL,
    Description                 NVARCHAR(MAX)   NULL,
    ScopeTypeId                 SMALLINT          NULL,
    ScopeReferenceId            INT          NULL,
    AcknowledgementRequired     BIT             NOT NULL DEFAULT 1,
    AcknowledgementDeadlineDays INT             NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

    CONSTRAINT FK_PolicyDocument_Category
        FOREIGN KEY (PolicyCategoryId)
        REFERENCES hr.PolicyCategory(Id),

    CONSTRAINT FK_PolicyDocument_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES time.ScopeType(Id),

    CONSTRAINT FK_PolicyDocument_CreatedBy
        FOREIGN KEY (CreatedBy)
        REFERENCES employee.Employee(Id)
);
GO

CREATE TABLE hr.PolicyVersion (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    PolicyDocumentId        SMALLINT          NOT NULL,
    VersionNumber           SMALLINT             NOT NULL,
    VersionLabel            NVARCHAR(50)    NULL,
    FileUrl                 NVARCHAR(1000)  NOT NULL,
    OriginalFileName        NVARCHAR(500)   NULL,
    ChangeNotes             NVARCHAR(MAX)   NULL,
    PolicyStatus            NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    PolicyStatusGroup       AS CAST('POLICY_STATUS' AS NVARCHAR(50)) PERSISTED,
    EffectiveDate           DATE            NULL,
    SupersededByVersionId   SMALLINT          NULL,
    PublishedByEmployeeId   INT          NULL,
    PublishedAt             DATETIME2       NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

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
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PolicyVersion_Status
        FOREIGN KEY (PolicyStatus, PolicyStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.PolicyAcknowledgement (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    PolicyVersionId     SMALLINT          NOT NULL,
    EmployeeId          INT          NOT NULL,
    AckStatus           NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    AckStatusGroup      AS CAST('POLICY_ACK_STATUS' AS NVARCHAR(50)) PERSISTED,
    DeadlineDate        DATE            NULL,
    AcknowledgedAt      DATETIME2       NULL,
    IPAddress           NVARCHAR(50)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT UQ_PolicyAcknowledgement
        UNIQUE (PolicyVersionId, EmployeeId),

    CONSTRAINT FK_PolicyAck_PolicyVersion
        FOREIGN KEY (PolicyVersionId)
        REFERENCES hr.PolicyVersion(Id),

    CONSTRAINT FK_PolicyAck_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PolicyAck_Status
        FOREIGN KEY (AckStatus, AckStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE D: PERFORMANCE REVIEWS
CREATE TABLE hr.PerformanceCycle (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    CycleName               NVARCHAR(150)   NOT NULL UNIQUE,
    CycleType               NVARCHAR(50)    NOT NULL DEFAULT 'ANNUAL',
    CycleTypeGroup          AS CAST('PERF_CYCLE_TYPE' AS NVARCHAR(50)) PERSISTED,
    StartDate               DATE            NOT NULL,
    EndDate                 DATE            NOT NULL,
    GoalSettingDeadline     DATE            NULL,
    ReviewStartDate         DATE            NULL,
    ReviewEndDate           DATE            NULL,
    CycleStatus             NVARCHAR(50)    NOT NULL DEFAULT 'UPCOMING',
    CycleStatusGroup        AS CAST('PERF_CYCLE_STATUS' AS NVARCHAR(50)) PERSISTED,
    LegalEntityId           SMALLINT          NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_PerfCycle_LegalEntity
        FOREIGN KEY (LegalEntityId)
        REFERENCES time.LegalEntity(Id),

    CONSTRAINT FK_PerfCycle_CreatedBy
        FOREIGN KEY (CreatedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PerfCycle_CycleType
        FOREIGN KEY (CycleType, CycleTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_PerfCycle_Status
        FOREIGN KEY (CycleStatus, CycleStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.Goal (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT          NOT NULL,
    PerformanceCycleId      SMALLINT          NOT NULL,
    Title                   NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    Category                NVARCHAR(100)   NULL,
    WeightagePct            DECIMAL(5,2)    NOT NULL DEFAULT 0
        CONSTRAINT CK_Goal_Weightage CHECK (WeightagePct BETWEEN 0 AND 100),
    TargetDate              DATE            NULL,
    GoalStatus              NVARCHAR(50)    NOT NULL DEFAULT 'DRAFT',
    GoalStatusGroup         AS CAST('GOAL_STATUS' AS NVARCHAR(50)) PERSISTED,
    ProgressPct             SMALLINT             NOT NULL DEFAULT 0
        CONSTRAINT CK_Goal_Progress CHECK (ProgressPct BETWEEN 0 AND 100),
    EmployeeRating          DECIMAL(3,1)    NULL,
    ManagerRating           DECIMAL(3,1)    NULL,
    ApprovedByEmployeeId    INT          NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_Goal_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Goal_PerfCycle
        FOREIGN KEY (PerformanceCycleId)
        REFERENCES hr.PerformanceCycle(Id),

    CONSTRAINT FK_Goal_ApprovedBy
        FOREIGN KEY (ApprovedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Goal_Status
        FOREIGN KEY (GoalStatus, GoalStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.GoalKeyResult (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    GoalId          INT          NOT NULL,
    Description     NVARCHAR(MAX)   NOT NULL,
    TargetValue     NVARCHAR(200)   NULL,
    ActualValue     NVARCHAR(200)   NULL,
    KRStatus        NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    KRStatusGroup   AS CAST('GOAL_KR_STATUS' AS NVARCHAR(50)) PERSISTED,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy       INT             NULL,
    LastUpdatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy   INT             NULL,

    CONSTRAINT FK_GoalKR_Goal
        FOREIGN KEY (GoalId)
        REFERENCES hr.Goal(Id),

    CONSTRAINT FK_GoalKR_Status
        FOREIGN KEY (KRStatus, KRStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.PerformanceReview (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                  INT          NOT NULL,
    PerformanceCycleId          SMALLINT          NOT NULL,
    ReviewerEmployeeId          INT          NOT NULL,
    SelfRating                  DECIMAL(3,1)    NULL,
    ManagerRating               DECIMAL(3,1)    NULL,
    FinalRating                 DECIMAL(3,1)    NULL,
    PerformanceBand             NVARCHAR(50)    NULL,
    SelfComments                NVARCHAR(MAX)   NULL,
    ManagerComments             NVARCHAR(MAX)   NULL,
    HRBPComments                NVARCHAR(MAX)   NULL,
    ReviewStatus                NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ReviewStatusGroup           AS CAST('PERF_REVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
    SelfSubmittedAt             DATETIME2       NULL,
    ManagerSubmittedAt         DATETIME2       NULL,
    CompletedAt                 DATETIME2       NULL,
    WorkflowInstanceId          INT          NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

    CONSTRAINT UQ_PerformanceReview_EmployeeCycle
        UNIQUE (EmployeeId, PerformanceCycleId),

    CONSTRAINT FK_PerfReview_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PerfReview_PerfCycle
        FOREIGN KEY (PerformanceCycleId)
        REFERENCES hr.PerformanceCycle(Id),

    CONSTRAINT FK_PerfReview_Reviewer
        FOREIGN KEY (ReviewerEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_PerfReview_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_PerfReview_Status
        FOREIGN KEY (ReviewStatus, ReviewStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.PerformanceReviewHistory (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    PerformanceReviewId     INT          NOT NULL,
    FromStatus              NVARCHAR(50)    NULL,
    ToStatus                NVARCHAR(50)    NOT NULL,
    ChangedByEmployeeId     INT          NULL,
    Remarks                 NVARCHAR(2000)  NULL,
    ChangedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_PerfReviewHistory_Review
        FOREIGN KEY (PerformanceReviewId)
        REFERENCES hr.PerformanceReview(Id),

    CONSTRAINT FK_PerfReviewHistory_ChangedBy
        FOREIGN KEY (ChangedByEmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

-- MODULE E: TRAINING RECORDS
CREATE TABLE hr.TrainingProgram (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    TrainingCategory        NVARCHAR(50)          NOT NULL,
    TrainingCategoryGroup   AS CAST('TRAINING_CATEGORY' AS NVARCHAR(50)) PERSISTED,
    ProgramCode             NVARCHAR(50)    NOT NULL UNIQUE,
    Title                   NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    TrainingMode            NVARCHAR(50)    NOT NULL DEFAULT 'ONLINE',
    TrainingModeGroup       AS CAST('TRAINING_MODE' AS NVARCHAR(50)) PERSISTED,
    DurationHours           DECIMAL(6,2)    NULL,
    Provider                NVARCHAR(200)   NULL,
    IsMandatory             BIT             NOT NULL DEFAULT 0,
    ApplicableTo            NVARCHAR(100)   NULL,
    MaxParticipants         SMALLINT             NULL,
    CertificateProvided     BIT             NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_TrainingProgram_TrainingCategory
        FOREIGN KEY (TrainingCategory, TrainingCategoryGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_TrainingProgram_Mode
        FOREIGN KEY (TrainingMode, TrainingModeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.TrainingBatch (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    TrainingProgramId       SMALLINT          NOT NULL,
    BatchName               NVARCHAR(200)   NULL,
    FacilitatorEmployeeId   INT          NULL,
    StartDate               DATE            NOT NULL,
    EndDate                 DATE            NULL,
    VenueOrLink             NVARCHAR(1000)  NULL,
    MaxSeats                SMALLINT             NULL,
    BatchStatus             NVARCHAR(50)    NOT NULL DEFAULT 'UPCOMING',
    BatchStatusGroup        AS CAST('TRAINING_BATCH_STATUS' AS NVARCHAR(50)) PERSISTED,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_TrainingBatch_Program
        FOREIGN KEY (TrainingProgramId)
        REFERENCES hr.TrainingProgram(Id),

    CONSTRAINT FK_TrainingBatch_Facilitator
        FOREIGN KEY (FacilitatorEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_TrainingBatch_Status
        FOREIGN KEY (BatchStatus, BatchStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.EmployeeTrainingRecord (
    Id                      INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT          NOT NULL,
    TrainingProgramId       SMALLINT          NOT NULL,
    TrainingBatchId         SMALLINT          NULL,
    EnrolledDate            DATE            NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    CompletedDate           DATE            NULL,
    RecordStatus            NVARCHAR(50)    NOT NULL DEFAULT 'ENROLLED',
    RecordStatusGroup       AS CAST('TRAINING_RECORD_STATUS' AS NVARCHAR(50)) PERSISTED,
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
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_EmpTrainingRecord_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmpTrainingRecord_Program
        FOREIGN KEY (TrainingProgramId)
        REFERENCES hr.TrainingProgram(Id),

    CONSTRAINT FK_EmpTrainingRecord_Batch
        FOREIGN KEY (TrainingBatchId)
        REFERENCES hr.TrainingBatch(Id),

    CONSTRAINT FK_EmpTrainingRecord_Status
        FOREIGN KEY (RecordStatus, RecordStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- MODULE F: EXIT MANAGEMENT
CREATE TABLE hr.ExitReason (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    ReasonText          NVARCHAR(200)   NOT NULL UNIQUE,
    Category            NVARCHAR(20)    NOT NULL
        CONSTRAINT CK_ExitReason_Category CHECK (Category IN ('VOLUNTARY', 'INVOLUNTARY')),
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

CREATE TABLE hr.ExitRecord (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId                  INT          NOT NULL UNIQUE,
    ExitReasonId                SMALLINT         NULL,
    ExitType                    NVARCHAR(50)    NOT NULL DEFAULT 'RESIGNATION',
    ExitTypeGroup               AS CAST('EXIT_TYPE' AS NVARCHAR(50)) PERSISTED,
    AdditionalReason            NVARCHAR(MAX)   NULL,
    ResignationDate             DATE            NULL,
    LastWorkingDate             DATE            NULL,
    NoticePeriodDays            SMALLINT             NULL,
    IsNoticeWaived              BIT             NOT NULL DEFAULT 0,
    ExitInterviewStatus         NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ExitInterviewStatusGroup    AS CAST('EXIT_INTERVIEW_STATUS' AS NVARCHAR(50)) PERSISTED,
    ExitInterviewDate           DATE            NULL,
    ConductedByEmployeeId       INT          NULL,
    ExitFeedback                NVARCHAR(MAX)   NULL,
    IsRehireEligible            BIT             NOT NULL DEFAULT 1,
    ClearanceStatus             NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ClearanceStatusGroup        AS CAST('CLEARANCE_STATUS' AS NVARCHAR(50)) PERSISTED,
    FinalSettlementStatus       NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    FinalSettlementStatusGroup  AS CAST('FINAL_SETTLEMENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    FinalSettlementDate         DATE            NULL,
    WorkflowInstanceId          INT          NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

    CONSTRAINT FK_ExitRecord_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExitRecord_ExitReason
        FOREIGN KEY (ExitReasonId)
        REFERENCES hr.ExitReason(Id),

    CONSTRAINT FK_ExitRecord_ConductedBy
        FOREIGN KEY (ConductedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExitRecord_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),

    CONSTRAINT FK_ExitRecord_CreatedBy
        FOREIGN KEY (CreatedBy)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExitRecord_ExitType
        FOREIGN KEY (ExitType, ExitTypeGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExitRecord_ExitInterviewStatus
        FOREIGN KEY (ExitInterviewStatus, ExitInterviewStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExitRecord_ClearanceStatus
        FOREIGN KEY (ClearanceStatus, ClearanceStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup),

    CONSTRAINT FK_ExitRecord_SettlementStatus
        FOREIGN KEY (FinalSettlementStatus, FinalSettlementStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

CREATE TABLE hr.ExitClearanceItem (
    Id                          INT          PRIMARY KEY IDENTITY(1,1),
    ExitRecordId                INT          NOT NULL,
    ItemName                    NVARCHAR(200)   NOT NULL,
    OwnerDepartment             NVARCHAR(100)   NULL,
    ItemStatus                  NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    ItemStatusGroup             AS CAST('CLEARANCE_ITEM_STATUS' AS NVARCHAR(50)) PERSISTED,
    CompletedByEmployeeId       INT          NULL,
    CompletedAt                 DATETIME2       NULL,
    Remarks                     NVARCHAR(2000)  NULL,
    IsActive                    BIT             NOT NULL DEFAULT 1,
    CreatedAt                   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                   INT             NULL,
    LastUpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy               INT             NULL,

    CONSTRAINT FK_ExitClearanceItem_ExitRecord
        FOREIGN KEY (ExitRecordId)
        REFERENCES hr.ExitRecord(Id),

    CONSTRAINT FK_ExitClearanceItem_CompletedBy
        FOREIGN KEY (CompletedByEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ExitClearanceItem_Status
        FOREIGN KEY (ItemStatus, ItemStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- INDEXES - hr Schema
CREATE INDEX IX_JobPosting_Department     ON hr.JobPosting (DepartmentId);
CREATE INDEX IX_JobPosting_Status         ON hr.JobPosting (JobPostingStatus);
CREATE INDEX IX_JobPosting_Location       ON hr.JobPosting (LocationId);

CREATE INDEX IX_Candidate_Email           ON hr.Candidate (Email);
CREATE INDEX IX_Candidate_Source         ON hr.Candidate (Source);

CREATE INDEX IX_Application_JobPosting    ON hr.Application (JobPostingId);
CREATE INDEX IX_Application_Candidate    ON hr.Application (CandidateId);
CREATE INDEX IX_Application_Status      ON hr.Application (ApplicationStatus);

CREATE INDEX IX_AppStatusHistory_Application ON hr.ApplicationStatusHistory (ApplicationId, ChangedAt);

CREATE INDEX IX_Interview_Application     ON hr.Interview (ApplicationId);
CREATE INDEX IX_Interview_Status         ON hr.Interview (InterviewStatus);

CREATE INDEX IX_InterviewPanel_Interview     ON hr.InterviewPanel (InterviewId);
CREATE INDEX IX_InterviewPanel_Interviewer   ON hr.InterviewPanel (InterviewerEmployeeId);

CREATE INDEX IX_InterviewFeedback_Panel      ON hr.InterviewFeedback (InterviewPanelId);

CREATE INDEX IX_PackageNegotiation_Application ON hr.PackageNegotiation (ApplicationId);

CREATE INDEX IX_OnboardingTask_Employee      ON hr.OnboardingTask (EmployeeId, Phase);
CREATE INDEX IX_OnboardingTask_Status       ON hr.OnboardingTask (TaskStatus);

CREATE INDEX IX_DocVerification_Employee     ON hr.DocumentVerification (EmployeeId, OnboardingPhase);
CREATE INDEX IX_DocVerification_Status      ON hr.DocumentVerification (DocVerifyStatus);

CREATE INDEX IX_BGV_Employee                 ON hr.BackgroundVerification (EmployeeId, OnboardingPhase);
CREATE INDEX IX_BGV_Status                  ON hr.BackgroundVerification (BGVStatus);

CREATE INDEX IX_PolicyDocument_Category     ON hr.PolicyDocument (PolicyCategoryId);
CREATE INDEX IX_PolicyVersion_Document      ON hr.PolicyVersion (PolicyDocumentId, VersionNumber);
CREATE INDEX IX_PolicyVersion_Status         ON hr.PolicyVersion (PolicyStatus);
CREATE INDEX IX_PolicyAck_Employee          ON hr.PolicyAcknowledgement (EmployeeId, AckStatus);

CREATE INDEX IX_PerfCycle_Status            ON hr.PerformanceCycle (CycleStatus);
CREATE INDEX IX_Goal_Employee_Cycle         ON hr.Goal (EmployeeId, PerformanceCycleId);
CREATE INDEX IX_GoalKR_Goal                  ON hr.GoalKeyResult (GoalId);
CREATE INDEX IX_PerfReview_Employee_Cycle    ON hr.PerformanceReview (EmployeeId, PerformanceCycleId);
CREATE INDEX IX_PerfReview_Status            ON hr.PerformanceReview (ReviewStatus);

CREATE INDEX IX_TrainingBatch_Program       ON hr.TrainingBatch (TrainingProgramId, BatchStatus);
CREATE INDEX IX_EmpTrainingRecord_Employee  ON hr.EmployeeTrainingRecord (EmployeeId, RecordStatus);
CREATE INDEX IX_EmpTrainingRecord_Program   ON hr.EmployeeTrainingRecord (TrainingProgramId);

CREATE INDEX IX_ExitRecord_Employee         ON hr.ExitRecord (EmployeeId);
CREATE INDEX IX_ExitRecord_ClearanceStatus  ON hr.ExitRecord (ClearanceStatus);
CREATE INDEX IX_ExitClearanceItem_ExitRecord ON hr.ExitClearanceItem (ExitRecordId, ItemStatus);

PRINT 'HR schema created successfully';
GO