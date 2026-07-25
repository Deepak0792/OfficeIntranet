namespace SdxCore.Attendance.Application.Configuration;

public sealed class AttendanceProcessorOptions
{
    public bool Enabled { get; set; } = true;

    /// <summary>
    /// Null means batching is not applicable for this processor.
    /// </summary>
    public int? BatchSize { get; set; } = 500;

    public int PollingIntervalSeconds { get; set; }

    /// <summary>
    /// Null means retry is not applicable for this processor.
    /// </summary>
    public int? MaxRetryCount { get; set; } = 3;

    public void Validate(string processorName)
    {
        if (BatchSize.HasValue && BatchSize.Value <= 0)
        {
            throw new InvalidOperationException(
                $"{processorName}: BatchSize must be greater than zero.");
        }

        if (PollingIntervalSeconds <= 0)
        {
            throw new InvalidOperationException(
                $"{processorName}: PollingIntervalSeconds must be greater than zero.");
        }

        if (MaxRetryCount.HasValue && MaxRetryCount.Value < 0)
        {
            throw new InvalidOperationException(
                $"{processorName}: MaxRetryCount cannot be negative.");
        }
    }
}