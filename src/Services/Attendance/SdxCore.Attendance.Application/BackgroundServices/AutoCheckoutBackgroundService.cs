using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.Attendance.Application.Abstractions.Processor;

namespace SdxCore.Attendance.Application.BackgroundServices;

public class AutoCheckoutBackgroundService(
    IServiceProvider serviceProvider,
    ILogger<AutoCheckoutBackgroundService> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = serviceProvider.CreateAsyncScope();
                var processor = scope.ServiceProvider.GetRequiredService<IAutoCheckoutProcessor>();
                await processor.ProcessAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Auto checkout background service failed.");
            }

            await Task.Delay(TimeSpan.FromMinutes(10), stoppingToken);
        }
    }
}