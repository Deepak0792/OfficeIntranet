using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class RotationShiftDetailRepository(AttendanceDbContext dbContext)
    : BaseRepository<RotationShiftDetail, Guid, AttendanceDbContext>(dbContext), IRotationShiftDetailRepository
{
    public async Task<IReadOnlyList<RotationShiftDetail>>
        GetByRotationShiftIdAsync(
            Guid rotationShiftId,
            CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .AsNoTracking()
            .Where(x =>
                x.RotationShiftId == rotationShiftId &&
                x.IsActive)
            .OrderBy(x => x.SequenceNo)
            .ToListAsync(cancellationToken);
    }
}
