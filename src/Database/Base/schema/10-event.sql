
-- EVENTS SCHEMA - Company Events Management
-- SQL Server Database Schema
-- Schema: event
-- Purpose: Manage company-wide event, RSVPs, attendance tracking, and feedback collection
-- Dependencies: shared (StatusLookup), time (Department, OfficeLocation), employee (Employee)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'event')
BEGIN
    EXEC('CREATE SCHEMA event');
END
GO


-- EVENT CATEGORY - Categories for events
CREATE TABLE event.EventCategory (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    CategoryCode        NVARCHAR(50)    NOT NULL UNIQUE,
    CategoryName        NVARCHAR(200)   NOT NULL,
    Description         NVARCHAR(1000)  NULL,
    IconUrl             NVARCHAR(500)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,
);
GO


-- EVENT - Main event entity
CREATE TABLE event.Event (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    EventCode               NVARCHAR(50)    NOT NULL UNIQUE,
    EventTitle              NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    EventCategoryId         UNIQUEIDENTIFIER          NOT NULL,
    CategoryStatus          NVARCHAR(50)    NOT NULL DEFAULT 'ANNUAL_FUNCTION',
    CategoryStatusGroup     AS CAST('EVENT_CATEGORY' AS NVARCHAR(50)) PERSISTED,
    Venue                   NVARCHAR(500)   NULL,
    OfficeLocationId        UNIQUEIDENTIFIER          NULL,
    EventDate               DATE            NOT NULL,
    StartTime               TIME            NOT NULL,
    EndTime                 TIME            NOT NULL,
    RegistrationStartDate   DATETIME2       NULL,
    RegistrationEndDate     DATETIME2       NULL,
    Capacity                INT             NULL,
    IsRegistrationRequired  BIT             NOT NULL DEFAULT 1,
    IsPublic                BIT             NOT NULL DEFAULT 1,
    OrganizerId             UNIQUEIDENTIFIER          NOT NULL,
    StatusCode              NVARCHAR(50)   NOT NULL DEFAULT 'DRAFT',
    StatusGroup             AS CAST('EVENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    QRCodeUrl               NVARCHAR(1000)  NULL,
    AllowWaitlist           BIT             NOT NULL DEFAULT 1,
    MaxWaitlistCount        SMALLINT             NULL,
    IsFeedbackEnabled       BIT             NOT NULL DEFAULT 1,
    FeedbackStartDate       DATETIME2       NULL,
    FeedbackEndDate         DATETIME2       NULL,
    Tags                    NVARCHAR(500)   NULL,
    AdditionalInfo          NVARCHAR(MAX)   NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_Event_Category
        FOREIGN KEY (EventCategoryId)
        REFERENCES event.EventCategory(Id),

    CONSTRAINT FK_Event_CategoryStatus
        FOREIGN KEY (CategoryStatus, CategoryStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_Event_OfficeLocation
        FOREIGN KEY (OfficeLocationId)
        REFERENCES time.OfficeLocation(Id),

    CONSTRAINT FK_Event_Organizer
        FOREIGN KEY (OrganizerId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Event_Status
        FOREIGN KEY (StatusCode, StatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
);
GO


-- EVENT BANNER - Event images and attachments
CREATE TABLE event.EventBanner (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    FileName            NVARCHAR(255)   NOT NULL,
    FileUrl             NVARCHAR(1000)  NOT NULL,
    FileType            NVARCHAR(50)    NOT NULL,
    FileSize            INT          NULL,
    DisplayOrder        SMALLINT             NOT NULL DEFAULT 0,
    IsCoverImage        BIT             NOT NULL DEFAULT 0,
    Description         NVARCHAR(500)   NULL,
    UploadedById        UNIQUEIDENTIFIER          NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventBanner_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventBanner_UploadedBy
        FOREIGN KEY (UploadedById)
        REFERENCES employee.Employee(Id)
);
GO


-- EVENT ATTACHMENT - Additional event documents
CREATE TABLE event.EventAttachment (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    FileName            NVARCHAR(255)   NOT NULL,
    FileUrl             NVARCHAR(1000)  NOT NULL,
    FileType            NVARCHAR(50)    NOT NULL,
    FileSize            INT          NULL,
    Description         NVARCHAR(500)   NULL,
    UploadedById        UNIQUEIDENTIFIER          NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventAttachment_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventAttachment_UploadedBy
        FOREIGN KEY (UploadedById)
        REFERENCES employee.Employee(Id)
);
GO


-- EVENT DEPARTMENT - Departments invited to event
CREATE TABLE event.EventDepartment (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    DepartmentId        UNIQUEIDENTIFIER          NOT NULL,
    IsMandatory         BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventDepartment_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventDepartment_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id),

    CONSTRAINT UQ_EventDepartment UNIQUE (EventId, DepartmentId)
);
GO


-- EVENT INVITEE - Specific employees invited to event
CREATE TABLE event.EventInvitee (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    IsMandatory         BIT             NOT NULL DEFAULT 0,
    InvitedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventInvitee_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventInvitee_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_EventInvitee UNIQUE (EventId, EmployeeId)
);
GO


-- EVENT RSVP - Employee response to event invitation
CREATE TABLE event.EventRSVP (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    ResponseStatus      NVARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    ResponseStatusGroup AS CAST('RSVP_STATUS' AS NVARCHAR(50)) PERSISTED,
    ResponseDate        DATETIME2       NULL,
    Remarks             NVARCHAR(500)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventRSVP_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventRSVP_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EventRSVP_Status
        FOREIGN KEY (ResponseStatus, ResponseStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_EventRSVP UNIQUE (EventId, EmployeeId)
);
GO


-- EVENT WAITLIST - Employees waiting for event capacity
CREATE TABLE event.EventWaitlist (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    Position            INT             NOT NULL,
    NotifiedAt          DATETIME2       NULL,
    OfferedAt           DATETIME2       NULL,
    RespondedAt         DATETIME2       NULL,
    Status              NVARCHAR(50)   NOT NULL DEFAULT 'WAITLISTED',
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventWaitlist_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventWaitlist_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_EventWaitlist UNIQUE (EventId, EmployeeId)
);
GO


-- EVENT ATTENDANCE - QR code based attendance tracking
CREATE TABLE event.EventAttendance (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    CheckInTime         DATETIME2       NULL,
    CheckOutTime        DATETIME2       NULL,
    AttendanceStatus    NVARCHAR(50)   NOT NULL DEFAULT 'CHECKED_IN',
    AttendanceStatusGroup AS CAST('EVENT_ATTENDANCE_STATUS' AS NVARCHAR(50)) PERSISTED,
    CheckInMethod       NVARCHAR(50)   NULL,
    CheckInDevice       NVARCHAR(100)  NULL,
    QRScannedAt         DATETIME2       NULL,
    Notes               NVARCHAR(500)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventAttendance_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventAttendance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EventAttendance_Status
        FOREIGN KEY (AttendanceStatus, AttendanceStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_EventAttendance UNIQUE (EventId, EmployeeId)
);
GO


-- EVENT NOTIFICATION - Notification history for events
CREATE TABLE event.EventNotification (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    NotificationType    NVARCHAR(50)   NOT NULL,
    Channel             NVARCHAR(50)   NOT NULL,
    ChannelStatusGroup  AS CAST('NOTIFICATION_CHANNEL' AS NVARCHAR(50)) PERSISTED,
    RecipientId         UNIQUEIDENTIFIER          NULL,
    RecipientEmail      NVARCHAR(255)  NULL,
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

    CONSTRAINT FK_EventNotification_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventNotification_Recipient
        FOREIGN KEY (RecipientId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EventNotification_Channel
        FOREIGN KEY (Channel, ChannelStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_EventNotification_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
);
GO


-- EVENT FEEDBACK QUESTION - Questions for event feedback
CREATE TABLE event.EventFeedbackQuestion (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    QuestionText        NVARCHAR(500)  NOT NULL,
    QuestionType        NVARCHAR(50)   NOT NULL,
    IsRequired          BIT             NOT NULL DEFAULT 1,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    Options             NVARCHAR(MAX)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventFeedbackQuestion_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id)
);
GO


-- EVENT FEEDBACK - Employee feedback for an event
CREATE TABLE event.EventFeedback (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EventId             UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    OverallRating       DECIMAL(3,2)   NOT NULL,
    Comments            NVARCHAR(MAX)  NULL,
    WouldRecommend      BIT             NULL,
    SubmittedAt         DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventFeedback_Event
        FOREIGN KEY (EventId)
        REFERENCES event.Event(Id),

    CONSTRAINT FK_EventFeedback_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_EventFeedback UNIQUE (EventId, EmployeeId)
);
GO


-- EVENT FEEDBACK ANSWER - Individual answers to feedback questions
CREATE TABLE event.EventFeedbackAnswer (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    FeedbackId          UNIQUEIDENTIFIER          NOT NULL,
    QuestionId          UNIQUEIDENTIFIER          NOT NULL,
    AnswerText          NVARCHAR(MAX)  NULL,
    AnswerRating        DECIMAL(3,2)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EventFeedbackAnswer_Feedback
        FOREIGN KEY (FeedbackId)
        REFERENCES event.EventFeedback(Id),

    CONSTRAINT FK_EventFeedbackAnswer_Question
        FOREIGN KEY (QuestionId)
        REFERENCES event.EventFeedbackQuestion(Id)
);
GO


-- INDEXES - For performance optimization

-- Event indexes
CREATE INDEX IX_Event_Category ON event.Event(EventCategoryId);
CREATE INDEX IX_Event_Organizer ON event.Event(OrganizerId);
CREATE INDEX IX_Event_Status ON event.Event(StatusCode);
CREATE INDEX IX_Event_Date ON event.Event(EventDate);
CREATE INDEX IX_Event_OfficeLocation ON event.Event(OfficeLocationId);

-- EventBanner indexes
CREATE INDEX IX_EventBanner_Event ON event.EventBanner(EventId);

-- EventAttachment indexes
CREATE INDEX IX_EventAttachment_Event ON event.EventAttachment(EventId);

-- EventDepartment indexes
CREATE INDEX IX_EventDepartment_Event ON event.EventDepartment(EventId);
CREATE INDEX IX_EventDepartment_Department ON event.EventDepartment(DepartmentId);

-- EventInvitee indexes
CREATE INDEX IX_EventInvitee_Event ON event.EventInvitee(EventId);
CREATE INDEX IX_EventInvitee_Employee ON event.EventInvitee(EmployeeId);

-- EventRSVP indexes
CREATE INDEX IX_EventRSVP_Event ON event.EventRSVP(EventId);
CREATE INDEX IX_EventRSVP_Employee ON event.EventRSVP(EmployeeId);
CREATE INDEX IX_EventRSVP_Status ON event.EventRSVP(ResponseStatus);

-- EventWaitlist indexes
CREATE INDEX IX_EventWaitlist_Event ON event.EventWaitlist(EventId);
CREATE INDEX IX_EventWaitlist_Employee ON event.EventWaitlist(EmployeeId);

-- EventAttendance indexes
CREATE INDEX IX_EventAttendance_Event ON event.EventAttendance(EventId);
CREATE INDEX IX_EventAttendance_Employee ON event.EventAttendance(EmployeeId);
CREATE INDEX IX_EventAttendance_Status ON event.EventAttendance(AttendanceStatus);

-- EventNotification indexes
CREATE INDEX IX_EventNotification_Event ON event.EventNotification(EventId);
CREATE INDEX IX_EventNotification_Recipient ON event.EventNotification(RecipientId);
CREATE INDEX IX_EventNotification_Status ON event.EventNotification(StatusCode);

-- EventFeedbackQuestion indexes
CREATE INDEX IX_EventFeedbackQuestion_Event ON event.EventFeedbackQuestion(EventId);

-- EventFeedback indexes
CREATE INDEX IX_EventFeedback_Event ON event.EventFeedback(EventId);
CREATE INDEX IX_EventFeedback_Employee ON event.EventFeedback(EmployeeId);

-- EventFeedbackAnswer indexes
CREATE INDEX IX_EventFeedbackAnswer_Feedback ON event.EventFeedbackAnswer(FeedbackId);
CREATE INDEX IX_EventFeedbackAnswer_Question ON event.EventFeedbackAnswer(QuestionId);
GO


-- BIRTHDAY & ANNIVERSARY STATUS CODES

-- Celebration Type
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'BIRTHDAY' AND StatusGroup = 'CELEBRATION_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('BIRTHDAY', 'CELEBRATION_TYPE', 'Birthday', 'Employee birthday celebration', 1, 0),
    ('WORK_ANNIVERSARY', 'CELEBRATION_TYPE', 'Work Anniversary', 'Work anniversary celebration', 2, 0);
END
GO

-- Greeting Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'GENERATED' AND StatusGroup = 'GREETING_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('GENERATED', 'GREETING_STATUS', 'Generated', 'Greeting card generated', 1, 0),
    ('SENT', 'GREETING_STATUS', 'Sent', 'Greeting sent successfully', 2, 0),
    ('VIEWED', 'GREETING_STATUS', 'Viewed', 'Greeting viewed by recipient', 3, 1),
    ('FAILED', 'GREETING_STATUS', 'Failed', 'Failed to send greeting', 4, 1);
END
GO

-- Reaction Type
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'LIKE' AND StatusGroup = 'REACTION_TYPE')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('LIKE', 'REACTION_TYPE', 'Like', 'Like the celebration', 1, 0),
    ('LOVE', 'REACTION_TYPE', 'Love', 'Love the celebration', 2, 0),
    ('CELEBRATE', 'REACTION_TYPE', 'Celebrate', 'Celebrate achievement', 3, 0),
    ('CONGRATS', 'REACTION_TYPE', 'Congrats', 'Congratulations', 4, 0),
    ('FIRE', 'REACTION_TYPE', 'Fire', 'On fire!', 5, 0),
    ('PARTY', 'REACTION_TYPE', 'Party', 'Party time!', 6, 0);
END
GO


-- CELEBRATION SCHEDULE - Daily schedule for birthdays and anniversaries
CREATE TABLE event.CelebrationSchedule (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId              UNIQUEIDENTIFIER          NOT NULL,
    CelebrationType         NVARCHAR(50)   NOT NULL,
    CelebrationTypeGroup    AS CAST('CELEBRATION_TYPE' AS NVARCHAR(50)) PERSISTED,
    CelebrationDate         DATE            NOT NULL,
    YearsCompleted          INT             NULL,
    IsAcknowledged          BIT             NOT NULL DEFAULT 0,
    AcknowledgedAt          DATETIME2       NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_CelebrationSchedule_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_CelebrationSchedule_Type
        FOREIGN KEY (CelebrationType, CelebrationTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_CelebrationSchedule UNIQUE (EmployeeId, CelebrationType, CelebrationDate)
);
GO


-- GREETING CARD - Generated greeting cards for celebrations
CREATE TABLE event.GreetingCard (
    Id                      UNIQUEIDENTIFIER          PRIMARY KEY,
    CelebrationScheduleId   UNIQUEIDENTIFIER          NOT NULL,
    EmployeeId              UNIQUEIDENTIFIER          NOT NULL,
    GreetingType            NVARCHAR(50)   NOT NULL,
    GreetingTypeGroup       AS CAST('CELEBRATION_TYPE' AS NVARCHAR(50)) PERSISTED,
    CardTemplate            NVARCHAR(100)  NULL,
    GreetingTitle           NVARCHAR(200)  NOT NULL,
    GreetingMessage         NVARCHAR(MAX)  NULL,
    CardImageUrl            NVARCHAR(1000)  NULL,
    StatusCode              NVARCHAR(50)   NOT NULL DEFAULT 'GENERATED',
    StatusCodeGroup         AS CAST('GREETING_STATUS' AS NVARCHAR(50)) PERSISTED,
    EmailSentAt             DATETIME2       NULL,
    NotificationSentAt      DATETIME2       NULL,
    ViewedAt                DATETIME2       NULL,
    IsTeamNotificationSent  BIT             NOT NULL DEFAULT 0,
    TeamNotificationSentAt  DATETIME2       NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_GreetingCard_Schedule
        FOREIGN KEY (CelebrationScheduleId)
        REFERENCES event.CelebrationSchedule(Id),

    CONSTRAINT FK_GreetingCard_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_GreetingCard_Type
        FOREIGN KEY (GreetingType, GreetingTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_GreetingCard_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_GreetingCard UNIQUE (CelebrationScheduleId, EmployeeId)
);
GO


-- GREETING CARD NOTIFICATION - Track notifications sent for greetings
CREATE TABLE event.GreetingNotification (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    GreetingCardId      UNIQUEIDENTIFIER          NOT NULL,
    Channel             NVARCHAR(50)   NOT NULL,
    ChannelStatusGroup  AS CAST('NOTIFICATION_CHANNEL' AS NVARCHAR(50)) PERSISTED,
    RecipientId         UNIQUEIDENTIFIER          NOT NULL,
    RecipientEmail      NVARCHAR(255)   NULL,
    Subject             NVARCHAR(300)   NULL,
    Message             NVARCHAR(MAX)   NULL,
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

    CONSTRAINT FK_GreetingNotification_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES event.GreetingCard(Id),

    CONSTRAINT FK_GreetingNotification_Recipient
        FOREIGN KEY (RecipientId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_GreetingNotification_Channel
        FOREIGN KEY (Channel, ChannelStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_GreetingNotification_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup)
);
GO


-- CELEBRATION WISH - Employee wishes on greeting cards
CREATE TABLE event.CelebrationWish (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    GreetingCardId      UNIQUEIDENTIFIER          NOT NULL,
    WisherId            UNIQUEIDENTIFIER          NOT NULL,
    WishText            NVARCHAR(500)  NOT NULL,
    IsGif               BIT             NOT NULL DEFAULT 0,
    GifUrl              NVARCHAR(1000)  NULL,
    IsEdited            BIT             NOT NULL DEFAULT 0,
    EditedAt            DATETIME2       NULL,
    IsDeleted           BIT             NOT NULL DEFAULT 0,
    DeletedAt           DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_CelebrationWish_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES event.GreetingCard(Id),

    CONSTRAINT FK_CelebrationWish_Wisher
        FOREIGN KEY (WisherId)
        REFERENCES employee.Employee(Id)
);
GO


-- CELEBRATION REACTION - Reactions to celebration wishes
CREATE TABLE event.CelebrationReaction (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    WishId              UNIQUEIDENTIFIER          NOT NULL,
    ReactorId           UNIQUEIDENTIFIER          NOT NULL,
    ReactionType        NVARCHAR(50)   NOT NULL,
    ReactionTypeGroup   AS CAST('REACTION_TYPE' AS NVARCHAR(50)) PERSISTED,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_CelebrationReaction_Wish
        FOREIGN KEY (WishId)
        REFERENCES event.CelebrationWish(Id),

    CONSTRAINT FK_CelebrationReaction_Reactor
        FOREIGN KEY (ReactorId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_CelebrationReaction_Type
        FOREIGN KEY (ReactionType, ReactionTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_CelebrationReaction UNIQUE (WishId, ReactorId, ReactionType)
);
GO


-- CELEBRATION COMMENT - Comments on celebration wishes
CREATE TABLE event.CelebrationComment (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    WishId              UNIQUEIDENTIFIER          NOT NULL,
    CommenterId         UNIQUEIDENTIFIER          NOT NULL,
    ParentCommentId     UNIQUEIDENTIFIER          NULL,
    CommentText         NVARCHAR(500)  NOT NULL,
    IsEdited            BIT             NOT NULL DEFAULT 0,
    EditedAt            DATETIME2       NULL,
    IsDeleted           BIT             NOT NULL DEFAULT 0,
    DeletedAt           DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_CelebrationComment_Wish
        FOREIGN KEY (WishId)
        REFERENCES event.CelebrationWish(Id),

    CONSTRAINT FK_CelebrationComment_Commenter
        FOREIGN KEY (CommenterId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_CelebrationComment_Parent
        FOREIGN KEY (ParentCommentId)
        REFERENCES event.CelebrationComment(Id)
);
GO


-- BIRTHDAY WALL POST - Featured birthday/anniversary posts on dashboard
CREATE TABLE event.BirthdayWallPost (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    GreetingCardId      UNIQUEIDENTIFIER          NOT NULL,
    PostedById          UNIQUEIDENTIFIER          NOT NULL,
    PostContent         NVARCHAR(MAX)  NULL,
    ImageUrl            NVARCHAR(1000)  NULL,
    IsFeatured          BIT             NOT NULL DEFAULT 0,
    DisplayStartDate    DATE            NOT NULL,
    DisplayEndDate      DATE            NOT NULL,
    ViewCount           INT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_BirthdayWallPost_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES event.GreetingCard(Id),

    CONSTRAINT FK_BirthdayWallPost_PostedBy
        FOREIGN KEY (PostedById)
        REFERENCES employee.Employee(Id)
);
GO


-- MILESTONE BADGE - Awarded for work anniversary milestones
CREATE TABLE event.MilestoneBadge (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    BadgeCode           NVARCHAR(50)    NOT NULL UNIQUE,
    BadgeName           NVARCHAR(100)   NOT NULL,
    Description         NVARCHAR(500)   NULL,
    YearsRequired       INT             NOT NULL,
    IconUrl             NVARCHAR(500)   NULL,
    BadgeColor          NVARCHAR(20)    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL
);
GO


-- EMPLOYEE BADGE - Badges earned by employees for milestones
CREATE TABLE event.EmployeeBadge (
    Id                  UNIQUEIDENTIFIER          PRIMARY KEY,
    EmployeeId          UNIQUEIDENTIFIER          NOT NULL,
    BadgeId             UNIQUEIDENTIFIER          NOT NULL,
    GreetingCardId      UNIQUEIDENTIFIER          NULL,
    AwardedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    DisplayOnProfile    BIT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           UNIQUEIDENTIFIER             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       UNIQUEIDENTIFIER             NULL,

    CONSTRAINT FK_EmployeeBadge_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeBadge_Badge
        FOREIGN KEY (BadgeId)
        REFERENCES event.MilestoneBadge(Id),

    CONSTRAINT FK_EmployeeBadge_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES event.GreetingCard(Id),

    CONSTRAINT UQ_EmployeeBadge UNIQUE (EmployeeId, BadgeId)
);
GO


-- INDEXES - For Birthday & Anniversary performance optimization

-- CelebrationSchedule indexes
CREATE INDEX IX_CelebrationSchedule_Employee ON event.CelebrationSchedule(EmployeeId);
CREATE INDEX IX_CelebrationSchedule_Type ON event.CelebrationSchedule(CelebrationType);
CREATE INDEX IX_CelebrationSchedule_Date ON event.CelebrationSchedule(CelebrationDate);

-- GreetingCard indexes
CREATE INDEX IX_GreetingCard_Schedule ON event.GreetingCard(CelebrationScheduleId);
CREATE INDEX IX_GreetingCard_Employee ON event.GreetingCard(EmployeeId);
CREATE INDEX IX_GreetingCard_Status ON event.GreetingCard(StatusCode);

-- GreetingNotification indexes
CREATE INDEX IX_GreetingNotification_GreetingCard ON event.GreetingNotification(GreetingCardId);
CREATE INDEX IX_GreetingNotification_Recipient ON event.GreetingNotification(RecipientId);

-- CelebrationWish indexes
CREATE INDEX IX_CelebrationWish_GreetingCard ON event.CelebrationWish(GreetingCardId);
CREATE INDEX IX_CelebrationWish_Wisher ON event.CelebrationWish(WisherId);
CREATE INDEX IX_CelebrationWish_Created ON event.CelebrationWish(CreatedAt);

-- CelebrationReaction indexes
CREATE INDEX IX_CelebrationReaction_Wish ON event.CelebrationReaction(WishId);
CREATE INDEX IX_CelebrationReaction_Reactor ON event.CelebrationReaction(ReactorId);

-- CelebrationComment indexes
CREATE INDEX IX_CelebrationComment_Wish ON event.CelebrationComment(WishId);
CREATE INDEX IX_CelebrationComment_Commenter ON event.CelebrationComment(CommenterId);
CREATE INDEX IX_CelebrationComment_Parent ON event.CelebrationComment(ParentCommentId);

-- BirthdayWallPost indexes
CREATE INDEX IX_BirthdayWallPost_GreetingCard ON event.BirthdayWallPost(GreetingCardId);
CREATE INDEX IX_BirthdayWallPost_Featured ON event.BirthdayWallPost(IsFeatured, DisplayStartDate, DisplayEndDate);

-- EmployeeBadge indexes
CREATE INDEX IX_EmployeeBadge_Employee ON event.EmployeeBadge(EmployeeId);
CREATE INDEX IX_EmployeeBadge_Badge ON event.EmployeeBadge(BadgeId);
GO


-- SEED DEFAULT MILESTONE BADGES
IF NOT EXISTS (SELECT 1 FROM event.MilestoneBadge WHERE BadgeCode = 'ONE_YEAR')
BEGIN
    INSERT INTO event.MilestoneBadge (Id, BadgeCode, BadgeName, Description, YearsRequired, IconUrl, BadgeColor)
    VALUES
    (NEWID(), 'ONE_YEAR', 'First Year', 'Completed 1 year at company', 1, NULL, '#CD7F32'),
    (NEWID(), 'THREE_YEARS', 'Three Year Club', 'Completed 3 years at company', 3, NULL, '#C0C0C0'),
    (NEWID(), 'FIVE_YEARS', 'Five Year Veteran', 'Completed 5 years at company', 5, NULL, '#FFD700'),
    (NEWID(), 'SEVEN_YEARS', 'Seven Year Champion', 'Completed 7 years at company', 7, NULL, '#E5E4E2'),
    (NEWID(), 'TEN_YEARS', 'Decade Master', 'Completed 10 years at company', 10, NULL, '#9966CC'),
    (NEWID(), 'FIFTEEN_YEARS', 'Fifteen Year Legend', 'Completed 15 years at company', 15, NULL, '#333399'),
    (NEWID(), 'TWENTY_YEARS', 'Twenty Year Icon', 'Completed 20 years at company', 20, NULL, '#FFD700');
END
GO

PRINT 'Event schema created successfully';
GO