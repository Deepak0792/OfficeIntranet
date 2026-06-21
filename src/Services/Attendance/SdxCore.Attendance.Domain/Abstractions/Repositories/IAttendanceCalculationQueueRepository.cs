using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IAttendanceCalculationQueueRepository : IRepository<AttendanceCalculationQueue, Guid>
{
    Task<AttendanceCalculationQueue?> GetAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);

    Task<List<AttendanceCalculationQueue>> GetPendingAsync(
        int batchSize,
        CancellationToken cancellationToken = default);
}