using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ICompOffBalanceResolver
{
    Task<CompOffBalance> ResolveAsync(
        Guid compOffBalanceId,
        CancellationToken cancellationToken = default);
}