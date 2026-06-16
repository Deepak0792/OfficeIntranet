using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Attendance.Request;
using SdxCore.Attendance.Application.DTOs.Attendance.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/attendance/regularizations")]
[GatewayOnly]
public class RegularizationsController(IAttendanceService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Regularization not found." };

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 20,
        [FromQuery] Guid? employeeId = null, CancellationToken cancellationToken = default)
    {
        var result = await service.GetRegularizationsAsync(page, pageSize, employeeId, cancellationToken);
        result.Message = "Regularizations fetched.";
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.GetRegularizationByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Regularization fetched.");
    }

    [HttpPost]
    public async Task<IActionResult> Submit([FromBody] CreateRegularizationRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.SubmitRegularizationAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id },
            new ApiResponse<RegularizationResponse>(result, "Regularization submitted."));
    }
}
