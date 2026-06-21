using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface ILeaveRequestRepository : IRepository<LeaveRequest, Guid>
{
    Task<LeaveRequest?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<LeaveRequest>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<LeaveRequest?> GetApprovedLeaveForDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default);
    Task<IReadOnlyCollection<LeaveRequest>> GetApprovedLeaveForDateAsync(Guid employeeId, DateOnly fromDate, DateOnly toDate, CancellationToken cancellationToken = default);
    Task<(IEnumerable<LeaveRequest> Items, int TotalCount)> GetPagedAsync(int page, int pageSize, Guid? employeeId, string? status, CancellationToken cancellationToken = default);
}
