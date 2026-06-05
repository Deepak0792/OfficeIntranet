namespace SdxCore.Workflow.Application.DTOs.Request;

public record CreateWorkflowAssignmentRequest(
    short     WorkflowDefinitionId,
    short     ScopeTypeId,
    short     ScopeReferenceId,
    DateOnly  EffectiveFrom,
    DateOnly? EffectiveTo,
    short     PriorityOrder);
