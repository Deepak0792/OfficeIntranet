using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.SharedKernel.Contracts;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;


[ApiController]
[Route("api/v1/workflow/tasks")]
[GatewayOnly]
public class WorkflowTaskController(
    IWorkflowTaskService svc,
    IRequestContext requestContext) : ControllerBase
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
        int userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.GetMyPendingAsync(userId, moduleCode, filter, cancellationToken);
        data.Message = "Successfully fetched my pending tasks.";
        return Ok(data);
    }

    /// <summary>GET /api/v1/workflow/tasks/{id}</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken)
    {
        int userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.GetByIdAsync(id, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully fetched workflow definition."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/approve</summary>
    [HttpPatch("{id:int}/approve")]
    public async Task<IActionResult> Approve(int id, [FromBody] ApproveTaskRequest request, CancellationToken cancellationToken)
    {
        int userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.ApproveAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task approved."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/reject</summary>
    [HttpPatch("{id:int}/reject")]
    public async Task<IActionResult> Reject(int id, [FromBody] RejectTaskRequest request, CancellationToken cancellationToken)
    {
        int userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.RejectAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task rejected."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/delegate</summary>
    [HttpPatch("{id:int}/delegate")]
    public async Task<IActionResult> Delegate(int id, [FromBody] DelegateTaskRequest request, CancellationToken cancellationToken)
    {
        int userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.DelegateAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task delegated."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/return</summary>
    [HttpPatch("{id:int}/return")]
    public async Task<IActionResult> Return(int id, [FromBody] ReturnTaskRequest request, CancellationToken cancellationToken)
    {
        int userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.ReturnAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task returned for clarification."));
    }

    /// <summary>PATCH /api/v1/workflow/tasks/{id}/reassign</summary>
    [HttpPatch("{id:int}/reassign")]
    public async Task<IActionResult> Reassign(int id, [FromBody] ReassignTaskRequest request, CancellationToken cancellationToken)
    {
        int userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await svc.ReassignAsync(id, userId, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowTaskResponse>(data, "Successfully task reassigned."));
    }
}