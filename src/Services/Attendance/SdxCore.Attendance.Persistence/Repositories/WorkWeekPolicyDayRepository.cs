using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class WorkWeekPolicyDayRepository(AttendanceDbContext dbContext)
    : BaseRepository<WorkWeekPolicyDay, Guid, AttendanceDbContext>(dbContext), IWorkWeekPolicyDayRepository
{
}
