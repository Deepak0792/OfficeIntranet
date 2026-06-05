namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowDefinitionResponse(
    short  Id,
    short  WorkflowModuleId,
    string ModuleCode,
    string ModuleName,
    string WorkflowCode,
    string WorkflowName,
    short  VersionNo,
    string? Description,
    bool   IsActive);
