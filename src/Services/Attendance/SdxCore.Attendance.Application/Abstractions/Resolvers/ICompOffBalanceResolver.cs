using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ICompOffBalanceResolver
{
    Task<CompOffBalance> ResolveAsync(
        Guid compOffBalanceId,
        CancellationToken cancellationToken = default);

    Task<decimal> GetAvailableBalanceAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default);

    Task<decimal> GetAvailableBalanceAsync(
        Guid employeeId,
        Guid compOffTypeId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<CompOffBalance>> GetAvailableBalancesAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default);

    Task ValidateLeaveBalanceAsync(
        Guid employeeId,
        decimal requestedDays,
        CancellationToken cancellationToken = default);
}