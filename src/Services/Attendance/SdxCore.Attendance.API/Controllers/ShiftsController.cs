using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Shift.Request;
using SdxCore.Attendance.Application.DTOs.Shift.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/shifts")]
[GatewayOnly]
public class ShiftsController(IShiftService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Shift not found." };

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<ShiftResponse>>(result, "Shifts fetched."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.GetByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Shift fetched.");
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateShiftRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id },
            new ApiResponse<ShiftResponse>(result, "Shift created."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateShiftRequest request, CancellationToken cancellationToken)
    {
        var result = await service.UpdateAsync(id, request, cancellationToken);
        return result is not null
            ? Ok(new ApiResponse<ShiftResponse>(result, "Shift updated."))
            : NotFound(NotFoundError);
    }

    [HttpPatch("{id:guid}/toggle-status")]
    public async Task<IActionResult> ToggleStatus(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.ToggleStatusAsync(id, cancellationToken);
        return result is not null
            ? Ok(new ApiResponse<ShiftResponse>(result, "Shift status toggled."))
            : NotFound(NotFoundError);
    }
}
