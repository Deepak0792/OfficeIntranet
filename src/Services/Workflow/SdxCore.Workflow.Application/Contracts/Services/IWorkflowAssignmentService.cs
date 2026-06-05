using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowAssignmentService
{
    Task<IEnumerable<WorkflowAssignmentResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<WorkflowAssignmentResponse> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowAssignmentResponse>> GetByDefinitionIdAsync(short definitionId, CancellationToken cancellationToken = default);
    Task<ResolveDefinitionResponse> ResolveAsync(string moduleCode, int employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default);
    Task<WorkflowAssignmentResponse> CreateAsync(CreateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowAssignmentResponse> UpdateAsync(short id, UpdateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
