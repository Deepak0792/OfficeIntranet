using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IHolidayTypeResolver
{
    Task<HolidayType> ResolveAsync(
        Guid holidayTypeId,
        CancellationToken cancellationToken = default);
}