namespace SdxCore.Workflow.Application.DTOs.Request;

public record PreviewApproversRequest(
    Guid WorkflowStepId,
    Guid InitiatorEmployeeId);
