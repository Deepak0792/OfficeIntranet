namespace SdxCore.Workflow.Application.DTOs.Request;

public record PreviewApproversRequest(
    short WorkflowStepId,
    int   InitiatorEmployeeId);
