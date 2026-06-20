namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface ICompOffConsumptionService
{
    Task ConsumeAsync(
        Guid employeeId,
        Guid leaveRequestId,
        decimal requiredDays,
        CancellationToken cancellationToken = default);
}