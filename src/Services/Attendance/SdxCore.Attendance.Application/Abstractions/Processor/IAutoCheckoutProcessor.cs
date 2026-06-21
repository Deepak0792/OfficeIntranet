namespace SdxCore.Attendance.Application.Abstractions.Processor;

public interface IAutoCheckoutProcessor
{
    Task ProcessAsync(CancellationToken cancellationToken = default);
}