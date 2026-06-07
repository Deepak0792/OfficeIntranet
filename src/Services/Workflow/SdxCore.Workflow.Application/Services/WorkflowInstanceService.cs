using SdxCore.Common.Models;
using SdxCore.Workflow.Application.Contracts.Engine;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowInstanceService(
    IWorkflowInstanceRepository instanceRepo,
    IWorkflowActionHistoryRepository historyRepo,
    IWorkflowTaskRepository taskRepo,
    IWorkflowEngine engine) : IWorkflowInstanceService
{
    public async Task<PagedResponse<IEnumerable<WorkflowInstanceResponse>>> GetPagedAsync(
        PaginationFilter filter,
        string? moduleCode, string? status,
        int? initiatedBy, DateTime? fromDate, DateTime? toDate, CancellationToken cancellationToken = default)
    {
        var (items, total) = await instanceRepo.GetPagedAsync(
           filter.PageNumber, filter.PageSize, moduleCode, status, initiatedBy, fromDate, toDate, cancellationToken);
        return new PagedResponse<IEnumerable<WorkflowInstanceResponse>>(
            items.Select(MapSummary), filter.PageNumber, filter.PageSize, total);
    }

    public async Task<WorkflowInstanceDetailResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var e = await instanceRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowInstance", id);

        var tasks = await taskRepo.GetByInstanceIdAsync(id, cancellationToken);
        var history = await historyRepo.GetByInstanceIdAsync(id, cancellationToken);

        return new WorkflowInstanceDetailResponse(
            e.Id,
            e.Definition?.WorkflowCode ?? string.Empty,
            e.Definition?.WorkflowName ?? string.Empty,
            e.Module?.ModuleCode ?? string.Empty,
            e.ReferenceTransactionId,
            e.CurrentWorkflowStepId,
            e.CurrentStep?.StepName,
            e.WorkflowStatus,
            e.CreatedBy, // enriched by persistence layer via join
            e.CreatedAt,
            e.CompletedAt,
            tasks.Select(MapTask),
            history.OrderBy(h => h.ActionAt).Select(MapHistory));
    }

    public async Task<IEnumerable<WorkflowActionHistoryResponse>> GetHistoryAsync(int instanceId, CancellationToken cancellationToken = default)
    {
        var history = await historyRepo.GetByInstanceIdAsync(instanceId, cancellationToken);
        return history.OrderBy(h => h.ActionAt).Select(MapHistory);
    }

    public async Task<IEnumerable<WorkflowTaskResponse>> GetTasksAsync(int instanceId, CancellationToken cancellationToken = default)
    {
        var tasks = await taskRepo.GetByInstanceIdAsync(instanceId, cancellationToken);
        return tasks.Select(MapTask);
    }

    public async Task<WorkflowInstanceResponse> GetByTransactionAsync(
        string moduleCode, int referenceTransactionId, CancellationToken cancellationToken = default)
    {
        var e = await instanceRepo.GetByTransactionAsync(moduleCode, referenceTransactionId, cancellationToken)
            ?? throw new WorkflowNotFoundException(
                "WorkflowInstance",
                $"module={moduleCode}&transactionId={referenceTransactionId}");
        return MapSummary(e);
    }

    public async Task<IEnumerable<WorkflowInstanceResponse>> GetMySubmissionsAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var items = await instanceRepo.GetMySubmissionsAsync(employeeId, cancellationToken);
        return items.Select(MapSummary);
    }

    public async Task<WorkflowInstanceResponse> CreateAsync(SubmitWorkflowInstanceRequest request, CancellationToken cancellationToken = default)
    {
        var instance = await engine.SubmitAsync(
            request.WorkflowModuleCode,
            request.ReferenceTransactionId,
            request.InitiatedByEmployeeId, cancellationToken);
        return MapSummary(instance);
    }

    public async Task<bool> CancelAsync(int id, int actionBy, CancellationToken cancellationToken = default)
    {
        await engine.CancelAsync(id, actionBy, cancellationToken);
        return true;
    }

    public async Task<bool> WithdrawAsync(int id, int actionBy, CancellationToken cancellationToken = default)
    {
        await engine.WithdrawAsync(id, actionBy, cancellationToken);
        return true;
    }

    // ── Mappers ──────────────────────────────────────────────
    private static WorkflowInstanceResponse MapSummary(Domain.Entities.WorkflowInstance e) =>
        new(e.Id,
            e.WorkflowDefinitionId,
            e.Definition?.WorkflowCode ?? string.Empty,
            e.Definition?.WorkflowName ?? string.Empty,
            e.WorkflowModuleId,
            e.Module?.ModuleCode ?? string.Empty,
            e.ReferenceTransactionId,
            e.CurrentWorkflowStepId,
            e.CurrentStep?.StepName,
            e.CurrentStep?.StepNo,
            e.WorkflowStatus,
            e.CreatedBy,
            e.CreatedAt,
            e.CompletedAt);

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
            t.Instance?.ReferenceTransactionId ?? 0,
            t.Instance?.WorkflowStatus ?? string.Empty);

    private static WorkflowActionHistoryResponse MapHistory(Domain.Entities.WorkflowActionHistory h) =>
        new(h.Id, h.WorkflowInstanceId, h.WorkflowTaskId,
            h.WorkflowStepId, h.Step?.StepName,
            h.WorkflowActionType, h.Remarks,
            h.FromWorkflowStatus, h.ToWorkflowStatus,
            h.ActionBy, string.Empty, h.ActionAt);
}
