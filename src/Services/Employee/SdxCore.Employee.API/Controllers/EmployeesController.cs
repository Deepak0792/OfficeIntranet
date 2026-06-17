using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.Employee.Request;
using SdxCore.Employee.Application.DTOs.Employee.Response;

namespace SdxCore.Employee.API.Controllers;

[ApiController]
[Route("api/v1/employees")]
[GatewayOnly]
public class EmployeesController(IEmployeeService service) : SdxControllerBase
{
    protected override ErrorResponse NotFoundError =>
        new() { ErrorCode = "NOT_FOUND", ErrorMessage = "Employee not found." };

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] PaginationFilter filter,
        [FromQuery] Guid? departmentId,
        [FromQuery] Guid? locationId,
        [FromQuery] Guid? legalEntityId,
        [FromQuery] string? employmentType,
        [FromQuery] bool? isActive,
        CancellationToken cancellationToken)
    {
        var response = await service.GetAllAsync(filter, departmentId, locationId, legalEntityId, employmentType, isActive, cancellationToken);
        response.Message = "Successfully fetched employees.";
        return Ok(response);
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetAllEmployees(
    [FromQuery] bool isActive = true,
    CancellationToken cancellationToken = default!)
    {
        var result = await service.GetAllEmployeesAsync(isActive, cancellationToken);

        return Ok(new ApiResponse<IReadOnlyList<EmployeeSummaryResponse>>(
            result,
            "Active employees fetched."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateEmployeeRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetSummary), new { id = result.Id },
            new ApiResponse<EmployeeResponse>(result, "Employee created successfully."));
    }

    [HttpGet("{id:guid}/full-profile")]
    public async Task<IActionResult> GetFullProfile(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.GetFullProfileAsync(id, cancellationToken);
        return OkOrNotFound(result, "Profile fetched successfully.");
    }

    [HttpGet("by-code/{code}")]
    public async Task<IActionResult> GetByCode(string code, CancellationToken cancellationToken)
    {
        var result = await service.GetByCodeAsync(code, cancellationToken);
        return OkOrNotFound(result, "Employee fetched successfully.");
    }

    [HttpGet("by-email")]
    public async Task<IActionResult> GetByEmail([FromQuery] string email, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(email))
            return BadRequest(new ErrorResponse { ErrorCode = "BAD_REQUEST", ErrorMessage = "Email is required." });

        var result = await service.GetByEmailAsync(email, cancellationToken);
        return OkOrNotFound(result, "Employee fetched successfully.");
    }

    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string q, [FromQuery] PaginationFilter filter, CancellationToken cancellationToken)
    {
        var response = await service.SearchAsync(q, filter, cancellationToken);
        response.Message = "Search results fetched successfully.";
        return Ok(response);
    }

    [HttpGet("{id:guid}/summary")]
    public async Task<IActionResult> GetSummary(Guid id, CancellationToken cancellationToken)
    {
        var result = await service.GetSummaryAsync(id, cancellationToken);
        return OkOrNotFound(result, "Summary fetched successfully.");
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateEmployeeRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.UpdateAsync(id, request, cancellationToken);
        return OkOrNotFound(result, "Employee updated successfully.");
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] UpdateEmployeeStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.ToggleStatusAsync(id, request, cancellationToken);
        return OkOrNotFound(result, "Status updated successfully.");
    }

    [HttpPatch("{id:guid}/photo")]
    public async Task<IActionResult> UpdatePhoto(Guid id, [FromBody] UpdateEmployeePhotoRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.UpdatePhotoAsync(id, request, cancellationToken);
        return OkOrNotFound(result, "Photo updated successfully.");
    }

    [HttpPatch("{id:guid}/about")]
    public async Task<IActionResult> UpdateAbout(Guid id, [FromBody] UpdateEmployeeAboutRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var result = await service.UpdateAboutAsync(id, request, cancellationToken);
        return OkOrNotFound(result, "About info updated successfully.");
    }

    /// <summary>
    /// GET /api/v1/employees/by-designation
    ///
    /// Returns employees matching given designation(s), optionally scoped.
    /// Called internally by the Workflow engine's approver resolver.
    ///
    /// Examples:
    ///   /by-designation?designationIds=5                      all HODs company-wide
    ///   /by-designation?designationIds=5&scopeTypeId=5&scopeReferenceId=7 HODs in Dept 7
    ///   /by-designation?designationIds=3&designationIds=5&scopeTypeId=4&scopeReferenceId=2 multi-designation, Office 2
    /// </summary>
    [HttpGet("by-designation")]
    public async Task<IActionResult> GetByDesignation(
        [FromQuery] List<Guid> designationIds,
        [FromQuery] string? scopeCode,
        [FromQuery] Guid? scopeReferenceId,
        CancellationToken cancellationToken)
    {
        if (designationIds is null || designationIds.Count == 0)
            return BadRequest(new ErrorResponse
            {
                ErrorCode = "BAD_REQUEST",
                ErrorMessage = "At least one designationId is required."
            });

        var result = await service.GetEmployeesByDesignationInScopeAsync(
            designationIds, scopeCode, scopeReferenceId, cancellationToken);

        return Ok(new ApiResponse<IEnumerable<EmployeesByDesignationResponse>>(
            result, "Employees fetched successfully."));
    }
}