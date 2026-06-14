using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.Employee.Request;
using SdxCore.Employee.Application.DTOs.EmployeeRelationship.Request;
using SdxCore.Employee.Application.DTOs.EmployeeRelationship.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[Route("api/v1/employees/{employeeId:guid}/relationships")]
[GatewayOnly]
public class EmployeeRelationshipsController : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Employee relationship not found." };

    private readonly IEmployeeRelationshipService _service;

    public EmployeeRelationshipsController(IEmployeeRelationshipService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetByEmployeeId(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<EmployeeRelationshipResponse>>(result));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee relationship retrieved successfully.");
    }

    [HttpGet("/api/v1/employees/{employeeId:guid}/direct-reports")]
    public async Task<IActionResult> GetDirectReports(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetDirectReportsAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<EmployeeRelationshipResponse>>(result));
    }

    [HttpGet("/api/v1/employees/{employeeId:guid}/manager")]
    public async Task<IActionResult> GetManager(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetManagerAsync(employeeId, cancellationToken);
        return OkOrNotFound(result, "Employee manager retrieved successfully.");
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid employeeId, [FromBody] CreateEmployeeRelationshipRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId = result.ChildEmployeeId, id = result.Id },
            new ApiResponse<EmployeeRelationshipResponse>(result, "Employee relationship added successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid employeeId, Guid id, [FromBody] UpdateEmployeeRelationshipRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeRelationshipResponse>(result, "Employee relationship updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid employeeId, Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Employee relationship status updated successfully.");
    }

    [HttpPatch("{id:guid}/set-primary")]
    public async Task<IActionResult> SetPrimary(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.SetPrimaryAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee relationship set as primary successfully.");
    }
}
