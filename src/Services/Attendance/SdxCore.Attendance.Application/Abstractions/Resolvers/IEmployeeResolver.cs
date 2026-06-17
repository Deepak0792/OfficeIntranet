namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

using SdxCore.Attendance.Application.DTOs.Employee;

public interface IEmployeeResolver
{
    Task<EmployeeSummaryResponse> ResolveActiveEmployeeAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<EmployeeSummaryResponse>> ResolveActiveEmployeesAsync(
        CancellationToken cancellationToken = default);
}