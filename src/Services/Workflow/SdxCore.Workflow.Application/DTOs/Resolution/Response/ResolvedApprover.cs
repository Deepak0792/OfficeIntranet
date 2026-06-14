namespace SdxCore.Workflow.Application.DTOs.Resolution.Response;

public sealed class ResolvedApprover
{
    public Guid WorkflowStepApproverId { get; set; }
    public string ApproverType { get; set; } = default!;
    public Guid ResolvedEmployeeId { get; set; }
    public string ResolvedEmployeeName { get; set; } = default!;
    public Guid? ResolvedDesignationId { get; set; }
    public Guid? ResolvedDepartmentId { get; set; }
}