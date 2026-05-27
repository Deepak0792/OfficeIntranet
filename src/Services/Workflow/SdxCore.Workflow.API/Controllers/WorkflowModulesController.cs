using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Security;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/modules")]
[GatewayOnly]
public class WorkflowModulesController : ControllerBase
{
    private readonly IWorkflowModuleService _service;

    public WorkflowModulesController(IWorkflowModuleService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("by-code/{moduleCode}")]
    public async Task<IActionResult> GetByCode(string moduleCode, CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Create(CreateWorkflowModuleRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, UpdateWorkflowModuleRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(int id, CancellationToken cancellationToken) => Ok();
}
