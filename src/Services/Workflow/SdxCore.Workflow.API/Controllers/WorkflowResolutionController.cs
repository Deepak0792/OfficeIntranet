using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/resolve")]
[GatewayOnly]
public class WorkflowResolutionController(IWorkflowResolutionService svc) : ControllerBase
{
    /// <summary>
    /// POST /api/v1/workflow/resolve/approvers
    /// Preview approver resolution for a step + initiator (dry-run).
    /// </summary>
    [HttpPost("approvers")]
    public async Task<IActionResult> PreviewApprovers([FromBody] PreviewApproversRequest request)
    {
        var data = await svc.PreviewApproversAsync(request);
        return Ok(new ApiResponse<IEnumerable<PreviewApproversResponse>>(data, "Approvers resolved."));
    }

    /// <summary>
    /// GET /api/v1/workflow/resolve/definition
    /// ?moduleCode=LEAVE_REQUEST&amp;employeeId=5&amp;effectiveDate=2025-04-01
    /// </summary>
    [HttpGet("definition")]
    public async Task<IActionResult> ResolveDefinition(
        [FromQuery] string moduleCode,
        [FromQuery] int employeeId,
        [FromQuery] DateOnly? effectiveDate)
    {
        var data = await svc.ResolveDefinitionAsync(moduleCode, employeeId, effectiveDate);
        return Ok(new ApiResponse<ResolveDefinitionResponse>(data, "Approvers resolved."));
    }
}