namespace SdxCore.Workflow.Application.DTOs.Resolution.Response;

public record PreviewApproversResponse(
    Guid WorkflowStepApproverId,
    string ApproverType,
    Guid ResolvedEmployeeId,
    string ResolvedEmployeeName,
    Guid? ResolvedDesignationId,
    Guid? ResolvedDepartmentId);
