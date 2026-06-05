namespace SdxCore.Workflow.Application.DTOs.Request;

public record UpdateWorkflowAssignmentRequest(
    DateOnly  EffectiveFrom,
    DateOnly? EffectiveTo,
    short     PriorityOrder);
