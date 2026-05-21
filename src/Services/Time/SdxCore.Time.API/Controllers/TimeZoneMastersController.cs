using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using SdxCore.Time.Application.Services;
using SdxCore.Time.Domain.Interfaces.Services;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using System;

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
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<TimeZoneMasterResponse>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
            public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetAllAsync(cancellationToken);
            return Ok(new ApiResponse<IEnumerable<TimeZoneMasterResponse>>(result, "Successfully fetched TimeZoneMasters."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching all TimeZoneMasters");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<TimeZoneMasterResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "TimeZoneMaster not found." });
            
            return Ok(new ApiResponse<TimeZoneMasterResponse>(result, "Successfully fetched TimeZoneMaster."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching TimeZoneMaster with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<TimeZoneMasterResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] CreateTimeZoneMasterRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _service.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<TimeZoneMasterResponse>(result, "TimeZoneMaster created successfully.");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while creating TimeZoneMaster");
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
    public async Task<IActionResult> Update(short id, [FromBody] UpdateTimeZoneMasterRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "TimeZoneMaster not found." });
            
            return Ok(new ApiResponse<bool>(true, "TimeZoneMaster updated successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while updating TimeZoneMaster with ID {Id}", id);
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
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "TimeZoneMaster not found." });
            
            var statusStr = request.IsActive ? "activated" : "deactivated";
            return Ok(new ApiResponse<bool>(true, $"TimeZoneMaster {statusStr} successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while toggling status for TimeZoneMaster with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "UPDATE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }
}


