using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Time.Response;
using SdxCore.Caching;

namespace SdxCore.Attendance.Application.Resolvers;

public sealed class TimeZoneResolver(
    ITimeClient timeClient,
    ICacheService cache,
    ICacheKeyBuilder keyBuilder)
    : ITimeZoneResolver
{
    public async Task<IReadOnlyCollection<TimeZoneMasterResponse>> GetAllAsync(
        CancellationToken cancellationToken = default)
    {
        var key =
            keyBuilder.BuildKey(
                nameof(TimeZoneMasterResponse),
                "all");

        return await cache.GetOrSetAsync(
            key,
            async ct =>
            {
                var timeZones =
                    await timeClient.GetAllTimeZoneMastersAsync(ct);

                return timeZones.ToList();
            },
            CacheOptions.StaticMasterData,
            cancellationToken)
            ?? [];
    }

    public async Task<TimeZoneMasterResponse?> GetByCodeAsync(
        string timeZoneCode,
        CancellationToken cancellationToken = default)
    {
        var timeZones =
            await GetAllAsync(cancellationToken);

        return timeZones.FirstOrDefault(
            x => string.Equals(
                x.TimeZoneCode,
                timeZoneCode,
                StringComparison.OrdinalIgnoreCase));
    }

    public async Task<Guid?> GetTimeZoneIdAsync(
        string timeZoneCode,
        CancellationToken cancellationToken = default)
    {
        var timeZone =
            await GetByCodeAsync(
                timeZoneCode,
                cancellationToken);

        return timeZone?.Id;
    }

    public async Task<TimeZoneMasterResponse> GetTimeZoneAsync(
        Guid timeZoneId,
        CancellationToken cancellationToken = default)
    {
        var timeZones =
            await GetAllAsync(cancellationToken);

        var timeZone =
            timeZones.FirstOrDefault(
                x => x.Id == timeZoneId);

        return timeZone
            ?? throw new InvalidOperationException(
                $"TimeZone '{timeZoneId}' not found.");
    }

    public async Task<string> GetTimeZoneCodeByIdAsync(
        Guid timeZoneId,
        CancellationToken cancellationToken = default)
    {
        var timeZones =
            await GetAllAsync(cancellationToken);

        var timeZone =
            timeZones.FirstOrDefault(
                x => x.Id == timeZoneId);

        return timeZone?.TimeZoneCode
            ?? throw new InvalidOperationException(
                $"TimeZone '{timeZoneId}' not found.");
    }
}