$apiDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.API\Controllers"
$appDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Application"
$dtoDir = "$appDir\DTOs"
$ifaceDir = "$appDir\Interfaces\Services"

New-Item -ItemType Directory -Force -Path $dtoDir | Out-Null
New-Item -ItemType Directory -Force -Path $ifaceDir | Out-Null
New-Item -ItemType Directory -Force -Path $apiDir | Out-Null

# 1. Generate DTOs
$dtos = @(
    "WorkflowModuleDto", "CreateWorkflowModuleRequest", "UpdateWorkflowModuleRequest",
    "WorkflowDefinitionDto", "CreateWorkflowDefinitionRequest", "UpdateWorkflowDefinitionRequest",
    "WorkflowStepDto", "CreateWorkflowStepRequest", "UpdateWorkflowStepRequest", "ReorderStepRequest",
    "WorkflowStepApproverDto", "CreateWorkflowStepApproverRequest", "UpdateWorkflowStepApproverRequest",
    "CreateApproverDesignationRequest",
    "WorkflowAssignmentDto", "CreateWorkflowAssignmentRequest", "UpdateWorkflowAssignmentRequest",
    "WorkflowInstanceDto", "SubmitWorkflowInstanceRequest",
    "WorkflowTaskDto", "ApproveTaskRequest", "RejectTaskRequest", "DelegateTaskRequest", "ReturnTaskRequest", "ReassignTaskRequest",
    "WorkflowActionHistoryDto",
    "ResolveApproversPreviewRequest", "ResolveApproversPreviewResponse", "ResolveDefinitionRequest"
)

foreach ($dto in $dtos) {
    $content = @"
namespace SdxCore.Workflow.Application.DTOs;

public class $dto
{
    // Scaffolding stub
}
"@
    Set-Content -Path "$dtoDir\$dto.cs" -Value $content
}

# 2. Generate Interfaces
$interfaces = @(
    "IWorkflowModuleService", "IWorkflowDefinitionService", "IWorkflowStepService",
    "IWorkflowApproverService", "IWorkflowDesignationService", "IWorkflowAssignmentService",
    "IWorkflowInstanceService", "IWorkflowTaskService", "IWorkflowHistoryService"
)

foreach ($iface in $interfaces) {
    $content = @"
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.BuildingBlocks.Contracts.Responses;

namespace SdxCore.Workflow.Application.Interfaces.Services;

public interface $iface
{
    // Scaffolding stub
}
"@
    Set-Content -Path "$ifaceDir\$iface.cs" -Value $content
}

# Update IWorkflowResolutionService
$resolutionService = @"
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.BuildingBlocks.Contracts.Responses;

namespace SdxCore.Workflow.Domain.Interfaces.Services;

public interface IWorkflowResolutionService
{
    Task AdvanceWorkflowAsync(int instanceId, CancellationToken cancellationToken);
    Task<ApiResponse<IEnumerable<ResolveApproversPreviewResponse>>> PreviewApproversAsync(ResolveApproversPreviewRequest request, CancellationToken cancellationToken);
    Task<ApiResponse<int>> ResolveDefinitionAsync(ResolveDefinitionRequest request, CancellationToken cancellationToken);
}
"@
Set-Content -Path "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Domain\Interfaces\Services\IWorkflowResolutionService.cs" -Value $resolutionService -Force

# 3. Generate Controllers
$controllers = @{
    "WorkflowModulesController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
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
"@;

    "WorkflowDefinitionsController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
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
"@;

    "WorkflowStepsController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
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
"@;

    "WorkflowApproversController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
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
"@;

    "WorkflowDesignationsController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
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
"@;

    "WorkflowAssignmentsController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
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
"@;

    "WorkflowInstancesController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/instances")]
[GatewayOnly]
public class WorkflowInstancesController : ControllerBase
{
    private readonly IWorkflowInstanceService _service;

    public WorkflowInstancesController(IWorkflowInstanceService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? moduleCode, [FromQuery] string? status, [FromQuery] int? initiatedBy, [FromQuery] string? fromDate, [FromQuery] string? toDate, [FromQuery] int page, [FromQuery] int pageSize, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}/tasks")]
    public async Task<IActionResult> GetTasks(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}/history")]
    public async Task<IActionResult> GetHistory(int id, CancellationToken cancellationToken) => Ok();

    [HttpGet("by-transaction")]
    public async Task<IActionResult> GetByTransaction([FromQuery] string moduleCode, [FromQuery] int referenceTransactionId, CancellationToken cancellationToken) => Ok();

    [HttpGet("my-submissions")]
    public async Task<IActionResult> GetMySubmissions(CancellationToken cancellationToken) => Ok();

    [HttpPost]
    public async Task<IActionResult> Submit(SubmitWorkflowInstanceRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/cancel")]
    public async Task<IActionResult> Cancel(int id, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/withdraw")]
    public async Task<IActionResult> Withdraw(int id, CancellationToken cancellationToken) => Ok();
}
"@;

    "WorkflowTasksController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/tasks")]
[GatewayOnly]
public class WorkflowTasksController : ControllerBase
{
    private readonly IWorkflowTaskService _service;

    public WorkflowTasksController(IWorkflowTaskService service)
    {
        _service = service;
    }

    [HttpGet("my-pending")]
    public async Task<IActionResult> GetMyPending([FromQuery] string? moduleCode, [FromQuery] int page, [FromQuery] int pageSize, CancellationToken cancellationToken) => Ok();

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/approve")]
    public async Task<IActionResult> Approve(int id, ApproveTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/reject")]
    public async Task<IActionResult> Reject(int id, RejectTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/delegate")]
    public async Task<IActionResult> Delegate(int id, DelegateTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/return")]
    public async Task<IActionResult> Return(int id, ReturnTaskRequest request, CancellationToken cancellationToken) => Ok();

    [HttpPatch("{id}/reassign")]
    public async Task<IActionResult> Reassign(int id, ReassignTaskRequest request, CancellationToken cancellationToken) => Ok();
}
"@;

    "WorkflowActionHistoryController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Application.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow")]
[GatewayOnly]
public class WorkflowActionHistoryController : ControllerBase
{
    private readonly IWorkflowHistoryService _service;

    public WorkflowActionHistoryController(IWorkflowHistoryService service)
    {
        _service = service;
    }

    [HttpGet("instances/{instanceId}/history")]
    public async Task<IActionResult> GetInstanceHistory(int instanceId, CancellationToken cancellationToken) => Ok();

    [HttpGet("tasks/{taskId}/history")]
    public async Task<IActionResult> GetTaskHistory(int taskId, CancellationToken cancellationToken) => Ok();
}
"@;

    "WorkflowResolutionController" = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.BuildingBlocks.API.Attributes;
using SdxCore.BuildingBlocks.Contracts.Responses;
using SdxCore.Workflow.Application.DTOs;
using SdxCore.Workflow.Domain.Interfaces.Services;

namespace SdxCore.Workflow.API.Controllers;

[ApiController]
[Route("api/v1/workflow/resolve")]
[GatewayOnly]
public class WorkflowResolutionController : ControllerBase
{
    private readonly IWorkflowResolutionService _service;

    public WorkflowResolutionController(IWorkflowResolutionService service)
    {
        _service = service;
    }

    [HttpPost("approvers")]
    public async Task<IActionResult> PreviewApprovers(ResolveApproversPreviewRequest request, CancellationToken cancellationToken) => Ok();

    [HttpGet("definition")]
    public async Task<IActionResult> ResolveDefinition([FromQuery] ResolveDefinitionRequest request, CancellationToken cancellationToken) => Ok();
}
"@;
}

foreach ($controller in $controllers.Keys) {
    Set-Content -Path "$apiDir\$controller.cs" -Value $controllers[$controller]
}

# Remove the old WorkflowController
if (Test-Path "$apiDir\WorkflowController.cs") {
    Remove-Item "$apiDir\WorkflowController.cs" -Force
}

Write-Host "Scaffolding complete."
