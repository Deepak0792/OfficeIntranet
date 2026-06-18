using SdxCore.Attendance.Application.DTOs.Holiday.Response;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IHolidayResolver
{
    Task<bool> IsHolidayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<DateOnly>> GetHolidayDatesAsync(
        Guid employeeId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken = default);

    Task<int> GetHolidayCountAsync(
        Guid employeeId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<EmployeeHolidayResponse>>
        GetHolidaysAsync(
            Guid employeeId,
            DateOnly from,
            DateOnly to,
            CancellationToken cancellationToken = default);
}