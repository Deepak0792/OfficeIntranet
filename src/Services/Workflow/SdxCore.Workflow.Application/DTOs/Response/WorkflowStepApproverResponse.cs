namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowStepApproverResponse(
    short  Id,
    short  WorkflowStepId,
    string WorkflowApproverType,
    short? ScopeTypeId,
    string? ScopeTypeName,
    short? ScopeReferenceId,
    short  PriorityOrder,
    bool   IsMandatory,
    bool   IsActive,
    IEnumerable<WorkflowStepApproverDesignationResponse>? Designations);
