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
[Route("api/v1/employees/{employeeId}/teams")]
[GatewayOnly]
public class EmployeeTeamsController : SdxControllerBase
{
    private readonly IEmployeeTeamService _service;

    public EmployeeTeamsController(IEmployeeTeamService service)
    {
        _service = service;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<System.Collections.Generic.IEnumerable<EmployeeTeamResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetByEmployeeId(int employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<System.Collections.Generic.IEnumerable<EmployeeTeamResponse>>(result, "Employee teams fetched successfully."));
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<EmployeeTeamResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetById(int employeeId, int id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee team fetched successfully.");
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<EmployeeTeamResponse>), StatusCodes.Status201Created)]
    public async Task<IActionResult> Add(int employeeId, [FromBody] AddEmployeeTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.AddAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id }, new ApiResponse<EmployeeTeamResponse>(result, "Team added to employee successfully."));
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(ApiResponse<EmployeeTeamResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Update(int employeeId, int id, [FromBody] UpdateEmployeeTeamRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeTeamResponse>(result, "Employee team updated successfully."));
    }

    [HttpPatch("{id}/status")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ToggleStatus(int employeeId, int id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Employee team status updated successfully.");
    }
}
