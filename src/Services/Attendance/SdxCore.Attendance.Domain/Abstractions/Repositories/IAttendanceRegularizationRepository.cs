using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IAttendanceRegularizationRepository : IRepository<AttendanceRegularization, Guid>
{
    Task<AttendanceRegularization?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default);
    Task<(IEnumerable<AttendanceRegularization> Items, int TotalCount)> GetPagedAsync(int page, int pageSize, Guid? employeeId, CancellationToken cancellationToken = default);
    Task<AttendanceRegularization?> GetApprovedByEmployeeDateAsync(Guid employeeId, DateOnly attendanceDate, CancellationToken cancellationToken = default);
}
