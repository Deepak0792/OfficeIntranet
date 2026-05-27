using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/assignments")]
[GatewayOnly]
public class WorkflowAssignmentsController : ControllerBase
{
    private readonly IWorkflowAssignmentService _service;

    public WorkflowAssignmentsController(IWorkflowAssignmentService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("by-definition/{definitionId}")]
    public async Task<IActionResult> GetByDefinitionId(int definitionId, CancellationToken cancellationToken) => Ok();

    [HttpGet("resolve")]
    public async Task<IActionResult> Resolve([FromQuery] string moduleCode, [FromQuery] int employeeId, [FromQuery] string? effectiveDate, CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Create(CreateWorkflowAssignmentRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, UpdateWorkflowAssignmentRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(int id, CancellationToken cancellationToken) => Ok();
}
