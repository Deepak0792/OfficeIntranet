using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.Country.Request;
using SdxCore.Time.Application.DTOs.Country.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/countries")]
[GatewayOnly]
public class CountriesController : SdxControllerBase
{
    private readonly ICountryService _service;
    private readonly ILogger<CountriesController> _logger;

    public CountriesController(ICountryService service, ILogger<CountriesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<CountryResponse>>(result, "Successfully fetched Countries."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Country not found." });

        return Ok(new ApiResponse<CountryResponse>(result, "Successfully fetched Country."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCountryRequest dto, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<CountryResponse>(result, "Country created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCountryRequest dto, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var updated = await _service.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Country not found." });

        return Ok(new ApiResponse<bool>(true, "Country updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var updated = await _service.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Country not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Country {statusStr} successfully."));
    }
}