using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Application.Services;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using System;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/legal-entities")]
[GatewayOnly]
public class LegalEntitiesController : ControllerBase
{
    private readonly ILegalEntityService _service;
    private readonly ILogger<LegalEntitiesController> _logger;

    public LegalEntitiesController(ILegalEntityService service, ILogger<LegalEntitiesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(typeof(PagedResponse<IEnumerable<LegalEntityDto>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAll([FromQuery] PaginationFilter filter, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _service.GetAllAsync(filter, cancellationToken);
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching all LegalEntities");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<LegalEntityDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "LegalEntity not found." });
            
            return Ok(new ApiResponse<LegalEntityDto>(result));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching LegalEntity with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<LegalEntityDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] CreateLegalEntityDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _service.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<LegalEntityDto>(result, "LegalEntity created successfully.");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while creating LegalEntity");
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
    public async Task<IActionResult> Update(long id, [FromBody] UpdateLegalEntityDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "LegalEntity not found." });
            
            return Ok(new ApiResponse<bool>(true, "LegalEntity updated successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while updating LegalEntity with ID {Id}", id);
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
            if (!deleted) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "LegalEntity not found." });
            
            return Ok(new ApiResponse<bool>(true, "LegalEntity deleted successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while deleting LegalEntity with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DELETE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }
}

