using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Employee;
using SdxCore.Attendance.Application.DTOs.Shift.Response;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Common.Enums.Workflow;

namespace SdxCore.Attendance.Application.Resolvers;

public class ShiftResolver(
    IEmployeeScopeResolver employeeScopeResolver,
    IScopeResolver scopeResolver,
    IShiftRepository shiftRepository,
    IShiftAssignmentRepository shiftAssignmentRepository,
    IRotationShiftAssignmentRepository rotationAssignmentRepository,
    IRotationShiftDetailRepository rotationDetailRepository)
    : IShiftResolver
{
    public async Task<ResolvedShiftResponse?> ResolveAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default)
    {
        var rotationShift =
            await ResolveRotationShiftAsync(
                employeeId,
                rosterDate,
                cancellationToken);

        if (rotationShift is not null)
            return rotationShift;

        return await ResolveFixedShiftAsync(
            employeeId,
            rosterDate,
            cancellationToken);
    }

    public async Task<bool> IsOffDayAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default)
    {
        var shift =
            await ResolveAsync(
                employeeId,
                rosterDate,
                cancellationToken);

        return shift?.IsOffDay ?? true;
    }

    private async Task<ResolvedShiftResponse?> ResolveFixedShiftAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken)
    {
        var scope =
            await employeeScopeResolver.ResolveAsync(
                employeeId,
                cancellationToken);

        if (scope is null)
            return null;

        var assignments =
            await shiftAssignmentRepository.GetActiveAssignmentsAsync(
                cancellationToken);

        foreach (var assignment in assignments.OrderBy(x => x.PriorityOrder))
        {
            if (!IsWithinDate(assignment.EffectiveFrom,
                    assignment.EffectiveTo,
                    rosterDate))
                continue;

            var scopeCode =
                await scopeResolver.GetScopeCodeByIdAsync(
                    assignment.ScopeTypeId,
                    cancellationToken);

            if (!IsMatch(
                    scopeCode,
                    assignment.ScopeReferenceId,
                    employeeId,
                    scope))
                continue;

            var shift =
                await shiftRepository.GetByIdAsync(
                    assignment.ShiftId,
                    cancellationToken);

            if (shift is null)
                continue;

            return new ResolvedShiftResponse
            {
                ShiftId = shift.Id,
                ShiftCode = shift.ShiftCode,
                ShiftName = shift.ShiftName,
                TimeZoneId = shift.TimeZoneId,
                StartTime = shift.StartTime,
                EndTime = shift.EndTime,
                CrossesMidnight = shift.CrossesMidnight,
                IsOffDay = false,
                IsRotationShift = false,
                RosterDate = rosterDate
            };
        }

        return null;
    }

    private async Task<ResolvedShiftResponse?> ResolveRotationShiftAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken)
    {
        var scope =
            await employeeScopeResolver.ResolveAsync(
                employeeId,
                cancellationToken);

        if (scope is null)
            return null;

        var assignments =
            await rotationAssignmentRepository
                .GetActiveAssignmentsAsync(cancellationToken);

        foreach (var assignment in assignments)
        {
            if (!IsWithinDate(
                    assignment.EffectiveFrom,
                    assignment.EffectiveTo,
                    rosterDate))
                continue;

            var scopeCode =
                await scopeResolver.GetScopeCodeByIdAsync(
                    assignment.ScopeTypeId,
                    cancellationToken);

            if (!IsMatch(
                    scopeCode,
                    assignment.ScopeReferenceId,
                    employeeId,
                    scope))
                continue;

            var details =
                (await rotationDetailRepository
                    .GetByRotationShiftIdAsync(
                        assignment.RotationShiftId,
                        cancellationToken))
                .OrderBy(x => x.SequenceNo)
                .ToList();

            if (details.Count == 0)
                return null;

            var cycleLength =
                details.Sum(x => x.DurationDays);

            var daysElapsed =
                rosterDate.DayNumber
                - assignment.RotationStartDate.DayNumber
                + assignment.RotationOffsetDays;

            while (daysElapsed < 0)
                daysElapsed += cycleLength;

            var cycleDay =
                daysElapsed % cycleLength;

            int runningDays = 0;

            foreach (var detail in details)
            {
                runningDays += detail.DurationDays;

                if (cycleDay >= runningDays)
                    continue;

                if (detail.IsOffDay)
                {
                    return new ResolvedShiftResponse
                    {
                        IsOffDay = true,
                        IsRotationShift = true,
                        RotationShiftId =
                            assignment.RotationShiftId,
                        RosterDate = rosterDate
                    };
                }

                var shift =
                    await shiftRepository.GetByIdAsync(
                        detail.ShiftId!.Value,
                        cancellationToken);

                if (shift is null)
                    return null;

                return new ResolvedShiftResponse
                {
                    ShiftId = shift.Id,
                    ShiftCode = shift.ShiftCode,
                    ShiftName = shift.ShiftName,
                    TimeZoneId = shift.TimeZoneId,
                    StartTime = shift.StartTime,
                    EndTime = shift.EndTime,
                    CrossesMidnight = shift.CrossesMidnight,
                    IsOffDay = false,
                    IsRotationShift = true,
                    RotationShiftId =
                        assignment.RotationShiftId,
                    RosterDate = rosterDate
                };
            }
        }

        return null;
    }

    private static bool IsWithinDate(
        DateOnly effectiveFrom,
        DateOnly? effectiveTo,
        DateOnly targetDate)
    {
        if (targetDate < effectiveFrom)
            return false;

        if (effectiveTo.HasValue &&
            targetDate > effectiveTo.Value)
            return false;

        return true;
    }

    private static bool IsMatch(
        string scopeCode,
        Guid? scopeReferenceId,
        Guid employeeId,
        EmployeeScopeContext scope)
    {
        return scopeCode switch
        {
            ScopeTypeCodes.Employee =>
                scopeReferenceId == employeeId,

            ScopeTypeCodes.Team =>
                scopeReferenceId == scope.TeamId,

            ScopeTypeCodes.Department =>
                scopeReferenceId == scope.DepartmentId,

            ScopeTypeCodes.Office =>
                scopeReferenceId == scope.OfficeLocationId,

            ScopeTypeCodes.LegalEntity =>
                scopeReferenceId == scope.LegalEntityId,

            ScopeTypeCodes.Country =>
                scopeReferenceId == scope.CountryId,

            ScopeTypeCodes.Global =>
                scopeReferenceId == null,

            _ => false
        };
    }
}