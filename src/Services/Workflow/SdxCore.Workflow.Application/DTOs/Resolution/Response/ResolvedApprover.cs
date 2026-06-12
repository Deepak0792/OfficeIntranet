namespace SdxCore.Workflow.Application.DTOs.Resolution.Response;

public record ResolvedApprover(
    Guid WorkflowStepApproverId,
    string ApproverType,
    Guid ResolvedEmployeeId,
    string ResolvedEmployeeName,
    Guid? ResolvedDesignationId,
    Guid? ResolvedDepartmentId);