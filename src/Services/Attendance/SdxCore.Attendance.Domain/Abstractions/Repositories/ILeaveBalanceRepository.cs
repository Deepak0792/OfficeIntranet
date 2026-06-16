using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface ILeaveBalanceRepository : IRepository<LeaveBalance, Guid>
{
    Task<IEnumerable<LeaveBalance>> GetByEmployeeAsync(Guid employeeId, int year, CancellationToken cancellationToken = default);
    Task<LeaveBalance?> GetByEmployeeAndTypeAsync(Guid employeeId, Guid leaveTypeId, int year, CancellationToken cancellationToken = default);
}
