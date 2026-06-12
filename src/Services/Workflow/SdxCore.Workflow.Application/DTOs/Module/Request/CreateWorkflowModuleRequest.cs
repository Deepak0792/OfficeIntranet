namespace SdxCore.Workflow.Application.DTOs.Module.Request;

public record CreateWorkflowModuleRequest(
    string ModuleCode,
    string ModuleName,
    /// <summary>The database schema that owns the tracked entity (e.g. "employee", "leave").</summary>
    string Schema,
    string EntityName);
