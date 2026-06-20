using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class CompOffBalanceResolver(ICompOffBalanceRepository repository)
    : ICompOffBalanceResolver
{
    public async Task<CompOffBalance> ResolveAsync(
        Guid compOffBalanceId,
        CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(
            compOffBalanceId,
            cancellationToken);

        if (entity is null)
        {
            throw new InvalidOperationException(
                $"CompOffBalance '{compOffBalanceId}' not found.");
        }

        return entity;
    }

    public async Task<IReadOnlyList<CompOffBalance>> GetAvailableBalancesAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await repository.GetActiveBalancesAsync(
            employeeId,
            cancellationToken);
    }

    public async Task<decimal> GetAvailableBalanceAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        var balances = await repository.GetActiveBalancesAsync(
            employeeId,
            cancellationToken);

        return balances.Sum(x => x.RemainingDays);
    }

    public async Task<decimal> GetAvailableBalanceAsync(
        Guid employeeId,
        Guid compOffTypeId,
        CancellationToken cancellationToken = default)
    {
        var balances = await repository.GetActiveBalancesAsync(
            employeeId,
            cancellationToken);

        return balances
            .Where(x => x.CompOffTypeId == compOffTypeId)
            .Sum(x => x.RemainingDays);
    }

    public async Task ValidateLeaveBalanceAsync(
        Guid employeeId,
        decimal requestedDays,
        CancellationToken cancellationToken = default)
    {
        var available =
            await GetAvailableBalanceAsync(
                employeeId,
                cancellationToken);

        if (available < requestedDays)
        {
            throw new InvalidOperationException(
                $"Insufficient Comp-Off balance. Available={available}, Requested={requestedDays}");
        }
    }
}