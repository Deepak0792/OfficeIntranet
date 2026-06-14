using SdxCore.Common.Helpers;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.Abstractions.Engine;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.ActionHistory.Response;
using SdxCore.Workflow.Application.DTOs.Instance.Request;
using SdxCore.Workflow.Application.DTOs.Instance.Response;
using SdxCore.Workflow.Application.DTOs.Task.Response;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;

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
        Guid? initiatedBy, DateTime? fromDate, DateTime? toDate, CancellationToken cancellationToken = default)
    {
        var (items, total) = await instanceRepo.GetPagedAsync(
           filter.PageNumber, filter.PageSize, moduleCode, status, initiatedBy, fromDate, toDate, cancellationToken);
        return new PagedResponse<IEnumerable<WorkflowInstanceResponse>>(
            PropertyMapper.MapList<WorkflowInstance, WorkflowInstanceResponse>(items), filter.PageNumber, filter.PageSize, total);
    }

    public async Task<WorkflowInstanceDetailResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var e = await instanceRepo.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowInstance", id);

        var tasks = await taskRepo.GetByInstanceIdAsync(id, cancellationToken);
        var history = await historyRepo.GetByInstanceIdAsync(id, cancellationToken);

        return new WorkflowInstanceDetailResponse
        {
            Id = e.Id,
            WorkflowCode = e.Definition?.WorkflowCode ?? string.Empty,
            WorkflowName = e.Definition?.WorkflowName ?? string.Empty,
            ModuleCode = e.Module?.ModuleCode ?? string.Empty,
            ReferenceTransactionId = e.ReferenceTransactionId,
            CurrentWorkflowStepId = e.CurrentWorkflowStepId,
            CurrentStepName = e.CurrentStep?.StepName,
            WorkflowStatus = e.WorkflowStatus,
            CreatedBy = e.CreatedBy,
            CreatedAt = e.CreatedAt,
            CompletedAt = e.CompletedAt,
            Tasks = PropertyMapper.MapList<WorkflowTask, WorkflowTaskResponse>(tasks),
            History = PropertyMapper.MapList<WorkflowActionHistory, WorkflowActionHistoryResponse>(history.OrderBy(h => h.ActionAt))
        };
    }

    public async Task<IEnumerable<WorkflowActionHistoryResponse>> GetHistoryAsync(Guid instanceId, CancellationToken cancellationToken = default)
    {
        var history = await historyRepo.GetByInstanceIdAsync(instanceId, cancellationToken);
        return PropertyMapper.MapList<WorkflowActionHistory, WorkflowActionHistoryResponse>(history.OrderBy(h => h.ActionAt));
    }

    public async Task<IEnumerable<WorkflowTaskResponse>> GetTasksAsync(Guid instanceId, CancellationToken cancellationToken = default)
    {
        var tasks = await taskRepo.GetByInstanceIdAsync(instanceId, cancellationToken);
        return tasks.Select(PropertyMapper.Map<WorkflowTask, WorkflowTaskResponse>);
    }

    public async Task<WorkflowInstanceResponse> GetByTransactionAsync(
        string moduleCode, Guid referenceTransactionId, CancellationToken cancellationToken = default)
    {
        var e = await instanceRepo.GetByTransactionAsync(moduleCode, referenceTransactionId, cancellationToken)
            ?? throw new WorkflowNotFoundException(
                "WorkflowInstance",
                $"module={moduleCode}&transactionId={referenceTransactionId}");

        return PropertyMapper.Map<WorkflowInstance, WorkflowInstanceResponse>(e);
    }

    public async Task<IEnumerable<WorkflowInstanceResponse>> GetMySubmissionsAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var items = await instanceRepo.GetMySubmissionsAsync(employeeId, cancellationToken);
        return items.Select(PropertyMapper.Map<WorkflowInstance, WorkflowInstanceResponse>);
    }

    public async Task<WorkflowInstanceResponse> CreateAsync(SubmitWorkflowInstanceRequest request, CancellationToken cancellationToken = default)
    {
        var instance = await engine.SubmitAsync(
            request.ModuleCode,
            request.WorkflowCode,
            request.ReferenceTransactionId,
            request.InitiatedByEmployeeId, cancellationToken);
        return PropertyMapper.Map<WorkflowInstance, WorkflowInstanceResponse>(instance);
    }

    public async Task<bool> CancelAsync(Guid id, Guid actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        await engine.CancelAsync(id, actionBy, remarks, cancellationToken);
        return true;
    }

    public async Task<bool> WithdrawAsync(Guid id, Guid actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        await engine.WithdrawAsync(id, actionBy, remarks, cancellationToken);
        return true;
    }
}
