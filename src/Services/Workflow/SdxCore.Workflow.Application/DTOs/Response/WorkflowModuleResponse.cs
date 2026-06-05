namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowModuleResponse(
    short  Id,
    string ModuleCode,
    string ModuleName,
    string EntityName,
    bool   IsActive);
