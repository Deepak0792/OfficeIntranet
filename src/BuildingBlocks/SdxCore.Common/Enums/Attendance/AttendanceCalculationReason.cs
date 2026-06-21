namespace SdxCore.Common.Enums.Attendance;

public enum AttendanceCalculationReason
{
    PunchReceived = 1,

    AutoCheckout = 2,

    LeaveApproved = 3,

    HolidayChanged = 4,

    RegularizationApproved = 5,

    ShiftChanged = 6,

    ShiftSwapApproved = 7,

    CompOffApproved = 8,

    ManualReprocess = 9
}