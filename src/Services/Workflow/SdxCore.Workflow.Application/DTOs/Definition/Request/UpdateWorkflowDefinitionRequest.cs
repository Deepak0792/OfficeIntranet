namespace SdxCore.Workflow.Application.DTOs.Definition.Request;

public record UpdateWorkflowDefinitionRequest(
    string WorkflowName,
    short VersionNo,
    string? Description);
