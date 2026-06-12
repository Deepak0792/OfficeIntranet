using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Resolution.Request;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IWorkflowResolutionService
{
    Task<IEnumerable<PreviewApproversResponse>> PreviewApproversAsync(PreviewApproversRequest request);
    Task<ResolveDefinitionResponse> ResolveDefinitionAsync(string moduleCode, Guid employeeId, DateOnly? effectiveDate);
}
