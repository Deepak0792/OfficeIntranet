using SdxCore.Attendance.Application.DTOs;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IEmployeeCalendarResolver
{
    Task<EmployeeCalendarResult> ResolveAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);
}