using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Application.Contracts.Engine;

public interface IWorkflowEngine
{
    /// <summary>
    /// Submits a transaction to workflow.
    /// 1. Resolves applicable WorkflowDefinition via WorkflowAssignment.
    /// 2. Creates WorkflowInstance with status PENDING.
    /// 3. Creates WorkflowTask rows for Step 1 approvers.
    /// 4. Writes SUBMIT action to WorkflowActionHistory.
    /// 5. Publishes outbox event.
    /// </summary>
    Task<WorkflowInstance> SubmitAsync(
        string moduleCode,
        string workflowCode,
        int referenceTransactionId,
        int initiatorEmployeeId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Processes an APPROVE action on a task.
    /// If all mandatory tasks for the current step are approved → advance to next step.
    /// If this is the final step → mark instance APPROVED and publish event.
    /// </summary>
    Task ProcessApproveAsync(int taskId, int actionBy, string? remarks, CancellationToken cancellationToken = default);

    /// <summary>
    /// Processes a REJECT action. Terminates the instance with status REJECTED.
    /// </summary>
    Task ProcessRejectAsync(int taskId, int actionBy, string? remarks, CancellationToken cancellationToken = default);

    /// <summary>
    /// Processes a DELEGATE action.
    /// Marks original task DELEGATED, creates new task for delegate employee.
    /// </summary>
    Task ProcessDelegateAsync(int taskId, int delegateToEmployeeId, int actionBy, string? remarks, CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns a task to the initiator for clarification.
    /// Instance stays IN_PROGRESS; step reset to allow resubmit.
    /// </summary>
    Task ProcessReturnAsync(int taskId, int actionBy, string? remarks, CancellationToken cancellationToken = default);

    /// <summary>
    /// Admin reassigns a pending task to a different employee.
    /// </summary>
    Task ProcessReassignAsync(int taskId, int reassignToEmployeeId, int actionBy, string? remarks, CancellationToken cancellationToken = default);

    /// <summary>Cancels an in-progress instance. Admin/system only.</summary>
    Task CancelAsync(int instanceId, int actionBy, string? remarks, CancellationToken cancellationToken = default);

    /// <summary>Withdrawn by the initiator. Only allowed when still PENDING.</summary>
    Task WithdrawAsync(int instanceId, int actionBy, string? remarks, CancellationToken cancellationToken = default);
}