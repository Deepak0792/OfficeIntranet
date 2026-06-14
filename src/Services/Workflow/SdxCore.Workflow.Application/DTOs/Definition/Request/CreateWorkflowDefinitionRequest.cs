namespace SdxCore.Workflow.Application.DTOs.Definition.Request;

public sealed class CreateWorkflowDefinitionRequest
{
    public Guid WorkflowModuleId { get; set; }
    public string WorkflowCode { get; set; } = default!;
    public string WorkflowName { get; set; } = default!;
    public short VersionNo { get; set; }
    public string? Description { get; set; }
}
