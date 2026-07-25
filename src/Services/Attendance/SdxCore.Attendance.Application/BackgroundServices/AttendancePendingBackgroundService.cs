using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Application.Configuration;

namespace SdxCore.Attendance.Application.BackgroundServices;

public sealed class AttendancePendingBackgroundService(
    IServiceScopeFactory serviceScopeFactory,
    IOptions<AttendanceProcessingOptions> options,
    ILogger<AttendancePendingBackgroundService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(
        CancellationToken stoppingToken)
    {
        var settings =
            options.Value.AttendancePending;

        if (!settings.Enabled)
        {
            logger.LogInformation(
                "Attendance Pending Background Service is disabled.");

            return;
        }

        if (!settings.BatchSize.HasValue)
        {
            throw new InvalidOperationException("BatchSize must be configured for AttendancePending.");
        }

        logger.LogInformation(
            "Attendance Pending Background Service started.");

        using var timer =
            new PeriodicTimer(
                TimeSpan.FromSeconds(
                    settings.PollingIntervalSeconds));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                using var scope =
                    serviceScopeFactory.CreateScope();

                var processor =
                    scope.ServiceProvider
                        .GetRequiredService<IAttendancePendingProcessor>();

                await processor.ProcessAsync(settings.BatchSize.Value, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Attendance Pending Processor execution failed.");
            }
        }

        logger.LogInformation("Attendance Pending Background Service stopped.");
    }
}