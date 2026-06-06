using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Shared.Application.Services;
using SdxCore.Shared.Domain.Entities;
using SdxCore.Shared.Application.Contracts.Services;

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
    public async Task<IActionResult> GetLookup(string code, CancellationToken cancellationToken)
    {

        var result = await _lookupService.GetLookupAsync(code, null, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<LookupItem>>(result, "Successfully fetched lookup items."));
    }

    /// <summary>
    /// Gets a list of lookup items by lookup code and parent ID.
    /// </summary>
    [HttpGet("{code}/{parentId}")]
    public async Task<IActionResult> GetLookupWithParent(string code, string parentId, CancellationToken cancellationToken)
    {
        var result = await _lookupService.GetLookupAsync(code, parentId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<LookupItem>>(result, "Successfully fetched lookup items."));
    }
}