using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface ICompOffAvailmentRepository
    : IRepository<CompOffAvailment, Guid>
{
    Task<IReadOnlyList<CompOffAvailment>> GetByLeaveRequestIdAsync(
        Guid leaveRequestId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<CompOffAvailment>> GetByCompOffBalanceIdAsync(
        Guid compOffBalanceId,
        CancellationToken cancellationToken = default);

    Task<decimal> GetTotalAvailedDaysAsync(
        Guid compOffBalanceId,
        CancellationToken cancellationToken = default);
}