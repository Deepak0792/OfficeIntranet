using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class RotationShiftRepository(AttendanceDbContext dbContext)
    : BaseRepository<RotationShift, Guid, AttendanceDbContext>(dbContext), IRotationShiftRepository
{
    public async Task<RotationShift?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(r => r.Details.Where(d => d.IsActive).OrderBy(d => d.SequenceNo))
                .ThenInclude(d => d.Shift)
            .FirstOrDefaultAsync(r => r.Id == id, cancellationToken);
}
