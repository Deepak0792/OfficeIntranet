using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/approvers/{approverId}/designations")]
[GatewayOnly]
public class WorkflowDesignationsController : ControllerBase
{
    private readonly IWorkflowDesignationService _service;

    public WorkflowDesignationsController(IWorkflowDesignationService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(int approverId, CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Create(int approverId, CreateApproverDesignationRequest request, CancellationToken cancellationToken) => Ok();

    [HttpDelete("{designationId}")]
    public async Task<IActionResult> Delete(int approverId, int designationId, CancellationToken cancellationToken) => Ok();
}
