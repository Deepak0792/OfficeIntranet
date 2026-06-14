using SdxCore.Workflow.Application.DTOs.Step.Response;

namespace SdxCore.Workflow.Application.DTOs.Definition.Response;

public sealed class WorkflowDefinitionWithStepsResponse
{
    public Guid Id { get; set; }
    public string WorkflowCode { get; set; } = default!;
    public string WorkflowName { get; set; } = default!;
    public short VersionNo { get; set; }
    public bool IsActive { get; set; }
    public IEnumerable<WorkflowStepResponse> Steps { get; set; } = [];
}
