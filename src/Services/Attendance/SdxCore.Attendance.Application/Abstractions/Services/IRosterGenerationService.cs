namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IRosterGenerationService
{
    Task GenerateForEmployeeAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);

    Task GenerateForEmployeesAsync(
        IEnumerable<Guid> employeeIds,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);

    Task GenerateForAllEmployeesAsync(
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);
}