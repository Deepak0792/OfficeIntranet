using SdxCore.Attendance.Application.DTOs.Leave.Request;
using SdxCore.Attendance.Application.DTOs.Leave.Response;
using SdxCore.Common.Models;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface ILeaveService
{
    Task<LeaveRequestResponse> SubmitAsync(CreateLeaveRequestRequest request, CancellationToken cancellationToken = default);
    Task<LeaveRequestResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<PagedResponse<IEnumerable<LeaveRequestResponse>>> GetAllAsync(int page, int pageSize, Guid? employeeId, string? status, CancellationToken cancellationToken = default);
    Task<IEnumerable<LeaveRequestResponse>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<bool> CancelAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> WithdrawAsync(Guid id, CancellationToken cancellationToken = default);
    Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default);
    Task<IEnumerable<LeaveBalanceResponse>> GetBalanceAsync(Guid employeeId, int year, CancellationToken cancellationToken = default);
}
