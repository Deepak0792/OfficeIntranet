using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IRegularizationResolver
{
    Task<AttendanceRegularization?> ResolveApprovedAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);

    Task<bool> IsRegularizedAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);
}