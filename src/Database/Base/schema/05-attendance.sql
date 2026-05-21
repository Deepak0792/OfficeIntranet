-- ATTENDANCE SCHEMA - Attendance, Leave & Scheduling
-- SQL Server Database Schema
-- Schema: attendance
-- Purpose: Leave management, shift scheduling, roster management, holiday calendars
-- Dependencies: shared (StatusLookup), employee (Employee), time (OfficeLocation, ScopeType, Shift)

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'attendance')
BEGIN
    EXEC('CREATE SCHEMA attendance');
END
GO

-- ATTENDANCE STATUS
CREATE TABLE attendance.AttendanceStatus (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    StatusCode          NVARCHAR(100)   NOT NULL UNIQUE,
    StatusName          NVARCHAR(200)   NOT NULL,
    IsPresent           BIT             NOT NULL DEFAULT 0,
    IsAbsent            BIT             NOT NULL DEFAULT 0,
    IsPaid              BIT             NOT NULL DEFAULT 0,
    CountsAsWorkingDay  BIT             NOT NULL DEFAULT 0,
    DisplayOrder        SMALLINT             NOT NULL DEFAULT 1,
    IsSystemStatus      BIT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- ATTENDANCE RECORD
CREATE TABLE attendance.AttendanceRecord (
    Id                      INT      PRIMARY KEY IDENTITY(1,1),
    EmployeeId              INT      NOT NULL,
    AttendanceDate          DATE        NOT NULL,
    ShiftId                 SMALLINT      NULL,
    AttendanceStatusId      SMALLINT      NULL,
    CheckInTime             DATETIME2   NULL,
    CheckOutTime            DATETIME2   NULL,
    LateByMinutes           SMALLINT         NULL,
    EarlyExitMinutes        SMALLINT         NULL,
    WorkedMinutes           SMALLINT         NULL,
    OvertimeMinutes         SMALLINT         NULL,
    IsManualEntry           BIT         NOT NULL DEFAULT 0,
    Remarks                 NVARCHAR(1000) NULL,
    ApprovedBy              INT      NULL,
    ApprovedAt              DATETIME2   NULL,
    IsActive                BIT         NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT         NULL,
    LastUpdatedAt           DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT         NULL,

    CONSTRAINT FK_Attendance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Attendance_Status
        FOREIGN KEY (AttendanceStatusId)
        REFERENCES attendance.AttendanceStatus(Id),

    CONSTRAINT UQ_Attendance
        UNIQUE (EmployeeId, AttendanceDate)
);
GO

-- ATTENDANCE LOG - Raw biometric punches
CREATE TABLE attendance.AttendanceLog (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT          NOT NULL,
    PunchTime           DATETIME2       NOT NULL,
    PunchType           NVARCHAR(20)    NULL,
    DeviceId            NVARCHAR(100)   NULL,
    Location            NVARCHAR(500)   NULL,
    IsProcessed         BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_AttendanceLog_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id)
);
GO

-- MOBILE ATTENDANCE LOG - GPS-based mobile punches
CREATE TABLE attendance.MobileAttendanceLog (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT          NOT NULL,
    GeoFenceId          SMALLINT     NULL,
    PunchTime           DATETIME2       NOT NULL,
    Latitude            DECIMAL(18,8)   NOT NULL,
    Longitude           DECIMAL(18,8)   NOT NULL,
    IsInsideGeoFence    BIT             NOT NULL DEFAULT 0,
    DeviceInfo          NVARCHAR(500)   NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_MobileAttendanceLog_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_MobileAttendanceLog_GeoFence
        FOREIGN KEY (GeoFenceId)
        REFERENCES time.GeoFence(Id)
);
GO

-- LEAVE TYPE
CREATE TABLE attendance.LeaveType (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    LeaveCode           NVARCHAR(100)   NOT NULL UNIQUE,
    LeaveName           NVARCHAR(200)   NOT NULL,
    IsPaid              BIT             NOT NULL DEFAULT 1,
    MaxDaysPerYear      DECIMAL(10,2)   NULL,
    AllowCarryForward   BIT             NOT NULL DEFAULT 0,
    RequiresApproval    BIT             NOT NULL DEFAULT 1,
    AllowHalfDay        BIT             NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- LEAVE REQUEST
CREATE TABLE attendance.LeaveRequest (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT          NOT NULL,
    LeaveTypeId         SMALLINT          NOT NULL,
    LeaveStatus         NVARCHAR(50)    NOT NULL,
    LeaveStatusGroup    AS CAST('LEAVE_STATUS' AS NVARCHAR(50)) PERSISTED,
    FromDate            DATE            NOT NULL,
    ToDate              DATE            NOT NULL,
    TotalDays           DECIMAL(10,2)   NOT NULL,
    IsHalfDay           BIT             NOT NULL DEFAULT 0,
    HalfDaySession      NVARCHAR(20)    NULL,
    Reason              NVARCHAR(1000)  NULL,
    WorkflowInstanceId  INT          NULL,
    Remarks             NVARCHAR(1000)  NULL,
    ApprovedBy          INT          NULL,
    ApprovedAt          DATETIME2       NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_LeaveRequest_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_LeaveRequest_Type
        FOREIGN KEY (LeaveTypeId)
        REFERENCES attendance.LeaveType(Id),

    CONSTRAINT FK_LeaveRequest_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),
    
    CONSTRAINT FK_LeaveRequest_LeaveStatus
        FOREIGN KEY (LeaveStatus, LeaveStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- LEAVE BALANCE
CREATE TABLE attendance.LeaveBalance (
    Id              INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId      INT          NOT NULL,
    LeaveTypeId     SMALLINT          NOT NULL,
    BalanceYear     SMALLINT             NOT NULL,
    OpeningBalance  DECIMAL(10,2)   NOT NULL DEFAULT 0,
    Allocated       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    Availed         DECIMAL(10,2)   NOT NULL DEFAULT 0,
    Encashed        DECIMAL(10,2)   NOT NULL DEFAULT 0,
    CarryForward    DECIMAL(10,2)   NOT NULL DEFAULT 0,
    ClosingBalance  AS (OpeningBalance + Allocated + CarryForward - Availed - Encashed),
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_LeaveBalance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_LeaveBalance_Type
        FOREIGN KEY (LeaveTypeId)
        REFERENCES attendance.LeaveType(Id),

    CONSTRAINT UQ_LeaveBalance
        UNIQUE (EmployeeId, LeaveTypeId, BalanceYear)
);
GO

-- COMP-OFF TYPE
CREATE TABLE attendance.CompOffType (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    CompOffTypeCode NVARCHAR(100)   NOT NULL UNIQUE,
    CompOffTypeName NVARCHAR(200)   NOT NULL,
    ExpiryDays      SMALLINT             NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- COMP-OFF BALANCE
CREATE TABLE attendance.CompOffBalance (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT          NOT NULL,
    CompOffTypeId       SMALLINT          NOT NULL,
    EarnedDate          DATE            NOT NULL,
    ExpiryDate          DATE            NULL,
    TotalDays           DECIMAL(10,2)   NOT NULL,
    AvailedDays         DECIMAL(10,2)   NOT NULL DEFAULT 0,
    RemainingDays       AS (TotalDays - AvailedDays),
    AttendanceRecordId  INT          NULL,
    WorkflowInstanceId  INT          NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_CompOffBalance_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_CompOffBalance_CompOffType
        FOREIGN KEY (CompOffTypeId)
        REFERENCES attendance.CompOffType(Id),

    CONSTRAINT FK_CompOffBalance_AttendanceRecord
        FOREIGN KEY (AttendanceRecordId)
        REFERENCES attendance.AttendanceRecord(Id),

    CONSTRAINT FK_CompOffBalance_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id)
);
GO

-- ATTENDANCE REGULARIZATION
CREATE TABLE attendance.AttendanceRegularization (
    Id                                  INT      PRIMARY KEY IDENTITY(1,1),
    EmployeeId                          INT      NOT NULL,
    AttendanceDate                      DATE        NOT NULL,
    RequestedCheckIn                    DATETIME2   NULL,
    RequestedCheckOut                   DATETIME2   NULL,
    Reason                              NVARCHAR(1000) NULL,
    RegularizationStatus                NVARCHAR(50) NOT NULL,
    RegularizationStatusGroup           AS CAST('ATTENDANCE_REGULARIZATION_STATUS' AS NVARCHAR(50)) PERSISTED,
    WorkflowInstanceId                  INT      NULL,
    ApprovedBy                          INT      NULL,
    ApprovedAt                          DATETIME2   NULL,
    Remarks                             NVARCHAR(1000) NULL,
    IsActive                            BIT             NOT NULL DEFAULT 1,
    CreatedAt                           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy                           INT             NULL,
    LastUpdatedAt                       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy                       INT             NULL,

    CONSTRAINT FK_Regularization_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_AttendanceRegularization_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),
    
    CONSTRAINT FK_AttendanceRegularization_RegularizationStatus
        FOREIGN KEY (RegularizationStatus, RegularizationStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- SHIFT
CREATE TABLE attendance.Shift (
    Id                      SMALLINT          PRIMARY KEY IDENTITY(1,1),
    ShiftCode               NVARCHAR(100)   NOT NULL UNIQUE,
    ShiftName               NVARCHAR(200)   NOT NULL,
    StartTime               TIME            NOT NULL,
    EndTime                 TIME            NOT NULL,
    BreakDurationMinutes    SMALLINT             NOT NULL DEFAULT 0,
    GraceInMinutes          SMALLINT             NOT NULL DEFAULT 0,
    GraceOutMinutes         SMALLINT             NOT NULL DEFAULT 0,
    MinimumWorkingMinutes   SMALLINT             NULL,
    MaximumWorkingMinutes   SMALLINT             NULL,
    IsNightShift            BIT             NOT NULL DEFAULT 0,
    CrossesMidnight         BIT             NOT NULL DEFAULT 0,
    IsFlexible              BIT             NOT NULL DEFAULT 0,
    AllowOvertime           BIT             NOT NULL DEFAULT 1,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL
);
GO

ALTER TABLE attendance.AttendanceRecord ADD CONSTRAINT FK_Attendance_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES attendance.Shift(Id)

GO

-- SHIFT ASSIGNMENT
CREATE TABLE attendance.ShiftAssignment (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    ShiftId             SMALLINT          NOT NULL,
    ScopeTypeId         SMALLINT          NOT NULL,
    ScopeReferenceId    INT  NOT NULL,
    EffectiveFrom       DATE    NOT NULL,
    EffectiveTo         DATE    NULL,
    PriorityOrder       SMALLINT     NOT NULL DEFAULT 1,
    IsPrimaryShift      BIT     NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_ShiftAssignment_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES attendance.Shift(Id),

    CONSTRAINT FK_ShiftAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES time.ScopeType(Id)
);
GO

-- SHIFT SWAP STATUS
CREATE TABLE attendance.ShiftSwapStatus (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    StatusCode          NVARCHAR(100)   NOT NULL UNIQUE,
    StatusName          NVARCHAR(200)   NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- SHIFT SWAP REQUEST
CREATE TABLE attendance.ShiftSwapRequest (
    Id                      INT      PRIMARY KEY IDENTITY(1,1),
    RequesterEmployeeId     INT      NOT NULL,
    TargetEmployeeId        INT      NOT NULL,
    RequesterRosterId       INT      NOT NULL,
    TargetRosterId          INT      NOT NULL,
    ShiftSwapStatus         NVARCHAR(50) NOT NULL,
    ShiftSwapStatusGroup    AS CAST('SHIFT_SWAP_STATUS' AS NVARCHAR(50)) PERSISTED,
    WorkflowInstanceId      INT      NULL,
    RequestedAt             DATETIME2   NOT NULL DEFAULT GETUTCDATE(),
    ApprovedBy              INT      NULL,
    ApprovedAt              DATETIME2   NULL,
    Remarks                 NVARCHAR(1000) NULL,
    IsActive                BIT             NOT NULL DEFAULT 1,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy               INT             NULL,
    LastUpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy           INT             NULL,

    CONSTRAINT FK_ShiftSwapRequest_RequesterEmployee
        FOREIGN KEY (RequesterEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ShiftSwapRequest_TargetEmployee
        FOREIGN KEY (TargetEmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_ShiftSwapRequest_WorkflowInstance
        FOREIGN KEY (WorkflowInstanceId)
        REFERENCES workflow.WorkflowInstance(Id),
    
    CONSTRAINT FK_ShiftSwapRequest_ShiftSwapStatus
        FOREIGN KEY (ShiftSwapStatus, ShiftSwapStatusGroup)
        REFERENCES shared.StatusLookup (StatusCode, StatusGroup)
);
GO

-- ROTATION SHIFT
CREATE TABLE attendance.RotationShift (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    RotationCode    NVARCHAR(100)   NOT NULL UNIQUE,
    RotationName    NVARCHAR(200)   NOT NULL,
    CycleLengthDays INT             NOT NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- ROTATION SHIFT DETAIL
CREATE TABLE attendance.RotationShiftDetail (
    Id              SMALLINT  PRIMARY KEY IDENTITY(1,1),
    RotationShiftId SMALLINT  NOT NULL,
    SequenceNo      SMALLINT     NOT NULL,
    ShiftId         SMALLINT  NULL,
    DurationDays    SMALLINT     NOT NULL,
    IsOffDay        BIT     NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_RotationDetail_Rotation
        FOREIGN KEY (RotationShiftId)
        REFERENCES attendance.RotationShift(Id),

    CONSTRAINT FK_RotationDetail_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES attendance.Shift(Id)
);
GO

-- ROTATION SHIFT ASSIGNMENT
CREATE TABLE attendance.RotationShiftAssignment (
    Id                  INT  PRIMARY KEY IDENTITY(1,1),
    RotationShiftId     SMALLINT  NOT NULL,
    ScopeTypeId         SMALLINT  NOT NULL,
    ScopeReferenceId    INT  NOT NULL,
    RotationStartDate   DATE    NOT NULL,
    EffectiveFrom       DATE    NOT NULL,
    EffectiveTo         DATE    NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_RotationAssignment_Rotation
        FOREIGN KEY (RotationShiftId)
        REFERENCES attendance.RotationShift(Id),

    CONSTRAINT FK_RotationAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES time.ScopeType(Id)
);
GO

-- EMPLOYEE SHIFT ROSTER
CREATE TABLE attendance.EmployeeShiftRoster (
    Id                  INT      PRIMARY KEY IDENTITY(1,1),
    EmployeeId          INT      NOT NULL,
    RosterDate          DATE        NOT NULL,
    ShiftId             SMALLINT      NULL,
    IsOffDay            BIT         NOT NULL DEFAULT 0,
    IsHoliday           BIT         NOT NULL DEFAULT 0,
    PlannedStartTime    DATETIME2   NULL,
    PlannedEndTime      DATETIME2   NULL,
    ActualStartTime     DATETIME2   NULL,
    ActualEndTime       DATETIME2   NULL,
    Remarks             NVARCHAR(1000) NULL,
    IsLocked            BIT         NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_Roster_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES employee.Employee(Id),

    CONSTRAINT FK_Roster_Shift
        FOREIGN KEY (ShiftId)
        REFERENCES attendance.Shift(Id),

    CONSTRAINT UQ_EmployeeRoster
        UNIQUE (EmployeeId, RosterDate)
);
GO

-- Add FKs for ShiftSwapRequest to Roster
ALTER TABLE attendance.ShiftSwapRequest
    ADD CONSTRAINT FK_ShiftSwapRequest_RequesterRoster
        FOREIGN KEY (RequesterRosterId)
        REFERENCES attendance.EmployeeShiftRoster(Id);

ALTER TABLE attendance.ShiftSwapRequest
    ADD CONSTRAINT FK_ShiftSwapRequest_TargetRoster
        FOREIGN KEY (TargetRosterId)
        REFERENCES attendance.EmployeeShiftRoster(Id);
GO

-- HOLIDAY CALENDAR
CREATE TABLE attendance.HolidayCalendar (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    CalendarCode    NVARCHAR(100)   NOT NULL UNIQUE,
    CalendarName    NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsDefault       BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- HOLIDAY TYPE
CREATE TABLE attendance.HolidayType (
    Id                  SMALLINT          PRIMARY KEY IDENTITY(1,1),
    HolidayTypeCode     NVARCHAR(100)   NOT NULL UNIQUE,
    HolidayTypeName     NVARCHAR(200)   NOT NULL,
    IsOptional          BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- HOLIDAY
CREATE TABLE attendance.Holiday (
    Id                  INT          PRIMARY KEY IDENTITY(1,1),
    HolidayCalendarId   SMALLINT          NOT NULL,
    HolidayTypeId       SMALLINT          NOT NULL,
    HolidayCode         NVARCHAR(100)   NULL,
    HolidayName         NVARCHAR(200)   NOT NULL,
    HolidayDate         DATE            NOT NULL,
    IsHalfDay           BIT             NOT NULL DEFAULT 0,
    HalfDaySession      NVARCHAR(20)    NULL,
    IsRecurring         BIT             NOT NULL DEFAULT 1,
    ApplicableYear      SMALLINT             NULL,
    Description         NVARCHAR(1000)  NULL,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_Holiday_Calendar
        FOREIGN KEY (HolidayCalendarId)
        REFERENCES attendance.HolidayCalendar(Id),

    CONSTRAINT FK_Holiday_Type
        FOREIGN KEY (HolidayTypeId)
        REFERENCES attendance.HolidayType(Id)
);
GO

-- HOLIDAY CALENDAR ASSIGNMENT
CREATE TABLE attendance.HolidayCalendarAssignment (
    Id                  INT  PRIMARY KEY IDENTITY(1,1),
    HolidayCalendarId   SMALLINT  NOT NULL,
    ScopeTypeId         SMALLINT  NOT NULL,
    ScopeReferenceId    INT  NOT NULL,
    EffectiveFrom       DATE    NULL,
    EffectiveTo         DATE    NULL,
    PriorityOrder       SMALLINT     NOT NULL DEFAULT 1,
    MergeStrategy       NVARCHAR(50)    NULL,
    IsPrimary           BIT     NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_HolidayAssignment_Calendar
        FOREIGN KEY (HolidayCalendarId)
        REFERENCES attendance.HolidayCalendar(Id),

    CONSTRAINT FK_HolidayAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES time.ScopeType(Id)
);
GO

-- WORK WEEK POLICY
CREATE TABLE attendance.WorkWeekPolicy (
    Id              SMALLINT          PRIMARY KEY IDENTITY(1,1),
    PolicyCode      NVARCHAR(100)   NOT NULL UNIQUE,
    PolicyName      NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    IsDefault       BIT             NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL
);
GO

-- WORK WEEK POLICY DAY
CREATE TABLE attendance.WorkWeekPolicyDay (
    Id                      SMALLINT  PRIMARY KEY IDENTITY(1,1),
    WorkWeekPolicyId        SMALLINT  NOT NULL,
    DayOfWeek               TINYINT NOT NULL,
    IsWorkingDay            BIT     NOT NULL,
    StandardWorkingMinutes  SMALLINT     NULL,
    IsHalfDay               BIT     NOT NULL DEFAULT 0,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_WorkWeekPolicyDay_Policy
        FOREIGN KEY (WorkWeekPolicyId)
        REFERENCES attendance.WorkWeekPolicy(Id),

    CONSTRAINT UQ_WorkWeekPolicyDay
        UNIQUE (WorkWeekPolicyId, DayOfWeek)
);
GO

-- WORK WEEK POLICY ASSIGNMENT
CREATE TABLE attendance.WorkWeekPolicyAssignment (
    Id                  SMALLINT  PRIMARY KEY IDENTITY(1,1),
    WorkWeekPolicyId    SMALLINT  NOT NULL,
    ScopeTypeId         SMALLINT  NOT NULL,
    ScopeReferenceId    INT  NOT NULL,
    EffectiveFrom       DATE    NOT NULL,
    EffectiveTo         DATE    NULL,
    PriorityOrder       SMALLINT     NOT NULL DEFAULT 1,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy           INT             NULL,
    LastUpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    LastUpdatedBy       INT             NULL,

    CONSTRAINT FK_WorkWeekAssignment_Policy
        FOREIGN KEY (WorkWeekPolicyId)
        REFERENCES attendance.WorkWeekPolicy(Id),

    CONSTRAINT FK_WorkWeekAssignment_ScopeType
        FOREIGN KEY (ScopeTypeId)
        REFERENCES time.ScopeType(Id)
);
GO

-- INDEXES - attendance Schema
CREATE INDEX IX_AttendanceRecord_Employee_Date ON attendance.AttendanceRecord (EmployeeId, AttendanceDate);
CREATE INDEX IX_AttendanceRecord_Shift         ON attendance.AttendanceRecord (ShiftId);
CREATE INDEX IX_AttendanceRecord_Status        ON attendance.AttendanceRecord (AttendanceStatusId);

CREATE INDEX IX_AttendanceLog_Employee_Time   ON attendance.AttendanceLog (EmployeeId, PunchTime);

CREATE INDEX IX_MobileAttendanceLog_Employee   ON attendance.MobileAttendanceLog (EmployeeId, PunchTime);

CREATE INDEX IX_LeaveRequest_Employee           ON attendance.LeaveRequest (EmployeeId, FromDate, ToDate);
CREATE INDEX IX_LeaveRequest_LeaveType         ON attendance.LeaveRequest (LeaveTypeId);
CREATE INDEX IX_LeaveRequest_WorkflowInstance  ON attendance.LeaveRequest (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_LeaveRequest_WorkflowInstance
    ON attendance.LeaveRequest (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

CREATE INDEX IX_LeaveBalance_Employee           ON attendance.LeaveBalance (EmployeeId, LeaveTypeId);

CREATE INDEX IX_CompOffBalance_Employee         ON attendance.CompOffBalance (EmployeeId, CompOffTypeId);
CREATE INDEX IX_CompOffBalance_WorkflowInstance ON attendance.CompOffBalance (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_CompOffBalance_WorkflowInstance
    ON attendance.CompOffBalance (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

CREATE INDEX IX_AttendanceRegularization_Employee   ON attendance.AttendanceRegularization (EmployeeId, AttendanceDate);
CREATE INDEX IX_AttendanceRegularization_WorkflowInstance ON attendance.AttendanceRegularization (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_AttendanceRegularization_WorkflowInstance
    ON attendance.AttendanceRegularization (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

CREATE INDEX IX_ShiftAssignment_Scope            ON attendance.ShiftAssignment (ScopeTypeId, ScopeReferenceId);

CREATE INDEX IX_ShiftSwapRequest_Requester       ON attendance.ShiftSwapRequest (RequesterEmployeeId, RequestedAt);
CREATE INDEX IX_ShiftSwapRequest_Target          ON attendance.ShiftSwapRequest (TargetEmployeeId);
CREATE INDEX IX_ShiftSwapRequest_WorkflowInstance ON attendance.ShiftSwapRequest (WorkflowInstanceId);

CREATE UNIQUE INDEX UIX_ShiftSwapRequest_WorkflowInstance
    ON attendance.ShiftSwapRequest (WorkflowInstanceId)
    WHERE WorkflowInstanceId IS NOT NULL;

CREATE INDEX IX_RotationAssignment_Scope        ON attendance.RotationShiftAssignment (ScopeTypeId, ScopeReferenceId);

CREATE INDEX IX_EmployeeShiftRoster_Employee_Date ON attendance.EmployeeShiftRoster (EmployeeId, RosterDate);

CREATE INDEX IX_Holiday_Date                      ON attendance.Holiday (HolidayDate);
CREATE INDEX IX_Holiday_Calendar                 ON attendance.Holiday (HolidayCalendarId);

CREATE INDEX IX_HolidayAssignment_Scope         ON attendance.HolidayCalendarAssignment (ScopeTypeId, ScopeReferenceId);

PRINT 'Attendance schema created successfully';
GO