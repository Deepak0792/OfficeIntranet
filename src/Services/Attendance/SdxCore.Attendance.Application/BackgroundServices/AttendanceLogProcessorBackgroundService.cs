using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Application.Configuration;

namespace SdxCore.Attendance.Application.BackgroundServices;

public sealed class AttendanceLogProcessorBackgroundService(
    IServiceScopeFactory serviceScopeFactory,
    IOptions<AttendanceProcessingOptions> options,
    ILogger<AttendanceLogProcessorBackgroundService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(
        CancellationToken stoppingToken)
    {
        var settings = options.Value.AttendanceLogProcessor;

        if (!settings.Enabled)
        {
            logger.LogInformation(
                "Attendance Log Processor Background Service is disabled.");

            return;
        }

        if (!settings.BatchSize.HasValue)
        {
            throw new InvalidOperationException("BatchSize must be configured for AttendanceProcessing.");
        }

        logger.LogInformation(
            "Attendance Log Processor Background Service started.");

        using var timer = new PeriodicTimer(
            TimeSpan.FromSeconds(settings.PollingIntervalSeconds));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                using var scope = serviceScopeFactory.CreateScope();

                var processor = scope.ServiceProvider
                    .GetRequiredService<IAttendanceLogProcessor>();

                await processor.ProcessPendingLogsAsync(settings.BatchSize.Value, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                logger.LogError(
                    ex,
                    "Error occurred while processing attendance logs.");
            }
        }

        logger.LogInformation(
            "Attendance Log Processor Background Service stopped.");
    }
}