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
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Regions."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });

        return Ok(new ApiResponse<RegionResponse>(result, "Successfully fetched Region."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateRegionRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<RegionResponse>(result, "Region created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateRegionRequest dto, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });

        return Ok(new ApiResponse<bool>(true, "Region updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Region {statusStr} successfully."));
    }

    [HttpGet("by-country/{countryId:guid}")]
    public async Task<IActionResult> GetByCountry(Guid countryId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByCountryIdAsync(countryId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpGet("tree")]
    public async Task<IActionResult> GetTree(CancellationToken cancellationToken)
    {
        var result = await _service.GetTreeAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpGet("{id:guid}/children")]
    public async Task<IActionResult> GetChildren(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetChildrenAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpGet("{id:guid}/ancestors")]
    public async Task<IActionResult> GetAncestors(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetAncestorsAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<RegionResponse>>(result, "Successfully fetched Region list."));
    }

    [HttpPatch("{id:guid}/parent")]
    public async Task<IActionResult> UpdateParent(Guid id, [FromBody] UpdateParentRequest request, CancellationToken cancellationToken)
    {
        var updated = await _service.UpdateParentAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Region not found." });
        return Ok(new ApiResponse<bool>(true, "Region parent updated successfully."));
    }
}