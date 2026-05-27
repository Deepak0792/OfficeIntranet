$domainDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Domain\Entities"
New-Item -ItemType Directory -Force -Path $domainDir | Out-Null

$baseEntityCode = @"
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using SdxCore.Common.Models;

namespace SdxCore.Workflow.Domain.Entities;

public abstract class BaseEntity : IHasDomainEvents
{    
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;
    public int? LastUpdatedBy { get; set; }

    private readonly List<object> _domainEvents = new();

    [NotMapped]
    public IReadOnlyCollection<object> DomainEvents => _domainEvents.AsReadOnly();

    public void AddDomainEvent(object domainEvent)
    {
        _domainEvents.Add(domainEvent);
    }

    public void RemoveDomainEvent(object domainEvent)
    {
        _domainEvents.Remove(domainEvent);
    }

    public void ClearDomainEvents()
    {
        _domainEvents.Clear();
    }

    public IReadOnlyCollection<object> GetDomainEvents() => _domainEvents.AsReadOnly();
}
"@
Set-Content -Path "$domainDir\BaseEntity.cs" -Value $baseEntityCode

$moduleCode = @"
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowModule : BaseEntity
{
    public short Id { get; set; }
    public string ModuleCode { get; set; } = string.Empty;
    public string ModuleName { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;

    public ICollection<WorkflowDefinition> Definitions { get; set; } = new List<WorkflowDefinition>();
    public ICollection<WorkflowInstance> Instances { get; set; } = new List<WorkflowInstance>();
}
"@
Set-Content -Path "$domainDir\WorkflowModule.cs" -Value $moduleCode

$defCode = @"
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowDefinition : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowModuleId { get; set; }
    public string WorkflowCode { get; set; } = string.Empty;
    public string WorkflowName { get; set; } = string.Empty;
    public short VersionNo { get; set; } = 1;
    public string? Description { get; set; }

    public WorkflowModule? Module { get; set; }
    public ICollection<WorkflowStep> Steps { get; set; } = new List<WorkflowStep>();
    public ICollection<WorkflowAssignment> Assignments { get; set; } = new List<WorkflowAssignment>();
    public ICollection<WorkflowInstance> Instances { get; set; } = new List<WorkflowInstance>();
}
"@
Set-Content -Path "$domainDir\WorkflowDefinition.cs" -Value $defCode

$stepCode = @"
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStep : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowDefinitionId { get; set; }
    public short StepNo { get; set; }
    public string StepName { get; set; } = string.Empty;
    public string WorkflowStepType { get; set; } = string.Empty;
    public bool IsFinalStep { get; set; } = false;
    public bool AllowDelegation { get; set; } = true;
    public int? EscalationAfterHours { get; set; }

    public WorkflowDefinition? Definition { get; set; }
    public ICollection<WorkflowStepApprover> Approvers { get; set; } = new List<WorkflowStepApprover>();
    public ICollection<WorkflowInstance> CurrentInstances { get; set; } = new List<WorkflowInstance>();
    public ICollection<WorkflowTask> Tasks { get; set; } = new List<WorkflowTask>();
    public ICollection<WorkflowActionHistory> ActionHistories { get; set; } = new List<WorkflowActionHistory>();
}
"@
Set-Content -Path "$domainDir\WorkflowStep.cs" -Value $stepCode

$approverCode = @"
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApprover : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowStepId { get; set; }
    public string WorkflowApproverType { get; set; } = string.Empty;
    public short? ScopeTypeId { get; set; }
    public short? ScopeReferenceId { get; set; }
    public short PriorityOrder { get; set; } = 1;
    public bool IsMandatory { get; set; } = true;

    public WorkflowStep? Step { get; set; }
    public ICollection<WorkflowStepApproverDesignation> Designations { get; set; } = new List<WorkflowStepApproverDesignation>();
    public ICollection<WorkflowTask> Tasks { get; set; } = new List<WorkflowTask>();
}
"@
Set-Content -Path "$domainDir\WorkflowStepApprover.cs" -Value $approverCode

$designationCode = @"
namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApproverDesignation : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowStepApproverId { get; set; }
    public short DesignationId { get; set; }

    public WorkflowStepApprover? StepApprover { get; set; }
}
"@
Set-Content -Path "$domainDir\WorkflowStepApproverDesignation.cs" -Value $designationCode

$assignmentCode = @"
using System;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowAssignment : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowDefinitionId { get; set; }
    public short ScopeTypeId { get; set; }
    public short ScopeReferenceId { get; set; }
    public DateTime EffectiveFrom { get; set; }
    public DateTime? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; } = 1;

    public WorkflowDefinition? Definition { get; set; }
}
"@
Set-Content -Path "$domainDir\WorkflowAssignment.cs" -Value $assignmentCode

$instanceCode = @"
using System;
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowInstance : BaseEntity
{
    public int Id { get; set; }
    public short WorkflowDefinitionId { get; set; }
    public short WorkflowModuleId { get; set; }
    public int ReferenceTransactionId { get; set; }
    public short? CurrentWorkflowStepId { get; set; }
    public string WorkflowStatus { get; set; } = string.Empty;
    public DateTime? CompletedAt { get; set; }
    public int? CompletedBy { get; set; }

    public WorkflowDefinition? Definition { get; set; }
    public WorkflowModule? Module { get; set; }
    public WorkflowStep? CurrentStep { get; set; }
    public ICollection<WorkflowTask> Tasks { get; set; } = new List<WorkflowTask>();
    public ICollection<WorkflowActionHistory> ActionHistories { get; set; } = new List<WorkflowActionHistory>();
}
"@
Set-Content -Path "$domainDir\WorkflowInstance.cs" -Value $instanceCode

$taskCode = @"
using System;
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowTask : BaseEntity
{
    public int Id { get; set; }
    public int WorkflowInstanceId { get; set; }
    public short WorkflowStepId { get; set; }
    public short WorkflowStepApproverId { get; set; }
    public int AssignedToEmployeeId { get; set; }
    public int? DelegatedFromEmployeeId { get; set; }
    public string TaskStatus { get; set; } = string.Empty;
    public string? Remarks { get; set; }
    public int? ParentWorkflowTaskId { get; set; }
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DueAt { get; set; }
    public DateTime? ActionAt { get; set; }
    public int? ActionBy { get; set; }

    public WorkflowInstance? Instance { get; set; }
    public WorkflowStep? Step { get; set; }
    public WorkflowStepApprover? StepApprover { get; set; }
    public WorkflowTask? ParentTask { get; set; }
    public ICollection<WorkflowTask> ChildTasks { get; set; } = new List<WorkflowTask>();
    public ICollection<WorkflowActionHistory> ActionHistories { get; set; } = new List<WorkflowActionHistory>();
}
"@
Set-Content -Path "$domainDir\WorkflowTask.cs" -Value $taskCode

$historyCode = @"
using System;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowActionHistory : BaseEntity
{
    public int Id { get; set; }
    public int WorkflowInstanceId { get; set; }
    public int? WorkflowTaskId { get; set; }
    public short? WorkflowStepId { get; set; }
    public string WorkflowActionType { get; set; } = string.Empty;
    public string? Remarks { get; set; }
    public string? FromWorkflowStatus { get; set; }
    public string? ToWorkflowStatus { get; set; }
    public int ActionBy { get; set; }
    public DateTime ActionAt { get; set; } = DateTime.UtcNow;

    public WorkflowInstance? Instance { get; set; }
    public WorkflowTask? Task { get; set; }
    public WorkflowStep? Step { get; set; }
}
"@
Set-Content -Path "$domainDir\WorkflowActionHistory.cs" -Value $historyCode

Write-Output "Successfully generated Workflow Domain Entities."
