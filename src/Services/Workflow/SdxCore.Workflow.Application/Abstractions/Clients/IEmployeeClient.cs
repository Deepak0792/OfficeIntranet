using SdxCore.Workflow.Application.DTOs.Employee;

namespace SdxCore.Workflow.Application.Abstractions.Clients;
public interface IEmployeeClient
{
    Task<EmployeeSummaryResponse?> GetEmployeeeSummaryAsync(Guid id, CancellationToken cancellationToken = default!);

    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(IEnumerable<Guid> designationIds, string? scopeCode,
    Guid? scopeReferenceId, CancellationToken cancellationToken);
}