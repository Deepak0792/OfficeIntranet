using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class RegularizationResolver(
    IAttendanceRegularizationRepository repository)
    : IRegularizationResolver
{
    public async Task<AttendanceRegularization> ResolveAsync(
        Guid regularizationId,
        CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                regularizationId,
                cancellationToken);

        if (entity is null)
            throw new InvalidOperationException(
                $"Regularization '{regularizationId}' not found.");

        return entity;
    }
}