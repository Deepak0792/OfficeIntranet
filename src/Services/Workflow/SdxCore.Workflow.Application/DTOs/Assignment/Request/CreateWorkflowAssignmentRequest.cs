namespace SdxCore.Workflow.Application.DTOs.Assignment.Request;

public sealed class CreateWorkflowAssignmentRequest
{
    public Guid WorkflowDefinitionId { get; set; }
    public Guid ScopeTypeId { get; set; }
    public Guid ScopeReferenceId { get; set; }
    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; }
}
