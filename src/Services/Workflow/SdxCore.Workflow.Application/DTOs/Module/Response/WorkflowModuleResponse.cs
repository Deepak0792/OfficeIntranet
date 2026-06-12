namespace SdxCore.Workflow.Application.DTOs.Module.Response;

public record WorkflowModuleResponse(
    Guid Id,
    string ModuleCode,
    string ModuleName,
    string Schema,
    string EntityName,
    bool IsActive);
