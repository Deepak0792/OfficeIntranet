using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IAttendanceStatusRepository : IRepository<AttendanceStatus, Guid>
{
    Task<Guid?> GetIdByCodeAsync(string statusCode, CancellationToken cancellationToken = default);
}
