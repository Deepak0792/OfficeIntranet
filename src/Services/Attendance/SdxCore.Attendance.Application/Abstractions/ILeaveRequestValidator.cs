using SdxCore.Attendance.Application.DTOs;
using SdxCore.Attendance.Application.DTOs.Leave.Request;

namespace SdxCore.Attendance.Application.Abstractions;

public interface ILeaveRequestValidator
{
    Task<LeaveValidationResult> ValidateAsync(
        CreateLeaveRequestRequest request,
        CancellationToken cancellationToken = default);
}