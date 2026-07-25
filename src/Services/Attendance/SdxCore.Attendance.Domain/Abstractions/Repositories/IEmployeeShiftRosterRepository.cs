using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IEmployeeShiftRosterRepository : IRepository<EmployeeShiftRoster, Guid>
{
    Task<EmployeeShiftRoster?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeShiftRoster>> GetByDateAsync(DateOnly date, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeShiftRoster>> GetByEmployeeRangeAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<EmployeeShiftRoster>> GetPendingAttendanceCalculationAsync(DateTime dueAt, int batchSize, CancellationToken cancellationToken = default);
}
