-- =============================================================================================================
-- EVENTS SCHEMA - Company Events Management
-- SQL Server Database Schema
-- Schema: events
-- Purpose: Manage company-wide events, RSVPs, attendance tracking, and feedback collection
-- Dependencies: shared (StatusLookup), time (Department, OfficeLocation), employee (Employee)
-- =============================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'events')
BEGIN
    EXEC('CREATE SCHEMA events');
END
GO


-- =============================================================================================================
-- SEED STATUS CODES - Event-specific status groups
-- =============================================================================================================

-- Event Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'DRAFT' AND StatusGroup = 'EVENT_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('DRAFT', 'EVENT_STATUS', 'Draft', 'Event created but not published', 1, 0),
    ('PUBLISHED', 'EVENT_STATUS', 'Published', 'Event published and open for registration', 2, 0),
    ('REGISTRATION_CLOSED', 'EVENT_STATUS', 'Registration Closed', 'Registration period ended', 3, 0),
    ('ONGOING', 'EVENT_STATUS', 'Ongoing', 'Event is currently in progress', 4, 0),
    ('COMPLETED', 'EVENT_STATUS', 'Completed', 'Event finished', 5, 1),
    ('CANCELLED', 'EVENT_STATUS', 'Cancelled', 'Event cancelled', 6, 1),
    ('ARCHIVED', 'EVENT_STATUS', 'Archived', 'Event archived for reference', 7, 1);
END
GO

-- Event Category
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'ANNUAL_FUNCTION' AND StatusGroup = 'EVENT_CATEGORY')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('ANNUAL_FUNCTION', 'EVENT_CATEGORY', 'Annual Function', 'Company annual day celebrations', 1, 0),
    ('FESTIVAL', 'EVENT_CATEGORY', 'Festival', 'Cultural and religious festivals', 2, 0),
    ('TEAM_OUTING', 'EVENT_CATEGORY', 'Team Outing', 'Team building and outings', 3, 0),
    ('HACKATHON', 'EVENT_CATEGORY', 'Hackathon', 'Technology hackathons and coding events', 4, 0),
    ('SPORTS', 'EVENT_CATEGORY', 'Sports', 'Sports activities and competitions', 5, 0),
    ('TOWNHALL', 'EVENT_CATEGORY', 'Townhall', 'Company-wide townhall meetings', 6, 0),
    ('TRAINING', 'EVENT_CATEGORY', 'Training', 'Workshops and training sessions', 7, 0),
    ('SEMINAR', 'EVENT_CATEGORY', 'Seminar', 'Seminars and presentations', 8, 0),
    ('MEETUP', 'EVENT_CATEGORY', 'Meetup', 'Social meetups and networking', 9, 0),
    ('OTHER', 'EVENT_CATEGORY', 'Other', 'Other event types', 10, 0);
END
GO

-- RSVP Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'PENDING' AND StatusGroup = 'RSVP_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('PENDING', 'RSVP_STATUS', 'Pending', 'Awaiting response', 1, 0),
    ('ACCEPTED', 'RSVP_STATUS', 'Accepted', 'Employee will attend', 2, 0),
    ('DECLINED', 'RSVP_STATUS', 'Declined', 'Employee cannot attend', 3, 0),
    ('MAYBE', 'RSVP_STATUS', 'Maybe', 'Employee may attend', 4, 0),
    ('WAITLISTED', 'RSVP_STATUS', 'Waitlisted', 'Added to waitlist due to capacity', 5, 0),
    ('CANCELLED', 'RSVP_STATUS', 'Cancelled', 'Registration cancelled', 6, 1);
END
GO

-- Attendance Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'CHECKED_IN' AND StatusGroup = 'EVENT_ATTENDANCE_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('CHECKED_IN', 'EVENT_ATTENDANCE_STATUS', 'Checked In', 'Employee has checked in', 1, 0),
    ('CHECKED_OUT', 'EVENT_ATTENDANCE_STATUS', 'Checked Out', 'Employee has checked out', 2, 1),
    ('NO_SHOW', 'EVENT_ATTENDANCE_STATUS', 'No Show', 'Registered but did not attend', 3, 1);
END
GO

-- Notification Status
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'PENDING' AND StatusGroup = 'NOTIFICATION_STATUS')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('PENDING', 'NOTIFICATION_STATUS', 'Pending', 'Notification to be sent', 1, 0),
    ('SENT', 'NOTIFICATION_STATUS', 'Sent', 'Notification sent successfully', 2, 0),
    ('FAILED', 'NOTIFICATION_STATUS', 'Failed', 'Notification failed to send', 3, 1),
    ('READ', 'NOTIFICATION_STATUS', 'Read', 'Notification viewed by recipient', 4, 1);
END
GO

-- Notification Channel
IF NOT EXISTS (SELECT 1 FROM shared.StatusLookup WHERE StatusCode = 'EMAIL' AND StatusGroup = 'NOTIFICATION_CHANNEL')
BEGIN
    INSERT INTO shared.StatusLookup (StatusCode, StatusGroup, Label, Description, DisplayOrder, IsTerminal)
    VALUES
    ('EMAIL', 'NOTIFICATION_CHANNEL', 'Email', 'Email notification', 1, 0),
    ('PUSH', 'NOTIFICATION_CHANNEL', 'Push', 'Push notification (mobile/web)', 2, 0),
    ('SMS', 'NOTIFICATION_CHANNEL', 'SMS', 'SMS notification', 3, 0),
    ('SLACK', 'NOTIFICATION_CHANNEL', 'Slack', 'Slack notification', 4, 0),
    ('TEAMS', 'NOTIFICATION_CHANNEL', 'Teams', 'Microsoft Teams notification', 5, 0),
    ('IN_APP', 'NOTIFICATION_CHANNEL', 'In-App', 'In-app notification', 6, 0);
END
GO


-- =============================================================================================================
-- EVENT CATEGORY - Categories for events
-- =============================================================================================================
CREATE TABLE events.EventCategory (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    CategoryCode        NVARCHAR(50)    NOT NULL UNIQUE,
    CategoryName        NVARCHAR(200)   NOT NULL,
    Description         NVARCHAR(1000)  NULL,
    IconUrl             NVARCHAR(500)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);
GO


-- =============================================================================================================
-- EVENT - Main event entity
-- =============================================================================================================
CREATE TABLE events.Event (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventCode               NVARCHAR(50)    NOT NULL UNIQUE,
    EventTitle              NVARCHAR(300)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    CategoryId              BIGINT          NOT NULL,
    CategoryStatus          NVARCHAR(50)    NOT NULL DEFAULT 'ANNUAL_FUNCTION',
    CategoryStatusGroup     AS CAST('EVENT_CATEGORY' AS NVARCHAR(50)) PERSISTED,
    Venue                   NVARCHAR(500)   NULL,
    OfficeLocationId        BIGINT          NULL,
    EventDate               DATE            NOT NULL,
    StartTime               TIME            NOT NULL,
    EndTime                 TIME            NOT NULL,
    RegistrationStartDate   DATETIME2       NULL,
    RegistrationEndDate     DATETIME2       NULL,
    Capacity                INT             NULL,
    IsRegistrationRequired BIT             NOT NULL DEFAULT 1,
    IsPublic                BIT             NOT NULL DEFAULT 1,
    OrganizerId             BIGINT          NOT NULL,
    StatusCode              NVARCHAR(50)   NOT NULL DEFAULT 'DRAFT',
    StatusGroup             AS CAST('EVENT_STATUS' AS NVARCHAR(50)) PERSISTED,
    QRCodeUrl               NVARCHAR(1000)  NULL,
    AllowWaitlist           BIT             NOT NULL DEFAULT 1,
    MaxWaitlistCount        INT             NULL,
    IsFeedbackEnabled      BIT             NOT NULL DEFAULT 1,
    FeedbackStartDate       DATETIME2       NULL,
    FeedbackEndDate         DATETIME2       NULL,
    Tags                    NVARCHAR(500)   NULL,
    AdditionalInfo          NVARCHAR(MAX)   NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NULL,

    CONSTRAINT FK_Event_Category
        FOREIGN KEY (CategoryId)
        REFERENCES events.EventCategory(Id),

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


-- =============================================================================================================
-- EVENT BANNER - Event images and attachments
-- =============================================================================================================
CREATE TABLE events.EventBanner (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    FileName            NVARCHAR(255)   NOT NULL,
    FileUrl             NVARCHAR(1000)  NOT NULL,
    FileType            NVARCHAR(50)    NOT NULL,
    FileSize            BIGINT          NULL,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    IsCoverImage        BIT             NOT NULL DEFAULT 0,
    Description         NVARCHAR(500)   NULL,
    UploadedById        BIGINT          NOT NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventBanner_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventBanner_UploadedBy
        FOREIGN KEY (UploadedById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- EVENT ATTACHMENT - Additional event documents
-- =============================================================================================================
CREATE TABLE events.EventAttachment (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    FileName            NVARCHAR(255)   NOT NULL,
    FileUrl             NVARCHAR(1000)  NOT NULL,
    FileType            NVARCHAR(50)    NOT NULL,
    FileSize            BIGINT          NULL,
    Description         NVARCHAR(500)   NULL,
    UploadedById        BIGINT          NOT NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventAttachment_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventAttachment_UploadedBy
        FOREIGN KEY (UploadedById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- EVENT DEPARTMENT - Departments invited to event
-- =============================================================================================================
CREATE TABLE events.EventDepartment (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    DepartmentId        BIGINT          NOT NULL,
    IsMandatory         BIT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventDepartment_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventDepartment_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES time.Department(Id),

    CONSTRAINT UQ_EventDepartment UNIQUE (EventId, DepartmentId)
);
GO


-- =============================================================================================================
-- EVENT INVITEE - Specific employees invited to event
-- =============================================================================================================
CREATE TABLE events.EventInvitee (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    EmployeeId          BIGINT          NOT NULL,
    IsMandatory         BIT             NOT NULL DEFAULT 0,
    InvitedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventInvitee_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventInvitee_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_EventInvitee UNIQUE (EventId, EmployeeId)
);
GO


-- =============================================================================================================
-- EVENT RSVP - Employee response to event invitation
-- =============================================================================================================
CREATE TABLE events.EventRSVP (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    EmployeeId          BIGINT          NOT NULL,
    ResponseStatus      NVARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    ResponseStatusGroup AS CAST('RSVP_STATUS' AS NVARCHAR(50)) PERSISTED,
    ResponseDate        DATETIME2       NULL,
    Remarks             NVARCHAR(500)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_EventRSVP_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventRSVP_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EventRSVP_Status
        FOREIGN KEY (ResponseStatus, ResponseStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_EventRSVP UNIQUE (EventId, EmployeeId)
);
GO


-- =============================================================================================================
-- EVENT WAITLIST - Employees waiting for event capacity
-- =============================================================================================================
CREATE TABLE events.EventWaitlist (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    EmployeeId          BIGINT          NOT NULL,
    Position            INT             NOT NULL,
    NotifiedAt          DATETIME2       NULL,
    OfferedAt           DATETIME2       NULL,
    RespondedAt         DATETIME2       NULL,
    Status              NVARCHAR(50)   NOT NULL DEFAULT 'WAITLISTED',
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_EventWaitlist_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventWaitlist_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_EventWaitlist UNIQUE (EventId, EmployeeId)
);
GO


-- =============================================================================================================
-- EVENT ATTENDANCE - QR code based attendance tracking
-- =============================================================================================================
CREATE TABLE events.EventAttendance (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    EmployeeId          BIGINT          NOT NULL,
    CheckInTime         DATETIME2       NULL,
    CheckOutTime        DATETIME2       NULL,
    AttendanceStatus    NVARCHAR(50)   NOT NULL DEFAULT 'CHECKED_IN',
    AttendanceStatusGroup AS CAST('EVENT_ATTENDANCE_STATUS' AS NVARCHAR(50)) PERSISTED,
    CheckInMethod       NVARCHAR(50)   NULL,
    CheckInDevice       NVARCHAR(100)  NULL,
    QRScannedAt         DATETIME2       NULL,
    Notes               NVARCHAR(500)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NULL,

    CONSTRAINT FK_EventAttendance_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventAttendance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EventAttendance_Status
        FOREIGN KEY (AttendanceStatus, AttendanceStatusGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_EventAttendance UNIQUE (EventId, EmployeeId)
);
GO


-- =============================================================================================================
-- EVENT NOTIFICATION - Notification history for events
-- =============================================================================================================
CREATE TABLE events.EventNotification (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    NotificationType    NVARCHAR(50)   NOT NULL,
    Channel             NVARCHAR(50)   NOT NULL,
    ChannelStatusGroup  AS CAST('NOTIFICATION_CHANNEL' AS NVARCHAR(50)) PERSISTED,
    RecipientId         BIGINT          NULL,
    RecipientEmail      NVARCHAR(255)  NULL,
    Subject             NVARCHAR(300)  NULL,
    Message             NVARCHAR(MAX)  NULL,
    StatusCode          NVARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    StatusCodeGroup     AS CAST('NOTIFICATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    SentAt              DATETIME2       NULL,
    ReadAt              DATETIME2       NULL,
    ErrorMessage        NVARCHAR(500)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventNotification_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

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


-- =============================================================================================================
-- EVENT FEEDBACK QUESTION - Questions for event feedback
-- =============================================================================================================
CREATE TABLE events.EventFeedbackQuestion (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    QuestionText        NVARCHAR(500)  NOT NULL,
    QuestionType        NVARCHAR(50)   NOT NULL,
    IsRequired          BIT             NOT NULL DEFAULT 1,
    DisplayOrder        INT             NOT NULL DEFAULT 0,
    Options             NVARCHAR(MAX)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventFeedbackQuestion_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id)
);
GO


-- =============================================================================================================
-- EVENT FEEDBACK - Employee feedback for an event
-- =============================================================================================================
CREATE TABLE events.EventFeedback (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EventId             BIGINT          NOT NULL,
    EmployeeId          BIGINT          NOT NULL,
    OverallRating       DECIMAL(3,2)   NOT NULL,
    Comments            NVARCHAR(MAX)  NULL,
    WouldRecommend      BIT             NULL,
    SubmittedAt         DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventFeedback_Event
        FOREIGN KEY (EventId)
        REFERENCES events.Event(Id),

    CONSTRAINT FK_EventFeedback_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT UQ_EventFeedback UNIQUE (EventId, EmployeeId)
);
GO


-- =============================================================================================================
-- EVENT FEEDBACK ANSWER - Individual answers to feedback questions
-- =============================================================================================================
CREATE TABLE events.EventFeedbackAnswer (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    FeedbackId          BIGINT          NOT NULL,
    QuestionId          BIGINT          NOT NULL,
    AnswerText          NVARCHAR(MAX)  NULL,
    AnswerRating        DECIMAL(3,2)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EventFeedbackAnswer_Feedback
        FOREIGN KEY (FeedbackId)
        REFERENCES events.EventFeedback(Id),

    CONSTRAINT FK_EventFeedbackAnswer_Question
        FOREIGN KEY (QuestionId)
        REFERENCES events.EventFeedbackQuestion(Id)
);
GO


-- =============================================================================================================
-- INDEXES - For performance optimization
-- =============================================================================================================

-- Event indexes
CREATE INDEX IX_Event_Category ON events.Event(CategoryId);
CREATE INDEX IX_Event_Organizer ON events.Event(OrganizerId);
CREATE INDEX IX_Event_Status ON events.Event(StatusCode);
CREATE INDEX IX_Event_Date ON events.Event(EventDate);
CREATE INDEX IX_Event_OfficeLocation ON events.Event(OfficeLocationId);

-- EventBanner indexes
CREATE INDEX IX_EventBanner_Event ON events.EventBanner(EventId);

-- EventAttachment indexes
CREATE INDEX IX_EventAttachment_Event ON events.EventAttachment(EventId);

-- EventDepartment indexes
CREATE INDEX IX_EventDepartment_Event ON events.EventDepartment(EventId);
CREATE INDEX IX_EventDepartment_Department ON events.EventDepartment(DepartmentId);

-- EventInvitee indexes
CREATE INDEX IX_EventInvitee_Event ON events.EventInvitee(EventId);
CREATE INDEX IX_EventInvitee_Employee ON events.EventInvitee(EmployeeId);

-- EventRSVP indexes
CREATE INDEX IX_EventRSVP_Event ON events.EventRSVP(EventId);
CREATE INDEX IX_EventRSVP_Employee ON events.EventRSVP(EmployeeId);
CREATE INDEX IX_EventRSVP_Status ON events.EventRSVP(ResponseStatus);

-- EventWaitlist indexes
CREATE INDEX IX_EventWaitlist_Event ON events.EventWaitlist(EventId);
CREATE INDEX IX_EventWaitlist_Employee ON events.EventWaitlist(EmployeeId);

-- EventAttendance indexes
CREATE INDEX IX_EventAttendance_Event ON events.EventAttendance(EventId);
CREATE INDEX IX_EventAttendance_Employee ON events.EventAttendance(EmployeeId);
CREATE INDEX IX_EventAttendance_Status ON events.EventAttendance(AttendanceStatus);

-- EventNotification indexes
CREATE INDEX IX_EventNotification_Event ON events.EventNotification(EventId);
CREATE INDEX IX_EventNotification_Recipient ON events.EventNotification(RecipientId);
CREATE INDEX IX_EventNotification_Status ON events.EventNotification(StatusCode);

-- EventFeedbackQuestion indexes
CREATE INDEX IX_EventFeedbackQuestion_Event ON events.EventFeedbackQuestion(EventId);

-- EventFeedback indexes
CREATE INDEX IX_EventFeedback_Event ON events.EventFeedback(EventId);
CREATE INDEX IX_EventFeedback_Employee ON events.EventFeedback(EmployeeId);

-- EventFeedbackAnswer indexes
CREATE INDEX IX_EventFeedbackAnswer_Feedback ON events.EventFeedbackAnswer(FeedbackId);
CREATE INDEX IX_EventFeedbackAnswer_Question ON events.EventFeedbackAnswer(QuestionId);
GO


-- =============================================================================================================
-- BIRTHDAY & ANNIVERSARY STATUS CODES
-- =============================================================================================================

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


-- =============================================================================================================
-- CELEBRATION SCHEDULE - Daily schedule for birthdays and anniversaries
-- =============================================================================================================
CREATE TABLE events.CelebrationSchedule (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId              BIGINT          NOT NULL,
    CelebrationType         NVARCHAR(50)   NOT NULL,
    CelebrationTypeGroup    AS CAST('CELEBRATION_TYPE' AS NVARCHAR(50)) PERSISTED,
    CelebrationDate        DATE            NOT NULL,
    YearsCompleted          INT             NULL,
    IsAcknowledged          BIT             NOT NULL DEFAULT 0,
    AcknowledgedAt         DATETIME2       NULL,
    CreatedAt              DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_CelebrationSchedule_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_CelebrationSchedule_Type
        FOREIGN KEY (CelebrationType, CelebrationTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_CelebrationSchedule UNIQUE (EmployeeId, CelebrationType, CelebrationDate)
);
GO


-- =============================================================================================================
-- GREETING CARD - Generated greeting cards for celebrations
-- =============================================================================================================
CREATE TABLE events.GreetingCard (
    Id                      BIGINT          PRIMARY KEY IDENTITY(1,1),
    CelebrationScheduleId   BIGINT          NOT NULL,
    EmployeeId              BIGINT          NOT NULL,
    GreetingType            NVARCHAR(50)   NOT NULL,
    GreetingTypeGroup       AS CAST('CELEBRATION_TYPE' AS NVARCHAR(50)) PERSISTED,
    CardTemplate           NVARCHAR(100)  NULL,
    GreetingTitle          NVARCHAR(200)  NOT NULL,
    GreetingMessage        NVARCHAR(MAX)  NULL,
    CardImageUrl           NVARCHAR(1000)  NULL,
    StatusCode             NVARCHAR(50)   NOT NULL DEFAULT 'GENERATED',
    StatusCodeGroup        AS CAST('GREETING_STATUS' AS NVARCHAR(50)) PERSISTED,
    EmailSentAt            DATETIME2       NULL,
    NotificationSentAt     DATETIME2       NULL,
    ViewedAt               DATETIME2       NULL,
    IsTeamNotificationSent BIT             NOT NULL DEFAULT 0,
    TeamNotificationSentAt DATETIME2       NULL,
    CreatedAt              DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_GreetingCard_Schedule
        FOREIGN KEY (CelebrationScheduleId)
        REFERENCES events.CelebrationSchedule(Id),

    CONSTRAINT FK_GreetingCard_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_GreetingCard_Type
        FOREIGN KEY (GreetingType, GreetingTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT FK_GreetingCard_Status
        FOREIGN KEY (StatusCode, StatusCodeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_GreetingCard UNIQUE (ScheduleId, EmployeeId)
);
GO


-- =============================================================================================================
-- GREETING CARD NOTIFICATION - Track notifications sent for greetings
-- =============================================================================================================
CREATE TABLE events.GreetingNotification (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    GreetingCardId      BIGINT          NOT NULL,
    Channel             NVARCHAR(50)   NOT NULL,
    ChannelStatusGroup  AS CAST('NOTIFICATION_CHANNEL' AS NVARCHAR(50)) PERSISTED,
    RecipientId         BIGINT          NOT NULL,
    RecipientEmail      NVARCHAR(255)   NULL,
    Subject             NVARCHAR(300)   NULL,
    Message             NVARCHAR(MAX)   NULL,
    StatusCode          NVARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    StatusCodeGroup     AS CAST('NOTIFICATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    SentAt              DATETIME2       NULL,
    ReadAt              DATETIME2       NULL,
    ErrorMessage        NVARCHAR(500)  NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_GreetingNotification_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES events.GreetingCard(Id),

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


-- =============================================================================================================
-- CELEBRATION WISH - Employee wishes on greeting cards
-- =============================================================================================================
CREATE TABLE events.CelebrationWish (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    GreetingCardId      BIGINT          NOT NULL,
    WisherId            BIGINT          NOT NULL,
    WishText            NVARCHAR(500)  NOT NULL,
    IsGif               BIT             NOT NULL DEFAULT 0,
    GifUrl             NVARCHAR(1000)  NULL,
    IsEdited            BIT             NOT NULL DEFAULT 0,
    EditedAt            DATETIME2       NULL,
    IsDeleted           BIT             NOT NULL DEFAULT 0,
    DeletedAt           DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_CelebrationWish_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES events.GreetingCard(Id),

    CONSTRAINT FK_CelebrationWish_Wisher
        FOREIGN KEY (WisherId)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- CELEBRATION REACTION - Reactions to celebration wishes
-- =============================================================================================================
CREATE TABLE events.CelebrationReaction (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    WishId              BIGINT          NOT NULL,
    ReactorId           BIGINT          NOT NULL,
    ReactionType        NVARCHAR(50)   NOT NULL,
    ReactionTypeGroup   AS CAST('REACTION_TYPE' AS NVARCHAR(50)) PERSISTED,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_CelebrationReaction_Wish
        FOREIGN KEY (WishId)
        REFERENCES events.CelebrationWish(Id),

    CONSTRAINT FK_CelebrationReaction_Reactor
        FOREIGN KEY (ReactorId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_CelebrationReaction_Type
        FOREIGN KEY (ReactionType, ReactionTypeGroup)
        REFERENCES shared.StatusLookup(StatusCode, StatusGroup),

    CONSTRAINT UQ_CelebrationReaction UNIQUE (WishId, ReactorId, ReactionType)
);
GO


-- =============================================================================================================
-- CELEBRATION COMMENT - Comments on celebration wishes
-- =============================================================================================================
CREATE TABLE events.CelebrationComment (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    WishId              BIGINT          NOT NULL,
    CommenterId         BIGINT          NOT NULL,
    ParentCommentId     BIGINT          NULL,
    CommentText         NVARCHAR(500)  NOT NULL,
    IsEdited            BIT             NOT NULL DEFAULT 0,
    EditedAt            DATETIME2       NULL,
    IsDeleted           BIT             NOT NULL DEFAULT 0,
    DeletedAt           DATETIME2       NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_CelebrationComment_Wish
        FOREIGN KEY (WishId)
        REFERENCES events.CelebrationWish(Id),

    CONSTRAINT FK_CelebrationComment_Commenter
        FOREIGN KEY (CommenterId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_CelebrationComment_Parent
        FOREIGN KEY (ParentCommentId)
        REFERENCES events.CelebrationComment(Id)
);
GO


-- =============================================================================================================
-- BIRTHDAY WALL POST - Featured birthday/anniversary posts on dashboard
-- =============================================================================================================
CREATE TABLE events.BirthdayWallPost (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    GreetingCardId      BIGINT          NOT NULL,
    PostedById          BIGINT          NOT NULL,
    PostContent         NVARCHAR(MAX)  NULL,
    ImageUrl            NVARCHAR(1000)  NULL,
    IsFeatured          BIT             NOT NULL DEFAULT 0,
    DisplayStartDate    DATE            NOT NULL,
    DisplayEndDate      DATE            NOT NULL,
    ViewCount           INT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_BirthdayWallPost_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES events.GreetingCard(Id),

    CONSTRAINT FK_BirthdayWallPost_PostedBy
        FOREIGN KEY (PostedById)
        REFERENCES employee.Employee(Id)
);
GO


-- =============================================================================================================
-- MILESTONE BADGE - Awarded for work anniversary milestones
-- =============================================================================================================
CREATE TABLE events.MilestoneBadge (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    BadgeCode           NVARCHAR(50)    NOT NULL UNIQUE,
    BadgeName           NVARCHAR(100)   NOT NULL,
    Description         NVARCHAR(500)   NULL,
    YearsRequired       INT             NOT NULL,
    IconUrl             NVARCHAR(500)   NULL,
    BadgeColor          NVARCHAR(20)    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE()
);
GO


-- =============================================================================================================
-- EMPLOYEE BADGE - Badges earned by employees for milestones
-- =============================================================================================================
CREATE TABLE events.EmployeeBadge (
    Id                  BIGINT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          BIGINT          NOT NULL,
    BadgeId             BIGINT          NOT NULL,
    GreetingCardId      BIGINT          NULL,
    AwardedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    DisplayOnProfile    BIT             NOT NULL DEFAULT 1,

    CONSTRAINT FK_EmployeeBadge_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_EmployeeBadge_Badge
        FOREIGN KEY (BadgeId)
        REFERENCES events.MilestoneBadge(Id),

    CONSTRAINT FK_EmployeeBadge_GreetingCard
        FOREIGN KEY (GreetingCardId)
        REFERENCES events.GreetingCard(Id),

    CONSTRAINT UQ_EmployeeBadge UNIQUE (EmployeeId, BadgeId)
);
GO


-- =============================================================================================================
-- INDEXES - For Birthday & Anniversary performance optimization
-- =============================================================================================================

-- CelebrationSchedule indexes
CREATE INDEX IX_CelebrationSchedule_Employee ON events.CelebrationSchedule(EmployeeId);
CREATE INDEX IX_CelebrationSchedule_Type ON events.CelebrationSchedule(CelebrationType);
CREATE INDEX IX_CelebrationSchedule_Date ON events.CelebrationSchedule(CelebrationDate);

-- GreetingCard indexes
CREATE INDEX IX_GreetingCard_Schedule ON events.GreetingCard(ScheduleId);
CREATE INDEX IX_GreetingCard_Employee ON events.GreetingCard(EmployeeId);
CREATE INDEX IX_GreetingCard_Status ON events.GreetingCard(StatusCode);

-- GreetingNotification indexes
CREATE INDEX IX_GreetingNotification_GreetingCard ON events.GreetingNotification(GreetingCardId);
CREATE INDEX IX_GreetingNotification_Recipient ON events.GreetingNotification(RecipientId);

-- CelebrationWish indexes
CREATE INDEX IX_CelebrationWish_GreetingCard ON events.CelebrationWish(GreetingCardId);
CREATE INDEX IX_CelebrationWish_Wisher ON events.CelebrationWish(WisherId);
CREATE INDEX IX_CelebrationWish_Created ON events.CelebrationWish(CreatedAt);

-- CelebrationReaction indexes
CREATE INDEX IX_CelebrationReaction_Wish ON events.CelebrationReaction(WishId);
CREATE INDEX IX_CelebrationReaction_Reactor ON events.CelebrationReaction(ReactorId);

-- CelebrationComment indexes
CREATE INDEX IX_CelebrationComment_Wish ON events.CelebrationComment(WishId);
CREATE INDEX IX_CelebrationComment_Commenter ON events.CelebrationComment(CommenterId);
CREATE INDEX IX_CelebrationComment_Parent ON events.CelebrationComment(ParentCommentId);

-- BirthdayWallPost indexes
CREATE INDEX IX_BirthdayWallPost_GreetingCard ON events.BirthdayWallPost(GreetingCardId);
CREATE INDEX IX_BirthdayWallPost_Featured ON events.BirthdayWallPost(IsFeatured, DisplayStartDate, DisplayEndDate);

-- EmployeeBadge indexes
CREATE INDEX IX_EmployeeBadge_Employee ON events.EmployeeBadge(EmployeeId);
CREATE INDEX IX_EmployeeBadge_Badge ON events.EmployeeBadge(BadgeId);
GO


-- =============================================================================================================
-- SEED DEFAULT MILESTONE BADGES
-- =============================================================================================================
IF NOT EXISTS (SELECT 1 FROM events.MilestoneBadge WHERE BadgeCode = 'ONE_YEAR')
BEGIN
    INSERT INTO events.MilestoneBadge (BadgeCode, BadgeName, Description, YearsRequired, IconUrl, BadgeColor)
    VALUES
    ('ONE_YEAR', 'First Year', 'Completed 1 year at company', 1, NULL, '#CD7F32'),
    ('THREE_YEARS', 'Three Year Club', 'Completed 3 years at company', 3, NULL, '#C0C0C0'),
    ('FIVE_YEARS', 'Five Year Veteran', 'Completed 5 years at company', 5, NULL, '#FFD700'),
    ('SEVEN_YEARS', 'Seven Year Champion', 'Completed 7 years at company', 7, NULL, '#E5E4E2'),
    ('TEN_YEARS', 'Decade Master', 'Completed 10 years at company', 10, NULL, '#9966CC'),
    ('FIFTEEN_YEARS', 'Fifteen Year Legend', 'Completed 15 years at company', 15, NULL, '#333399'),
    ('TWENTY_YEARS', 'Twenty Year Icon', 'Completed 20 years at company', 20, NULL, '#FFD700');
END
GO


PRINT 'Birthdays & Work Anniversaries schema created successfully';
GO

PRINT 'Events schema created successfully';
GO