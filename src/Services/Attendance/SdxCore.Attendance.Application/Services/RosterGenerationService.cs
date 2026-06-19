using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Helpers;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Application.Services;

public class RosterGenerationService(
    IEmployeeClient employeeClient,
    IShiftResolver shiftResolver,
    ITimeZoneResolver timeZoneResolver,
    IHolidayResolver holidayResolver,
    IWorkWeekPolicyResolver workWeekPolicyResolver,
    IEmployeeShiftRosterRepository rosterRepository,
    IUnitOfWork unitOfWork)
    : IRosterGenerationService
{
    public async Task GenerateForAllEmployeesAsync(DateOnly fromDate, DateOnly toDate, CancellationToken cancellationToken = default)
    {
        var employees = await employeeClient.GetEmployeesAsync(true, cancellationToken);

        foreach (var employee in employees)
            await GenerateForEmployeeAsync(employee.EmployeeId, fromDate, toDate, cancellationToken);
    }

    public async Task GenerateForEmployeesAsync(IEnumerable<Guid> employeeIds, DateOnly fromDate, DateOnly toDate, CancellationToken cancellationToken = default)
    {
        foreach (var employeeId in employeeIds)
            await GenerateForEmployeeAsync(employeeId, fromDate, toDate, cancellationToken);
    }

    public async Task GenerateForEmployeeAsync(Guid employeeId, DateOnly fromDate, DateOnly toDate, CancellationToken cancellationToken = default)
    {
        for (var date = fromDate; date <= toDate; date = date.AddDays(1))
            await GenerateRosterAsync(employeeId, date, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private async Task GenerateRosterAsync(Guid employeeId, DateOnly rosterDate, CancellationToken cancellationToken)
    {
        var existing =
            await rosterRepository.GetByEmployeeDateAsync(employeeId, rosterDate, cancellationToken);

        if (existing is not null)
            return;

        var shift = await shiftResolver.ResolveAsync(employeeId, rosterDate, cancellationToken);
        var isHoliday = await holidayResolver.IsHolidayAsync(employeeId, rosterDate, cancellationToken);
        var isWeekend = await workWeekPolicyResolver.IsWeekendAsync(employeeId, rosterDate, cancellationToken);

        var shiftEntity = shift ?? throw new InvalidOperationException("Shift not found.");

        var timeZone = await timeZoneResolver.GetTimeZoneAsync(shiftEntity.TimeZoneId, cancellationToken);

        var ianaTimeZoneId = timeZone.IanaTimeZoneId
            ?? throw new InvalidOperationException("Time zone IANA ID is missing.");

        var localStart = rosterDate.ToDateTime(shiftEntity.StartTime);
        var localEnd = rosterDate.ToDateTime(shiftEntity.EndTime);

        if (shiftEntity.CrossesMidnight && shiftEntity.EndTime < shiftEntity.StartTime)
        {
            localEnd = localEnd.AddDays(1);
        }

        var plannedStartUtc = TimeZoneHelper.ToUtc(localStart, ianaTimeZoneId);
        var plannedEndUtc = TimeZoneHelper.ToUtc(localEnd, ianaTimeZoneId);

        var roster = new EmployeeShiftRoster
        {
            Id = Guid.NewGuid(),
            EmployeeId = employeeId,
            RosterDate = rosterDate,
            ShiftId = shiftEntity.ShiftId,
            IsHoliday = isHoliday,
            IsOffDay = isWeekend || shiftEntity.IsOffDay,
            RosterTimeZoneId = shiftEntity.TimeZoneId,
            StartTimeLocal = localStart,
            EndTimeLocal = localEnd,
            PlannedStartTime = plannedStartUtc,
            PlannedEndTime = plannedEndUtc,
            IsLocked = false,
            IsActive = true
        };

        if (shift!.CrossesMidnight && roster.PlannedEndTime <= roster.PlannedStartTime)
            roster.PlannedEndTime = roster.PlannedEndTime.Value.AddDays(1);

        await rosterRepository.AddAsync(
            roster,
            cancellationToken);
    }
}