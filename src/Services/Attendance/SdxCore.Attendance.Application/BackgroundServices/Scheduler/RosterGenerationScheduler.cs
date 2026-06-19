using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Abstractions.Scheduler;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.RosterPolicy.Response;

namespace SdxCore.Attendance.Application.Services;

public class RosterGenerationScheduler(
    IEmployeeClient employeeClient,
    IRosterGenerationPolicyResolver policyResolver,
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

            await rosterGenerationService.GenerateForEmployeeAsync(employee.EmployeeId, fromDate, toDate, cancellationToken);
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