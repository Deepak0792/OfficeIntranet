using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.Attendance.Application.Abstractions.Scheduler;
using SdxCore.Attendance.Application.Abstractions.Services;

namespace SdxCore.Attendance.Application.BackgroundServices;

public class RosterGenerationBackgroundService(
    IServiceProvider serviceProvider,
    ILogger<RosterGenerationBackgroundService> logger)
    : BackgroundService
{
    private static readonly TimeSpan Interval = TimeSpan.FromHours(12);
    protected override async Task ExecuteAsync(
        CancellationToken stoppingToken)
    {
        logger.LogInformation("Roster generation background service started.");
        while (!stoppingToken.IsCancellationRequested)
        {
            var cycleStart = DateTime.UtcNow;
            try
            {
                using var scope = serviceProvider.CreateAsyncScope();
                var scheduler = scope.ServiceProvider.GetRequiredService<IRosterGenerationScheduler>();

                logger.LogInformation("Roster generation started at {Time}", cycleStart);
                await scheduler.ExecuteAsync(stoppingToken);
                logger.LogInformation("Roster generation completed at {Time}", DateTime.UtcNow);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Roster generation failed.");
            }

            // Prevent drift (fixed schedule alignment)
            var elapsed = DateTime.UtcNow - cycleStart;
            var delay = Interval - elapsed;

            if (delay < TimeSpan.Zero)
                delay = TimeSpan.Zero;

            await Task.Delay(delay, stoppingToken);
        }
    }
}