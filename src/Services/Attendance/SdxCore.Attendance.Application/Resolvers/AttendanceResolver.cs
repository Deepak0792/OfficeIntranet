using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class AttendanceResolver(
    IAttendanceRecordRepository repository)
    : IAttendanceResolver
{
    public async Task<AttendanceRecord> GetAttendanceAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default)
    {
        var attendance =
            await repository.GetByEmployeeDateAsync(
                employeeId,
                attendanceDate,
                cancellationToken);

        if (attendance is null)
            throw new KeyNotFoundException(
                "Attendance record not found.");

        return attendance;
    }
}