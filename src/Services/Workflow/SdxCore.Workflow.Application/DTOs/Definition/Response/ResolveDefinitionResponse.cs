namespace SdxCore.Workflow.Application.DTOs.Definition.Response;

public sealed class ResolveDefinitionResponse
{
    public Guid WorkflowDefinitionId { get; set; }
    public string WorkflowCode { get; set; } = default!;
    public string WorkflowName { get; set; } = default!;
    public short VersionNo { get; set; }
}
