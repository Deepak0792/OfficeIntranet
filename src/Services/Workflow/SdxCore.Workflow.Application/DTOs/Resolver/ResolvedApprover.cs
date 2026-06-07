namespace SdxCore.Workflow.Application.DTOs.Resolver;

public record ResolvedApprover(
    short WorkflowStepApproverId,
    string ApproverType,
    int ResolvedEmployeeId,
    string ResolvedEmployeeName,
    short? ResolvedDesignationId,
    short? ResolvedDepartmentId);