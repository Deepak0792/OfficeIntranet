using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Domain.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/resolve")]
[GatewayOnly]
public class WorkflowResolutionController : ControllerBase
{
    private readonly IWorkflowResolutionService _service;

    public WorkflowResolutionController(IWorkflowResolutionService service)
    {
        _service = service;
    }

    [HttpPost("approvers")]
    public async Task<IActionResult> PreviewApprovers(ResolveApproversPreviewRequest request, CancellationToken cancellationToken) => Ok();

    [HttpGet("definition")]
    public async Task<IActionResult> ResolveDefinition([FromQuery] ResolveDefinitionRequest request, CancellationToken cancellationToken) => Ok();
}
