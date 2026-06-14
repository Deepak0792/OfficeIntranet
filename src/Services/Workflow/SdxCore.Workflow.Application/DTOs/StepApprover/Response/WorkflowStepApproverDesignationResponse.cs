namespace SdxCore.Workflow.Application.DTOs.StepApprover.Response;

public sealed class WorkflowStepApproverDesignationResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowStepApproverId { get; set; }
    public Guid DesignationId { get; set; }
    public string DesignationCode { get; set; } = default!;
    public string DesignationName { get; set; } = default!;
}
