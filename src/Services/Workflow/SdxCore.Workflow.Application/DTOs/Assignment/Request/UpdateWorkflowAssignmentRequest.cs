namespace SdxCore.Workflow.Application.DTOs.Assignment.Request;

public class UpdateWorkflowAssignmentRequest
{
    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; }
}
