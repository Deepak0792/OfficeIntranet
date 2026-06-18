using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Holiday.Response;
using SdxCore.Common.Enums.Workflow;

namespace SdxCore.Attendance.Application.Resolvers;


public class HolidayCalendarResolver(
    IEmployeeScopeResolver employeeScopeResolver,
    IScopeResolver scopeResolver,
    IHolidayCalendarAssignmentRepository assignmentRepository)
    : IHolidayCalendarResolver
{
    public async Task<IReadOnlyList<ResolvedHolidayCalendar>>
        ResolveCalendarsAsync(
            Guid employeeId,
            CancellationToken cancellationToken = default)
    {
        DateOnly todayDate = DateOnly.FromDateTime(DateTime.UtcNow);

        var scope =
            await employeeScopeResolver.ResolveAsync(
                employeeId,
                cancellationToken);

        var assignments =
            await assignmentRepository.GetActiveAssignmentsAsync(
                cancellationToken);

        var matched = new List<ResolvedHolidayCalendar>();

        foreach (var assignment in assignments)
        {
            if (!IsWithinDate(assignment, todayDate))
                continue;

            var scopeCode = await scopeResolver.GetScopeCodeByIdAsync(assignment.ScopeTypeId, cancellationToken);

            bool matches = scopeCode switch
            {
                ScopeTypeCodes.Employee
                    => assignment.ScopeReferenceId == employeeId,

                ScopeTypeCodes.Team
                    => assignment.ScopeReferenceId == scope.TeamId,

                ScopeTypeCodes.Department
                    => assignment.ScopeReferenceId == scope.DepartmentId,

                ScopeTypeCodes.Office
                    => assignment.ScopeReferenceId == scope.OfficeLocationId,

                ScopeTypeCodes.LegalEntity
                    => assignment.ScopeReferenceId == scope.LegalEntityId,

                ScopeTypeCodes.Country
                    => assignment.ScopeReferenceId == scope.CountryId,

                ScopeTypeCodes.Global
                    => assignment.ScopeReferenceId == null,

                _ => false
            };

            if (!matches)
                continue;

            matched.Add(
                new ResolvedHolidayCalendar(
                    assignment.HolidayCalendarId,
                    assignment.HolidayCalendar.CalendarName,
                    assignment.MergeStrategy,
                    assignment.IsPrimary,
                    assignment.EffectiveFrom,
                    assignment.EffectiveTo,
                    assignment.PriorityOrder,
                    scopeCode));
        }

        return [.. matched.OrderBy(x => x.PriorityOrder)];
    }

    private static bool IsWithinDate(
        HolidayCalendarAssignment assignment,
        DateOnly date)
    {
        if (date < assignment.EffectiveFrom)
        {
            return false;
        }

        if (assignment.EffectiveTo.HasValue &&
            date > assignment.EffectiveTo.Value)
        {
            return false;
        }

        return true;
    }
}