$domainDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Domain"
$appDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Application"

New-Item -ItemType Directory -Force -Path "$domainDir\Interfaces\Repositories" | Out-Null
New-Item -ItemType Directory -Force -Path "$domainDir\Interfaces\Services" | Out-Null
New-Item -ItemType Directory -Force -Path "$appDir\Services" | Out-Null

$baseRepoCode = @"
using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Interfaces.Repositories;

public interface IBaseRepository<TEntity> where TEntity : BaseEntity
{
    Task<TEntity?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default);
    Task AddAsync(TEntity entity, CancellationToken cancellationToken = default);
    void Update(TEntity entity);
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
"@
Set-Content -Path "$domainDir\Interfaces\Repositories\IBaseRepository.cs" -Value $baseRepoCode

$resIfcCode = @"
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Workflow.Domain.Interfaces.Services;

public interface IWorkflowResolutionService
{
    Task InitiateWorkflowAsync(string moduleCode, int referenceTransactionId, int initiatorEmployeeId, CancellationToken cancellationToken = default);
    Task AdvanceWorkflowAsync(int workflowInstanceId, CancellationToken cancellationToken = default);
}
"@
Set-Content -Path "$domainDir\Interfaces\Services\IWorkflowResolutionService.cs" -Value $resIfcCode

$resImplCode = @"
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Interfaces.Repositories;
using SdxCore.Workflow.Domain.Interfaces.Services;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowResolutionService : IWorkflowResolutionService
{
    private readonly IBaseRepository<WorkflowModule> _moduleRepository;
    private readonly IBaseRepository<WorkflowDefinition> _definitionRepository;
    private readonly IBaseRepository<WorkflowInstance> _instanceRepository;
    private readonly IBaseRepository<WorkflowTask> _taskRepository;
    private readonly ILogger<WorkflowResolutionService> _logger;

    public WorkflowResolutionService(
        IBaseRepository<WorkflowModule> moduleRepository,
        IBaseRepository<WorkflowDefinition> definitionRepository,
        IBaseRepository<WorkflowInstance> instanceRepository,
        IBaseRepository<WorkflowTask> taskRepository,
        ILogger<WorkflowResolutionService> logger)
    {
        _moduleRepository = moduleRepository;
        _definitionRepository = definitionRepository;
        _instanceRepository = instanceRepository;
        _taskRepository = taskRepository;
        _logger = logger;
    }

    public async Task InitiateWorkflowAsync(string moduleCode, int referenceTransactionId, int initiatorEmployeeId, CancellationToken cancellationToken = default)
    {
        var modules = await _moduleRepository.FindAsync(m => m.ModuleCode == moduleCode, cancellationToken);
        var module = modules.FirstOrDefault();
        
        if (module == null)
        {
            _logger.LogWarning("Module {ModuleCode} not found.", moduleCode);
            return;
        }

        var definitions = await _definitionRepository.FindAsync(d => d.WorkflowModuleId == module.Id && d.IsActive, cancellationToken);
        var definition = definitions.FirstOrDefault();

        if (definition == null)
        {
            _logger.LogWarning("Active Workflow Definition for module {ModuleCode} not found.", moduleCode);
            return;
        }

        // Create Instance
        var instance = new WorkflowInstance
        {
            WorkflowDefinitionId = definition.Id,
            WorkflowModuleId = module.Id,
            ReferenceTransactionId = referenceTransactionId,
            WorkflowStatus = "PENDING",
            CreatedBy = initiatorEmployeeId
        };

        await _instanceRepository.AddAsync(instance, cancellationToken);
        await _instanceRepository.SaveChangesAsync(cancellationToken);

        // Advance to step 1
        await AdvanceWorkflowAsync(instance.Id, cancellationToken);
    }

    public async Task AdvanceWorkflowAsync(int workflowInstanceId, CancellationToken cancellationToken = default)
    {
        var instanceResult = await _instanceRepository.FindAsync(i => i.Id == workflowInstanceId, cancellationToken);
        var instance = instanceResult.FirstOrDefault();
        if (instance == null) return;

        // In a real implementation, this would evaluate current step, find the next step, 
        // resolve approvers via WorkflowStepApprover rules, and create WorkflowTask records.
        // For demonstration, just marking completed.
        
        instance.WorkflowStatus = "COMPLETED";
        instance.CompletedAt = DateTime.UtcNow;
        _instanceRepository.Update(instance);
        await _instanceRepository.SaveChangesAsync(cancellationToken);
    }
}
"@
Set-Content -Path "$appDir\Services\WorkflowResolutionService.cs" -Value $resImplCode

Write-Output "Generated Workflow Application Services."
