using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowResolutionService
{
    Task<IEnumerable<PreviewApproversResponse>> PreviewApproversAsync(PreviewApproversRequest request);
    Task<ResolveDefinitionResponse> ResolveDefinitionAsync(string moduleCode, int employeeId, DateOnly? effectiveDate);
}
