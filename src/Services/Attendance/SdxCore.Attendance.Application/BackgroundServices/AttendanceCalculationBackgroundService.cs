using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.Configuration;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;

namespace SdxCore.Attendance.Application.BackgroundServices;

public sealed class AttendanceCalculationBackgroundService(
    IServiceScopeFactory serviceScopeFactory,
    IOptions<AttendanceProcessingOptions> options,
    ILogger<AttendanceCalculationBackgroundService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(
        CancellationToken stoppingToken)
    {
        var settings = options.Value.AttendanceCalculation;

        if (!settings.Enabled)
        {
            logger.LogInformation(
                "Attendance Queue Processor Background Service is disabled.");

            return;
        }

        if (!settings.BatchSize.HasValue)
        {
            throw new InvalidOperationException("BatchSize must be configured for AttendanceCalculation.");
        }

        logger.LogInformation(
            "Attendance Queue Processor Background Service started.");

        using var timer = new PeriodicTimer(
            TimeSpan.FromSeconds(settings.PollingIntervalSeconds));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                using var scope = serviceScopeFactory.CreateScope();

                var repository =
                    scope.ServiceProvider
                        .GetRequiredService<IAttendanceCalculationQueueRepository>();

                var calculator =
                    scope.ServiceProvider
                        .GetRequiredService<IAttendanceCalculator>();

                var unitOfWork =
                    scope.ServiceProvider
                        .GetRequiredService<IAttendanceUnitOfWork>();

                var batch =
                    await repository.GetPendingAsync(
                        settings.BatchSize.Value,
                        stoppingToken);

                foreach (var item in batch)
                {
                    try
                    {
                        await calculator.CalculateAsync(
                            item.EmployeeId,
                            item.AttendanceDate,
                            stoppingToken);

                        item.ProcessedAt = DateTime.UtcNow;
                        item.LastAttemptAt = DateTime.UtcNow;
                        item.ErrorMessage = null;
                    }
                    catch (Exception ex)
                    {
                        item.RetryCount++;
                        item.LastAttemptAt = DateTime.UtcNow;
                        item.ErrorMessage = ex.Message;

                        logger.LogError(
                            ex,
                            "Attendance calculation failed for EmployeeId: {EmployeeId}, AttendanceDate: {AttendanceDate}",
                            item.EmployeeId,
                            item.AttendanceDate);
                    }
                }

                await unitOfWork.SaveChangesAsync(
                    stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                logger.LogError(
                    ex,
                    "Attendance Queue Processor execution failed.");
            }
        }

        logger.LogInformation(
            "Attendance Queue Processor Background Service stopped.");
    }
}