namespace SdxCore.Attendance.Application.Abstractions.Processor;

public interface IRosterGenerationProcessor
{
    Task ExecuteAsync(
        CancellationToken cancellationToken = default);
}