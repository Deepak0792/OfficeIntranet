namespace SdxCore.Workflow.Application.DTOs.Task.Request;

public record DelegateTaskRequest(
    Guid DelegateToEmployeeId,
    string? Remarks);
