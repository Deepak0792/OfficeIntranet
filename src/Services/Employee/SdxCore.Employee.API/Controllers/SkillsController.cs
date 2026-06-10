using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[GatewayOnly]
public class SkillsController : SdxControllerBase
{
    private readonly ISkillService _service;

    public SkillsController(ISkillService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? category, CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(category, cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<SkillResponse>>(result, "Skills fetched successfully."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Skill fetched successfully.");
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateSkillRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, new ApiResponse<SkillResponse>(result, "Skill created successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateSkillRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(id, request, cancellationToken);
        return Ok(new ApiResponse<SkillResponse>(result, "Skill updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Skill status updated successfully.");
    }
}
