using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Leave.Request;
using SdxCore.Attendance.Application.DTOs.Leave.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/leaves")]
[GatewayOnly]
public class LeavesController(ILeaveService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Leave request not found." };

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 20,
        [FromQuery] Guid? employeeId = null, [FromQuery] string? status = null, CancellationToken cancellationToken = default)
    {
        var result = await service.GetAllAsync(page, pageSize, employeeId, status, cancellationToken);
        result.Message = "Leave requests fetched successfully.";
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.GetByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Leave request fetched.");
    }

    [HttpGet("employee/{employeeId:guid}")]
    public async Task<IActionResult> GetByEmployee(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await service.GetByEmployeeAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<LeaveRequestResponse>>(result, "Leave requests fetched."));
    }

    [HttpGet("employee/{employeeId:guid}/balance")]
    public async Task<IActionResult> GetBalance(Guid employeeId, [FromQuery] int year, CancellationToken cancellationToken)
    {
        var result = await service.GetBalanceAsync(employeeId, year, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<LeaveBalanceResponse>>(result, "Leave balance fetched."));
    }

    [HttpPost]
    public async Task<IActionResult> Submit([FromBody] CreateLeaveRequestRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.SubmitAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id },
            new ApiResponse<LeaveRequestResponse>(result, "Leave request submitted successfully."));
    }

    [HttpPatch("{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id, CancellationToken cancellationToken)
    {
        var success = await service.CancelAsync(id, cancellationToken);
        return success
            ? Ok(new ApiResponse<bool>(success, "Leave request cancelled."))
            : NotFound(NotFoundError);
    }

    [HttpPatch("{id:guid}/withdraw")]
    public async Task<IActionResult> Withdraw(Guid id, CancellationToken cancellationToken)
    {
        var success = await service.WithdrawAsync(id, cancellationToken);
        return success
            ? Ok(new ApiResponse<bool>(success, "Leave request withdrawn."))
            : NotFound(NotFoundError);
    }
}
