using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Abstractions.Scheduler;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.RosterPolicy.Response;

namespace SdxCore.Attendance.Application.BackgroundServices.Scheduler;

public class RosterGenerationScheduler(
    IEmployeeClient employeeClient,
    IRosterGenerationPolicyResolver policyResolver,
    IRosterGenerationTrackerResolver trackerResolver,
    IRosterGenerationService rosterGenerationService)
    : IRosterGenerationScheduler
{
    public async Task ExecuteAsync(CancellationToken cancellationToken = default)
    {
        var employees = await employeeClient.GetEmployeesAsync(true, cancellationToken);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        foreach (var employee in employees)
        {
            var policy = await policyResolver.ResolveAsync(employee.EmployeeId, today, cancellationToken);

            if (policy is null)
                continue;

            var (fromDate, toDate) = BuildGenerationWindow(today, policy);

            var missingDates =
                await trackerResolver.GetMissingDatesAsync(
                    employee.EmployeeId,
                    fromDate,
                    toDate,
                    cancellationToken);

            if (missingDates.Count == 0)
                continue;

            await rosterGenerationService.GenerateForEmployeeAsync(
                employee.EmployeeId,
                policy.GenerationType,
                missingDates.Min(),
                missingDates.Max(),
                cancellationToken);
        }
    }

    private static (DateOnly FromDate, DateOnly ToDate) BuildGenerationWindow(DateOnly today, ResolvedRosterGenerationPolicy policy)
    {
        return policy.GenerationType switch
        {
            "WEEKLY" => (today, today.AddDays(7)),
            "MONTHLY" => (today, today.AddMonths(1)),
            _ => (today, today.AddDays(policy.GenerateDaysBefore))
        };
    }
}