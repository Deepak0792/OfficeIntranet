using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Time;

namespace SdxCore.Attendance.Application.Resolvers;

public class ScopeResolver(
    ITimeClient timeClient)
    : IScopeResolver
{
    public async Task<ScopeTypeResponse> GetScopeTypeAsync(
        Guid scopeTypeId,
        CancellationToken cancellationToken = default)
    {
        var scope =
            await timeClient.GetScopeTypeByIdAsync(
                scopeTypeId,
                cancellationToken);

        if (scope is null)
            throw new KeyNotFoundException(
                $"ScopeType '{scopeTypeId}' not found.");

        return scope;
    }
}