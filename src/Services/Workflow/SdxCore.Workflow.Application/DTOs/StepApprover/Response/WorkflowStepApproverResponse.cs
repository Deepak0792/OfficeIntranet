namespace SdxCore.Workflow.Application.DTOs.StepApprover.Response;

public sealed class WorkflowStepApproverResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowStepId { get; set; }
    public string WorkflowApproverType { get; set; } = default!;
    public Guid? ScopeTypeId { get; set; }
    public Guid? ScopeReferenceId { get; set; }
    public short PriorityOrder { get; set; }
    public bool IsMandatory { get; set; }
    public bool IsActive { get; set; }
    public IEnumerable<WorkflowStepApproverDesignationResponse>? Designations { get; set; }
}
