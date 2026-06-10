namespace SdxCore.Workflow.Application.DTOs.Response;

public record PreviewApproversResponse(
    Guid WorkflowStepApproverId,
    string ApproverType,
    Guid ResolvedEmployeeId,
    string ResolvedEmployeeName,
    Guid? ResolvedDesignationId,
    Guid? ResolvedDepartmentId);
