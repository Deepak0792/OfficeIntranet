using SdxCore.Workflow.Application.Abstractions.Resolver;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Resolution.Request;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;
using SdxCore.Workflow.Domain;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Exceptions;

namespace SdxCore.Workflow.Application.Services;
public class WorkflowResolutionService(
    IWorkflowAssignmentRepository assignmentRepo,
    IWorkflowApproverResolver resolver) : IWorkflowResolutionService
{
    public async Task<IEnumerable<PreviewApproversResponse>> PreviewApproversAsync(
        PreviewApproversRequest request)
    {
        var resolved = await resolver.ResolveApproverAsync(request.WorkflowStepId, request.InitiatorEmployeeId);
        return resolved.Select(r => new PreviewApproversResponse(
            r.WorkflowStepApproverId, r.ApproverType,
            r.ResolvedEmployeeId, r.ResolvedEmployeeName,
            r.ResolvedDesignationId, r.ResolvedDepartmentId));
    }

    public async Task<ResolveDefinitionResponse> ResolveDefinitionAsync(
        string moduleCode, Guid employeeId, DateOnly? effectiveDate)
    {
        var date = effectiveDate ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var def = await assignmentRepo.ResolveDefinitionAsync(moduleCode, employeeId, date)
            ?? throw new WorkflowDefinitionNotFoundException(moduleCode);
        return new ResolveDefinitionResponse(def.Id, def.WorkflowCode, def.WorkflowName, def.VersionNo);
    }
}