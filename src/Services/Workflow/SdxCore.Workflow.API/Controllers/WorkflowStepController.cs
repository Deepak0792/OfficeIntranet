using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;


[ApiController]
[Route("api/v1/workflow/definitions/{definitionId:guid}/steps")]
[GatewayOnly]
public class WorkflowStepController(IWorkflowStepService svc) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(Guid definitionId, CancellationToken cancellationToken)
    {
        var data = await svc.GetByDefinitionIdAsync(definitionId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowStepResponse>>(data, "Successfully fetched workflow steps."));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid definitionId, Guid id, CancellationToken cancellationToken)
    {
        var data = await svc.GetByIdAsync(definitionId, id, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepResponse>(data, "Successfully fetched workflow step."));
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid definitionId,
        [FromBody] CreateWorkflowStepRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.CreateAsync(definitionId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepResponse>(data, "Workflow step created successfully."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid definitionId, Guid id,
        [FromBody] UpdateWorkflowStepRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.UpdateAsync(definitionId, id, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepResponse>(data, "Workflow step updated successfully."));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> ToggleStatus(Guid definitionId, Guid id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await svc.ToggleStatusAsync(definitionId, id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Workflow definition not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Workflow step {statusStr} successfully."));
    }

    [HttpPatch("{id:guid}/reorder")]
    public async Task<IActionResult> Reorder(Guid definitionId, Guid id,
        [FromBody] ReorderWorkflowStepRequest request, CancellationToken cancellationToken)
    {
        var result = await svc.ReorderAsync(definitionId, id, request, cancellationToken);
        return Ok(new ApiResponse<bool>(result, "Workflow step reordered successfully."));
    }
}