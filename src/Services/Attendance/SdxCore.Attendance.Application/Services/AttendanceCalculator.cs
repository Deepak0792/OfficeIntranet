using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.Services;

public sealed class AttendanceCalculator(
    IAttendanceRecordRepository attendanceRepository,
    IWorkSessionRepository workSessionRepository,
    IAttendanceStatusResolver attendanceStatusResolver,
    ILeaveResolver leaveResolver,
    IRegularizationResolver regularizationResolver,
    IRosterResolver rosterResolver,
    IShiftResolver shiftResolver)
    : IAttendanceCalculator
{
    public async Task CalculateAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default)
    {
        var roster =
            await rosterResolver.ResolveByEmployeeAsync(
                employeeId,
                attendanceDate,
                cancellationToken);

        if (roster is null)
            throw new InvalidOperationException(
                $"Roster not found for employee {employeeId}");

        var attendance =
            await attendanceRepository.GetByEmployeeDateAsync(
                employeeId,
                attendanceDate,
                cancellationToken);

        attendance ??= CreateAttendanceRecord(
            employeeId,
            attendanceDate,
            roster);

        var sessions = await workSessionRepository.GetByEmployeeDateAsync(
                employeeId,
                attendanceDate,
                cancellationToken);

        var leave = await leaveResolver.ResolveAsync(
                employeeId,
                attendanceDate,
                cancellationToken);

        var regularization = await regularizationResolver.ResolveApprovedAsync(
            employeeId,
            attendanceDate,
            cancellationToken);

        Shift? shift = null;

        if (roster.ShiftId.HasValue)
        {
            shift =
                await shiftResolver.ResolveShiftByIdAsync(
                    roster.ShiftId.Value,
                    cancellationToken);
        }

        PopulateSessionInformation(
            attendance,
            sessions);

        PopulateShiftInformation(
            attendance,
            shift);

        attendance.LeaveRequestId = leave?.Id;
        attendance.RegularizationRequestId = regularization?.Id;
        attendance.IsRegularized = regularization is not null;

        await DetermineAttendanceStatusAsync(
            attendance,
            roster,
            shift,
            leave,
            cancellationToken);

        CalculateLateMinutes(attendance, roster, shift);

        CalculateEarlyExit(attendance, roster, shift);

        CalculateOvertime(attendance, shift);

        if (attendance.Id == Guid.Empty)
        {
            attendance.Id = Guid.NewGuid();

            await attendanceRepository.AddAsync(
                attendance,
                cancellationToken);
        }
        else
        {
            attendanceRepository.Update(attendance);
        }
    }

    private static AttendanceRecord CreateAttendanceRecord(
        Guid employeeId,
        DateOnly attendanceDate,
        EmployeeShiftRoster roster)
    {
        return new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            EmployeeId = employeeId,
            EmployeeShiftRosterId = roster.Id,
            AttendanceDate = attendanceDate,
            AttendanceState = AttendanceState.Draft,
            IsAutoProcessed = true,
            IsActive = true
        };
    }

    private static void PopulateSessionInformation(AttendanceRecord attendance, IReadOnlyCollection<WorkSession> sessions)
    {
        attendance.SessionCount =
            (short)sessions.Count;

        if (sessions.Count == 0)
        {
            attendance.WorkedMinutes = 0;
            attendance.BreakMinutes = 0;
            return;
        }

        var orderedSessions =
            sessions
                .OrderBy(x => x.CheckInTime)
                .ToList();

        attendance.CheckInTime =
            orderedSessions.First().CheckInTime;

        attendance.CheckOutTime =
            orderedSessions.Max(x => x.CheckOutTime);

        attendance.WorkedMinutes =
            (short)orderedSessions.Sum(x => x.WorkedMinutes ?? 0);

        var totalBreakMinutes = 0;

        for (var i = 1; i < orderedSessions.Count; i++)
        {
            var previous =
                orderedSessions[i - 1];

            var current =
                orderedSessions[i];

            if (previous.CheckOutTime.HasValue)
            {
                var gap =
                    current.CheckInTime -
                    previous.CheckOutTime.Value;

                if (gap.TotalMinutes > 0)
                {
                    totalBreakMinutes +=
                        (int)gap.TotalMinutes;
                }
            }
        }

        attendance.BreakMinutes =
            (short)totalBreakMinutes;
    }

    private static void PopulateShiftInformation(
        AttendanceRecord attendance,
        Shift? shift)
    {
        attendance.ShiftId = shift?.Id;

        attendance.MinimumWorkingMinutes = shift?.MinimumWorkingMinutes ?? 0;
    }

    private async Task DetermineAttendanceStatusAsync(
        AttendanceRecord attendance,
        EmployeeShiftRoster roster,
        Shift? shift,
        LeaveRequest? leave,
        CancellationToken cancellationToken)
    {
        string statusCode;

        if (leave is not null)
        {
            statusCode = AttendanceStatusCodes.OnLeave;
        }
        else if (roster.IsHoliday)
        {
            statusCode =
                attendance.WorkedMinutes > 0
                    ? AttendanceStatusCodes.HolidayDuty
                    : AttendanceStatusCodes.Holiday;
        }
        else if (roster.IsWeekend)
        {
            statusCode =
                attendance.WorkedMinutes > 0
                    ? AttendanceStatusCodes.WeekendDuty
                    : AttendanceStatusCodes.Weekend;
        }
        else if (roster.IsOffDay)
        {
            statusCode =
                attendance.WorkedMinutes > 0
                    ? AttendanceStatusCodes.OffDayDuty
                    : AttendanceStatusCodes.Absent;
        }
        else
        {
            statusCode =
                DetermineWorkingDayStatus(
                    attendance,
                    shift);
        }

        var attendanceStatus =
            await attendanceStatusResolver.ResolveByCodeAsync(
                statusCode,
                cancellationToken);

        attendance.AttendanceStatusId =
            attendanceStatus.Id;
    }

    private static string DetermineWorkingDayStatus(
        AttendanceRecord attendance,
        Shift? shift)
    {
        if (attendance.WorkedMinutes is null ||
            attendance.WorkedMinutes == 0)
        {
            return AttendanceStatusCodes.Absent;
        }

        if (shift is null)
            return AttendanceStatusCodes.Present;

        if (shift.MinimumWorkingMinutes.HasValue &&
            attendance.WorkedMinutes.Value < shift.MinimumWorkingMinutes.Value)
            return AttendanceStatusCodes.HalfDay;

        return AttendanceStatusCodes.Present;
    }

    private static void CalculateLateMinutes(
        AttendanceRecord attendance,
        EmployeeShiftRoster roster,
        Shift? shift)
    {
        if (shift is null ||
            attendance.CheckInTime is null ||
            roster.PlannedStartTime is null)
        {
            return;
        }

        var graceStart =
            roster.PlannedStartTime.Value
                .AddMinutes(shift.GraceInMinutes);

        var late =
            attendance.CheckInTime.Value - graceStart;

        attendance.LateByMinutes =
            late.TotalMinutes > 0
                ? (short)late.TotalMinutes
                : null;
    }

    private static void CalculateEarlyExit(
        AttendanceRecord attendance,
        EmployeeShiftRoster roster,
        Shift? shift)
    {
        if (shift is null ||
            attendance.CheckOutTime is null ||
            roster.PlannedEndTime is null)
        {
            return;
        }

        var allowedEnd =
            roster.PlannedEndTime.Value
                .AddMinutes(-shift.GraceOutMinutes);

        var early =
            allowedEnd - attendance.CheckOutTime.Value;

        attendance.EarlyExitMinutes =
            early.TotalMinutes > 0
                ? (short)early.TotalMinutes
                : null;
    }

    private static void CalculateOvertime(
        AttendanceRecord attendance,
        Shift? shift)
    {
        if (shift is null ||
            !shift.AllowOvertime ||
            attendance.WorkedMinutes is null)
        {
            attendance.OvertimeMinutes = 0;
            return;
        }

        if (!shift.MaximumWorkingMinutes.HasValue)
            return;

        var overtime =
            attendance.WorkedMinutes.Value -
            shift.MaximumWorkingMinutes.Value;

        attendance.OvertimeMinutes =
            overtime > 0
                ? (short)overtime
                : (short)0;
    }
}