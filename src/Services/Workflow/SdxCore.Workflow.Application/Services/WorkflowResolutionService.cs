using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Events;
using SdxCore.Workflow.Domain.Interfaces.Repositories;
using SdxCore.Workflow.Domain.Interfaces.Services;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowResolutionService : IWorkflowResolutionService
{
    private readonly IBaseRepository<WorkflowModule> _moduleRepository;
    private readonly IBaseRepository<WorkflowDefinition> _definitionRepository;
    private readonly IBaseRepository<WorkflowInstance> _instanceRepository;
    private readonly IBaseRepository<WorkflowTask> _taskRepository;
    private readonly IBaseRepository<WorkflowStep> _stepRepository;
    private readonly ILogger<WorkflowResolutionService> _logger;

    public WorkflowResolutionService(
        IBaseRepository<WorkflowModule> moduleRepository,
        IBaseRepository<WorkflowDefinition> definitionRepository,
        IBaseRepository<WorkflowInstance> instanceRepository,
        IBaseRepository<WorkflowTask> taskRepository,
        IBaseRepository<WorkflowStep> stepRepository,
        ILogger<WorkflowResolutionService> logger)
    {
        _moduleRepository = moduleRepository;
        _definitionRepository = definitionRepository;
        _instanceRepository = instanceRepository;
        _taskRepository = taskRepository;
        _stepRepository = stepRepository;
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

        var instance = new WorkflowInstance
        {
            WorkflowDefinitionId = definition.Id,
            WorkflowModuleId = module.Id,
            ReferenceTransactionId = referenceTransactionId,
            WorkflowStatus = "PENDING",
            CreatedBy = initiatorEmployeeId
        };
        
        instance.AddDomainEvent(new WorkflowStatusChangedEvent 
        { 
            WorkflowInstanceId = instance.Id, 
            NewStatus = "PENDING" 
        });

        await _instanceRepository.AddAsync(instance, cancellationToken);
        await _instanceRepository.SaveChangesAsync(cancellationToken);

        await AdvanceWorkflowAsync(instance.Id, cancellationToken);
    }

    public async Task AdvanceWorkflowAsync(int workflowInstanceId, CancellationToken cancellationToken = default)
    {
        var instanceResult = await _instanceRepository.FindAsync(i => i.Id == workflowInstanceId, cancellationToken);
        var instance = instanceResult.FirstOrDefault();
        if (instance == null) return;

        var steps = await _stepRepository.FindAsync(s => s.WorkflowDefinitionId == instance.WorkflowDefinitionId && s.IsActive, cancellationToken);
        var orderedSteps = steps.OrderBy(s => s.StepNo).ToList();

        WorkflowStep? nextStep = null;

        if (instance.CurrentWorkflowStepId == null)
        {
            nextStep = orderedSteps.FirstOrDefault();
        }
        else
        {
            var currentStep = orderedSteps.FirstOrDefault(s => s.Id == instance.CurrentWorkflowStepId);
            if (currentStep != null)
            {
                if (currentStep.IsFinalStep)
                {
                    instance.WorkflowStatus = "COMPLETED";
                    instance.CompletedAt = DateTime.UtcNow;
                    instance.AddDomainEvent(new WorkflowStatusChangedEvent { WorkflowInstanceId = instance.Id, NewStatus = "COMPLETED" });
                    _instanceRepository.Update(instance);
                    await _instanceRepository.SaveChangesAsync(cancellationToken);
                    return;
                }
                nextStep = orderedSteps.FirstOrDefault(s => s.StepNo > currentStep.StepNo);
            }
        }

        if (nextStep == null)
        {
            instance.WorkflowStatus = "COMPLETED";
            instance.CompletedAt = DateTime.UtcNow;
            instance.AddDomainEvent(new WorkflowStatusChangedEvent { WorkflowInstanceId = instance.Id, NewStatus = "COMPLETED" });
            _instanceRepository.Update(instance);
            await _instanceRepository.SaveChangesAsync(cancellationToken);
            return;
        }

        instance.CurrentWorkflowStepId = nextStep.Id;
        _instanceRepository.Update(instance);
        
        // Resolve approver (stubbed logic for external service call)
        int resolvedApproverId = await ResolveApproverAsync(nextStep, instance.CreatedBy ?? 0, cancellationToken);

        var task = new WorkflowTask
        {
            WorkflowInstanceId = instance.Id,
            WorkflowStepId = nextStep.Id,
            WorkflowStepApproverId = 1, // Fallback placeholder if no rule is found
            AssignedToEmployeeId = resolvedApproverId,
            TaskStatus = "PENDING"
        };
        
        task.AddDomainEvent(new WorkflowTaskAssignedEvent 
        { 
            WorkflowTaskId = task.Id, 
            WorkflowInstanceId = instance.Id, 
            AssignedToEmployeeId = resolvedApproverId 
        });

        await _taskRepository.AddAsync(task, cancellationToken);
        
        // Save changes atomically (Outbox interceptor should catch status changes here)
        await _instanceRepository.SaveChangesAsync(cancellationToken);
    }

    private Task<int> ResolveApproverAsync(WorkflowStep step, int initiatorId, CancellationToken cancellationToken)
    {
        // 1. In a fully decoupled microservice, this makes an HTTP call to Employee API:
        // GET /api/employees/{initiatorId}/approvers?stepId={step.Id}
        //
        // 2. Or evaluates WorkflowStepApprover rules dynamically:
        // if (rule.WorkflowApproverType == "REPORTING_MANAGER") return GetManager(initiatorId);
        // if (rule.WorkflowApproverType == "DESIGNATION") return GetEmployeeByDesignation(rule.DesignationId);
        
        // Defaulting to the initiator's manager for Step 1, or HR (fallback) for Step 2
        return Task.FromResult(step.StepNo == 1 ? 1001 : 1002); // 1001: Manager, 1002: HR
    }
}
