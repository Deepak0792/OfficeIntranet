using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Resolution.Request;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IWorkflowResolutionService
{
    Task<IEnumerable<PreviewApproversResponse>> PreviewApproversAsync(PreviewApproversRequest request);
    Task<WorkflowAssignmentSummary> ResolveWorkflowDefinitionAsync(string moduleCode, string workflowCode, Guid employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default);
    Task<WorkflowAssignmentSummary> ResolveWorkflowDefinitionAsync(string moduleCode, string workflowCode, Guid initiatorEmployeeId, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> ResolveDefinitionByEffectiveDateAsync(string moduleCode, string workflowCode, Guid employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default);
}
