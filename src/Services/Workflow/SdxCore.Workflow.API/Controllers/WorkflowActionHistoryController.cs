using SdxCore.Common.Controllers;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Workflow.Application.DTOs.ActionHistory.Response;
using SdxCore.Workflow.Application.DTOs.Task.Response;
using SdxCore.Workflow.Application.Abstractions.Services;

namespace SdxCore.Workflow.API.Controllers;


[ApiController]
[Route("api/v1/workflow")]
[GatewayOnly]
public class WorkflowActionHistoryController : SdxControllerBase
{
    private readonly IWorkflowInstanceService _workflowInstanceService;
    private readonly IWorkflowTaskService _workflowTaskService;

    public WorkflowActionHistoryController(IWorkflowInstanceService workflowInstanceService, IWorkflowTaskService workflowTaskService)
    {
        this._workflowInstanceService = workflowInstanceService;
        this._workflowTaskService = workflowTaskService;
    }

    /// <summary>GET /api/v1/workflow/instances/{instanceId}/history</summary>
    [HttpGet("instances/{instanceId:guid}/history")]
    public async Task<IActionResult> GetByInstance(Guid instanceId, CancellationToken cancellationToken)
    {
        var data = await _workflowInstanceService.GetHistoryAsync(instanceId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowActionHistoryResponse>>(data, "Successfully fetched workflow instances."));
    }

    /// <summary>GET /api/v1/workflow/tasks/{taskId}/history</summary>
    [HttpGet("tasks/{taskId:guid}/history")]
    public async Task<IActionResult> GetByTask(Guid taskId, CancellationToken cancellationToken)
    {
        // Task history is retrieved via the task detail
        var task = await _workflowTaskService.GetByIdAsync(taskId, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(task, "Successfully fetched task history."));
    }
}
