namespace SdxCore.Workflow.Application.DTOs.Request;

public record CreateWorkflowDefinitionRequest(
    short  WorkflowModuleId,
    string WorkflowCode,
    string WorkflowName,
    short  VersionNo,
    string? Description);
