namespace SdxCore.Workflow.Application.DTOs.Request;

public record UpdateWorkflowDefinitionRequest(
    string WorkflowName,
    short  VersionNo,
    string? Description);
