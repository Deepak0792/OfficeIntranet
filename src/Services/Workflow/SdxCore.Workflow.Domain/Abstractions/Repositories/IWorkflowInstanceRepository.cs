using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowInstanceRepository : IRepository<WorkflowInstance, Guid>
{
    Task<WorkflowInstance?> GetByIdWithDetailsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<WorkflowInstance?> GetByTransactionAsync(string moduleCode, Guid referenceTransactionId, CancellationToken cancellationToken = default);
    Task<(IEnumerable<WorkflowInstance> Items, int TotalCount)> GetPagedAsync(
        int page, int pageSize,
        string? moduleCode = null,
        string? status = null,
        Guid? initiatedBy = null,
        DateTime? fromDate = null,
        DateTime? toDate = null,
        CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowInstance>> GetMySubmissionsAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<bool> CancelAsync(Guid id, Guid actionBy, CancellationToken cancellationToken = default);
    Task<bool> WithdrawAsync(Guid id, Guid actionBy, CancellationToken cancellationToken = default);
}
