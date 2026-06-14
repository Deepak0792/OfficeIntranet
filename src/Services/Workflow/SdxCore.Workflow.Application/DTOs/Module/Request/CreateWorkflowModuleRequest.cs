namespace SdxCore.Workflow.Application.DTOs.Module.Request;

public sealed class CreateWorkflowModuleRequest
{
    public string ModuleCode { get; set; } = default!;
    public string ModuleName { get; set; } = default!;

    /// <summary>The database schema that owns the tracked entity (e.g. "employee", "leave").</summary>
    public string Schema { get; set; } = default!;
    public string EntityName { get; set; } = default!;
}
