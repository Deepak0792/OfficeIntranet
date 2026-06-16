using SdxCore.Attendance.Application.DTOs.LeaveType.Request;
using SdxCore.Attendance.Application.DTOs.LeaveType.Response;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface ILeaveTypeService
{
    Task<IEnumerable<LeaveTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LeaveTypeResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<LeaveTypeResponse> CreateAsync(CreateLeaveTypeRequest request, CancellationToken cancellationToken = default);
    Task<LeaveTypeResponse?> UpdateAsync(Guid id, UpdateLeaveTypeRequest request, CancellationToken cancellationToken = default);
    Task<LeaveTypeResponse?> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);
}
