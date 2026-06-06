using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApprover : BaseAuditEntity<short>
{
    public short WorkflowStepId { get; set; }
    public string WorkflowApproverType { get; set; } = null!;
    public short? ScopeTypeId { get; set; }
    public short? ScopeReferenceId { get; set; }
    public short PriorityOrder { get; set; } = 1;
    public bool IsMandatory { get; set; } = true;
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowStep Step { get; set; } = null!;
    public ICollection<WorkflowStepApproverDesignation> Designations { get; set; } = [];
}
