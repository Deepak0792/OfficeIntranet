using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;


[ApiController]
[Route("api/v1/workflow/step-approver")]
[GatewayOnly]
public class WorkflowStepApproverController(IWorkflowStepApproverService svc) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(short stepId, CancellationToken cancellationToken)
    {
        var data = await svc.GetByStepIdAsync(stepId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowStepApproverResponse>>(data, "Successfully fetched workflow approver rules."));
    }

    [HttpGet("{id:short}")]
    public async Task<IActionResult> GetById(short stepId, short id, CancellationToken cancellationToken)
    {
        var data = await svc.GetByIdAsync(stepId, id, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepApproverResponse>(data, "Successfully fetched workflow approver rule."));
    }

    [HttpPost]
    public async Task<IActionResult> Create(short stepId,
        [FromBody] CreateWorkflowStepApproverRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.CreateAsync(stepId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepApproverResponse>(data, "Workflow Approver rule created."));
    }

    [HttpPut("{id:short}")]
    public async Task<IActionResult> Update(short stepId, short id,
        [FromBody] UpdateWorkflowStepApproverRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.UpdateAsync(stepId, id, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowStepApproverResponse>(data, "Workflow Approver rule updated."));
    }

    [HttpPatch("{id:short}/status")]
    public async Task<IActionResult> ToggleStatus(short stepId, short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await svc.ToggleStatusAsync(stepId, id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Workflow definition not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Workflow Approver {statusStr} successfully."));
    }
}