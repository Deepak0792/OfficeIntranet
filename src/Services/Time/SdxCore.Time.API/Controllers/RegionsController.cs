using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Contracts.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/regions")]
[GatewayOnly]
public class RegionsController : ControllerBase
{
    private readonly IRegionService _service;
    private readonly ILogger<RegionsController> _logger;

    public RegionsController(IRegionService service, ILogger<RegionsController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<RegionResponse>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
            public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetAllAsync(cancellationToken);
            return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Regions."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching all Regions");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<RegionResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });
            
            return Ok(new ApiResponse<RegionResponse>(result, "Successfully fetched Region."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching Region with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "FETCH_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<RegionResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] CreateRegionRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _service.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<RegionResponse>(result, "Region created successfully.");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while creating Region");
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
    public async Task<IActionResult> Update(short id, [FromBody] UpdateRegionRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });
            
            return Ok(new ApiResponse<bool>(true, "Region updated successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while updating Region with ID {Id}", id);
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
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });
            
            var statusStr = request.IsActive ? "activated" : "deactivated";
            return Ok(new ApiResponse<bool>(true, $"Region {statusStr} successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while toggling status for Region with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "UPDATE_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("by-country/{countryId}")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<RegionResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetByCountry(short countryId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByCountryIdAsync(countryId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpGet("tree")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<RegionResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetTree(CancellationToken cancellationToken)
    {
        var result = await _service.GetTreeAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpGet("{id}/children")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<RegionResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetChildren(short id, CancellationToken cancellationToken)
    {
        var result = await _service.GetChildrenAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpGet("{id}/ancestors")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<RegionResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAncestors(short id, CancellationToken cancellationToken)
    {
        var result = await _service.GetAncestorsAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpPatch("{id}/parent")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateParent(short id, [FromBody] UpdateParentRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var updated = await _service.UpdateParentAsync(id, request, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });
            return Ok(new ApiResponse<bool>(true, "Region parent updated successfully."));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new ErrorResponse { ErrorCode = "INVALID_PARENT", ErrorMessage = ex.Message });
        }
    }
}



