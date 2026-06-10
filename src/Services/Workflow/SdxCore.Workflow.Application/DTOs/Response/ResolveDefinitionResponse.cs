namespace SdxCore.Workflow.Application.DTOs.Response;

public record ResolveDefinitionResponse(
    Guid WorkflowDefinitionId,
    string WorkflowCode,
    string WorkflowName,
    short  VersionNo);
