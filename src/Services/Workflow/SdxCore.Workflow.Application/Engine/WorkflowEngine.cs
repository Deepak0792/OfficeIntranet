using SdxCore.SharedKernel.Events;
using SdxCore.Workflow.Application.Contracts.Engine;
using SdxCore.Workflow.Application.Contracts.Resolver;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Enums;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Engine;

public class WorkflowEngine(
    IWorkflowStepService workflowStepService,
    IWorkflowStepApproverService workflowStepApproverService,
    IWorkflowInstanceRepository instanceRepository,
    IWorkflowTaskRepository taskRepository,
    IWorkflowActionHistoryRepository historyRepository,

    IWorkflowApproverResolver resolver,
    IWorkflowOutboxPublisher outboxPublisher) : IWorkflowEngine
{
    // ── Submit ───────────────────────────────────────────────
    public async Task<WorkflowInstance> SubmitAsync(
        string moduleCode, string workflowCode, int referenceTransactionId, int initiatorEmployeeId, CancellationToken cancellationToken = default)
    {
        var definition = await resolver.ResolveDefinitionAsync(moduleCode, workflowCode, initiatorEmployeeId);

        // 2. Get the first active step
        var firstStep = await workflowStepService.GetNextStepAsync(definition.WorkflowDefinitionId, 0, cancellationToken)
            ?? throw new WorkflowApproverResolutionException(
                definition.WorkflowDefinitionId, "No active steps found in the workflow definition.");

        // 3. Create WorkflowInstance
        var instance = new WorkflowInstance
        {
            WorkflowDefinitionId = definition.WorkflowDefinitionId,
            WorkflowModuleId = definition.WorkflowModuleId,
            ReferenceTransactionId = referenceTransactionId,
            CurrentWorkflowStepId = firstStep.Id,
            WorkflowStatus = WorkflowStatus.Pending,
            CreatedBy = initiatorEmployeeId,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            LastUpdatedAt = DateTime.UtcNow
        };
        instance = await instanceRepository.AddAsync(instance, cancellationToken);
        //

        // 4. Write SUBMIT history
        await WriteHistoryAsync(instance.Id, null, firstStep.Id,
            WorkflowActionType.Submit, null,
            null, WorkflowStatus.Pending, initiatorEmployeeId, cancellationToken);

        // 5. Create tasks for first step
        await CreateTasksForStepAsync(instance, firstStep, cancellationToken);

        // 6. Publish outbox event
        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, moduleCode, referenceTransactionId,
            WorkflowStatus.Pending, WorkflowActionType.Submit, initiatorEmployeeId, null, cancellationToken);

        await instanceRepository.SaveChangesAsync(cancellationToken);

        return instance;
    }

    // ── Approve ──────────────────────────────────────────────
    public async Task ProcessApproveAsync(int taskId, int actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);
        var currentStep = await workflowStepService.GetByIdAsync(task.WorkflowStepId, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowStep", task.WorkflowStepId);

        // Mark this task completed
        await CompleteTaskAsync(task, WorkflowTaskStatus.Completed, actionBy, remarks, cancellationToken);

        // Write APPROVE history
        await WriteHistoryAsync(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Approve, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.InProgress, actionBy, cancellationToken);

        // Check if ALL mandatory tasks for this step are completed
        var allStepTasks = await taskRepository.GetByInstanceIdAsync(instance.Id, cancellationToken);
        var stepTasks = allStepTasks
            .Where(t => t.WorkflowStepId == currentStep.Id && t.IsActive)
            .ToList();

        var allApprovers = await workflowStepApproverService.GetByStepIdAsync(currentStep.Id, cancellationToken);
        var mandatoryApproverIds = allApprovers
            .Where(a => a.IsMandatory && a.IsActive)
            .Select(a => a.Id)
            .ToHashSet();

        bool allMandatoryDone = stepTasks
            .Where(t => mandatoryApproverIds.Contains(t.WorkflowStepApproverId))
            .All(t => t.TaskStatus == WorkflowTaskStatus.Completed);

        if (!allMandatoryDone) return; // Still waiting on other approvers

        if (currentStep.IsFinalStep)
        {
            // Terminal: APPROVED
            await TerminateInstanceAsync(instance, WorkflowStatus.Approved, actionBy, cancellationToken);
            await WriteHistoryAsync(instance.Id, null, currentStep.Id,
                WorkflowActionType.Approve, "Final step approved.",
                WorkflowStatus.InProgress, WorkflowStatus.Approved, actionBy, cancellationToken);

            // On APPROVE (final step):
            await outboxPublisher.PublishStatusChangedAsync(
                instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
                WorkflowStatus.Approved, WorkflowActionType.Approve, actionBy, remarks, cancellationToken);
        }
        else
        {
            // Advance to next step
            var nextStep = await workflowStepService.GetNextStepAsync(
                instance.WorkflowDefinitionId, currentStep.StepNo, cancellationToken)
                ?? throw new WorkflowApproverResolutionException(
                    currentStep.Id, "Could not find next step.");

            instance.CurrentWorkflowStepId = nextStep.Id;
            instance.WorkflowStatus = WorkflowStatus.InProgress;
            instance.LastUpdatedAt = DateTime.UtcNow;
            instanceRepository.Update(instance);
            await instanceRepository.SaveChangesAsync(cancellationToken);

            await CreateTasksForStepAsync(instance, nextStep, cancellationToken);
        }
    }

    // ── Reject ───────────────────────────────────────────────
    public async Task ProcessRejectAsync(int taskId, int actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        await CompleteTaskAsync(task, WorkflowTaskStatus.Completed, actionBy, remarks, cancellationToken);
        await CancelOpenTasksAsync(instance.Id, taskId, cancellationToken);

        await WriteHistoryAsync(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Reject, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.Rejected, actionBy, cancellationToken);

        await TerminateInstanceAsync(instance, WorkflowStatus.Rejected, actionBy, cancellationToken);

        // On REJECT:
        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Rejected, WorkflowActionType.Reject, actionBy, remarks, cancellationToken);
    }

    // ── Delegate ─────────────────────────────────────────────
    public async Task ProcessDelegateAsync(
        int taskId, int delegateToEmployeeId, int actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        await CompleteTaskAsync(task, WorkflowTaskStatus.Delegated, actionBy, remarks, cancellationToken);

        var dueAt = task.Step?.EscalationAfterHours is not null
            ? DateTime.UtcNow.AddHours(task.Step.EscalationAfterHours.Value)
            : (DateTime?)null;

        var newTask = new WorkflowTask
        {
            WorkflowInstanceId = instance.Id,
            WorkflowStepId = task.WorkflowStepId,
            WorkflowStepApproverId = task.WorkflowStepApproverId,
            AssignedToEmployeeId = delegateToEmployeeId,
            DelegatedFromEmployeeId = actionBy,
            TaskStatus = WorkflowTaskStatus.Pending,
            ParentWorkflowTaskId = taskId,
            AssignedAt = DateTime.UtcNow,
            DueAt = dueAt,
            ActionBy = actionBy,
            IsActive = true
        };
        await taskRepository.AddAsync(newTask, cancellationToken);
        await taskRepository.SaveChangesAsync(cancellationToken);

        await WriteHistoryAsync(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Delegate, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.InProgress, actionBy, cancellationToken);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.InProgress, WorkflowActionType.Delegate,
            actionBy, remarks, cancellationToken);
    }

    // ── Return for clarification ─────────────────────────────
    public async Task ProcessReturnAsync(int taskId, int actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        await CompleteTaskAsync(task, WorkflowTaskStatus.Completed, actionBy, remarks, cancellationToken);

        // Cancel any other pending tasks for the current step
        await CancelOpenTasksAsync(instance.Id, taskId, cancellationToken);

        await WriteHistoryAsync(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Return, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.Pending, actionBy, cancellationToken);

        // Reset to first step so initiator can resubmit
        var firstStep = await workflowStepService.GetNextStepAsync(instance.WorkflowDefinitionId, 0, cancellationToken);
        instance.CurrentWorkflowStepId = firstStep?.Id;
        instance.WorkflowStatus = WorkflowStatus.Pending;
        instance.LastUpdatedAt = DateTime.UtcNow;
        instanceRepository.Update(instance);
        await instanceRepository.SaveChangesAsync(cancellationToken);

        // RETURN ← new
        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Pending, WorkflowActionType.Return,
            actionBy, remarks, cancellationToken);
    }

    // ── Reassign (admin) ─────────────────────────────────────
    public async Task ProcessReassignAsync(
        int taskId, int reassignToEmployeeId, int actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var task = await taskRepository.GetByIdWithDetailsAsync(taskId, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(taskId);

        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        if (task.TaskStatus != WorkflowTaskStatus.Pending)
            throw new WorkflowTaskAlreadyActionedException(taskId, task.TaskStatus);

        await CompleteTaskAsync(task, WorkflowTaskStatus.Cancelled, actionBy, remarks, cancellationToken);

        var newTask = new WorkflowTask
        {
            WorkflowInstanceId = task.WorkflowInstanceId,
            WorkflowStepId = task.WorkflowStepId,
            WorkflowStepApproverId = task.WorkflowStepApproverId,
            AssignedToEmployeeId = reassignToEmployeeId,
            TaskStatus = WorkflowTaskStatus.Pending,
            ParentWorkflowTaskId = taskId,
            AssignedAt = DateTime.UtcNow,
            DueAt = task.DueAt,
            ActionBy = actionBy,
            IsActive = true
        };
        await taskRepository.AddAsync(newTask, cancellationToken);
        await taskRepository.SaveChangesAsync(cancellationToken);

        await WriteHistoryAsync(task.WorkflowInstanceId, taskId, task.WorkflowStepId,
            WorkflowActionType.Reassign, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.InProgress, actionBy, cancellationToken);

        // On REASSIGN:
        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.InProgress, WorkflowActionType.Reassign, actionBy, remarks, cancellationToken);
    }

    // ── Cancel (admin/system) ────────────────────────────────
    public async Task CancelAsync(int instanceId, int actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var instance = await GetInstanceOrThrowAsync(instanceId, cancellationToken);

        if (instance.WorkflowStatus is WorkflowStatus.Approved
            or WorkflowStatus.Rejected
            or WorkflowStatus.Cancelled)
            throw new WorkflowInstanceNotCancellableException(instanceId, instance.WorkflowStatus);

        await CancelOpenTasksAsync(instanceId, null, cancellationToken);
        await WriteHistoryAsync(instanceId, null, null,
            WorkflowActionType.Cancel, remarks,
            instance.WorkflowStatus, WorkflowStatus.Cancelled, actionBy, cancellationToken);

        await TerminateInstanceAsync(instance, WorkflowStatus.Cancelled, actionBy, cancellationToken);

        // On CANCEL:
        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Cancelled, WorkflowActionType.Cancel, actionBy, remarks, cancellationToken);
    }

    // ── Withdraw (initiator only) ────────────────────────────
    public async Task WithdrawAsync(int instanceId, int actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var instance = await GetInstanceOrThrowAsync(instanceId, cancellationToken);

        if (instance.WorkflowStatus != WorkflowStatus.Pending)
            throw new WorkflowInstanceNotWithdrawableException(instanceId, instance.WorkflowStatus);

        await CancelOpenTasksAsync(instanceId, null, cancellationToken);
        await WriteHistoryAsync(instanceId, null, null,
            WorkflowActionType.Withdraw, remarks,
            WorkflowStatus.Pending, WorkflowStatus.Withdrawn, actionBy, cancellationToken);

        await TerminateInstanceAsync(instance, WorkflowStatus.Withdrawn, actionBy, cancellationToken);

        // On WITHDRAW:
        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Withdrawn, WorkflowActionType.Withdraw, actionBy, remarks, cancellationToken);
    }

    // ── Private helpers ──────────────────────────────────────

    /// <summary>
    /// Resolves approvers once per step, then creates one WorkflowTask
    /// per resolved employee per approver rule.
    /// resolver.ResolveAsync is called once — it returns all resolved
    /// approvers for the entire step, keyed by WorkflowStepApproverId.
    /// </summary>
    private async Task CreateTasksForStepAsync(WorkflowInstance instance, WorkflowStepResponse step, CancellationToken cancellationToken)
    {
        var approvers = await workflowStepApproverService.GetByStepIdAsync(step.Id, cancellationToken);
        var activeApprovers = approvers.Where(a => a.IsActive).ToList();

        if (!activeApprovers.Any())
            throw new WorkflowApproverResolutionException(step.Id,
                $"No active approver rules found for step '{step.StepName}'.");

        var dueAt = step.EscalationAfterHours.HasValue
            ? DateTime.UtcNow.AddHours(step.EscalationAfterHours.Value)
            : (DateTime?)null;

        int userId = instance.CreatedBy ?? throw new ArgumentNullException("UserId is not available");

        // Resolve all approvers for the step in a single call
        var allResolved = await resolver.ResolveApproverAsync(step.Id, userId); // Note: IWorkflowApproverResolver doesn't have CancellationToken yet
        var resolvedByRule = allResolved.ToLookup(r => r.WorkflowStepApproverId);

        foreach (var approverRule in activeApprovers.OrderBy(a => a.PriorityOrder))
        {
            var resolvedForRule = resolvedByRule[approverRule.Id].ToList();

            if (!resolvedForRule.Any())
            {
                if (approverRule.IsMandatory)
                    throw new WorkflowApproverResolutionException(step.Id,
                        $"Could not resolve mandatory approver rule {approverRule.Id} " +
                        $"(type={approverRule.WorkflowApproverType}) for step '{step.StepName}'.");
                continue; // optional rule with no match — skip
            }

            foreach (var r in resolvedForRule)
            {
                var task = new WorkflowTask
                {
                    WorkflowInstanceId = instance.Id,
                    WorkflowStepId = step.Id,
                    WorkflowStepApproverId = approverRule.Id,
                    AssignedToEmployeeId = r.ResolvedEmployeeId,
                    TaskStatus = WorkflowTaskStatus.Pending,
                    AssignedAt = DateTime.UtcNow,
                    DueAt = dueAt,
                    ActionBy = userId,
                    IsActive = true
                };
                await taskRepository.AddAsync(task, cancellationToken);
            }
        }
        await taskRepository.SaveChangesAsync(cancellationToken);
    }

    private async Task CompleteTaskAsync(
        WorkflowTask task, string newStatus, int actionBy, string? remarks, CancellationToken cancellationToken)
    {
        task.TaskStatus = newStatus;
        task.Remarks = remarks;
        task.ActionAt = DateTime.UtcNow;
        task.ActionBy = actionBy;
        taskRepository.Update(task);
        await taskRepository.SaveChangesAsync(cancellationToken);
    }

    private async Task CancelOpenTasksAsync(int instanceId, int? exceptTaskId, CancellationToken cancellationToken)
    {
        var tasks = await taskRepository.GetByInstanceIdAsync(instanceId, cancellationToken);
        foreach (var t in tasks.Where(t =>
            t.TaskStatus == WorkflowTaskStatus.Pending && t.Id != exceptTaskId))
        {
            t.TaskStatus = WorkflowTaskStatus.Cancelled;
            t.ActionAt = DateTime.UtcNow;
            taskRepository.Update(t);
        }
        await taskRepository.SaveChangesAsync(cancellationToken);
    }

    private async Task TerminateInstanceAsync(
        WorkflowInstance instance, string finalStatus, int actionBy, CancellationToken cancellationToken)
    {
        instance.WorkflowStatus = finalStatus;
        instance.CurrentWorkflowStepId = null;
        instance.CompletedAt = DateTime.UtcNow;
        instance.CompletedBy = actionBy;
        instance.LastUpdatedAt = DateTime.UtcNow;
        instanceRepository.Update(instance);
        await instanceRepository.SaveChangesAsync(cancellationToken);
    }

    private async Task WriteHistoryAsync(
        int instanceId, int? taskId, short? stepId,
        string actionType, string? remarks,
        string? fromStatus, string? toStatus, int actionBy, CancellationToken cancellationToken)
    {
        var history = new WorkflowActionHistory
        {
            WorkflowInstanceId = instanceId,
            WorkflowTaskId = taskId,
            WorkflowStepId = stepId,
            WorkflowActionType = actionType,
            Remarks = remarks,
            FromWorkflowStatus = fromStatus,
            ToWorkflowStatus = toStatus,
            ActionBy = actionBy,
            ActionAt = DateTime.UtcNow,
            IsActive = true
        };
        await historyRepository.AddAsync(history, cancellationToken);
    }

    private async Task<WorkflowTask> GetPendingTaskOrThrowAsync(int taskId, int actionBy, CancellationToken cancellationToken)
    {
        var task = await taskRepository.GetByIdWithDetailsAsync(taskId, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(taskId);

        if (task.AssignedToEmployeeId != actionBy)
            throw new WorkflowTaskNotAssignedToUserException(taskId, actionBy);

        if (task.TaskStatus != WorkflowTaskStatus.Pending)
            throw new WorkflowTaskAlreadyActionedException(taskId, task.TaskStatus);

        return task;
    }

    private async Task<WorkflowInstance> GetInstanceOrThrowAsync(int instanceId, CancellationToken cancellationToken)
    {
        return await instanceRepository.GetByIdWithDetailsAsync(instanceId, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowInstance", instanceId);
    }
}