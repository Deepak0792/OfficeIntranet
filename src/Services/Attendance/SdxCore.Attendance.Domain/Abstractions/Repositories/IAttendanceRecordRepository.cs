using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IAttendanceRecordRepository : IRepository<AttendanceRecord, Guid>
{
    Task<AttendanceRecord?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default);
    Task<(IEnumerable<AttendanceRecord> Items, int TotalCount)> GetPagedAsync(int page, int pageSize, Guid? employeeId, DateOnly? from, DateOnly? to, CancellationToken cancellationToken = default);
    Task UpsertAsync(AttendanceRecord record, CancellationToken cancellationToken = default);
}
