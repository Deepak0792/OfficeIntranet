namespace SdxCore.Workflow.Application.DTOs.Request;

public record ReassignTaskRequest(
    int    ReassignToEmployeeId,
    string? Remarks);
