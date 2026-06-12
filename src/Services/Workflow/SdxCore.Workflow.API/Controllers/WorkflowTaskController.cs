using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.SharedKernel.Abstractions;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Task.Request;
using SdxCore.Workflow.Application.DTOs.Task.Response;

namespace SdxCore.Workflow.API.Controllers;


[ApiController]
[Route("api/v1/workflow/tasks")]
[GatewayOnly]
public class WorkflowTaskController(
    IWorkflowTaskService svc,
    IUserContext requestContext) : SdxControllerBase
{
    /// <summary>
    /// GET /api/v1/workflow/tasks/my-pending
    /// Approver inbox â€” most frequently called endpoint.
    /// </summary>
    [HttpGet("my-pending")]
    public async Task<IActionResult> GetMyPending(
        [FromQuery] string? moduleCode,
        [FromQuery] PaginationFilter filter, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.GetMyPendingAsync(userId, moduleCode, filter, cancellationToken);
        data.Message = "Successfully fetched my pending tasks.";
        return Ok(data);
    }

    /// <summary>GET /api/v1/workflow/tasks/{id}</summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.GetByIdAsync(id, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully fetched workflow definition."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/approve</summary>
    [HttpPatch("{id:guid}/approve")]
    public async Task<IActionResult> Approve(Guid id, [FromBody] ApproveTaskRequest request, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.ApproveAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task approved."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/reject</summary>
    [HttpPatch("{id:guid}/reject")]
    public async Task<IActionResult> Reject(Guid id, [FromBody] RejectTaskRequest request, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.RejectAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task rejected."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/delegate</summary>
    [HttpPatch("{id:guid}/delegate")]
    public async Task<IActionResult> Delegate(Guid id, [FromBody] DelegateTaskRequest request, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.DelegateAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task delegated."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/return</summary>
    [HttpPatch("{id:guid}/return")]
    public async Task<IActionResult> Return(Guid id, [FromBody] ReturnTaskRequest request, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.ReturnAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task returned for clarification."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/reassign</summary>
    [HttpPatch("{id:guid}/reassign")]
    public async Task<IActionResult> Reassign(Guid id, [FromBody] ReassignTaskRequest request, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.ReassignAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task reassigned."));
    }
}
