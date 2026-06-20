using SdxCore.Attendance.Application.Abstractions;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs;
using SdxCore.Attendance.Application.DTOs.Leave.Request;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.Validators.Leave;

public class LeaveRequestValidator(
    IEmployeeResolver employeeResolver,
    ILeaveTypeResolver leaveTypeResolver,
    ILeaveBalanceResolver leaveBalanceResolver,
    ICompOffBalanceResolver compOffBalanceResolver,
    ILeaveDayCalculator leaveDayCalculator)
    : ILeaveRequestValidator
{
    public async Task<LeaveValidationResult> ValidateAsync(
        CreateLeaveRequestRequest request,
        CancellationToken cancellationToken = default)
    {
        await employeeResolver.ResolveActiveEmployeeAsync(
            request.EmployeeId,
            cancellationToken);

        var leaveType =
            await leaveTypeResolver.ResolveActiveLeaveTypeAsync(
                request.LeaveTypeId,
                cancellationToken);

        var calculation =
            await leaveDayCalculator.CalculateAsync(
                request.EmployeeId,
                request.FromDate,
                request.ToDate,
                cancellationToken);

        var leaveDays = calculation.PayableDays;

        if (leaveDays <= 0)
        {
            throw new InvalidOperationException("No payable leave days found.");
        }

        var leaveCode =
            leaveType.LeaveCode.ToUpperInvariant();

        var isCompOff =
            leaveCode == LeaveTypeCode.CompOff.ToString();

        var isLwp =
            leaveCode == LeaveTypeCode.LWP.ToString();

        if (isCompOff)
        {
            await compOffBalanceResolver.ValidateLeaveBalanceAsync(
                request.EmployeeId,
                leaveDays,
                cancellationToken);
        }
        else if (!isLwp)
        {
            await leaveBalanceResolver.ValidateLeaveBalanceAsync(
                request.EmployeeId,
                request.LeaveTypeId,
                request.FromDate.Year,
                leaveDays,
                cancellationToken);
        }

        return new LeaveValidationResult
        {
            LeaveTypeId = leaveType.Id,
            LeaveTypeCode = leaveType.LeaveCode,
            LeaveTypeName = leaveType.LeaveName,
            TotalLeaveDays = leaveDays,
            IsCompOff = isCompOff,
            IsLwp = isLwp
        };
    }
}