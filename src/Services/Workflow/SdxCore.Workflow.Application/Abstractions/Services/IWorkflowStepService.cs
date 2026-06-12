using SdxCore.Workflow.Application.DTOs.Shared.Request;
using SdxCore.Workflow.Application.DTOs.Step.Request;
using SdxCore.Workflow.Application.DTOs.Step.Response;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IWorkflowStepService
{
    Task<IEnumerable<WorkflowStepResponse>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse> GetByIdAsync(Guid definitionId, Guid id, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse?> GetNextStepAsync(Guid definitionId, short currentStepNo, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse> CreateAsync(Guid definitionId, CreateWorkflowStepRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowStepResponse> UpdateAsync(Guid definitionId, Guid id, UpdateWorkflowStepRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid definitionId, Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<bool> ReorderAsync(Guid definitionId, Guid id, ReorderWorkflowStepRequest request, CancellationToken cancellationToken = default);
}
