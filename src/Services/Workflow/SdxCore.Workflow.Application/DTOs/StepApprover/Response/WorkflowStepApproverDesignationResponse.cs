namespace SdxCore.Workflow.Application.DTOs.StepApprover.Response;

public record WorkflowStepApproverDesignationResponse(
    Guid Id,
    Guid WorkflowStepApproverId,
    Guid DesignationId,
    string DesignationCode,
    string DesignationName);
