using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Processor;

public interface ICheckInProcessor
{
    Task ProcessAsync(
        AttendanceLog attendanceLog,
        CancellationToken cancellationToken = default);
}