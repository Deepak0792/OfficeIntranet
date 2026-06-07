using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Clients;
public interface IEmployeeClient
{
    Task<EmployeeSummaryResponse?> GetEmployeeeSummaryAsync(int id, CancellationToken cancellationToken = default!);

    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(IEnumerable<short> designationIds, short? scopeTypeId,
    int? scopeReferenceId, CancellationToken cancellationToken);
}