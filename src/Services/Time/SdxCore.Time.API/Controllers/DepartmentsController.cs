using SdxCore.Common.Controllers;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Time.Application.DTOs.Department.Request;
using SdxCore.Time.Application.DTOs.Department.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Application.Abstractions.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/departments")]
[GatewayOnly]
public class DepartmentsController : SdxControllerBase
{
    private readonly IDepartmentService _departmentService;
    private readonly ILogger<DepartmentsController> _logger;

    public DepartmentsController(IDepartmentService departmentService, ILogger<DepartmentsController> logger)
    {
        _departmentService = departmentService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Departments."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });

        return Ok(new ApiResponse<DepartmentResponse>(result, "Successfully fetched Department."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDepartmentRequest dto, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var result = await _departmentService.CreateAsync(dto, cancellationToken);
        var response = new ApiResponse<DepartmentResponse>(result, "Department created successfully.");

        return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateDepartmentRequest dto, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(dto, cancellationToken);
        if (validation != null) return validation;

        var updated = await _departmentService.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });

        return Ok(new ApiResponse<bool>(true, "Department updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var validation = await ValidateAsync(request, cancellationToken);
        if (validation != null) return validation;

        var updated = await _departmentService.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Department {statusStr} successfully."));
    }

    [HttpGet("tree")]
    public async Task<IActionResult> GetTree(CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetTreeAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Department list."));
    }

    [HttpGet("{id:guid}/children")]
    public async Task<IActionResult> GetChildren(Guid id, CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetChildrenAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Department list."));
    }

    [HttpGet("{id:guid}/ancestors")]
    public async Task<IActionResult> GetAncestors(Guid id, CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetAncestorsAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Department list."));
    }

    [HttpPatch("{id:guid}/parent")]
    public async Task<IActionResult> UpdateParent(Guid id, [FromBody] UpdateParentRequest request, CancellationToken cancellationToken)
    {
        var updated = await _departmentService.UpdateParentAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });
        return Ok(new ApiResponse<bool>(true, "Department parent updated successfully."));
    }
}