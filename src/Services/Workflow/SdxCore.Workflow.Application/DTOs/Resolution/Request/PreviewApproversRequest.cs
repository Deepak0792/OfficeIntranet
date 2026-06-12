namespace SdxCore.Workflow.Application.DTOs.Resolution.Request;

public record PreviewApproversRequest(
    Guid WorkflowStepId,
    Guid InitiatorEmployeeId);
