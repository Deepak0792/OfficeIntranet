using SdxCore.Attendance.Application.DTOs.Roster.Request;
using SdxCore.Attendance.Application.DTOs.Roster.Response;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IRosterService
{
    Task<IEnumerable<RosterResponse>> GetByEmployeeAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default);
    Task<IEnumerable<RosterResponse>> GetByDateAsync(DateOnly date, CancellationToken cancellationToken = default);
    Task<RosterGenerationResult> GenerateAsync(GenerateRosterRequest request, CancellationToken cancellationToken = default);
    Task<RosterUploadResult> UploadAsync(RosterUploadRequest request, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateRosterRequest request, CancellationToken cancellationToken = default);
    Task<bool> LockAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> UnlockAsync(Guid id, CancellationToken cancellationToken = default);
    Task ExecuteShiftSwapAsync(Guid requesterRosterId, Guid targetRosterId, CancellationToken cancellationToken = default);
}
