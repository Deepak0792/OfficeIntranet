using SdxCore.Attendance.Application.DTOs.Time;
using SdxCore.Attendance.Application.DTOs.Time.Response;

namespace SdxCore.Attendance.Application.Abstractions.Clients;

public interface ITimeClient
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<TimeZoneMasterResponse>> GetAllTimeZoneMastersAsync(CancellationToken cancellationToken = default!);
}
