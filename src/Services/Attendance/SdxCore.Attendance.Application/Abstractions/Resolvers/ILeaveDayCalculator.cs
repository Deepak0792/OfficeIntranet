using SdxCore.Attendance.Application.DTOs;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ILeaveDayCalculator
{
    Task<EmployeeCalendarResult> CalculateAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);
}