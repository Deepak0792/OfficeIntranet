using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/module")]
[GatewayOnly]
public class WorkflowModuleController(IWorkflowModuleService svc) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool activeOnly = true, CancellationToken cancellationToken = default)
    {
        var data = await svc.GetAllAsync(activeOnly, cancellationToken);
        return Ok(new ApiResponse<IEnumerable<WorkflowModuleResponse>>(data, "Successfully fetched Workflow modules."));
    }

    [HttpGet("{id:short}")]
    public async Task<IActionResult> GetById(short id, CancellationToken cancellationToken)
    {
        var data = await svc.GetByIdAsync(id, cancellationToken);
        return Ok(new ApiResponse<WorkflowModuleResponse>(data, "Successfully fetched workflow module."));
    }

    [HttpGet("by-code/{moduleCode}")]
    public async Task<IActionResult> GetByCode(string moduleCode, CancellationToken cancellationToken)
    {
        var data = await svc.GetByCodeAsync(moduleCode, cancellationToken);
        return Ok(new ApiResponse<WorkflowModuleResponse>(data, "Successfully fetched workflow module."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWorkflowModuleRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.CreateAsync(request, cancellationToken);
        return Ok(new ApiResponse<WorkflowModuleResponse>(data, "Workflow module created successfully."));
    }

    [HttpPut("{id:short}")]
    public async Task<IActionResult> Update(short id, [FromBody] UpdateWorkflowModuleRequest request, CancellationToken cancellationToken)
    {
        var data = await svc.UpdateAsync(id, request, cancellationToken);
        return Ok(new ApiResponse<WorkflowModuleResponse>(data, "Workflow module updated successfully."));
    }

    [HttpPatch("{id:short}/status")]
    public async Task<IActionResult> ToggleStatus(short id, [FromBody] ToggleStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await svc.ToggleStatusAsync(id, request, cancellationToken);
        if (!updated) return NotFound(new ErrorResponse { ErrorCode = "NOT_FOUND", ErrorMessage = "Workflow definition not found." });

        var statusStr = request.IsActive ? "activated" : "deactivated";
        return Ok(new ApiResponse<bool>(true, $"Workflow module {statusStr} successfully."));
    }
}