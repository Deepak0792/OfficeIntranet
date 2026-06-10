using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowInstanceService
{
    Task<PagedResponse<IEnumerable<WorkflowInstanceResponse>>> GetPagedAsync(
       PaginationFilter filter,
        string? moduleCode, string? status,
        Guid? initiatedBy, DateTime? fromDate, DateTime? toDate, CancellationToken cancellationToken = default);
    Task<WorkflowInstanceDetailResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowActionHistoryResponse>> GetHistoryAsync(Guid instanceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowTaskResponse>> GetTasksAsync(Guid instanceId, CancellationToken cancellationToken = default);
    Task<WorkflowInstanceResponse> GetByTransactionAsync(string moduleCode, Guid referenceTransactionId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowInstanceResponse>> GetMySubmissionsAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<WorkflowInstanceResponse> CreateAsync(SubmitWorkflowInstanceRequest request, CancellationToken cancellationToken = default);
    Task<bool> CancelAsync(Guid id, Guid actionBy, string? remarks, CancellationToken cancellationToken = default);
    Task<bool> WithdrawAsync(Guid id, Guid actionBy, string? remarks, CancellationToken cancellationToken = default);
}
