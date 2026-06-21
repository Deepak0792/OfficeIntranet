using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Caching;

namespace SdxCore.Attendance.Application.Resolvers;

public class AttendanceStatusResolver(
    IAttendanceStatusRepository repository,
    ICacheService cache,
    ICacheKeyBuilder keyBuilder)
    : IAttendanceStatusResolver
{
    public async Task<AttendanceStatus> ResolveAsync(
        Guid attendanceStatusId,
        CancellationToken cancellationToken = default)
    {
        return (await GetAllAttendanceStatusAsync(cancellationToken))?.FirstOrDefault(e => e.Id == attendanceStatusId)
            ?? throw new InvalidOperationException($"AttendanceStatus '{attendanceStatusId}' not found.");
    }

    public async Task<AttendanceStatus> ResolveByCodeAsync(
        string statusCode,
        CancellationToken cancellationToken = default)
    {
        return (await GetAllAttendanceStatusAsync(cancellationToken))?.FirstOrDefault(e => e.StatusCode == statusCode)
            ?? throw new InvalidOperationException($"AttendanceStatus '{statusCode}' not found.");
    }

    private async Task<IEnumerable<AttendanceStatus>> GetAllAttendanceStatusAsync(CancellationToken cancellationToken)
    {
        var key = keyBuilder.BuildKey(nameof(AttendanceStatus), "all");

        return await cache.GetOrSetAsync(key, async ct =>
        {
            var result = await repository.GetAllAsync(ct);
            return result?.ToList() ?? [];
        }, CacheOptions.StaticMasterData, cancellationToken) ?? [];
    }
}