using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class RotationShiftDetailRepository(AttendanceDbContext dbContext)
    : BaseRepository<RotationShiftDetail, Guid, AttendanceDbContext>(dbContext), IRotationShiftDetailRepository
{
}
