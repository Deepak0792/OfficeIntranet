using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Helpers;

public static class AttendanceHelper
{
    public static bool HasWorked(AttendanceRecord attendance)
    {
        return attendance.WorkedMinutes > 0;
    }
}