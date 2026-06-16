using SdxCore.Attendance.Application.DTOs.CompOff.Request;
using SdxCore.Attendance.Application.DTOs.CompOff.Response;

namespace SdxCore.Attendance.Application.Abstractions.Services;

public interface ICompOffService
{
    Task<CompOffBalanceResponse> EarnAsync(EarnCompOffRequest request, CancellationToken cancellationToken = default);
    Task<CompOffBalanceResponse> RedeemAsync(RedeemCompOffRequest request, CancellationToken cancellationToken = default);
    Task<IEnumerable<CompOffBalanceResponse>> GetBalanceAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default);
}
