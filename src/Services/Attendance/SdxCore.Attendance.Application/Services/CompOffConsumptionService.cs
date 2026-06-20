using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Services;

public class CompOffConsumptionService(
    ICompOffBalanceRepository compOffBalanceRepository,
    ICompOffAvailmentRepository compOffAvailmentRepository)
    : ICompOffConsumptionService
{
    public async Task ConsumeAsync(
        Guid employeeId,
        Guid leaveRequestId,
        decimal requiredDays,
        CancellationToken cancellationToken = default)
    {
        var balances =
            await compOffBalanceRepository
                .GetActiveBalancesAsync(employeeId, cancellationToken);

        decimal remainingDays = requiredDays;

        foreach (var balance in balances)
        {
            if (remainingDays <= 0)
                break;

            var consumedDays = Math.Min(balance.RemainingDays, remainingDays);

            if (consumedDays <= 0)
                continue;

            balance.AvailedDays += consumedDays;
            balance.RemainingDays -= consumedDays;

            compOffBalanceRepository.Update(balance);

            await compOffAvailmentRepository.AddAsync(
                new CompOffAvailment
                {
                    Id = Guid.NewGuid(),
                    LeaveRequestId = leaveRequestId,
                    CompOffBalanceId = balance.Id,
                    DaysAvailed = consumedDays,
                    IsActive = true
                },
                cancellationToken);

            remainingDays -= consumedDays;
        }
    }
}