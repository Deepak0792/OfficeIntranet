using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;


[ApiController]
[Route("api/v1/workflow/step")]
[GatewayOnly]
public class WorkflowStepController(IWorkflowStepService svc) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(short definitionId, CancellationToken cancellationToken)
    {
        var data = await svc.GetByDefinitionIdAsync(definitionId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowStepResponse>>(data, "Successfully fetched workflow steps."));
    }

    [HttpGet("{id:short}")]
    public async Task<IActionResult> GetById(short definitionId, short id, CancellationToken cancellationToken)
    {
        var data = await svc.GetByIdAsync(definitionId, id, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepResponse>(data, "Successfully fetched workflow step."));
    }

    [HttpPost]
    public async Task<IActionResult> Create(short definitionId,
        [FromBody] CreateWorkflowStepRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.CreateAsync(definitionId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepResponse>(data, "Workflow step created successfully."));
    }

    [HttpPut("{id:short}")]
    public async Task<IActionResult> Update(short definitionId, short id,
        [FromBody] UpdateWorkflowStepRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.UpdateAsync(definitionId, id, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepResponse>(data, "Workflow step updated successfully."));
    }

    [HttpPatch("{id:short}/status")]
    public async Task<IActionResult> ToggleStatus(short definitionId, short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await svc.ToggleStatusAsync(definitionId, id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Workflow definition not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Workflow step {statusStr} successfully."));
    }

    [HttpPatch("{id:short}/reorder")]
    public async Task<IActionResult> Reorder(short definitionId, short id,
        [FromBody] ReorderWorkflowStepRequest request, CancellationToken cancellationToken)
    {
        var result = await svc.ReorderAsync(definitionId, id, request, cancellationToken);
        return Ok(new ApiResponse<bool>(result, "Workflow step reordered successfully."));
    }
}