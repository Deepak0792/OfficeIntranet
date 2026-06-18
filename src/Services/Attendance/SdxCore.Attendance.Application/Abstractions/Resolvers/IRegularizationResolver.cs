using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IRegularizationResolver
{
    Task<AttendanceRegularization> ResolveAsync(
        Guid regularizationId,
        CancellationToken cancellationToken = default);
}