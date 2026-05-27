using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/steps/{stepId}/approvers")]
[GatewayOnly]
public class WorkflowApproversController : ControllerBase
{
    private readonly IWorkflowApproverService _service;

    public WorkflowApproversController(IWorkflowApproverService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(int stepId, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int stepId, int id, CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Create(int stepId, CreateWorkflowStepApproverRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int stepId, int id, UpdateWorkflowStepApproverRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(int stepId, int id, CancellationToken cancellationToken) => Ok();
}
