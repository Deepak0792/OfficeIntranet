using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using SdxCore.Time.Application.Services;
using SdxCore.Time.Domain.Interfaces.Services;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using System;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/departments")]
[GatewayOnly]
public class DepartmentsController : ControllerBase
{
    private readonly IDepartmentService _departmentService;
    private readonly ILogger<DepartmentsController> _logger;

    public DepartmentsController(IDepartmentService departmentService, ILogger<DepartmentsController> logger)
    {
        _departmentService = departmentService;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<DepartmentResponse>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _departmentService.GetAllAsync(cancellationToken);
            return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Departments."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching all departments");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DEPARTMENT_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<DepartmentResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _departmentService.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });
            
            return Ok(new ApiResponse<DepartmentResponse>(result, "Successfully fetched Department."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching department with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DEPARTMENT_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<DepartmentResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] CreateDepartmentRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _departmentService.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<DepartmentResponse>(result, "Department created successfully.");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while creating department");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DEPARTMENT_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Update(short id, [FromBody] UpdateDepartmentRequest dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _departmentService.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });
            
            return Ok(new ApiResponse<bool>(true, "Department updated successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while updating department with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DEPARTMENT_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpPatch("{id}/status")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _departmentService.ToggleStatusAsync(id, request, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });
            
            var statusStr = request.IsActive ? "activated" : "deactivated";
            return Ok(new ApiResponse<bool>(true, $"Department {statusStr} successfully."));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while toggling status for department with ID {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DEPARTMENT_ERROR",
                ErrorMessage = "An unexpected error occurred while processing the request."
            });
        }
    }

    [HttpGet("tree")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<DepartmentResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetTree(CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetTreeAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Department list."));
    }

    [HttpGet("{id}/children")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<DepartmentResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetChildren(short id, CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetChildrenAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Department list."));
    }

    [HttpGet("{id}/ancestors")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<DepartmentResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAncestors(short id, CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetAncestorsAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<DepartmentResponse>>(result, "Successfully fetched Department list."));
    }

    [HttpPatch("{id}/parent")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateParent(short id, [FromBody] UpdateParentRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var updated = await _departmentService.UpdateParentAsync(id, request, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Department not found." });
            return Ok(new ApiResponse<bool>(true, "Department parent updated successfully."));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new ErrorResponse { ErrorCode = "INVALID_PARENT", ErrorMessage = ex.Message });
        }
    }
}



