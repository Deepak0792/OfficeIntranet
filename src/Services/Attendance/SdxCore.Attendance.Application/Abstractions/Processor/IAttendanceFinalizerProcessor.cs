namespace SdxCore.Attendance.Application.Abstractions.Processor;

public interface IAttendanceFinalizerProcessor
{
    Task FinalizeAsync(int batchSize, CancellationToken cancellationToken = default);
}
