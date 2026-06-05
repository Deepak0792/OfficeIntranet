using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowStepService
{
    Task<IEnumerable<WorkflowStepResponse>> GetByDefinitionIdAsync(short definitionId, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse> GetByIdAsync(short definitionId, short id, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse> CreateAsync(short definitionId, CreateWorkflowStepRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse> UpdateAsync(short definitionId, short id, UpdateWorkflowStepRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short definitionId, short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<bool> ReorderAsync(short definitionId, short id, ReorderWorkflowStepRequest request, CancellationToken cancellationToken = default);
}
