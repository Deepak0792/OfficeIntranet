using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow")]
[GatewayOnly]
public class WorkflowActionHistoryController : ControllerBase
{
    private readonly IWorkflowHistoryService _service;

    public WorkflowActionHistoryController(IWorkflowHistoryService service)
    {
        _service = service;
    }

    [HttpGet("instances/{instanceId}/history")]
    public async Task<IActionResult> GetInstanceHistory(int instanceId, CancellationToken cancellationToken) => Ok();

    [HttpGet("tasks/{taskId}/history")]
    public async Task<IActionResult> GetTaskHistory(int taskId, CancellationToken cancellationToken) => Ok();
}
