using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IWorkWeekPolicyDayRepository : IRepository<WorkWeekPolicyDay, Guid>
{
}
