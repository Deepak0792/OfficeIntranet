using SdxCore.Attendance.Application.DTOs.Employee;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IEmployeeScopeResolver
{
    Task<EmployeeScopeContext> ResolveAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default);
}