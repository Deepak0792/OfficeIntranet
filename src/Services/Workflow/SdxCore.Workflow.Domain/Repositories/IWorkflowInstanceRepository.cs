using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowInstanceRepository : IRepository<WorkflowInstance, int>
{
    Task<WorkflowInstance?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);
    Task<WorkflowInstance?> GetByTransactionAsync(string moduleCode, int referenceTransactionId, CancellationToken cancellationToken = default);
    Task<(IEnumerable<WorkflowInstance> Items, int TotalCount)> GetPagedAsync(
        int page, int pageSize,
        string? moduleCode = null,
        string? status = null,
        int? initiatedBy = null,
        DateTime? fromDate = null,
        DateTime? toDate = null,
        CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowInstance>> GetMySubmissionsAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<bool> CancelAsync(int id, int actionBy, CancellationToken cancellationToken = default);
    Task<bool> WithdrawAsync(int id, int actionBy, CancellationToken cancellationToken = default);
}
