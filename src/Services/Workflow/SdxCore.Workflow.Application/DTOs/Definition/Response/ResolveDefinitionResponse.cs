namespace SdxCore.Workflow.Application.DTOs.Definition.Response;

public record ResolveDefinitionResponse(
    Guid WorkflowDefinitionId,
    string WorkflowCode,
    string WorkflowName,
    short VersionNo);
