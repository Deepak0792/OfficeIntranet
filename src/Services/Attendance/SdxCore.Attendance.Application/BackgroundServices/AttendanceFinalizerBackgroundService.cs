namespace SdxCore.Attendance.Application.BackgroundServices;

using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.Attendance.Application.Abstractions.Processor;

public class AttendanceFinalizerBackgroundService(
    IServiceProvider serviceProvider,
    ILogger<AttendanceFinalizerBackgroundService> logger)
    : BackgroundService
{
    private static readonly TimeSpan Interval = TimeSpan.FromMinutes(5);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = serviceProvider.CreateAsyncScope();

                var finalizer = scope.ServiceProvider.GetRequiredService<IAttendanceFinalizerProcessor>();

                await finalizer.FinalizeAsync(
                    stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Attendance finalizer failed.");
            }

            await Task.Delay(Interval, stoppingToken);
        }
    }
}