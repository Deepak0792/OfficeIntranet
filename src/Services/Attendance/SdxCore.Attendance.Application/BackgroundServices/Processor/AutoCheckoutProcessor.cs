using Microsoft.Extensions.Logging;
using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.BackgroundServices.Processor;

public class AutoCheckoutProcessor(
    IWorkSessionRepository workSessionRepository,
    IAttendanceCalculationQueueService queueService,
    IAttendanceUnitOfWork unitOfWork,
    ILogger<AutoCheckoutProcessor> logger)
    : IAutoCheckoutProcessor
{
    public async Task ProcessAsync(int batchSize,
        CancellationToken cancellationToken = default)
    {
        var utcNow = DateTime.UtcNow;

        var sessions =
            await workSessionRepository
                .GetDueForAutoCheckoutAsync(
                    utcNow,
                    batchSize,
                    cancellationToken);

        if (sessions.Count == 0)
            return;

        foreach (var session in sessions)
        {
            try
            {
                await ProcessSessionAsync(
                    session,
                    cancellationToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Auto checkout failed for session {SessionId}", session.Id);
            }
        }

        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private async Task ProcessSessionAsync(WorkSession session, CancellationToken cancellationToken)
    {
        var checkoutTime = session.AutoCheckoutDueAt ?? DateTime.UtcNow;
        session.CheckOutTime = checkoutTime;
        session.WorkedMinutes = Math.Max(0, (int)(checkoutTime - session.CheckInTime).TotalMinutes);
        session.IsAutoCheckout = true;
        session.AutoCheckoutProcessed = true;

        workSessionRepository.Update(session);

        await queueService.EnqueueAsync(
            session.EmployeeId,
            session.SessionDate,
            AttendanceCalculationReason.AutoCheckout,
            priority: 5,
            cancellationToken);
    }
}