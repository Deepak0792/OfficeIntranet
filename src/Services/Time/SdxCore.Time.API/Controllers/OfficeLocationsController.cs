using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Domain.DTOs;
using SdxCore.Time.Application.Services;
using SdxCore.Time.Domain.Interfaces.Services;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using System;

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
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<OfficeLocationDto>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
            public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetAllAsync(cancellationToken);
            return Ok(new ApiResponse<IEnumerable<OfficeLocationDto>>(result, "Successfully fetched OfficeLocations."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching all OfficeLocations");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<OfficeLocationDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "OfficeLocation not found." });
            
            return Ok(new ApiResponse<OfficeLocationDto>(result));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching OfficeLocation with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<OfficeLocationDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] CreateOfficeLocationDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _service.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<OfficeLocationDto>(result, "OfficeLocation created successfully.");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while creating OfficeLocation");
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
    public async Task<IActionResult> Update(long id, [FromBody] UpdateOfficeLocationDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "OfficeLocation not found." });
            
            return Ok(new ApiResponse<bool>(true, "OfficeLocation updated successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while updating OfficeLocation with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "UPDATE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Delete(long id, CancellationToken cancellationToken)
    {
        try
        {
            var deleted = await _service.DeleteAsync(id, cancellationToken);
            if (!deleted) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "OfficeLocation not found." });
            
            return Ok(new ApiResponse<bool>(true, "OfficeLocation deleted successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while deleting OfficeLocation with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DELETE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }
}


