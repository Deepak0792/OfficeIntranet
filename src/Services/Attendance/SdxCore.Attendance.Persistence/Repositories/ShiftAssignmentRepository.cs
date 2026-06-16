using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class ShiftAssignmentRepository(AttendanceDbContext dbContext)
    : BaseRepository<ShiftAssignment, Guid, AttendanceDbContext>(dbContext), IShiftAssignmentRepository
{
}
