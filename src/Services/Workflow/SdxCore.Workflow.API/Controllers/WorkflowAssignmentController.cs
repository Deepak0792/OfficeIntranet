using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/assignments")]
[GatewayOnly]
public class WorkflowAssignmentController : ControllerBase
{

    private readonly IWorkflowAssignmentService _workflowAssignmentService;

    public WorkflowAssignmentController(IWorkflowAssignmentService workflowAssignmentService)
    {
        this._workflowAssignmentService = workflowAssignmentService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var data = await _workflowAssignmentService.GetAllAsync(cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowAssignmentResponse>>(data, "Successfully fetched workflow assignments."));
    }

    [HttpGet("{id:short}")]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        var data = await _workflowAssignmentService.GetByIdAsync(id, cancellationToken);
        return Ok(new ApiResponse<WorkflowAssignmentResponse>(data, "Successfully fetched workflow assignment."));
    }

    [HttpGet("by-definition/{definitionId:short}")]
    public async Task<IActionResult> GetByDefinition(short definitionId, CancellationToken cancellationToken)
    {
        var data = await _workflowAssignmentService.GetByDefinitionIdAsync(definitionId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowAssignmentResponse>>(data, "Successfully fetched workflow assignments."));
    }

    [HttpGet("resolve")]
    public async Task<IActionResult> Resolve(
        [FromQuery] string moduleCode,
        [FromQuery] int employeeId,
        [FromQuery] DateOnly? effectiveDate, CancellationToken cancellationToken)
    {
        var data = await _workflowAssignmentService.ResolveAsync(moduleCode, employeeId, effectiveDate, cancellationToken);
        return Ok(new ApiResponse<ResolveDefinitionResponse>(data, "Successfully resolved workflow assignment."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWorkflowAssignmentRequest request, CancellationToken cancellationToken)
    {
        var data = await _workflowAssignmentService.CreateAsync(request, cancellationToken);
        return Ok(new ApiResponse<WorkflowAssignmentResponse>(data, "Workflow assignment created successfully."));
    }

    [HttpPut("{id:short}")]
    public async Task<IActionResult> Update(short id,
        [FromBody] UpdateWorkflowAssignmentRequest request, CancellationToken cancellationToken)
    {
        var data = await _workflowAssignmentService.UpdateAsync(id, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowAssignmentResponse>(data, "Workflow assignment updated successfully."));
    }

    [HttpPatch("{id:short}/status")]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await _workflowAssignmentService.ToggleStatusAsync(id, request, cancellationToken);
        
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Workflow assignment not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Workflow assignment {statusStr} successfully."));
    }
}