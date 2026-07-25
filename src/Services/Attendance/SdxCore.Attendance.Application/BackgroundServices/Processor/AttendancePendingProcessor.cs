namespace SdxCore.Attendance.Application.BackgroundServices.Processor;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.Configuration;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Common.Enums.Attendance;

public sealed class AttendancePendingProcessor(
    IEmployeeShiftRosterRepository rosterRepository,
    IAttendanceCalculationQueueService queueService,
    IAttendanceUnitOfWork unitOfWork,
    ILogger<AttendancePendingProcessor> logger)
    : IAttendancePendingProcessor
{
    public async Task ProcessAsync( int batchSize,
        CancellationToken cancellationToken = default)
    {
        var rosters =
            await rosterRepository
                .GetPendingAttendanceCalculationAsync(
                    DateTime.UtcNow,
                    batchSize,
                    cancellationToken);

        if (rosters.Count() == 0)
            return;

        logger.LogInformation("Found {Count} pending attendance calculation(s).", rosters.Count());

        foreach (var roster in rosters)
        {
            try
            {
                await queueService.EnqueueAsync(
                    roster.EmployeeId,
                    roster.RosterDate,
                    AttendanceCalculationReason.MissingPunch,
                    priority: 2,
                    cancellationToken);

                logger.LogInformation(
                    "Attendance calculation queued for Employee {EmployeeId}, Date {AttendanceDate}",
                    roster.EmployeeId,
                    roster.RosterDate);
            }
            catch (Exception ex)
            {
                logger.LogError(
                    ex,
                    "Unable to queue attendance calculation for Employee {EmployeeId}, Date {AttendanceDate}",
                    roster.EmployeeId,
                    roster.RosterDate);
            }
        }

        await unitOfWork.SaveChangesAsync(
            cancellationToken);
    }
}