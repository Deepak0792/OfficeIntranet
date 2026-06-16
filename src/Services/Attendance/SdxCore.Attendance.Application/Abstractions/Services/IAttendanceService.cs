using SdxCore.Attendance.Application.DTOs.Attendance.Request;
using SdxCore.Attendance.Application.DTOs.Attendance.Response;
using SdxCore.Common.Models;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface IAttendanceService
{
    Task<AttendanceRecordResponse?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default);
    Task<PagedResponse<IEnumerable<AttendanceRecordResponse>>> GetAllAsync(int page, int pageSize, Guid? employeeId, DateOnly? from, DateOnly? to, CancellationToken cancellationToken = default);
    Task<AttendanceRecordResponse?> CheckInAsync(CheckInRequest request, CancellationToken cancellationToken = default);
    Task<AttendanceRecordResponse?> CheckOutAsync(CheckOutRequest request, CancellationToken cancellationToken = default);
    Task ProcessDailyAsync(DateOnly date, CancellationToken cancellationToken = default);
    Task<bool> LockAsync(Guid id, CancellationToken cancellationToken = default);
    Task<RegularizationResponse> SubmitRegularizationAsync(CreateRegularizationRequest request, CancellationToken cancellationToken = default);
    Task<RegularizationResponse?> GetRegularizationByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<PagedResponse<IEnumerable<RegularizationResponse>>> GetRegularizationsAsync(int page, int pageSize, Guid? employeeId, CancellationToken cancellationToken = default);
    Task UpdateRegularizationStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default);
}
