namespace SdxCore.Attendance.Application.BackgroundServices;

using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;

public class AttendanceQueueProcessorBackgroundService(
    IServiceProvider serviceProvider,
    ILogger<AttendanceQueueProcessorBackgroundService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(
        CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope =
                serviceProvider.CreateAsyncScope();

            var repository =
                scope.ServiceProvider
                    .GetRequiredService<
                        IAttendanceCalculationQueueRepository>();

            var calculator =
                scope.ServiceProvider
                    .GetRequiredService<
                        IAttendanceCalculator>();

            var unitOfWork =
                scope.ServiceProvider
                    .GetRequiredService<
                        IAttendanceUnitOfWork>();

            var batch =
                await repository.GetPendingAsync(
                    500,
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
                    item.ErrorMessage = null;
                }
                catch (Exception ex)
                {
                    item.RetryCount++;
                    item.LastAttemptAt = DateTime.UtcNow;
                    item.ErrorMessage = ex.Message;
                }
            }

            await unitOfWork.SaveChangesAsync(stoppingToken);
            await Task.Delay(TimeSpan.FromMinutes(10), stoppingToken);
        }
    }
}