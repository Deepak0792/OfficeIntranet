using SdxCore.Workflow.Application.DTOs.Step.Response;

namespace SdxCore.Workflow.Application.DTOs.Definition.Response;

public record WorkflowDefinitionWithStepsResponse(
    Guid Id,
    string WorkflowCode,
    string WorkflowName,
    short VersionNo,
    bool IsActive,
    IEnumerable<WorkflowStepResponse> Steps);
