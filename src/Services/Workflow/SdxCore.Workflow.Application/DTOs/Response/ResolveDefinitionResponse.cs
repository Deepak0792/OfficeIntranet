namespace SdxCore.Workflow.Application.DTOs.Response;

public record ResolveDefinitionResponse(
    short  WorkflowDefinitionId,
    string WorkflowCode,
    string WorkflowName,
    short  VersionNo);
