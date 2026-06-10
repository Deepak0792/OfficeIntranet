using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[Route("api/v1/employees/{employeeId:guid}/documents")]
[GatewayOnly]
public class EmployeeDocumentsController : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Employee document not found." };

    private readonly IEmployeeDocumentService _service;

    public EmployeeDocumentsController(IEmployeeDocumentService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetByEmployeeId(Guid employeeId, CancellationToken cancellationToken)
    {
        var result = await _service.GetByEmployeeIdAsync(employeeId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<EmployeeDocumentResponse>>(result));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid employeeId, Guid id, CancellationToken cancellationToken)
    {
        var result = await _service.GetByIdAsync(employeeId, id, cancellationToken);
        return OkOrNotFound(result, "Employee document retrieved successfully.");
    }

    [HttpGet("expiring")]
    public async Task<IActionResult> GetExpiring(Guid employeeId, [FromQuery] int days = 30, CancellationToken cancellationToken = default)
    {
        var result = await _service.GetExpiringAsync(employeeId, days, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<EmployeeDocumentResponse>>(result));
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid employeeId, [FromBody] CreateEmployeeDocumentRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;
        var result = await _service.AddAsync(employeeId, request, cancellationToken);

        return CreatedAtAction(nameof(GetById), new { employeeId, id = result.Id },
            new ApiResponse<EmployeeDocumentResponse>(result, "Employee document added successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid employeeId, Guid id, [FromBody] UpdateEmployeeDocumentRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.UpdateAsync(employeeId, id, request, cancellationToken);
        return Ok(new ApiResponse<EmployeeDocumentResponse>(result, "Employee document updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid employeeId, Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await _service.ToggleStatusAsync(employeeId, id, request.IsActive, cancellationToken);
        return OkOrNotFound(result, "Employee document status updated successfully.");
    }
}
