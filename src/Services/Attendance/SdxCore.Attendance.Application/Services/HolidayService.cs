using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Holiday.Request;
using SdxCore.Attendance.Application.DTOs.Holiday.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Caching;
using SdxCore.Common.Helpers;

namespace SdxCore.Attendance.Application.Services;

public class HolidayService(
    IHolidayCalendarRepository calendarRepository,
    IHolidayResolver holidayResolver,
    IHolidayRepository holidayRepository,
    IAttendanceUnitOfWork unitOfWork,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder) : IHolidayService
{
    private readonly ICacheService _cache = cacheService;
    private readonly ICacheKeyBuilder _keyBuilder = cacheKeyBuilder;

    public async Task<IEnumerable<HolidayCalendarResponse>> GetAllCalendarsAsync(CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(HolidayCalendar), "all");
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var items = await calendarRepository.GetAllAsync(ct);
            return PropertyMapper.MapList<HolidayCalendar, HolidayCalendarResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? [];
    }

    public async Task<HolidayCalendarResponse?> GetCalendarByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(HolidayCalendar), id.ToString());
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var entity = await calendarRepository.GetByIdAsync(id, ct);
            return entity is null ? null : PropertyMapper.Map<HolidayCalendar, HolidayCalendarResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<HolidayCalendarResponse> CreateCalendarAsync(CreateHolidayCalendarRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateHolidayCalendarRequest, HolidayCalendar>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await calendarRepository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<HolidayCalendar, HolidayCalendarResponse>(entity);
    }

    public async Task<IEnumerable<HolidayResponse>> GetByCalendarAsync(Guid calendarId, int year, CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(Holiday), $"cal_{calendarId}_{year}");
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var items = await holidayRepository.GetByCalendarAsync(calendarId, year, ct);
            return PropertyMapper.MapList<Holiday, HolidayResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? [];
    }

    public async Task<HolidayResponse> CreateHolidayAsync(CreateHolidayRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateHolidayRequest, Holiday>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await holidayRepository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Holiday, HolidayResponse>(entity);
    }

    public async Task<HolidayResponse?> UpdateHolidayAsync(Guid id, UpdateHolidayRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await holidayRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return null;

        PropertyMapper.Patch(request, entity);
        holidayRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Holiday, HolidayResponse>(entity);
    }

    public async Task<HolidayResponse?> ToggleHolidayStatusAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await holidayRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return null;

        entity.IsActive = !entity.IsActive;
        holidayRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Holiday, HolidayResponse>(entity);
    }

    public async Task<IEnumerable<HolidayResponse>> GetApplicableAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(Holiday), $"applicable_{employeeId}_{from}_{to}");
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var calendars = await calendarRepository.FindAsync(c => c.IsDefault && c.IsActive, ct);
            var defaultCalendar = calendars.FirstOrDefault();
            if (defaultCalendar is null) return Enumerable.Empty<HolidayResponse>();

            var holidays = await holidayRepository.GetByCalendarRangeAsync(defaultCalendar.Id, from, to, ct);
            return PropertyMapper.MapList<Holiday, HolidayResponse>(holidays);
        }, CacheOptions.Default, cancellationToken) ?? [];
    }

    public async Task<EmployeeHolidaySummaryResponse>
       GetEmployeeHolidayListAsync(
           Guid employeeId,
           int year,
           CancellationToken cancellationToken = default)
    {
        var holidays =
            await holidayResolver.GetHolidaysAsync(
                employeeId,
                new DateOnly(year, 1, 1),
                new DateOnly(year, 12, 31),
                cancellationToken);

        return new EmployeeHolidaySummaryResponse
        {
            TotalHolidays = holidays.Count,

            NationalHolidays =
                holidays.Count(x =>
                    x.HolidayTypeCode == "NATIONAL"),

            StateHolidays =
                holidays.Count(x =>
                    x.HolidayTypeCode == "STATE"),

            ReligiousHolidays =
                holidays.Count(x =>
                    x.HolidayTypeCode == "RELIGIOUS"),

            Holidays = holidays
        };
    }
}
