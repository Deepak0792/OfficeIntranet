using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.Employee.Request;
using SdxCore.Employee.Application.DTOs.EmployeeAddress.Request;
using SdxCore.Employee.Application.DTOs.EmployeeAddress.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[GatewayOnly]
[Route("api/v1/employees/{employeeId:guid}/addresses")]
public class EmployeeAddressesController : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Employee address not found." };

    private readonly IEmployeeAddressService _service;

    public EmployeeAddressesController(IEmployeeAddressService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetByEmployeeId(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<EmployeeAddressResponse>>(result));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee address retrieved successfully.");
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid employeeId, [FromBody] CreateEmployeeAddressRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.CreateAsync(employeeId, request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id },
            new ApiResponse<EmployeeAddressResponse>(result, "Employee address added successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid employeeId, Guid id, [FromBody] UpdateEmployeeAddressRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeAddressResponse>(result, "Employee address updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid employeeId, Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Employee address status updated successfully.");
    }

    [HttpPatch("{id:guid}/set-primary")]
    public async Task<IActionResult> SetPrimary(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.SetPrimaryAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee address set as primary successfully.");
    }
}