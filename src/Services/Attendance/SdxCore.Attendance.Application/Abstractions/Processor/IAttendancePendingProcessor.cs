namespace SdxCore.Attendance.Application.Abstractions.Processor;

public interface IAttendancePendingProcessor
{
    Task ProcessAsync(int batchSize, CancellationToken cancellationToken = default);
}