using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IAttendanceStatusResolver
{
    Task<AttendanceStatus> ResolveAsync(
        Guid attendanceStatusId,
        CancellationToken cancellationToken = default);

    Task<AttendanceStatus> ResolveByCodeAsync(
        string statusCode,
        CancellationToken cancellationToken = default);
}