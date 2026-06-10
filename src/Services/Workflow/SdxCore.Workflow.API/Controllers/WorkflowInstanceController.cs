using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.SharedKernel.Contracts;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/instances")]
[GatewayOnly]
public class WorkflowInstanceController(
    IWorkflowInstanceService workflowInstanceService,
    IUserContext requestContext) : ControllerBase
{
    /// <summary>
    /// Query params: moduleCode, status, initiatedBy, fromDate, toDate, page, pageSize
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetPaged(
        [FromQuery] string? moduleCode,
        [FromQuery] string? status,
        [FromQuery] Guid? initiatedBy,
        [FromQuery] DateTime? fromDate,
        [FromQuery] DateTime? toDate,
        [FromQuery] PaginationFilter filter,
        CancellationToken cancellationToken)
    {
        var data = await workflowInstanceService.GetPagedAsync(filter, moduleCode, status, initiatedBy, fromDate, toDate, cancellationToken);
        data.Message = "Successfully fetched workflow instance details.";
        return Ok(data);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var data = await workflowInstanceService.GetByIdAsync(id, cancellationToken);
        return Ok(new ApiResponse<WorkflowInstanceDetailResponse>(data, "Successfully fetched workflow instance details."));
    }

    [HttpGet("{id:guid}/tasks")]
    public async Task<IActionResult> GetTasks(Guid id, CancellationToken cancellationToken)
    {
        var data = await workflowInstanceService.GetTasksAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowTaskResponse>>(data, "Successfully fetched task information."));
    }

    /// <summary>GET /api/v1/workflow/instances/{id}/history</summary>
    [HttpGet("{id:guid}/history")]
    public async Task<IActionResult> GetHistory(Guid id, CancellationToken cancellationToken)
    {
        var data = await workflowInstanceService.GetHistoryAsync(id, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowActionHistoryResponse>>(data, "Successfully fetched instances history."));
    }

    /// <summary>
    /// GET /api/v1/workflow/instances/by-transaction
    /// ?moduleCode=LEAVE_REQUEST&amp;referenceTransactionId=501
    /// </summary>
    [HttpGet("by-transaction")]
    public async Task<IActionResult> GetByTransaction(
        [FromQuery] string moduleCode,
        [FromQuery] Guid referenceTransactionId, CancellationToken cancellationToken)
    {
        var data = await workflowInstanceService.GetByTransactionAsync(moduleCode, referenceTransactionId, cancellationToken);
        return Ok(new ApiResponse<WorkflowInstanceResponse>(data, "Successfully fetched instance."));
    }

    /// <summary>GET /api/v1/workflow/instances/my-submissions</summary>
    [HttpGet("my-submissions")]
    public async Task<IActionResult> GetMySubmissions(CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        var data = await workflowInstanceService.GetMySubmissionsAsync(userId, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowInstanceResponse>>(data, "Successfully fetched instances."));
    }

    /// <summary>
    /// POST /api/v1/workflow/instances
    /// Submit a new transaction to the workflow engine.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] SubmitWorkflowInstanceRequest request, CancellationToken cancellationToken)
    {
        var data = await workflowInstanceService.CreateAsync(request, cancellationToken);
        return Ok(new ApiResponse<WorkflowInstanceResponse>(data, "Workflow instance created successfully."));
    }

    /// <summary>PATCH /api/v1/workflow/instances/{id}/cancel</summary>
    [HttpPatch("{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id, [FromBody] WorkflowActionRequest request, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        await workflowInstanceService.CancelAsync(id, userId, request.Remarks, cancellationToken);
        return Ok(new ApiResponse<bool>(true, "Workflow instance cancelled."));
    }

    /// <summary>PATCH /api/v1/workflow/instances/{id}/withdraw</summary>
    [HttpPatch("{id:guid}/withdraw")]
    public async Task<IActionResult> Withdraw(Guid id, [FromBody] WorkflowActionRequest request, CancellationToken cancellationToken)
    {
        Guid userId = requestContext.UserId ?? throw new InvalidOperationException("UserId is not available.");
        await workflowInstanceService.WithdrawAsync(id, userId, request.Remarks, cancellationToken);
        return Ok(new ApiResponse<bool>(true, "Workflow instance withdrawn."));
    }
}