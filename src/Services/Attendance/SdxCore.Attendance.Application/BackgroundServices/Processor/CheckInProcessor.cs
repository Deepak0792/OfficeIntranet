using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.BackgroundServices.Processor;

public sealed class CheckInProcessor(
    IEmployeeShiftRosterRepository rosterRepository,
    IWorkSessionRepository workSessionRepository,
    IAttendanceCalculationQueueService queueService,
    IAttendanceUnitOfWork unitOfWork)
    : ICheckInProcessor
{
    public async Task ProcessAsync(
        AttendanceLog attendanceLog,
        CancellationToken cancellationToken = default)
    {
        // Duplicate IN punch
        var activeSession =
            await workSessionRepository.GetActiveSessionAsync(
                attendanceLog.EmployeeId,
                cancellationToken);

        if (activeSession is not null)
        {
            return;
        }

        var attendanceDate =
            DateOnly.FromDateTime(attendanceLog.PunchTime);

        var roster =
            await rosterRepository.GetByEmployeeDateAsync(
                attendanceLog.EmployeeId,
                attendanceDate,
                cancellationToken);

        var session = new WorkSession
        {
            Id = Guid.NewGuid(),
            EmployeeId = attendanceLog.EmployeeId,
            EmployeeShiftRosterId = roster?.Id,
            SessionDate = attendanceDate,

            CheckInTime = attendanceLog.PunchTime,

            IsAutoCheckout = false,
            AutoCheckoutProcessed = false,

            IsActive = true
        };

        // Auto Checkout Due Time
        if (roster?.ShiftId != null &&
            roster.PlannedEndTime.HasValue)
        {
            session.AutoCheckoutDueAt =
                roster.PlannedEndTime.Value.AddMinutes(
                    roster.Shift?.MaxAllowedCheckoutDelayMinutes ?? 0);
        }
        else
        {
            // Rotation Off / Holiday Duty / Weekend Duty
            session.AutoCheckoutDueAt =
                attendanceLog.PunchTime.AddHours(12);
        }

        await workSessionRepository.AddAsync(
            session,
            cancellationToken);

        await queueService.EnqueueAsync(
            attendanceLog.EmployeeId,
            attendanceDate,
            AttendanceCalculationReason.PunchReceived,
            priority: 1,
            cancellationToken);

        await unitOfWork.SaveChangesAsync(
            cancellationToken);
    }
}