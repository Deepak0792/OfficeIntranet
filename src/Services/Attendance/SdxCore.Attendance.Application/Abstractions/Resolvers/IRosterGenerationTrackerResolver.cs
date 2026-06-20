namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IRosterGenerationTrackerResolver
{
    Task<bool> IsGeneratedAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<DateOnly>> GetMissingDatesAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);
}