namespace SdxCore.Workflow.Application.DTOs.Assignment.Response;

public sealed class WorkflowAssignmentResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowDefinitionId { get; set; }
    public string WorkflowCode { get; set; } = default!;
    public string WorkflowName { get; set; } = default!;
    public Guid ScopeTypeId { get; set; }
    public string ScopeTypeName { get; set; } = default!;
    public Guid ScopeReferenceId { get; set; }
    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; }
    public bool IsActive { get; set; }
}
