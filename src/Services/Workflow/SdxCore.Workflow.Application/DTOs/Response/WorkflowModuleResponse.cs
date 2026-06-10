namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowModuleResponse(
    Guid Id,
    string ModuleCode,
    string ModuleName,
    string EntityName,
    bool   IsActive);
