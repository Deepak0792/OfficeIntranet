using SdxCore.Common.Helpers;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.Abstractions.Engine;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Task.Request;
using SdxCore.Workflow.Application.DTOs.Task.Response;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowTaskService(
    IWorkflowTaskRepository _repository,
    IWorkflowEngine _engine) : IWorkflowTaskService
{
    public async Task<WorkflowTaskResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var t = await _repository.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return PropertyMapper.Map<WorkflowTask, WorkflowTaskResponse>(t);
    }

    public async Task<PagedResponse<IEnumerable<WorkflowTaskResponse>>> GetMyPendingAsync(
        Guid employeeId, string? moduleCode, PaginationFilter filter, CancellationToken cancellationToken = default)
    {
        var (items, total) = await _repository.GetMyPendingPagedAsync(employeeId, moduleCode, filter.PageNumber, filter.PageSize, cancellationToken);
        return new PagedResponse<IEnumerable<WorkflowTaskResponse>>(PropertyMapper.MapList<WorkflowTask, WorkflowTaskResponse>(items), filter.PageNumber, filter.PageSize, total);
    }

    public async Task<WorkflowTaskResponse> ApproveAsync(Guid id, Guid actionBy, ApproveTaskRequest request, CancellationToken cancellationToken = default)
    {
        await _engine.ProcessApproveAsync(id, actionBy, request.Remarks, cancellationToken);
        var t = await _repository.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return PropertyMapper.Map<WorkflowTask, WorkflowTaskResponse>(t);
    }

    public async Task<WorkflowTaskResponse> RejectAsync(Guid id, Guid actionBy, RejectTaskRequest request, CancellationToken cancellationToken = default)
    {
        await _engine.ProcessRejectAsync(id, actionBy, request.Remarks, cancellationToken);
        var t = await _repository.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return PropertyMapper.Map<WorkflowTask, WorkflowTaskResponse>(t);
    }

    public async Task<WorkflowTaskResponse> DelegateAsync(Guid id, Guid actionBy, DelegateTaskRequest request, CancellationToken cancellationToken = default)
    {
        await _engine.ProcessDelegateAsync(id, request.DelegateToEmployeeId, actionBy, request.Remarks, cancellationToken);
        var t = await _repository.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return PropertyMapper.Map<WorkflowTask, WorkflowTaskResponse>(t);
    }

    public async Task<WorkflowTaskResponse> ReturnAsync(Guid id, Guid actionBy, ReturnTaskRequest request, CancellationToken cancellationToken = default)
    {
        await _engine.ProcessReturnAsync(id, actionBy, request.Remarks, cancellationToken);
        var t = await _repository.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return PropertyMapper.Map<WorkflowTask, WorkflowTaskResponse>(t);
    }

    public async Task<WorkflowTaskResponse> ReassignAsync(Guid id, Guid actionBy, ReassignTaskRequest request, CancellationToken cancellationToken = default)
    {
        await _engine.ProcessReassignAsync(id, request.ReassignToEmployeeId, actionBy, request.Remarks, cancellationToken);
        var t = await _repository.GetByIdWithDetailsAsync(id, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(id);
        return PropertyMapper.Map<WorkflowTask, WorkflowTaskResponse>(t);
    }
}
