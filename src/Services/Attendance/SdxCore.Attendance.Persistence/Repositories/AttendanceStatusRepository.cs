using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class AttendanceStatusRepository(AttendanceDbContext dbContext)
    : BaseRepository<AttendanceStatus, Guid, AttendanceDbContext>(dbContext), IAttendanceStatusRepository
{
    public async Task<Guid?> GetIdByCodeAsync(string statusCode, CancellationToken cancellationToken = default)
    {
        var status = await _dbSet.FirstOrDefaultAsync(s => s.StatusCode == statusCode, cancellationToken);
        return status?.Id;
    }
}
