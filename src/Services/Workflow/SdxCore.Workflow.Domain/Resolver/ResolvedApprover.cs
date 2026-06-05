using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Resolver;

public record ResolvedApprover(
    short WorkflowStepApproverId,
    string ApproverType,
    int ResolvedEmployeeId,
    string ResolvedEmployeeName,
    string? ResolvedDesignation,
    string? ResolvedDepartment);