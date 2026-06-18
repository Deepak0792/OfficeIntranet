using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class AttendanceStatusResolver(
    IAttendanceStatusRepository repository)
    : IAttendanceStatusResolver
{
    public async Task<AttendanceStatus> ResolveAsync(
        Guid attendanceStatusId,
        CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                attendanceStatusId,
                cancellationToken);

        if (entity is null)
            throw new InvalidOperationException(
                $"AttendanceStatus '{attendanceStatusId}' not found.");

        return entity;
    }
}