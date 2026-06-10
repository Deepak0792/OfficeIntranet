namespace SdxCore.Workflow.Application.DTOs.Request;

public record DelegateTaskRequest(
    Guid DelegateToEmployeeId,
    string? Remarks);
