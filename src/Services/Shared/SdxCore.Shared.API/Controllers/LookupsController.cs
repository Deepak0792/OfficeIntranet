using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Shared.Application.Services;
using SdxCore.Shared.Domain.Entities;
using SdxCore.Shared.Domain.Interfaces.Services;

namespace SdxCore.Shared.API.Controllers;

[ApiController]
[Route("api/v1/lookups")]
[GatewayOnly]
public class LookupsController : ControllerBase
{
    private readonly ILookupService _lookupService;
    private readonly ILogger<LookupsController> _logger;

    public LookupsController(ILookupService lookupService, ILogger<LookupsController> logger)
    {
        _lookupService = lookupService;
        _logger = logger;
    }

    /// <summary>
    /// Gets a list of lookup items by lookup code.
    /// </summary>
    [HttpGet("{code}")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<LookupItem>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetLookup(string code, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _lookupService.GetLookupAsync(code, null, cancellationToken);
            return Ok(new ApiResponse<IEnumerable<LookupItem>>(result, "Successfully fetched lookup items."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching lookup for code {Code}", code);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "LOOKUP_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the lookup."
            });
        }
    }

    /// <summary>
    /// Gets a list of lookup items by lookup code and parent ID.
    /// </summary>
    [HttpGet("{code}/{parentId}")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<LookupItem>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetLookupWithParent(string code, string parentId, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _lookupService.GetLookupAsync(code, parentId, cancellationToken);
            return Ok(new ApiResponse<IEnumerable<LookupItem>>(result, "Successfully fetched lookup items."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching lookup for code {Code} and parentId {ParentId}", code, parentId);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "LOOKUP_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the lookup."
            });
        }
    }
}
