namespace SdxCore.Workflow.Application.DTOs.Request;

public record UpdateWorkflowModuleRequest(
    string ModuleName,
    string EntityName);
