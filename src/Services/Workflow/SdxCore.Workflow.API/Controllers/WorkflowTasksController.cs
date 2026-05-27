using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/tasks")]
[GatewayOnly]
public class WorkflowTasksController : ControllerBase
{
    private readonly IWorkflowTaskService _service;

    public WorkflowTasksController(IWorkflowTaskService service)
    {
        _service = service;
    }

    [HttpGet("my-pending")]
    public async Task<IActionResult> GetMyPending([FromQuery] string? moduleCode, [FromQuery] int page, [FromQuery] int pageSize, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/approve")]
    public async Task<IActionResult> Approve(int id, ApproveTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/reject")]
    public async Task<IActionResult> Reject(int id, RejectTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/delegate")]
    public async Task<IActionResult> Delegate(int id, DelegateTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/return")]
    public async Task<IActionResult> Return(int id, ReturnTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/reassign")]
    public async Task<IActionResult> Reassign(int id, ReassignTaskRequest request, CancellationToken cancellationToken) => Ok();
}
