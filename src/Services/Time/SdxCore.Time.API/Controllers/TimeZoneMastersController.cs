using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Contracts.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/time-zones")]
[GatewayOnly]
public class TimeZoneMastersController : ControllerBase
{
    private readonly ITimeZoneMasterService _service;
    private readonly ILogger<TimeZoneMastersController> _logger;

    public TimeZoneMastersController(ITimeZoneMasterService service, ILogger<TimeZoneMastersController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<TimeZoneMasterResponse>>(result, "Successfully fetched TimeZoneMasters."));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "TimeZoneMaster not found." });

        return Ok(new ApiResponse<TimeZoneMasterResponse>(result, "Successfully fetched TimeZoneMaster."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTimeZoneMasterRequest dto, CancellationToken cancellationToken)
    {

        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<TimeZoneMasterResponse>(result, "TimeZoneMaster created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(short id, [FromBody] UpdateTimeZoneMasterRequest dto, CancellationToken cancellationToken)
    {

        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "TimeZoneMaster not found." });

        return Ok(new ApiResponse<bool>(true, "TimeZoneMaster updated successfully."));

    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "TimeZoneMaster not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"TimeZoneMaster {statusStr} successfully."));
    }
}