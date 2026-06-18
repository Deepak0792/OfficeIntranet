using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Employee;

namespace SdxCore.Attendance.Application.Resolvers;

public class EmployeeScopeResolver(
    IEmployeeClient employeeClient)
    : IEmployeeScopeResolver
{
    public async Task<EmployeeScopeContext> ResolveAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        var employee =
            await employeeClient.GetEmployeeSummaryByIdAsync(
                employeeId,
                cancellationToken)
            ?? throw new InvalidOperationException(
                $"Employee '{employeeId}' not found.");

        return new EmployeeScopeContext
        {
            EmployeeId = employee.EmployeeId,
            TeamId = employee.PrimaryTeamId,
            DepartmentId = employee.PrimaryDepartmentId,
            OfficeLocationId = employee.PrimaryLocationId,
            LegalEntityId = employee.PrimaryLegalEntityId,
            CountryId = employee.PrimaryCountryId,
            ManagerId = employee.DirectManagerId
        };
    }
}