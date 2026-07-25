using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Helpers;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Application.Services;

public class RosterGenerationService(
    IEmployeeClient employeeClient,
    IShiftResolver shiftResolver,
    ITimeZoneResolver timeZoneResolver,
    IEmployeeCalendarResolver employeeCalendarResolver,
    IEmployeeShiftRosterRepository rosterRepository,
    IEmployeeRosterGenerationTrackerRepository trackerRepository,
    IUnitOfWork unitOfWork)
    : IRosterGenerationService
{
    public async Task GenerateForAllEmployeesAsync(
        DateOnly fromDate,
        DateOnly toDate,
        string generationType = "MANUAL",
        CancellationToken cancellationToken = default)
    {
        var employees =
            await employeeClient.GetEmployeesAsync(
                true,
                cancellationToken);

        foreach (var employee in employees)
        {
            await GenerateForEmployeeAsync(
                employee.EmployeeId,
                generationType,
                fromDate,
                toDate,
                cancellationToken);
        }
    }

    public async Task GenerateForEmployeesAsync(
        IEnumerable<Guid> employeeIds,
        DateOnly fromDate,
        DateOnly toDate,
        string generationType = "MANUAL",
        CancellationToken cancellationToken = default)
    {
        foreach (var employeeId in employeeIds)
        {
            await GenerateForEmployeeAsync(
                employeeId,
                generationType,
                fromDate,
                toDate,
                cancellationToken);
        }
    }

    public async Task GenerateForEmployeeAsync(
        Guid employeeId,
        string generationType,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default)
    {
        var calendar =
            await employeeCalendarResolver.ResolveAsync(
                employeeId,
                fromDate,
                toDate,
                cancellationToken);

        for (var date = fromDate;
             date <= toDate;
             date = date.AddDays(1))
        {
            await GenerateRosterAsync(
                employeeId,
                date,
                calendar,
                cancellationToken);
        }

        await CreateTrackerAsync(
            employeeId,
            fromDate,
            toDate,
            generationType,
            cancellationToken);

        await unitOfWork.SaveChangesAsync(
            cancellationToken);
    }

    private async Task GenerateRosterAsync(
        Guid employeeId,
        DateOnly rosterDate,
        EmployeeCalendarResult calendar,
        CancellationToken cancellationToken)
    {
        var existing =
            await rosterRepository.GetByEmployeeDateAsync(
                employeeId,
                rosterDate,
                cancellationToken);

        if (existing is not null)
            return;

        var shift =
            await shiftResolver.ResolveAsync(
                employeeId,
                rosterDate,
                cancellationToken);

        if (shift is null)
        {
            throw new InvalidOperationException(
                $"No shift resolved for Employee '{employeeId}' on '{rosterDate}'.");
        }

        var isHoliday =
            calendar.HolidayDays.Contains(rosterDate);

        var isWeekend =
            calendar.WeekendDays.Contains(rosterDate);

        var timeZone =
            await timeZoneResolver.GetTimeZoneAsync(
                shift.TimeZoneId,
                cancellationToken);

        var ianaTimeZoneId =
            timeZone.IanaTimeZoneId
            ?? throw new InvalidOperationException(
                "IANA TimeZone Id not configured.");

        var localStart =
            rosterDate.ToDateTime(
                shift.StartTime);

        var localEnd =
            rosterDate.ToDateTime(
                shift.EndTime);

        if (shift.CrossesMidnight &&
            shift.EndTime < shift.StartTime)
        {
            localEnd = localEnd.AddDays(1);
        }

        var plannedStartUtc =
            TimeZoneHelper.ToUtc(
                localStart,
                ianaTimeZoneId);

        var plannedEndUtc =
            TimeZoneHelper.ToUtc(
                localEnd,
                ianaTimeZoneId);

        var roster = new EmployeeShiftRoster
        {
            Id = Guid.NewGuid(),
            EmployeeId = employeeId,
            RosterDate = rosterDate,

            ShiftId = shift.ShiftId,

            IsHoliday = isHoliday,
            IsWeekend = isWeekend,

            IsOffDay =
                isWeekend ||
                shift.IsOffDay,

            RosterTimeZoneId = shift.TimeZoneId,
            
            StartTimeLocal = localStart,
            EndTimeLocal = localEnd,

            PlannedStartTime = plannedStartUtc,
            PlannedEndTime = plannedEndUtc,
            AttendanceCalculationDueAt = plannedStartUtc.AddMinutes(shift.GraceInMinutes),

            IsLocked = false,
            IsActive = true
        };

        if (shift.CrossesMidnight &&
            roster.PlannedEndTime <= roster.PlannedStartTime)
        {
            roster.PlannedEndTime =
                roster.PlannedEndTime!.Value.AddDays(1);
        }

        await rosterRepository.AddAsync(
            roster,
            cancellationToken);
    }

    private async Task CreateTrackerAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        string generationType,
        CancellationToken cancellationToken)
    {
        var tracker = new EmployeeRosterGenerationTracker
        {
            Id = Guid.NewGuid(),

            EmployeeId = employeeId,
            RosterYear = (short)fromDate.Year,
            RosterMonth = (byte)fromDate.Month,
            GenerationType = generationType,
            GeneratedFromDate = fromDate,
            GeneratedToDate = toDate,
            LastGeneratedAt = DateTime.UtcNow,
            IsLocked = false,
            IsActive = true
        };

        await trackerRepository.AddAsync(
            tracker,
            cancellationToken);
    }
}