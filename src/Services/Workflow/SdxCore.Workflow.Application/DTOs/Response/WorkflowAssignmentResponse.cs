namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowAssignmentResponse(
    Guid Id,
    Guid WorkflowDefinitionId,
    string WorkflowCode,
    string WorkflowName,
    Guid ScopeTypeId,
    string ScopeTypeName,
    Guid ScopeReferenceId,
    DateOnly EffectiveFrom,
    DateOnly? EffectiveTo,
    Guid PriorityOrder,
    bool IsActive);
