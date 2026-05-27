using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/instances")]
[GatewayOnly]
public class WorkflowInstancesController : ControllerBase
{
    private readonly IWorkflowInstanceService _service;

    public WorkflowInstancesController(IWorkflowInstanceService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? moduleCode, [FromQuery] string? status, [FromQuery] int? initiatedBy, [FromQuery] string? fromDate, [FromQuery] string? toDate, [FromQuery] int page, [FromQuery] int pageSize, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}/tasks")]
    public async Task<IActionResult> GetTasks(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}/history")]
    public async Task<IActionResult> GetHistory(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("by-transaction")]
    public async Task<IActionResult> GetByTransaction([FromQuery] string moduleCode, [FromQuery] int referenceTransactionId, CancellationToken cancellationToken) => Ok();

    [HttpGet("my-submissions")]
    public async Task<IActionResult> GetMySubmissions(CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Submit(SubmitWorkflowInstanceRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/cancel")]
    public async Task<IActionResult> Cancel(int id, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/withdraw")]
    public async Task<IActionResult> Withdraw(int id, CancellationToken cancellationToken) => Ok();
}
