namespace SdxCore.Workflow.Application.DTOs.Request;

public record CreateWorkflowModuleRequest(
    string ModuleCode,
    string ModuleName,
    string EntityName);
