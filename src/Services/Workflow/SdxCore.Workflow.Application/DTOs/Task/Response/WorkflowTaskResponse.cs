namespace SdxCore.Workflow.Application.DTOs.Task.Response;

public sealed class WorkflowTaskResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowInstanceId { get; set; }
    public Guid WorkflowStepId { get; set; }
    public string StepName { get; set; } = default!;
    public short StepNo { get; set; }
    public Guid WorkflowStepApproverId { get; set; }
    public Guid AssignedToEmployeeId { get; set; }
    public string AssignedToEmployeeName { get; set; } = default!;
    public Guid? DelegatedFromEmployeeId { get; set; }
    public string? DelegatedFromEmployeeName { get; set; }
    public string TaskStatus { get; set; } = default!;
    public string? Remarks { get; set; }
    public Guid? ParentWorkflowTaskId { get; set; }
    public DateTime AssignedAt { get; set; }
    public DateTime? DueAt { get; set; }
    public DateTime? ActionAt { get; set; }
    public string ModuleCode { get; set; } = default!;
    public Guid ReferenceTransactionId { get; set; }
    public string WorkflowStatus { get; set; } = default!;
}
