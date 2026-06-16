using SdxCore.Attendance.Application.DTOs.Shift.Request;
using SdxCore.Attendance.Application.DTOs.Shift.Response;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IShiftService
{
    Task<IEnumerable<ShiftResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<ShiftResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<ShiftResponse> CreateAsync(CreateShiftRequest request, CancellationToken cancellationToken = default);
    Task<ShiftResponse?> UpdateAsync(Guid id, UpdateShiftRequest request, CancellationToken cancellationToken = default);
    Task<ShiftResponse?> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);
}
