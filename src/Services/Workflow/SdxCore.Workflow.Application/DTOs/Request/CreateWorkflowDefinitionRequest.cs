namespace SdxCore.Workflow.Application.DTOs.Request;

public record CreateWorkflowDefinitionRequest(
    Guid WorkflowModuleId,
    string WorkflowCode,
    string WorkflowName,
    short  VersionNo,
    string? Description);
