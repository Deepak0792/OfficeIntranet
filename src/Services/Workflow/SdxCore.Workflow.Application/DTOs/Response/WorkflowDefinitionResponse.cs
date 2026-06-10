namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowDefinitionResponse(
    Guid Id,
    Guid WorkflowModuleId,
    string ModuleCode,
    string ModuleName,
    string WorkflowCode,
    string WorkflowName,
    Guid VersionNo,
    string? Description,
    bool IsActive);
