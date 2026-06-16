using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface ICompOffBalanceRepository : IRepository<CompOffBalance, Guid>
{
    Task<IEnumerable<CompOffBalance>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<CompOffBalance?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default);
}
