using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Shared.Application.Abstractions.Services;
using SdxCore.Shared.Domain.Entities;

namespace SdxCore.Shared.API.Controllers;

[ApiController]
[Route("api/v1/lookups")]
[GatewayOnly]
public class LookupsController : SdxControllerBase
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
    [HttpGet("{code}/{parentId:guid}")]
    public async Task<IActionResult> GetLookupWithParent(string code, Guid parentId, CancellationToken cancellationToken)
    {
        var result = await _lookupService.GetLookupAsync(code, parentId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<LookupItem>>(result, "Successfully fetched lookup items."));
    }
}