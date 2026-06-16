using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Roster.Request;
using SdxCore.Attendance.Application.DTOs.Roster.Response;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/v1/rosters")]
[GatewayOnly]
public class RostersController(IRosterService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Roster not found." };

    [HttpGet("employee/{employeeId:guid}")]
    public async Task<IActionResult> GetByEmployee(Guid employeeId, [FromQuery] DateOnly from, [FromQuery] DateOnly to, CancellationToken cancellationToken)
    {
        var result = await service.GetByEmployeeAsync(employeeId, from, to, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RosterResponse>>(result, "Roster fetched."));
    }

    [HttpGet("date/{date}")]
    public async Task<IActionResult> GetByDate(DateOnly date, CancellationToken cancellationToken)
    {
        var result = await service.GetByDateAsync(date, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RosterResponse>>(result, "Roster fetched."));
    }

    [HttpPost("generate")]
    public async Task<IActionResult> GenerateRoster([FromBody] GenerateRosterRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.GenerateAsync(request, cancellationToken);
        return Ok(new ApiResponse<RosterGenerationResult>(result, "Roster generation completed."));
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadRoster([FromBody] RosterUploadRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.UploadAsync(request, cancellationToken);
        return Ok(new ApiResponse<RosterUploadResult>(result, "Roster upload completed."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateRosterRequest request, CancellationToken cancellationToken)
    {
        var success = await service.UpdateAsync(id, request, cancellationToken);
        return success
            ? Ok(new ApiResponse<bool>(success, "Roster updated."))
            : NotFound(NotFoundError);
    }

    [HttpPatch("{id:guid}/lock")]
    public async Task<IActionResult> Lock(Guid id, CancellationToken cancellationToken)
    {
        var success = await service.LockAsync(id, cancellationToken);
        return success ? Ok(new ApiResponse<bool>(success, "Roster locked.")) : NotFound(NotFoundError);
    }

    [HttpPatch("{id:guid}/unlock")]
    public async Task<IActionResult> Unlock(Guid id, CancellationToken cancellationToken)
    {
        var success = await service.UnlockAsync(id, cancellationToken);
        return success ? Ok(new ApiResponse<bool>(success, "Roster unlocked.")) : NotFound(NotFoundError);
    }
}
