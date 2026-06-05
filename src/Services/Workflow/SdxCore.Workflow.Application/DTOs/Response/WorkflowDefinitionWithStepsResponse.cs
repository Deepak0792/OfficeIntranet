namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowDefinitionWithStepsResponse(
    short  Id,
    string WorkflowCode,
    string WorkflowName,
    short  VersionNo,
    bool   IsActive,
    IEnumerable<WorkflowStepResponse> Steps);
