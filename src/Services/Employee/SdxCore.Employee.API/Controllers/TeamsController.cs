using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Interfaces.Services;

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
    [ProducesResponseType(typeof(ApiResponse<System.Collections.Generic.IEnumerable<TeamResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _service.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<TeamResponse>>(result, "Teams fetched successfully."));
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<TeamResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(id, cancellationToken);
        return OkOrNotFound(result, "Team fetched successfully.");
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<TeamResponse>), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create([FromBody] CreateTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, new ApiResponse<TeamResponse>(result, "Team created successfully."));
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(ApiResponse<TeamResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Update(short id, [FromBody] UpdateTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(id, request, cancellationToken);
        return Ok(new ApiResponse<TeamResponse>(result, "Team updated successfully."));
    }

    [HttpPatch("{id}/status")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        // Reusing UpdateEmployeeStatusRequest since it just has a boolean IsActive.
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Team status updated successfully.");
    }
}
