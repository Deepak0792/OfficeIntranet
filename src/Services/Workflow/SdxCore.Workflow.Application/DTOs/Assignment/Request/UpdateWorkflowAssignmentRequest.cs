namespace SdxCore.Workflow.Application.DTOs.Assignment.Request;

public record UpdateWorkflowAssignmentRequest(
    DateOnly EffectiveFrom,
    DateOnly? EffectiveTo,
    short PriorityOrder);
