using SdxCore.Attendance.Application.DTOs.Time;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IScopeResolver
{
    Task<ScopeTypeResponse> GetScopeTypeAsync(
        Guid scopeTypeId,
        CancellationToken cancellationToken = default);
}