using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowStepApproverService
{
    Task<IEnumerable<WorkflowStepApproverResponse>> GetByStepIdAsync(Guid stepId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> GetByIdAsync(Guid stepId, Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<Guid>> GetDesignationIdsAsync(Guid approverId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> CreateAsync(Guid stepId, CreateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> UpdateAsync(Guid stepId, Guid id, UpdateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid stepId, Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
