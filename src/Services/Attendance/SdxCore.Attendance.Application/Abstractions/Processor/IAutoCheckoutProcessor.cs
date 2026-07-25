namespace SdxCore.Attendance.Application.Abstractions.Processor;

public interface IAutoCheckoutProcessor
{
    Task ProcessAsync(int batchSize, CancellationToken cancellationToken = default);
}