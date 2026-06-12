namespace SdxCore.Workflow.Application.DTOs.Task.Request;

public record ReassignTaskRequest(
    Guid ReassignToEmployeeId,
    string? Remarks);
