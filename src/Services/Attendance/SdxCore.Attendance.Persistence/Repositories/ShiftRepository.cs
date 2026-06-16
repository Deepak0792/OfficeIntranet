using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class ShiftRepository(AttendanceDbContext dbContext)
    : BaseRepository<Shift, Guid, AttendanceDbContext>(dbContext), IShiftRepository
{
}
