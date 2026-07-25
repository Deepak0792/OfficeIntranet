using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.BackgroundServices.Processor;

public sealed class CheckOutProcessor(
IWorkSessionRepository workSessionRepository,
IAttendanceCalculationQueueService queueService,
IAttendanceUnitOfWork unitOfWork)
: ICheckOutProcessor
{
    public async Task ProcessAsync(
    AttendanceLog attendanceLog,
    CancellationToken cancellationToken = default)
    {
        var session =
            await workSessionRepository.GetActiveSessionAsync(
                attendanceLog.EmployeeId,
                cancellationToken);

        // Duplicate/Orphan checkout
        if (session is null)
        {
            return;
        }

        // Ignore invalid checkout
        if (attendanceLog.PunchTime < session.CheckInTime)
        {
            return;
        }

        session.CheckOutTime = attendanceLog.PunchTime;

        session.WorkedMinutes =
            (int)(session.CheckOutTime.Value - session.CheckInTime)
            .TotalMinutes;

        session.IsAutoCheckout = false;
        session.AutoCheckoutProcessed = true;

        workSessionRepository.Update(session);

        await queueService.EnqueueAsync(
            attendanceLog.EmployeeId,
            session.SessionDate,
            AttendanceCalculationReason.PunchReceived,
            priority: 1,
            cancellationToken);

        await unitOfWork.SaveChangesAsync(
            cancellationToken);
    }
}