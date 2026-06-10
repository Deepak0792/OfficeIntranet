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
public class TeamsController : SdxControllerBase
{
    private readonly ITeamService _service;

    public TeamsController(ITeamService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<TeamResponse>>(result, "Teams fetched successfully."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Team fetched successfully.");
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, new ApiResponse<TeamResponse>(result, "Team created successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(id, request, cancellationToken);
        return Ok(new ApiResponse<TeamResponse>(result, "Team updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        // Reusing UpdateEmployeeStatusRequest since it just has a boolean IsActive.
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Team status updated successfully.");
    }
}