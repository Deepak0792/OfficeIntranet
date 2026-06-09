using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Contracts.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/office-locations")]
[GatewayOnly]
public class OfficeLocationsController : ControllerBase
{
    private readonly IOfficeLocationService _service;
    private readonly ILogger<OfficeLocationsController> _logger;

    public OfficeLocationsController(IOfficeLocationService service, ILogger<OfficeLocationsController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<OfficeLocationResponse>>(result, "Successfully fetched OfficeLocations."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "OfficeLocation not found." });

        return Ok(new ApiResponse<OfficeLocationResponse>(result, "Successfully fetched OfficeLocation."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateOfficeLocationRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<OfficeLocationResponse>(result, "OfficeLocation created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateOfficeLocationRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "OfficeLocation not found." });

        return Ok(new ApiResponse<bool>(true, "OfficeLocation updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "OfficeLocation not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"OfficeLocation {statusStr} successfully."));
    }
}