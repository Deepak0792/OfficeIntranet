using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Exceptions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

internal class HolidayTypeResolver(
    IHolidayTypeRepository repository)
    : IHolidayTypeResolver
{
    public async Task<HolidayType>
        ResolveAsync(
            Guid holidayTypeId,
            CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                holidayTypeId,
                cancellationToken);

        if (entity is null)
            throw ResolverException.NotFound(
                nameof(HolidayType),
                holidayTypeId);

        return entity;
    }
}