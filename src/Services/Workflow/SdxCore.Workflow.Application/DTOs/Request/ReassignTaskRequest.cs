namespace SdxCore.Workflow.Application.DTOs.Request;

public record ReassignTaskRequest(
    Guid ReassignToEmployeeId,
    string? Remarks);
