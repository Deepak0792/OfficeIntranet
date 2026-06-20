using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;

namespace SdxCore.Attendance.Application.Resolvers;

public class RosterGenerationTrackerResolver(
    IEmployeeRosterGenerationTrackerRepository repository)
    : IRosterGenerationTrackerResolver
{
    public async Task<bool> IsGeneratedAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default)
    {
        var trackers =
            await repository.GetByEmployeeAsync(
                employeeId,
                cancellationToken);

        return trackers.Any(t =>
            t.IsActive
            && fromDate >= t.GeneratedFromDate
            && toDate <= t.GeneratedToDate);
    }

    public async Task<IReadOnlyCollection<DateOnly>> GetMissingDatesAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default)
    {
        var trackers =
            (await repository.GetByEmployeeAsync(
                employeeId,
                cancellationToken))
            .Where(x => x.IsActive)
            .OrderBy(x => x.GeneratedFromDate)
            .ToList();

        var missingDates = new List<DateOnly>();

        for (var date = fromDate;
             date <= toDate;
             date = date.AddDays(1))
        {
            bool covered = false;

            foreach (var tracker in trackers)
            {
                if (date < tracker.GeneratedFromDate)
                    break;

                if (date >= tracker.GeneratedFromDate &&
                    date <= tracker.GeneratedToDate)
                {
                    covered = true;
                    break;
                }
            }

            if (!covered)
            {
                missingDates.Add(date);
            }
        }

        return missingDates;
    }
}