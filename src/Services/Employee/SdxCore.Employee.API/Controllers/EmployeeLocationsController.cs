using System.Collections.Generic;
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
[Route("api/v1/employees/{employeeId}/locations")]
[GatewayOnly]
public class EmployeeLocationsController : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Employee location not found." };

    private readonly IEmployeeLocationService _service;

    public EmployeeLocationsController(IEmployeeLocationService service)
    {
        _service = service;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<EmployeeLocationResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetByEmployeeId(int employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<EmployeeLocationResponse>>(result));
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<EmployeeLocationResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int employeeId, int id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee location retrieved successfully.");
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<EmployeeLocationResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create(int employeeId, [FromBody] AddEmployeeLocationRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.AddAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id }, new ApiResponse<EmployeeLocationResponse>(result, "Employee location added successfully."));
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(ApiResponse<EmployeeLocationResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(int employeeId, int id, [FromBody] UpdateEmployeeLocationRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeLocationResponse>(result, "Employee location updated successfully."));
    }

    [HttpPatch("{id}/status")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ToggleStatus(int employeeId, int id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Employee location status updated successfully.");
    }

    [HttpPatch("{id}/set-primary")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<IActionResult> SetPrimary(int employeeId, int id, CancellationToken cancellationToken)
    {
        var result = await _service.SetPrimaryAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee location set as primary successfully.");
    }
}
