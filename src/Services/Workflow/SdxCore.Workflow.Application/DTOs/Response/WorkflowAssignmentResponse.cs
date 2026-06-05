namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowAssignmentResponse(
    short    Id,
    short    WorkflowDefinitionId,
    string   WorkflowCode,
    string   WorkflowName,
    short    ScopeTypeId,
    string   ScopeTypeName,
    short    ScopeReferenceId,
    DateOnly EffectiveFrom,
    DateOnly? EffectiveTo,
    short    PriorityOrder,
    bool     IsActive);
