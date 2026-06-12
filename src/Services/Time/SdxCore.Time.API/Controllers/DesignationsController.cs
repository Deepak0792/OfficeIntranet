using SdxCore.Common.Controllers;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Time.Application.DTOs.Designation.Request;
using SdxCore.Time.Application.DTOs.Designation.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Application.Abstractions.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/designations")]
[GatewayOnly]
public class DesignationsController : SdxControllerBase
{
    private readonly IDesignationService _service;
    private readonly ILogger<DesignationsController> _logger;

    public DesignationsController(IDesignationService service, ILogger<DesignationsController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DesignationResponse>>(result, "Successfully fetched Designations."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Designation not found." });

        return Ok(new ApiResponse<DesignationResponse>(result, "Successfully fetched Designation."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDesignationRequest dto, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<DesignationResponse>(result, "Designation created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateDesignationRequest dto, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Designation not found." });

        return Ok(new ApiResponse<bool>(true, "Designation updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Designation not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Designation {statusStr} successfully."));
    }
}