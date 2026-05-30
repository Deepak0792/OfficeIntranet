using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Interfaces.Services;

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
    [ProducesResponseType(typeof(PagedResponse<IEnumerable<BiometricDeviceResponse>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAll([FromQuery] PaginationFilter filter, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _service.GetAllAsync(filter, cancellationToken);
            response.Message = "Successfully fetched BiometricDevices.";
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching all BiometricDevices");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<BiometricDeviceResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "BiometricDevice not found." });
            
            return Ok(new ApiResponse<BiometricDeviceResponse>(result, "Successfully fetched BiometricDevice."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching BiometricDevice with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<BiometricDeviceResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] CreateBiometricDeviceRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _service.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<BiometricDeviceResponse>(result, "BiometricDevice created successfully.");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while creating BiometricDevice");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "CREATE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateBiometricDeviceRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "BiometricDevice not found." });
            
            return Ok(new ApiResponse<bool>(true, "BiometricDevice updated successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while updating BiometricDevice with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "UPDATE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPatch("{id}/status")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> ToggleStatus(int id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "BiometricDevice not found." });
            
            var statusStr = request.IsActive ? "activated" : "deactivated";
            return Ok(new ApiResponse<bool>(true, $"BiometricDevice {statusStr} successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while toggling status for BiometricDevice with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "UPDATE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPatch("{id}/sync")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SyncDevice(int id, CancellationToken cancellationToken)
    {
        var updated = await _service.SyncDeviceAsync(id, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Active BiometricDevice not found." });
        return Ok(new ApiResponse<bool>(true, "Device synchronized successfully."));
    }
}


