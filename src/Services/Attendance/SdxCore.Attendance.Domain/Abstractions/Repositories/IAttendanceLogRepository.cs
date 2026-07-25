using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IAttendanceLogRepository : IRepository<AttendanceLog, Guid>
{
    Task<IReadOnlyList<AttendanceLog>> GetPendingLogsAsync(
        int batchSize,
        CancellationToken cancellationToken = default);
}
