namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IAttendanceCalculator
{
    Task CalculateAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);
}