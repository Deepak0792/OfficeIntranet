using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IAttendanceCalculationQueueService
{
    Task EnqueueAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        AttendanceCalculationReason reason,
        byte priority = 1,
        CancellationToken cancellationToken = default);
}