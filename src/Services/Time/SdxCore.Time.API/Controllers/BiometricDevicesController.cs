using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Contracts.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/biometric-devices")]
[GatewayOnly]
public class BiometricDevicesController : ControllerBase
{
    private readonly IBiometricDeviceService _service;
    private readonly ILogger<BiometricDevicesController> _logger;

    public BiometricDevicesController(IBiometricDeviceService service, ILogger<BiometricDevicesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] PaginationFilter filter, CancellationToken cancellationToken)
    {
        var response = await _service.GetAllAsync(filter, cancellationToken);
        response.Message = "Successfully fetched BiometricDevices.";
        return Ok(response);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "BiometricDevice not found." });

        return Ok(new ApiResponse<BiometricDeviceResponse>(result, "Successfully fetched BiometricDevice."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBiometricDeviceRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<BiometricDeviceResponse>(result, "BiometricDevice created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateBiometricDeviceRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "BiometricDevice not found." });

        return Ok(new ApiResponse<bool>(true, "BiometricDevice updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "BiometricDevice not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"BiometricDevice {statusStr} successfully."));
    }

    [HttpPatch("{id:guid}/sync")]
    public async Task<IActionResult> SyncDevice(Guid id, CancellationToken cancellationToken)
    {
        var updated = await _service.SyncDeviceAsync(id, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Active BiometricDevice not found." });
        return Ok(new ApiResponse<bool>(true, "Device synchronized successfully."));
    }
}