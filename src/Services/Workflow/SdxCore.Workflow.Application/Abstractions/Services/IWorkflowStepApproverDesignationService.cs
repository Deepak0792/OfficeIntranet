using SdxCore.Workflow.Application.DTOs.StepApprover.Request;
using SdxCore.Workflow.Application.DTOs.StepApprover.Response;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IWorkflowStepApproverDesignationService
{
    Task<IEnumerable<WorkflowStepApproverDesignationResponse>> GetByApproverIdAsync(Guid approverId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverDesignationResponse> AddAsync(Guid approverId, AddApproverDesignationRequest request, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(Guid approverId, Guid designationId, CancellationToken cancellationToken = default);
}
