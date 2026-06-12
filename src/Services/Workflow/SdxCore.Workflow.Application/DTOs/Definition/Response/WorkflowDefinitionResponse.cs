namespace SdxCore.Workflow.Application.DTOs.Definition.Response;

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
