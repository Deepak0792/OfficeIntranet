using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowInstanceService
{
    Task<PagedResponse<IEnumerable<WorkflowInstanceResponse>>> GetPagedAsync(
       PaginationFilter filter,
        string? moduleCode, string? status,
        int? initiatedBy, DateTime? fromDate, DateTime? toDate, CancellationToken cancellationToken = default);
    Task<WorkflowInstanceDetailResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowActionHistoryResponse>> GetHistoryAsync(int instanceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowTaskResponse>> GetTasksAsync(int instanceId, CancellationToken cancellationToken = default);
    Task<WorkflowInstanceResponse> GetByTransactionAsync(string moduleCode, int referenceTransactionId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowInstanceResponse>> GetMySubmissionsAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<WorkflowInstanceResponse> SubmitAsync(SubmitWorkflowInstanceRequest request, CancellationToken cancellationToken = default);
    Task<bool> CancelAsync(int id, int actionBy, CancellationToken cancellationToken = default);
    Task<bool> WithdrawAsync(int id, int actionBy, CancellationToken cancellationToken = default);
}
