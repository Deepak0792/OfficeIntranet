using SdxCore.Attendance.Application.DTOs.Holiday.Response;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IHolidayCalendarResolver
{
    Task<IReadOnlyList<ResolvedHolidayCalendar>>
        ResolveCalendarsAsync(
            Guid employeeId,
            CancellationToken cancellationToken = default);
}