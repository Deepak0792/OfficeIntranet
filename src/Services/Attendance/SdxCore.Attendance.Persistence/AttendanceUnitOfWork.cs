using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence;

namespace SdxCore.Attendance.Persistence;

public sealed class AttendanceUnitOfWork : UnitOfWork<AttendanceDbContext>, IAttendanceUnitOfWork
{
    public AttendanceUnitOfWork(AttendanceDbContext dbContext) : base(dbContext) { }
}
