using SdxCore.Attendance.Application.DTOs.ShiftSwap.Request;
using SdxCore.Attendance.Application.DTOs.ShiftSwap.Response;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IShiftSwapService
{
    Task<ShiftSwapResponse> RequestSwapAsync(CreateShiftSwapRequest request, CancellationToken cancellationToken = default);
    Task<ShiftSwapResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<ShiftSwapResponse>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<bool> CancelAsync(Guid id, CancellationToken cancellationToken = default);
    Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default);
}
