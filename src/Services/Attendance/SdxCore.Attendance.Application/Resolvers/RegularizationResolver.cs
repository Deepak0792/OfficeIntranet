using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public sealed class RegularizationResolver(
    IAttendanceRegularizationRepository repository)
    : IRegularizationResolver
{
    public async Task<AttendanceRegularization?>
        ResolveApprovedAsync(
            Guid employeeId,
            DateOnly attendanceDate,
            CancellationToken cancellationToken = default)
    {
        return await repository
            .GetApprovedByEmployeeDateAsync(
                employeeId,
                attendanceDate,
                cancellationToken);
    }

    public async Task<bool> IsRegularizedAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default)
    {
        return await ResolveApprovedAsync(
                   employeeId,
                   attendanceDate,
                   cancellationToken)
               is not null;
    }
}