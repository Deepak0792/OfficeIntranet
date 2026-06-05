using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowStepApproverDesignationService
{
    Task<IEnumerable<WorkflowStepApproverDesignationResponse>> GetByApproverIdAsync(short approverId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApproverDesignationResponse> AddAsync(short approverId, AddApproverDesignationRequest request, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short approverId, short designationId, CancellationToken cancellationToken = default);
}
