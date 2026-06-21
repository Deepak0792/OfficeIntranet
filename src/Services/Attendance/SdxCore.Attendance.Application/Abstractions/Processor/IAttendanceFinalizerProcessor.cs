namespace SdxCore.Attendance.Application.Abstractions.Processor;

public interface IAttendanceFinalizerProcessor
{
    Task FinalizeAsync(CancellationToken cancellationToken = default);
}
