using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class CompOffBalanceResolver(
    ICompOffBalanceRepository repository)
    : ICompOffBalanceResolver
{
    public async Task<CompOffBalance> ResolveAsync(
        Guid compOffBalanceId,
        CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                compOffBalanceId,
                cancellationToken);

        if (entity is null)
            throw new InvalidOperationException(
                $"CompOffBalance '{compOffBalanceId}' not found.");

        return entity;
    }
}