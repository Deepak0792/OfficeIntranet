using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;
public class WorkflowResolutionService(
    IWorkflowAssignmentRepository assignmentRepo,
    IWorkflowApproverResolver resolver) : IWorkflowResolutionService
{
    public async Task<IEnumerable<PreviewApproversResponse>> PreviewApproversAsync(
        PreviewApproversRequest request)
    {
        var resolved = await resolver.ResolveAsync(request.WorkflowStepId, request.InitiatorEmployeeId);
        return resolved.Select(r => new PreviewApproversResponse(
            r.WorkflowStepApproverId, r.ApproverType,
            r.ResolvedEmployeeId, r.ResolvedEmployeeName,
            r.ResolvedDesignation, r.ResolvedDepartment));
    }

    public async Task<ResolveDefinitionResponse> ResolveDefinitionAsync(
        string moduleCode, int employeeId, DateOnly? effectiveDate)
    {
        var date = effectiveDate ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var def = await assignmentRepo.ResolveDefinitionAsync(moduleCode, employeeId, date)
            ?? throw new WorkflowDefinitionNotFoundException(moduleCode);
        return new ResolveDefinitionResponse(def.Id, def.WorkflowCode, def.WorkflowName, def.VersionNo);
    }
}
