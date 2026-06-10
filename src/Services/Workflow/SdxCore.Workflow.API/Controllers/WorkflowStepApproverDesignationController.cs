using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/approvers/{approverId:guid}/designations")]
[GatewayOnly]
public class WorkflowStepApproverDesignationController(IWorkflowStepApproverDesignationService svc) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(Guid approverId)
    {
        var data = await svc.GetByApproverIdAsync(approverId, HttpContext.RequestAborted);
        return Ok(new ApiResponse<IEnumerable<WorkflowStepApproverDesignationResponse>>(data,
            "Successfully fetched workflow step approver designation."));
    }

    [HttpPost]
    public async Task<IActionResult> Add(Guid approverId, [FromBody] AddApproverDesignationRequest request)
    {
        var data = await svc.AddAsync(approverId, request, HttpContext.RequestAborted);
        return Ok(new ApiResponse<WorkflowStepApproverDesignationResponse>(data,
            "Workflow step approver designation mapping added."));
    }

    // Hard DELETE â€” only resource in workflow API that uses DELETE
    [HttpDelete("{designationId:guid}")]
    public async Task<IActionResult> Remove(Guid approverId, Guid designationId)
    {
        var status = await svc.DeleteAsync(approverId, designationId, HttpContext.RequestAborted);
        return Ok(new ApiResponse<bool>(status,
            "Workflow step approver designation mapping removed."));
    }
}