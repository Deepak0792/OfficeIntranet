using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Time;
using SdxCore.Caching;

namespace SdxCore.Attendance.Application.Resolvers;

public sealed class ScopeResolver(
    ITimeClient timeClient,
    ICacheService cache,
    ICacheKeyBuilder keyBuilder)
    : IScopeResolver
{
    public async Task<IReadOnlyCollection<ScopeTypeResponse>> GetAllAsync(
        CancellationToken cancellationToken = default)
    {
        var key =
            keyBuilder.BuildKey(
                nameof(ScopeTypeResponse),
                "all");

        return await cache.GetOrSetAsync(
            key,
            async ct =>
            {
                var scopes =
                    await timeClient.GetAllScopeTypeAsync(ct);

                return scopes.ToList();
            },
            CacheOptions.StaticMasterData,
            cancellationToken)
            ?? [];
    }

    public async Task<ScopeTypeResponse?> GetByCodeAsync(
        string scopeCode,
        CancellationToken cancellationToken = default)
    {
        var scopes =
            await GetAllAsync(cancellationToken);

        return scopes.FirstOrDefault(
            x => string.Equals(
                x.ScopeCode,
                scopeCode,
                StringComparison.OrdinalIgnoreCase));
    }

    public async Task<Guid?> GetScopeTypeIdAsync(
        string scopeCode,
        CancellationToken cancellationToken = default)
    {
        var scope =
            await GetByCodeAsync(
                scopeCode,
                cancellationToken);

        return scope?.Id;
    }

    public async Task<ScopeTypeResponse> GetScopeTypeAsync(
        Guid scopeTypeId,
        CancellationToken cancellationToken = default)
    {
        var scopes =
            await GetAllAsync(cancellationToken);

        var scope =
            scopes.FirstOrDefault(
                x => x.Id == scopeTypeId);

        return scope
            ?? throw new InvalidOperationException(
                $"ScopeType '{scopeTypeId}' not found.");
    }

    public async Task<string> GetScopeCodeByIdAsync(
        Guid scopeTypeId,
        CancellationToken cancellationToken = default)
    {
        var scopes =
            await GetAllAsync(cancellationToken);

        var scope =
            scopes.FirstOrDefault(x => x.Id == scopeTypeId);

        return scope?.ScopeCode
            ?? throw new InvalidOperationException(
                $"ScopeType '{scopeTypeId}' not found.");
    }
}