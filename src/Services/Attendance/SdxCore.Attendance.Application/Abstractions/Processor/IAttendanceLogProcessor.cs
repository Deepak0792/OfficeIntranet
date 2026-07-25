namespace SdxCore.Attendance.Application.Abstractions.Processor;
public interface IAttendanceLogProcessor
{
    Task ProcessPendingLogsAsync(int batchSize,
        CancellationToken cancellationToken = default);
}