using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowStepApproverService
{
    Task<IEnumerable<WorkflowStepApproverResponse>> GetByStepIdAsync(short stepId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> GetByIdAsync(short stepId, short id, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> CreateAsync(short stepId, CreateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverResponse> UpdateAsync(short stepId, short id, UpdateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short stepId, short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
