using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class CompOffTypeRepository(AttendanceDbContext dbContext)
    : BaseRepository<CompOffType, Guid, AttendanceDbContext>(dbContext), ICompOffTypeRepository
{
}
