using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IAttendanceResolver
{
    Task<AttendanceRecord> GetAttendanceAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);
}