using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Quartz;

namespace SdxCore.Attendance.Processor.Jobs;

public class AttendanceFinalizerJob : IJob
{
    private readonly ILogger<AttendanceFinalizerJob> _logger;

    public AttendanceFinalizerJob(ILogger<AttendanceFinalizerJob> logger)
    {
        _logger = logger;
    }

    public Task Execute(IJobExecutionContext context)
    {
        _logger.LogInformation("Running AttendanceFinalizerJob at {Time}", DateTimeOffset.Now);
        // Logic to finalize attendance and calculate late/early/overtime
        return Task.CompletedTask;
    }
}
