namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IHolidayResolver
{
    Task<bool> IsHolidayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);
}