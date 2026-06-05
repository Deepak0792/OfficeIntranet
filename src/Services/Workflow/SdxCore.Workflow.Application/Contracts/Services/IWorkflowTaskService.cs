using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowTaskService
{
    Task<WorkflowTaskResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<PagedResponse<IEnumerable<WorkflowTaskResponse>>> GetMyPendingAsync(int employeeId, string? moduleCode, PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> ApproveAsync(int id, int actionBy, ApproveTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> RejectAsync(int id, int actionBy, RejectTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> DelegateAsync(int id, int actionBy, DelegateTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> ReturnAsync(int id, int actionBy, ReturnTaskRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowTaskResponse> ReassignAsync(int id, int actionBy, ReassignTaskRequest request, CancellationToken cancellationToken = default);
}
