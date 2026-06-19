namespace SdxCore.Attendance.Application.Abstractions.Scheduler;

public interface IRosterGenerationScheduler
{
    Task ExecuteAsync(
        CancellationToken cancellationToken = default);
}