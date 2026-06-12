using SdxCore.Workflow.Application.DTOs.Shared.Request;
using SdxCore.Workflow.Application.DTOs.StepApprover.Request;
using SdxCore.Workflow.Application.DTOs.StepApprover.Response;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IWorkflowStepApproverService
{
    Task<IEnumerable<WorkflowStepApproverResponse>> GetByStepIdAsync(Guid stepId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> GetByIdAsync(Guid stepId, Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<Guid>> GetDesignationIdsAsync(Guid approverId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> CreateAsync(Guid stepId, CreateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> UpdateAsync(Guid stepId, Guid id, UpdateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid stepId, Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
