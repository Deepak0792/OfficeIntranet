using SdxCore.Attendance.Application.DTOs.Time;

namespace SdxCore.Attendance.Application.Abstractions.Clients;

public interface ITimeClient
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default);
}
