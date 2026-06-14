using SdxCore.Common.Controllers;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security.Attributes;
using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Resolution.Request;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;
using SdxCore.Workflow.Application.Abstractions.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/resolve")]
[GatewayOnly]
public class WorkflowResolutionController(IWorkflowResolutionService workflowResolutionService) : SdxControllerBase
{
    /// <summary>
    /// POST /api/v1/workflow/resolve/approvers
    /// Preview approver resolution for a step + initiator (dry-run).
    /// </summary>
    [HttpPost("approvers")]
    public async Task<IActionResult> PreviewApprovers([FromBody] PreviewApproversRequest request, CancellationToken cancellationToken)
    {
        var data = await workflowResolutionService.PreviewApproversAsync(request);
        return Ok(new ApiResponse<IEnumerable<PreviewApproversResponse>>(data, "Approvers resolved."));
    }

    /// <summary>
    /// GET /api/v1/workflow/resolve/definition
    /// ?moduleCode=LEAVE_REQUEST&amp;employeeId=5&amp;effectiveDate=2025-04-01
    /// </summary>
    [HttpGet("definition")]
    public async Task<IActionResult> ResolveDefinition(
        [FromQuery] string moduleCode,
         [FromQuery] string workflowCode,
        [FromQuery] Guid employeeId,
        [FromQuery] DateOnly? effectiveDate, CancellationToken cancellationToken)
    {
        var data = await workflowResolutionService.ResolveDefinitionByEffectiveDateAsync(moduleCode, workflowCode, employeeId, effectiveDate, cancellationToken);
        return Ok(new ApiResponse<WorkflowDefinitionResponse>(data, "Approvers resolved."));
    }
}