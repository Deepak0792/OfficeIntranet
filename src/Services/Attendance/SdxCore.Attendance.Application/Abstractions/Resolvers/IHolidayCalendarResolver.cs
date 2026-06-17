using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IHolidayCalendarResolver
{
    Task<HolidayCalendar> ResolveAsync(
        Guid calendarId,
        CancellationToken cancellationToken = default);
}