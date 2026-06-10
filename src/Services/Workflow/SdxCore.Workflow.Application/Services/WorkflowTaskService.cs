using SdxCore.Common.Models;
using SdxCore.Workflow.Application.Contracts.Engine;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowTaskService(
    IWorkflowTaskRepository taskRepo,
    IWorkflowEngine engine) : IWorkflowTaskService
{
    public async Task<WorkflowTaskResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var t = await taskRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return MapTask(t);
    }

    public async Task<PagedResponse<IEnumerable<WorkflowTaskResponse>>> GetMyPendingAsync(
        Guid employeeId, string? moduleCode, PaginationFilter filter, CancellationToken cancellationToken = default)
    {
        var (items, total) = await taskRepo.GetMyPendingPagedAsync(employeeId, moduleCode, filter.PageNumber, filter.PageSize, cancellationToken);
        return new PagedResponse<IEnumerable<WorkflowTaskResponse>>(items.Select(MapTask), filter.PageNumber, filter.PageSize, total);
    }

    public async Task<WorkflowTaskResponse> ApproveAsync(Guid id, Guid actionBy, ApproveTaskRequest request, CancellationToken cancellationToken = default)
    {
        await engine.ProcessApproveAsync(id, actionBy, request.Remarks, cancellationToken);
        var t = await taskRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return MapTask(t);
    }

    public async Task<WorkflowTaskResponse> RejectAsync(Guid id, Guid actionBy, RejectTaskRequest request, CancellationToken cancellationToken = default)
    {
        await engine.ProcessRejectAsync(id, actionBy, request.Remarks, cancellationToken);
        var t = await taskRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return MapTask(t);
    }

    public async Task<WorkflowTaskResponse> DelegateAsync(Guid id, Guid actionBy, DelegateTaskRequest request, CancellationToken cancellationToken = default)
    {
        await engine.ProcessDelegateAsync(id, request.DelegateToEmployeeId, actionBy, request.Remarks, cancellationToken);
        var t = await taskRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return MapTask(t);
    }

    public async Task<WorkflowTaskResponse> ReturnAsync(Guid id, Guid actionBy, ReturnTaskRequest request, CancellationToken cancellationToken = default)
    {
        await engine.ProcessReturnAsync(id, actionBy, request.Remarks, cancellationToken);
        var t = await taskRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return MapTask(t);
    }

    public async Task<WorkflowTaskResponse> ReassignAsync(Guid id, Guid actionBy, ReassignTaskRequest request, CancellationToken cancellationToken = default)
    {
        await engine.ProcessReassignAsync(id, request.ReassignToEmployeeId, actionBy, request.Remarks, cancellationToken);
        var t = await taskRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return MapTask(t);
    }

    private static WorkflowTaskResponse MapTask(Domain.Entities.WorkflowTask t) =>
        new(t.Id, t.WorkflowInstanceId,
            t.WorkflowStepId,
            t.Step?.StepName ?? string.Empty,
            t.Step?.StepNo ?? 0,
            t.WorkflowStepApproverId,
            t.AssignedToEmployeeId, string.Empty,
            t.DelegatedFromEmployeeId, null,
            t.TaskStatus, t.Remarks,
            t.ParentWorkflowTaskId,
            t.AssignedAt, t.DueAt, t.ActionAt,
            t.Instance?.Module?.ModuleCode ?? string.Empty,
            t.Instance?.ReferenceTransactionId ?? Guid.Empty,
            t.Instance?.WorkflowStatus ?? string.Empty);
}
