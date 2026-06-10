using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowStepApproverDesignationService
{
    Task<IEnumerable<WorkflowStepApproverDesignationResponse>> GetByApproverIdAsync(Guid approverId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverDesignationResponse> AddAsync(Guid approverId, AddApproverDesignationRequest request, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(Guid approverId, Guid designationId, CancellationToken cancellationToken = default);
}
