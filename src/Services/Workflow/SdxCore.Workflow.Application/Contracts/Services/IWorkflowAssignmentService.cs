using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowAssignmentService
{
    Task<IEnumerable<WorkflowAssignmentResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<WorkflowAssignmentResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowAssignmentResponse>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default);
    Task<ResolveDefinitionResponse> ResolveAsync(string moduleCode, Guid employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default);
    Task<WorkflowAssignmentResponse> CreateAsync(CreateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowAssignmentResponse> UpdateAsync(Guid id, UpdateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
