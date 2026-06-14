namespace SdxCore.Workflow.Application.DTOs.Module.Response;

public sealed class WorkflowModuleResponse
{
    public Guid Id { get; set; }
    public string ModuleCode { get; set; } = default!;
    public string ModuleName { get; set; } = default!;
    public string Schema { get; set; } = default!;
    public string EntityName { get; set; } = default!;
    public bool IsActive { get; set; }
}
