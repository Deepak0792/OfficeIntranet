using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowTaskService
{
    Task<WorkflowTaskResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<PagedResponse<IEnumerable<WorkflowTaskResponse>>> GetMyPendingAsync(Guid employeeId, string? moduleCode, PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> ApproveAsync(Guid id, Guid actionBy, ApproveTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> RejectAsync(Guid id, Guid actionBy, RejectTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> DelegateAsync(Guid id, Guid actionBy, DelegateTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> ReturnAsync(Guid id, Guid actionBy, ReturnTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> ReassignAsync(Guid id, Guid actionBy, ReassignTaskRequest request, CancellationToken cancellationToken = default);
}
