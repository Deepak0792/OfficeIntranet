namespace SdxCore.Workflow.Application.DTOs.Definition.Response;

public sealed class WorkflowDefinitionResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowModuleId { get; set; }
    public string ModuleCode { get; set; } = default!;
    public string ModuleName { get; set; } = default!;
    public string WorkflowCode { get; set; } = default!;
    public string WorkflowName { get; set; } = default!;
    public short VersionNo { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}
