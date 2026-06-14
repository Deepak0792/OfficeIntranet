namespace SdxCore.Workflow.Application.DTOs.StepApprover.Request;

public sealed class CreateWorkflowStepApproverRequest
{
    public string WorkflowApproverType { get; set; } = default!; // REPORTING_MANAGER | DESIGNATION | EMPLOYEE | ROLE | SKIP_MANAGER
    public Guid? ScopeTypeId { get; set; }
    public Guid? ScopeReferenceId { get; set; }
    public short PriorityOrder { get; set; }
    public bool IsMandatory { get; set; }
}
