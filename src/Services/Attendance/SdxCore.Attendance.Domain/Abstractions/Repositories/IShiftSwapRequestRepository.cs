using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IShiftSwapRequestRepository : IRepository<ShiftSwapRequest, Guid>
{
    Task<IEnumerable<ShiftSwapRequest>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<ShiftSwapRequest?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default);
}
