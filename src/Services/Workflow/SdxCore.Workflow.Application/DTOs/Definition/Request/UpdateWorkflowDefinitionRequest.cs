namespace SdxCore.Workflow.Application.DTOs.Definition.Request;

public sealed class UpdateWorkflowDefinitionRequest
{
    public string WorkflowName { get; set; } = default!;
    public short VersionNo { get; set; }
    public string? Description { get; set; }
}
