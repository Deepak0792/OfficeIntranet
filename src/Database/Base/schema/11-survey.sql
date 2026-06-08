
-- SURVEYS & FEEDBACK SCHEMA - Surveys, Polls, and Anonymous Feedback
-- SQL Server Database Schema
-- Schema: survey
-- Purpose: Collect employee satisfaction feedback, polls, anonymous suggestions
-- Dependencies: shared (StatusLookup), time (Department), employee (Employee)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'survey')
BEGIN
    EXEC('CREATE SCHEMA survey');
END
GO


-- SEED STATUS CODES - Survey-specific status groups

-- Survey Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'DRAFT' AND StatusGroup = 'SURVEY_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('DRAFT', 'SURVEY_STATUS', 'Draft', 'Survey created but not published', 1, 0),
    ('PUBLISHED', 'SURVEY_STATUS', 'Published', 'Survey published and open for responses', 2, 0),
    ('CLOSED', 'SURVEY_STATUS', 'Closed', 'Survey closed for responses', 3, 1),
    ('ARCHIVED', 'SURVEY_STATUS', 'Archived', 'Survey archived', 4, 1);
END
GO

-- Question Type
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'RATING_SCALE' AND StatusGroup = 'QUESTION_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('RATING_SCALE', 'QUESTION_TYPE', 'Rating Scale', '1-5 or 1-10 rating', 1, 0),
    ('MULTIPLE_CHOICE', 'QUESTION_TYPE', 'Multiple Choice', 'Select one from options', 2, 0),
    ('MULTI_SELECT', 'QUESTION_TYPE', 'Multi-Select', 'Select multiple options', 3, 0),
    ('TEXT', 'QUESTION_TYPE', 'Text', 'Free text response', 4, 0),
    ('YES_NO', 'QUESTION_TYPE', 'Yes/No', 'Binary yes/no question', 5, 0),
    ('EMOJI_SENTIMENT', 'QUESTION_TYPE', 'Emoji Sentiment', 'Emoji-based sentiment', 6, 0),
    ('DATE', 'QUESTION_TYPE', 'Date', 'Date picker response', 7, 0),
    ('NUMBER', 'QUESTION_TYPE', 'Number', 'Numeric input', 8, 0);
END
GO

-- Poll Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'ACTIVE' AND StatusGroup = 'POLL_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('ACTIVE', 'POLL_STATUS', 'Active', 'Poll is open for voting', 1, 0),
    ('CLOSED', 'POLL_STATUS', 'Closed', 'Poll voting closed', 2, 1),
    ('ARCHIVED', 'POLL_STATUS', 'Archived', 'Poll archived', 3, 1);
END
GO

-- Poll Type
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'SINGLE_CHOICE' AND StatusGroup = 'POLL_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('SINGLE_CHOICE', 'POLL_TYPE', 'Single Choice', 'Vote for one option', 1, 0),
    ('MULTIPLE_CHOICE', 'POLL_TYPE', 'Multiple Choice', 'Vote for multiple options', 2, 0);
END
GO

-- Feedback Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'SUBMITTED' AND StatusGroup = 'FEEDBACK_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('SUBMITTED', 'FEEDBACK_STATUS', 'Submitted', 'Feedback submitted', 1, 0),
    ('UNDER_REVIEW', 'FEEDBACK_STATUS', 'Under Review', 'Being reviewed by admin', 2, 0),
    ('IN_PROGRESS', 'FEEDBACK_STATUS', 'In Progress', 'Action being taken', 3, 0),
    ('RESOLVED', 'FEEDBACK_STATUS', 'Resolved', 'Feedback resolved', 4, 1),
    ('ESCALATED', 'FEEDBACK_STATUS', 'Escalated', 'Escalated to higher authority', 5, 0),
    ('REJECTED', 'FEEDBACK_STATUS', 'Rejected', 'Feedback rejected', 6, 1);
END
GO

-- Feedback Category
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'WORKPLACE_CULTURE' AND StatusGroup = 'FEEDBACK_CATEGORY')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('WORKPLACE_CULTURE', 'FEEDBACK_CATEGORY', 'Workplace Culture', 'Issues related to work environment', 1, 0),
    ('MANAGER_CONCERNS', 'FEEDBACK_CATEGORY', 'Manager Concerns', 'Issues with direct manager', 2, 0),
    ('HARASSMENT', 'FEEDBACK_CATEGORY', 'Harassment', 'Harassment complaints', 3, 0),
    ('POLICY_IMPROVEMENT', 'FEEDBACK_CATEGORY', 'Policy Improvement', 'Suggestions for policy changes', 4, 0),
    ('INFRASTRUCTURE', 'FEEDBACK_CATEGORY', 'Infrastructure', 'Facilities and equipment issues', 5, 0),
    ('GENERAL_SUGGESTION', 'FEEDBACK_CATEGORY', 'General Suggestion', 'General improvement suggestions', 6, 0),
    ('ETHICS_VIOLATION', 'FEEDBACK_CATEGORY', 'Ethics Violation', 'Ethics and compliance issues', 7, 0),
    ('OTHER', 'FEEDBACK_CATEGORY', 'Other', 'Other feedback', 8, 0);
END
GO

-- Target Type (for SurveyTarget and PollTarget)
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'ALL' AND StatusGroup = 'TARGET_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('ALL', 'TARGET_TYPE', 'All', 'All employees', 1, 0),
    ('DEPARTMENT', 'TARGET_TYPE', 'Department', 'Target by department', 2, 0),
    ('LOCATION', 'TARGET_TYPE', 'Location', 'Target by office location', 3, 0),
    ('EMPLOYEE', 'TARGET_TYPE', 'Specific Employee', 'Target specific employees', 4, 0);
END
GO


-- SURVEY - Main survey entity
CREATE TABLE survey.Survey (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    SurveyCode              NVARCHAR(50)    NOT NULL UNIQUE,
    Title                   NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    Instructions            NVARCHAR(MAX)   NULL,
    CreatedById             UNIQUEIDENTIFIER          NOT NULL,
    StartDate               DATE            NOT NULL,
    EndDate                 DATE            NOT NULL,
    IsAnonymous             BIT             NOT NULL DEFAULT 0,
    IsMultipleResponses     BIT             NOT NULL DEFAULT 0,
    AllowSaveResume         BIT             NOT NULL DEFAULT 1,
    SendReminders           BIT             NOT NULL DEFAULT 1,
    ReminderFrequencyDays   SMAllINT             NULL,
    StatusCode              NVARCHAR(50)   NOT NULL DEFAULT 'DRAFT',
    StatusCodeGroup         AS CAST('SURVEY_STATUS' AS NVARCHAR(50)) PERSISTED,
    MinRatingScale          SMAllINT             NOT NULL DEFAULT 1,
    MaxRatingScale          SMAllINT             NOT NULL DEFAULT 5,
    ShowResultsToEmployee   BIT             NOT NULL DEFAULT 0,
    ShowResultsAfterClose   BIT             NOT NULL DEFAULT 1,
    Tags                    NVARCHAR(500)   NULL,
    AdditionalSettings      NVARCHAR(MAX)   NULL,
    TotalResponses          INT             NOT NULL DEFAULT 0,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_Survey_CreatedBy
        FOREIGN KEY (CreatedById)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Survey_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT CK_Survey_Dates CHECK (EndDate >= StartDate),
    CONSTRAINT CK_Survey_Rating CHECK (MaxRatingScale >= MinRatingScale)
);
GO


-- SURVEY TARGET - Departments/employees targeted for survey
CREATE TABLE survey.SurveyTarget (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    SurveyId            UNIQUEIDENTIFIER          NOT NULL,
    TargetType          NVARCHAR(50)   NOT NULL,
    TargetTypeGroup     AS CAST('TARGET_TYPE' AS NVARCHAR(50)) PERSISTED,
    -- TargetId mapping based on TargetType:
    -- ALL: NULL (targets all employees)
    -- DEPARTMENT: - time.Department(Id)
    -- LOCATION: - time.OfficeLocation(Id)
    -- EMPLOYEE: - employee.Employee(Id)
    TargetId            UNIQUEIDENTIFIER          NULL,
    DepartmentId        UNIQUEIDENTIFIER          NULL,
    LocationId          UNIQUEIDENTIFIER          NULL,
    EmployeeId          UNIQUEIDENTIFIER          NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SurveyTarget_Survey
        FOREIGN KEY (SurveyId)
        REFERENCES survey.Survey(Id),

    CONSTRAINT FK_SurveyTarget_Type
        FOREIGN KEY (TargetType, TargetTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_SurveyTarget_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id),

    CONSTRAINT FK_SurveyTarget_Location
        FOREIGN KEY (LocationId)
        REFERENCES time.OfficeLocation(Id),

    CONSTRAINT FK_SurveyTarget_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id)
);
GO


-- SURVEY QUESTION - Questions in a survey
CREATE TABLE survey.SurveyQuestion (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    SurveyId            UNIQUEIDENTIFIER          NOT NULL,
    QuestionText        NVARCHAR(1000) NOT NULL,
    QuestionType        NVARCHAR(50)   NOT NULL,
    QuestionTypeGroup   AS CAST('QUESTION_TYPE' AS NVARCHAR(50)) PERSISTED,
    IsRequired          BIT             NOT NULL DEFAULT 1,
    DisplayOrder        SMAllINT             NOT NULL,
    HelpText            NVARCHAR(500)  NULL,
    Options             NVARCHAR(MAX)  NULL,
    MinRating           SMAllINT             NULL,
    MaxRating           SMAllINT             NULL,
    EnableOtherOption   BIT             NOT NULL DEFAULT 0,
    SkipLogic           NVARCHAR(MAX)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SurveyQuestion_Survey
        FOREIGN KEY (SurveyId)
        REFERENCES survey.Survey(Id),

    CONSTRAINT FK_SurveyQuestion_Type
        FOREIGN KEY (QuestionType, QuestionTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
);
GO


-- SURVEY RESPONSE - Employee responses to survey
CREATE TABLE survey.SurveyResponse (
    Id                  UNIQUEIDENTIFIER             PRIMARY KEY,
    SurveyId            UNIQUEIDENTIFIER             NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER             NOT NULL,
    SubmissionNumber    INT             NOT NULL DEFAULT 1,
    IsAnonymous         BIT             NOT NULL DEFAULT 0,
    AnonymousHash       NVARCHAR(64)    NULL,
    StartedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    SubmittedAt         DATETIME2       NULL,
    IsComplete          BIT             NOT NULL DEFAULT 0,
    IPAddress           NVARCHAR(50)    NULL,
    DeviceInfo          NVARCHAR(200)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SurveyResponse_Survey
        FOREIGN KEY (SurveyId)
        REFERENCES survey.Survey(Id),

    CONSTRAINT FK_SurveyResponse_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_SurveyResponse UNIQUE (SurveyId, EmployeeId, SubmissionNumber)
);
GO


-- SURVEY RESPONSE ANSWER - Individual answers to survey questions
CREATE TABLE survey.SurveyResponseAnswer (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    ResponseId          UNIQUEIDENTIFIER          NOT NULL,
    QuestionId          UNIQUEIDENTIFIER          NOT NULL,
    AnswerText          NVARCHAR(MAX)  NULL,
    AnswerRating        DECIMAL(5,2)   NULL,
    AnswerOptions       NVARCHAR(MAX)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SurveyResponseAnswer_Response
        FOREIGN KEY (ResponseId)
        REFERENCES survey.SurveyResponse(Id),

    CONSTRAINT FK_SurveyResponseAnswer_Question
        FOREIGN KEY (QuestionId)
        REFERENCES survey.SurveyQuestion(Id)
);
GO


-- SURVEY NOTIFICATION - Survey notifications to employees
CREATE TABLE survey.SurveyNotification (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    SurveyId            UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    NotificationType    NVARCHAR(50)   NOT NULL,
    Channel             NVARCHAR(50)   NOT NULL,
    ChannelStatusGroup  AS CAST('NOTIFICATION_CHANNEL' AS NVARCHAR(50)) PERSISTED,
    Subject             NVARCHAR(300)  NULL,
    Message             NVARCHAR(MAX)  NULL,
    StatusCode          NVARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    StatusCodeGroup     AS CAST('NOTIFICATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    SentAt              DATETIME2       NULL,
    ReadAt              DATETIME2       NULL,
    ErrorMessage        NVARCHAR(500)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SurveyNotification_Survey
        FOREIGN KEY (SurveyId)
        REFERENCES survey.Survey(Id),

    CONSTRAINT FK_SurveyNotification_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_SurveyNotification_Channel
        FOREIGN KEY (Channel, ChannelStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_SurveyNotification_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
);
GO


-- SURVEY ANALYTICS - Pre-computed survey analytics
CREATE TABLE survey.SurveyAnalytics (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    SurveyId            UNIQUEIDENTIFIER          NOT NULL,
    TotalQuestions      INT             NOT NULL DEFAULT 0,
    TotalResponses      INT             NOT NULL DEFAULT 0,
    CompletionRate      DECIMAL(5,2)   NOT NULL DEFAULT 0,
    AverageRating       DECIMAL(5,2)   NULL,
    DepartmentAnalytics NVARCHAR(MAX)   NULL,
    QuestionAnalytics   NVARCHAR(MAX)   NULL,
    TrendData           NVARCHAR(MAX)   NULL,
    LastCalculatedAt    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_SurveyAnalytics_Survey
        FOREIGN KEY (SurveyId)
        REFERENCES survey.Survey(Id),

    CONSTRAINT UQ_SurveyAnalytics UNIQUE (SurveyId)
);
GO


-- POLLS MODULE

-- POLL - Main poll entity
CREATE TABLE survey.Poll (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    PollCode                NVARCHAR(50)    NOT NULL UNIQUE,
    Question                NVARCHAR(500)   NOT NULL,
    Description             NVARCHAR(1000)  NULL,
    PollType                NVARCHAR(50)   NOT NULL,
    PollTypeGroup           AS CAST('POLL_TYPE' AS NVARCHAR(50)) PERSISTED,
    CreatedById             UNIQUEIDENTIFIER          NOT NULL,
    IsAnonymous             BIT             NOT NULL DEFAULT 0,
    AllowMultipleVotes      BIT             NOT NULL DEFAULT 0,
    ExpiryDate              DATETIME2       NULL,
    StatusCode              NVARCHAR(50)   NOT NULL DEFAULT 'ACTIVE',
    StatusCodeGroup         AS CAST('POLL_STATUS' AS NVARCHAR(50)) PERSISTED,
    TotalVotes              INT             NOT NULL DEFAULT 0,
    ShowResultsBeforeVote   BIT             NOT NULL DEFAULT 0,
    ShowResultsAfterClose   BIT             NOT NULL DEFAULT 1,
    Category                NVARCHAR(100)  NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_Poll_CreatedBy
        FOREIGN KEY (CreatedById)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Poll_Type
        FOREIGN KEY (PollType, PollTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_Poll_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
);
GO


-- POLL OPTION - Options for a poll
CREATE TABLE survey.PollOption (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    PollId              UNIQUEIDENTIFIER          NOT NULL,
    OptionText          NVARCHAR(300)   NOT NULL,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    ImageUrl            NVARCHAR(1000)  NULL,
    VoteCount           INT             NOT NULL DEFAULT 0,
    Percentage          DECIMAL(5,2)   NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_PollOption_Poll
        FOREIGN KEY (PollId)
        REFERENCES survey.Poll(Id)
);
GO


-- POLL VOTE - Employee votes on poll
CREATE TABLE survey.PollVote (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    PollId              UNIQUEIDENTIFIER          NOT NULL,
    OptionId            UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    AnonymousHash       NVARCHAR(64)    NULL,
    VoteDate            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IPAddress           NVARCHAR(50)    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_PollVote_Poll
        FOREIGN KEY (PollId)
        REFERENCES survey.Poll(Id),

    CONSTRAINT FK_PollVote_Option
        FOREIGN KEY (OptionId)
        REFERENCES survey.PollOption(Id),

    CONSTRAINT FK_PollVote_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_PollVote UNIQUE (PollId, EmployeeId, OptionId)
);
GO


-- POLL TARGET - Departments/employees targeted for poll
CREATE TABLE survey.PollTarget (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    PollId              UNIQUEIDENTIFIER          NOT NULL,
    TargetType          NVARCHAR(50)   NOT NULL,
    TargetTypeGroup     AS CAST('TARGET_TYPE' AS NVARCHAR(50)) PERSISTED,
    -- TargetId mapping based on TargetType:
    -- ALL: NULL (targets all employees)
    -- DEPARTMENT: - time.Department(Id)
    -- LOCATION: - time.OfficeLocation(Id)
    -- EMPLOYEE: - employee.Employee(Id)
    TargetId            UNIQUEIDENTIFIER          NULL,
    DepartmentId        UNIQUEIDENTIFIER          NULL,
    LocationId          UNIQUEIDENTIFIER          NULL,
    EmployeeId          UNIQUEIDENTIFIER          NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_PollTarget_Poll
        FOREIGN KEY (PollId)
        REFERENCES survey.Poll(Id),

    CONSTRAINT FK_PollTarget_Type
        FOREIGN KEY (TargetType, TargetTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_PollTarget_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id),

    CONSTRAINT FK_PollTarget_Location
        FOREIGN KEY (LocationId)
        REFERENCES time.OfficeLocation(Id),

    CONSTRAINT FK_PollTarget_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id)
);
GO


-- ANONYMOUS FEEDBACK MODULE

-- ANONYMOUS FEEDBACK - Employee anonymous feedback
CREATE TABLE survey.AnonymousFeedback (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    FeedbackReference   NVARCHAR(20)   NOT NULL UNIQUE,
    FeedbackCategory    NVARCHAR(50)   NOT NULL,
    FeedbackCategoryGroup AS CAST('FEEDBACK_CATEGORY' AS NVARCHAR(50)) PERSISTED,
    Subject             NVARCHAR(300)  NOT NULL,
    Description         NVARCHAR(MAX)  NOT NULL,
    StatusCode          NVARCHAR(50)   NOT NULL DEFAULT 'SUBMITTED',
    StatusCodeGroup     AS CAST('FEEDBACK_STATUS' AS NVARCHAR(50)) PERSISTED,
    Priority            NVARCHAR(20)   NOT NULL DEFAULT 'NORMAL',
    AssignedToId        UNIQUEIDENTIFIER          NULL,
    AnonymousHash       NVARCHAR(64)   NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NULL,
    IsAnonymousByChoice BIT             NOT NULL DEFAULT 1,
    AttachmentUrl       NVARCHAR(1000)  NULL,
    AttachmentName      NVARCHAR(255)  NULL,
    SubmittedAt         DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    ResolvedAt          DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_AnonymousFeedback_Category
        FOREIGN KEY (FeedbackCategory, FeedbackCategoryGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AnonymousFeedback_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_AnonymousFeedback_AssignedTo
        FOREIGN KEY (AssignedToId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_AnonymousFeedback_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT CK_Feedback_Priority CHECK (Priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT'))
);
GO


-- FEEDBACK ACTION - Actions taken on feedback
CREATE TABLE survey.FeedbackAction (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    FeedbackId          UNIQUEIDENTIFIER          NOT NULL,
    ActionType          NVARCHAR(50)   NOT NULL,
    ActionById          UNIQUEIDENTIFIER          NOT NULL,
    PreviousStatus      NVARCHAR(50)   NULL,
    NewStatus           NVARCHAR(50)   NULL,
    Comments            NVARCHAR(MAX)  NULL,
    AttachmentUrl       NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_FeedbackAction_Feedback
        FOREIGN KEY (FeedbackId)
        REFERENCES survey.AnonymousFeedback(Id),

    CONSTRAINT FK_FeedbackAction_ActionBy
        FOREIGN KEY (ActionById)
        REFERENCES employee.Employee(Id),

    CONSTRAINT CK_FeedbackAction_Type CHECK (ActionType IN ('SUBMITTED', 'ASSIGNED', 'STATUS_CHANGED', 'COMMENT', 'ESCALATED', 'RESOLVED', 'REJECTED'))
);
GO


-- FEEDBACK ESCALATION - Escalation tracking for feedback
CREATE TABLE survey.FeedbackEscalation (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    FeedbackId          UNIQUEIDENTIFIER          NOT NULL,
    EscalatedById       UNIQUEIDENTIFIER          NOT NULL,
    EscalatedToId       UNIQUEIDENTIFIER          NOT NULL,
    EscalationLevel     SMAllINT             NOT NULL DEFAULT 1,
    Reason              NVARCHAR(500)  NOT NULL,
    IsAccepted          BIT             NULL,
    AcceptedAt          DATETIME2       NULL,
    ResolvedAt          DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_FeedbackEscalation_Feedback
        FOREIGN KEY (FeedbackId)
        REFERENCES survey.AnonymousFeedback(Id),

    CONSTRAINT FK_FeedbackEscalation_EscalatedBy
        FOREIGN KEY (EscalatedById)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_FeedbackEscalation_EscalatedTo
        FOREIGN KEY (EscalatedToId)
        REFERENCES employee.Employee(Id)
);
GO


-- INDEXES - For performance optimization

-- Survey indexes
CREATE INDEX IX_Survey_CreatedBy ON survey.Survey(CreatedById);
CREATE INDEX IX_Survey_Status ON survey.Survey(StatusCode);
CREATE INDEX IX_Survey_Dates ON survey.Survey(StartDate, EndDate);
CREATE INDEX IX_Survey_Active ON survey.Survey(IsActive);

-- SurveyTarget indexes
CREATE INDEX IX_SurveyTarget_Survey ON survey.SurveyTarget(SurveyId);
CREATE INDEX IX_SurveyTarget_Type ON survey.SurveyTarget(TargetType, TargetTypeGroup);
CREATE INDEX IX_SurveyTarget_Department ON survey.SurveyTarget(DepartmentId);
CREATE INDEX IX_SurveyTarget_Location ON survey.SurveyTarget(LocationId);
CREATE INDEX IX_SurveyTarget_Employee ON survey.SurveyTarget(EmployeeId);

-- SurveyQuestion indexes
CREATE INDEX IX_SurveyQuestion_Survey ON survey.SurveyQuestion(SurveyId);
CREATE INDEX IX_SurveyQuestion_Order ON survey.SurveyQuestion(SurveyId, DisplayOrder);

-- SurveyResponse indexes
CREATE INDEX IX_SurveyResponse_Survey ON survey.SurveyResponse(SurveyId);
CREATE INDEX IX_SurveyResponse_Employee ON survey.SurveyResponse(EmployeeId);
CREATE INDEX IX_SurveyResponse_Submitted ON survey.SurveyResponse(SubmittedAt);

-- SurveyResponseAnswer indexes
CREATE INDEX IX_SurveyResponseAnswer_Response ON survey.SurveyResponseAnswer(ResponseId);
CREATE INDEX IX_SurveyResponseAnswer_Question ON survey.SurveyResponseAnswer(QuestionId);

-- SurveyNotification indexes
CREATE INDEX IX_SurveyNotification_Survey ON survey.SurveyNotification(SurveyId);
CREATE INDEX IX_SurveyNotification_Employee ON survey.SurveyNotification(EmployeeId);

-- Poll indexes
CREATE INDEX IX_Poll_CreatedBy ON survey.Poll(CreatedById);
CREATE INDEX IX_Poll_Status ON survey.Poll(StatusCode);
CREATE INDEX IX_Poll_Expiry ON survey.Poll(ExpiryDate);
CREATE INDEX IX_Poll_Category ON survey.Poll(Category);

-- PollTarget indexes
CREATE INDEX IX_PollTarget_Poll ON survey.PollTarget(PollId);
CREATE INDEX IX_PollTarget_Type ON survey.PollTarget(TargetType, TargetTypeGroup);
CREATE INDEX IX_PollTarget_Department ON survey.PollTarget(DepartmentId);
CREATE INDEX IX_PollTarget_Location ON survey.PollTarget(LocationId);
CREATE INDEX IX_PollTarget_Employee ON survey.PollTarget(EmployeeId);

-- PollOption indexes
CREATE INDEX IX_PollOption_Poll ON survey.PollOption(PollId);

-- PollVote indexes
CREATE INDEX IX_PollVote_Poll ON survey.PollVote(PollId);
CREATE INDEX IX_PollVote_Employee ON survey.PollVote(EmployeeId);
CREATE INDEX IX_PollVote_Option ON survey.PollVote(OptionId);

-- AnonymousFeedback indexes
CREATE INDEX IX_AnonymousFeedback_Category ON survey.AnonymousFeedback(FeedbackCategory);
CREATE INDEX IX_AnonymousFeedback_Status ON survey.AnonymousFeedback(StatusCode);
CREATE INDEX IX_AnonymousFeedback_Reference ON survey.AnonymousFeedback(FeedbackReference);
CREATE INDEX IX_AnonymousFeedback_Submitted ON survey.AnonymousFeedback(SubmittedAt);
CREATE INDEX IX_AnonymousFeedback_Assigned ON survey.AnonymousFeedback(AssignedToId);

-- FeedbackAction indexes
CREATE INDEX IX_FeedbackAction_Feedback ON survey.FeedbackAction(FeedbackId);
CREATE INDEX IX_FeedbackAction_ActionBy ON survey.FeedbackAction(ActionById);
CREATE INDEX IX_FeedbackAction_Created ON survey.FeedbackAction(CreatedAt);

-- FeedbackEscalation indexes
CREATE INDEX IX_FeedbackEscalation_Feedback ON survey.FeedbackEscalation(FeedbackId);
CREATE INDEX IX_FeedbackEscalation_EscalatedTo ON survey.FeedbackEscalation(EscalatedToId);
GO

PRINT 'Survey schema created successfully';
GO