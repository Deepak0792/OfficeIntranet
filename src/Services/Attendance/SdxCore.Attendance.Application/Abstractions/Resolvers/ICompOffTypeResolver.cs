using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ICompOffTypeResolver
{
    Task<CompOffType> ResolveAsync(
        Guid compOffTypeId,
        CancellationToken cancellationToken = default);
}
