using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Application.Configuration;

namespace SdxCore.Attendance.Application.BackgroundServices;

public sealed class AutoCheckoutBackgroundService(
    IServiceScopeFactory serviceScopeFactory,
    IOptions<AttendanceProcessingOptions> options,
    ILogger<AutoCheckoutBackgroundService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(
        CancellationToken stoppingToken)
    {
        var settings = options.Value.AutoCheckout;

        if (!settings.Enabled)
        {
            logger.LogInformation(
                "Auto Checkout Background Service is disabled.");

            return;
        }

        if (!settings.BatchSize.HasValue)
        {
            throw new InvalidOperationException("BatchSize must be configured for AttendanceCalculation.");
        }

        logger.LogInformation(
            "Auto Checkout Background Service started.");

        using var timer = new PeriodicTimer(
            TimeSpan.FromSeconds(settings.PollingIntervalSeconds));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                using var scope = serviceScopeFactory.CreateScope();

                var processor =
                    scope.ServiceProvider
                        .GetRequiredService<IAutoCheckoutProcessor>();

                await processor.ProcessAsync(settings.BatchSize.Value, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                logger.LogError(
                    ex,
                    "Auto Checkout Background Service execution failed.");
            }
        }

        logger.LogInformation(
            "Auto Checkout Background Service stopped.");
    }
}