using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/definitions/{definitionId}/steps")]
[GatewayOnly]
public class WorkflowStepsController : ControllerBase
{
    private readonly IWorkflowStepService _service;

    public WorkflowStepsController(IWorkflowStepService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(int definitionId, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int definitionId, int id, CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Create(int definitionId, CreateWorkflowStepRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int definitionId, int id, UpdateWorkflowStepRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(int definitionId, int id, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/reorder")]
    public async Task<IActionResult> Reorder(int definitionId, int id, ReorderStepRequest request, CancellationToken cancellationToken) => Ok();
}
