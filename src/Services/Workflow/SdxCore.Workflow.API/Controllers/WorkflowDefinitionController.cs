using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/definition")]
[GatewayOnly]
public class WorkflowDefinitionController(IWorkflowDefinitionService svc) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetPaged([FromQuery] PaginationFilter filter, CancellationToken cancellationToken)
    {
        var data = await svc.GetPagedAsync(filter, cancellationToken);
        data.Message = "Successfully fetched workflow definitions.";
        return Ok(data);
    }

    [HttpGet("{id:short}")]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        var data = await svc.GetByIdAsync(id, cancellationToken);
        return Ok(new ApiResponse<WorkflowDefinitionResponse>(data, "Successfully fetched workflow definition."));
    }

    [HttpGet("by-code/{workflowCode}")]
    public async Task<IActionResult> GetByCode(string workflowCode, CancellationToken cancellationToken)
    {
        var data = await svc.GetByCodeAsync(workflowCode, cancellationToken);
        return Ok(new ApiResponse<WorkflowDefinitionResponse>(data, "Successfully fetched workflow definition."));
    }

    [HttpGet("by-module/{moduleId:short}")]
    public async Task<IActionResult> GetByModule(short moduleId, CancellationToken cancellationToken)
    {
        var data = await svc.GetByModuleIdAsync(moduleId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowDefinitionResponse>>(data, "Successfully fetched workflow definitions."));
    }

    [HttpGet("{id:short}/steps")]
    public async Task<IActionResult> GetWithSteps(short id, CancellationToken cancellationToken)
    {
        var data = await svc.GetWithStepsAsync(id, cancellationToken);
        return Ok(new ApiResponse<WorkflowDefinitionWithStepsResponse>(data, "Successfully fetched workflow step."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWorkflowDefinitionRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.CreateAsync(request, cancellationToken);
        return Ok(new ApiResponse<WorkflowDefinitionResponse>(data, "Workflow definition created successfully."));
    }

    [HttpPut("{id:short}")]
    public async Task<IActionResult> Update(short id, [FromBody] UpdateWorkflowDefinitionRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.UpdateAsync(id, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowDefinitionResponse>(data, "Workflow definition updated successfully."));
    }

    [HttpPatch("{id:short}/status")]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await svc.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Workflow definition not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Workflow definition {statusStr} successfully."));
    }
}