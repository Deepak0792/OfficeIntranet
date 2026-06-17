using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Application.Exceptions;
using SdxCore.Attendance.Application.Abstractions.Resolvers;

namespace SdxCore.Attendance.Application.Resolvers;


public class HolidayCalendarResolver(
    IHolidayCalendarRepository repository)
    : IHolidayCalendarResolver
{
    public async Task<HolidayCalendar>
        ResolveAsync(
            Guid calendarId,
            CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                calendarId,
                cancellationToken);

        if (entity is null)
            throw ResolverException.NotFound(
                nameof(HolidayCalendar),
                calendarId);

        return entity;
    }
}