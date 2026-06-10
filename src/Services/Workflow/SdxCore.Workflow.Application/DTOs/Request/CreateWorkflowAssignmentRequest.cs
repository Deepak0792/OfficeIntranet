namespace SdxCore.Workflow.Application.DTOs.Request;

public record CreateWorkflowAssignmentRequest(
    Guid WorkflowDefinitionId,
    Guid ScopeTypeId,
    Guid ScopeReferenceId,
    DateOnly  EffectiveFrom,
    DateOnly? EffectiveTo,
    short     PriorityOrder);
