namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowStepApproverDesignationResponse(
    Guid Id,
    Guid WorkflowStepApproverId,
    Guid DesignationId,
    string DesignationCode,
    string DesignationName);
