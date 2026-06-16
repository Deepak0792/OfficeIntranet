using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.ShiftSwap.Request;
using SdxCore.Attendance.Application.DTOs.ShiftSwap.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/shift-swaps")]
[GatewayOnly]
public class ShiftSwapsController(IShiftSwapService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Shift swap request not found." };

    [HttpGet("employee/{employeeId:guid}")]
    public async Task<IActionResult> GetByEmployee(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await service.GetByEmployeeAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<ShiftSwapResponse>>(result, "Shift swap requests fetched."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.GetByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Shift swap request fetched.");
    }

    [HttpPost]
    public async Task<IActionResult> RequestSwap([FromBody] CreateShiftSwapRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.RequestSwapAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id },
            new ApiResponse<ShiftSwapResponse>(result, "Shift swap requested."));
    }

    [HttpPatch("{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id, CancellationToken cancellationToken)
    {
        var success = await service.CancelAsync(id, cancellationToken);
        return success
            ? Ok(new ApiResponse<bool>(success, "Shift swap cancelled."))
            : NotFound(NotFoundError);
    }
}
