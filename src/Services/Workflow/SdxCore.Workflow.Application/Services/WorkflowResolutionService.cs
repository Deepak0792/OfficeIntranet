using SdxCore.Common.Helpers;
using SdxCore.Workflow.Application.Abstractions.Resolver;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Resolution.Request;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;
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
        return PropertyMapper.MapList<ResolvedApprover, PreviewApproversResponse>(resolved);
    }

    public async Task<ResolveDefinitionResponse> ResolveDefinitionAsync(
        string moduleCode, Guid employeeId, DateOnly? effectiveDate)
    {
        var date = effectiveDate ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var def = await assignmentRepo.ResolveDefinitionAsync(moduleCode, employeeId, date)
            ?? throw new WorkflowDefinitionNotFoundException(moduleCode);
        return PropertyMapper.Map<Domain.Entities.WorkflowDefinition, ResolveDefinitionResponse>(def);
    }
}