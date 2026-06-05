namespace SdxCore.Workflow.Application.DTOs.Request;

public record DelegateTaskRequest(
    int    DelegateToEmployeeId,
    string? Remarks);
