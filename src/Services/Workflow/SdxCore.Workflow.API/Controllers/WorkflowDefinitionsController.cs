using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/definitions")]
[GatewayOnly]
public class WorkflowDefinitionsController : ControllerBase
{
    private readonly IWorkflowDefinitionService _service;

    public WorkflowDefinitionsController(IWorkflowDefinitionService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int page, [FromQuery] int pageSize, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("by-module/{moduleId}")]
    public async Task<IActionResult> GetByModuleId(int moduleId, CancellationToken cancellationToken) => Ok();

    [HttpGet("by-code/{workflowCode}")]
    public async Task<IActionResult> GetByCode(string workflowCode, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}/steps")]
    public async Task<IActionResult> GetSteps(int id, CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Create(CreateWorkflowDefinitionRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, UpdateWorkflowDefinitionRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(int id, CancellationToken cancellationToken) => Ok();
}
