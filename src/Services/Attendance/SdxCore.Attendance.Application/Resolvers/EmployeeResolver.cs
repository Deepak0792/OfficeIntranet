using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Employee;
using SdxCore.Attendance.Application.Exceptions;

namespace SdxCore.Attendance.Application.Resolvers;

public class EmployeeResolver(
    IEmployeeClient employeeClient)
    : IEmployeeResolver
{
    public async Task<EmployeeSummaryResponse>
        ResolveActiveEmployeeAsync(
            Guid employeeId,
            CancellationToken cancellationToken = default)
    {
        var employee =
            await employeeClient.GetEmployeeSummaryByIdAsync(
                employeeId,
                cancellationToken);

        if (employee is null)
            throw ResolverException.NotFound(
                "Employee",
                employeeId);

        if (!employee.IsActive)
            throw ResolverException.Inactive(
                "Employee",
                employeeId);

        return employee;
    }

    public async Task<IReadOnlyList<EmployeeSummaryResponse>>
        ResolveActiveEmployeesAsync(
            CancellationToken cancellationToken = default)
    {
        return await employeeClient.GetEmployeesAsync(
            true,
            cancellationToken);
    }
}