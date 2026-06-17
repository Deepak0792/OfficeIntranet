using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;

namespace SdxCore.Attendance.Application.Resolvers;

public class HolidayResolver(
    IHolidayRepository holidayRepository)
    : IHolidayResolver
{
    public async Task<bool> IsHolidayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var holidays =
            await holidayRepository.GetByDateAsync(
                date,
                cancellationToken);

        return holidays.Any();
    }
}