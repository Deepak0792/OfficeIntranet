namespace SdxCore.Workflow.Application.DTOs.Resolver;

public record ResolvedApprover(
    Guid WorkflowStepApproverId,
    string ApproverType,
    Guid ResolvedEmployeeId,
    string ResolvedEmployeeName,
    Guid? ResolvedDesignationId,
    Guid? ResolvedDepartmentId);