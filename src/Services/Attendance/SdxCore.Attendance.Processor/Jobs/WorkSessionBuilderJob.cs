using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Quartz;

namespace SdxCore.Attendance.Processor.Jobs;

public class WorkSessionBuilderJob : IJob
{
    private readonly ILogger<WorkSessionBuilderJob> _logger;

    public WorkSessionBuilderJob(ILogger<WorkSessionBuilderJob> logger)
    {
        _logger = logger;
    }

    public Task Execute(IJobExecutionContext context)
    {
        _logger.LogInformation("Running WorkSessionBuilderJob at {Time}", DateTimeOffset.Now);
        // Logic to build work sessions from attendance logs
        return Task.CompletedTask;
    }
}
