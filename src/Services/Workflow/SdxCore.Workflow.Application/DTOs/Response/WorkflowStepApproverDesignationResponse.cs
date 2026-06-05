namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowStepApproverDesignationResponse(
    short  Id,
    short  WorkflowStepApproverId,
    short  DesignationId,
    string DesignationCode,
    string DesignationName);
