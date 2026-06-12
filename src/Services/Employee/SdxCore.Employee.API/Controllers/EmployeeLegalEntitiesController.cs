using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.Employee.Request;
using SdxCore.Employee.Application.DTOs.EmployeeLegalEntity.Request;
using SdxCore.Employee.Application.DTOs.EmployeeLegalEntity.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[Route("api/v1/employees/{employeeId:guid}/legal-entities")]
[GatewayOnly]
public class EmployeeLegalEntitiesController : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Employee legal entity not found." };

    private readonly IEmployeeLegalEntityService _service;

    public EmployeeLegalEntitiesController(IEmployeeLegalEntityService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetByEmployeeId(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<EmployeeLegalEntityResponse>>(result));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee legal entity retrieved successfully.");
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid employeeId, [FromBody] CreateEmployeeLegalEntityRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.AddAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id },
            new ApiResponse<EmployeeLegalEntityResponse>(result, "Employee legal entity added successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid employeeId, Guid id, [FromBody] UpdateEmployeeLegalEntityRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeLegalEntityResponse>(result, "Employee legal entity updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid employeeId, Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Employee legal entity status updated successfully.");
    }

    [HttpPatch("{id:guid}/set-primary")]
    public async Task<IActionResult> SetPrimary(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.SetPrimaryAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee legal entity set as primary successfully.");
    }
}
