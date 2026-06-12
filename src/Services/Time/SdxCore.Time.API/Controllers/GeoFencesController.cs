using SdxCore.Common.Controllers;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Time.Application.DTOs.GeoFence.Request;
using SdxCore.Time.Application.DTOs.GeoFence.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Application.Abstractions.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/geo-fences")]
[GatewayOnly]
public class GeoFencesController : SdxControllerBase
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

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "GeoFence not found." });

        return Ok(new ApiResponse<GeoFenceResponse>(result, "Successfully fetched GeoFence."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateGeoFenceRequest dto, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<GeoFenceResponse>(result, "GeoFence created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateGeoFenceRequest dto, CancellationToken cancellationToken)
    {

        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "GeoFence not found." });

        return Ok(new ApiResponse<bool>(true, "GeoFence updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {

        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

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