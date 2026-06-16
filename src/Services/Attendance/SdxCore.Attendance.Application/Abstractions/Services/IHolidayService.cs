using SdxCore.Attendance.Application.DTOs.Holiday.Request;
using SdxCore.Attendance.Application.DTOs.Holiday.Response;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IHolidayService
{
    Task<IEnumerable<HolidayCalendarResponse>> GetAllCalendarsAsync(CancellationToken cancellationToken = default);
    Task<HolidayCalendarResponse?> GetCalendarByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<HolidayCalendarResponse> CreateCalendarAsync(CreateHolidayCalendarRequest request, CancellationToken cancellationToken = default);
    Task<IEnumerable<HolidayResponse>> GetByCalendarAsync(Guid calendarId, int year, CancellationToken cancellationToken = default);
    Task<HolidayResponse> CreateHolidayAsync(CreateHolidayRequest request, CancellationToken cancellationToken = default);
    Task<HolidayResponse?> UpdateHolidayAsync(Guid id, UpdateHolidayRequest request, CancellationToken cancellationToken = default);
    Task<HolidayResponse?> ToggleHolidayStatusAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<HolidayResponse>> GetApplicableAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default);
}
