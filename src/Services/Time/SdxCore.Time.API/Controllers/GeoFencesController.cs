using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Contracts.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/geo-fences")]
[GatewayOnly]
public class GeoFencesController : ControllerBase
{
    private readonly IGeoFenceService _service;
    private readonly ILogger<GeoFencesController> _logger;

    public GeoFencesController(IGeoFenceService service, ILogger<GeoFencesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<GeoFenceResponse>>(result, "Successfully fetched GeoFences."));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "GeoFence not found." });

        return Ok(new ApiResponse<GeoFenceResponse>(result, "Successfully fetched GeoFence."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateGeoFenceRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<GeoFenceResponse>(result, "GeoFence created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(short id, [FromBody] UpdateGeoFenceRequest dto, CancellationToken cancellationToken)
    {

        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "GeoFence not found." });

        return Ok(new ApiResponse<bool>(true, "GeoFence updated successfully."));
    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {

        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "GeoFence not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"GeoFence {statusStr} successfully."));
    }

    [HttpPost("check")]
    public async Task<IActionResult> CheckGeoFence([FromBody] GeoFenceCheckRequest request, CancellationToken cancellationToken)
    {
        var result = await _service.CheckGeoFenceAsync(request, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "OUT_OF_BOUNDS", ErrorMessage = "User is not within any active geofence." });
        return Ok(new ApiResponse<GeoFenceResponse>(result, "User is within a valid geofence."));
    }
}