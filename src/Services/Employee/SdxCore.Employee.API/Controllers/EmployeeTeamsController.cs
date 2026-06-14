using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.Employee.Request;
using SdxCore.Employee.Application.DTOs.EmployeeTeam.Request;
using SdxCore.Employee.Application.DTOs.EmployeeTeam.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[Route("api/v1/employees/{employeeId:guid}/teams")]
[GatewayOnly]
public class EmployeeTeamsController : SdxControllerBase
{
    private readonly IEmployeeTeamService _service;

    public EmployeeTeamsController(IEmployeeTeamService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetByEmployeeId(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<EmployeeTeamResponse>>(result, "Employee teams fetched successfully."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee team fetched successfully.");
    }

    [HttpPost]
    public async Task<IActionResult> Add(Guid employeeId, [FromBody] CreateEmployeeTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id }, new ApiResponse<EmployeeTeamResponse>(result, "Team added to employee successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid employeeId, Guid id, [FromBody] UpdateEmployeeTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeTeamResponse>(result, "Employee team updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid employeeId, Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Employee team status updated successfully.");
    }

    [HttpPatch("{id:guid}/set-primary")]
    public async Task<IActionResult> SetPrimary(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.SetPrimaryAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee primary team updated successfully.");
    }
}
