namespace SdxCore.Workflow.Application.DTOs.Response;

public record PreviewApproversResponse(
    short  WorkflowStepApproverId,
    string ApproverType,
    int    ResolvedEmployeeId,
    string ResolvedEmployeeName,
    short? ResolvedDesignationId,
    short? ResolvedDepartmentId);
