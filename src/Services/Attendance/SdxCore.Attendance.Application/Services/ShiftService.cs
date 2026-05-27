using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Distributed;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;

namespace SdxCore.Attendance.Application.Services;

public interface IShiftService
{
    Task<Shift?> GetShiftAsync(short shiftId, CancellationToken cancellationToken = default);
}

public class ShiftService : IShiftService
{
    private readonly AttendanceDbContext _dbContext;
    private readonly IDistributedCache _cache;
    private readonly string _cacheKeyPrefix = "shift:";

    public ShiftService(AttendanceDbContext dbContext, IDistributedCache cache)
    {
        _dbContext = dbContext;
        _cache = cache;
    }

    public async Task<Shift?> GetShiftAsync(short shiftId, CancellationToken cancellationToken = default)
    {
        string cacheKey = _cacheKeyPrefix + shiftId;
        var cachedData = await _cache.GetStringAsync(cacheKey, cancellationToken);
        if (!string.IsNullOrEmpty(cachedData))
        {
            return JsonSerializer.Deserialize<Shift>(cachedData);
        }

        var shift = await _dbContext.Shifts.FindAsync(new object[] { shiftId }, cancellationToken);
        if (shift != null)
        {
            var options = new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24) };
            await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(shift), options, cancellationToken);
        }

        return shift;
    }
}
