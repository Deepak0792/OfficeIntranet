using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Application.Exceptions;
using SdxCore.Attendance.Application.Abstractions.Resolvers;

namespace SdxCore.Attendance.Application.Resolvers;

public class CompOffTypeResolver(
    ICompOffTypeRepository repository)
    : ICompOffTypeResolver
{
    public async Task<CompOffType>
        ResolveAsync(
            Guid compOffTypeId,
            CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                compOffTypeId,
                cancellationToken);

        if (entity is null)
            throw ResolverException.NotFound(
                nameof(CompOffType),
                compOffTypeId);

        return entity;
    }
}