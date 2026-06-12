using SdxCore.Common.Enums.Workflow;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Abstractions;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Application.DTOs.Step.Response;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.Abstractions.Engine;
using SdxCore.Workflow.Application.Abstractions.Resolver;

namespace SdxCore.Workflow.Application.Engine;

public class WorkflowEngine(
    IWorkflowStepService workflowStepService,
    IWorkflowStepApproverService workflowStepApproverService,
    IWorkflowInstanceRepository instanceRepository,
    IWorkflowTaskRepository taskRepository,
    IWorkflowActionHistoryRepository historyRepository,
    IWorkflowUnitOfWork unitOfWork,
    IWorkflowApproverResolver resolver,
    IWorkflowOutboxPublisher outboxPublisher) : IWorkflowEngine
{
    // ── Submit ───────────────────────────────────────────────
    public async Task<WorkflowInstance> SubmitAsync(
        string moduleCode, string workflowCode,
        Guid referenceTransactionId, Guid initiatorEmployeeId,
        CancellationToken cancellationToken = default)
    {
        var definition = await resolver.ResolveDefinitionAsync(moduleCode, workflowCode, initiatorEmployeeId);

        var firstStep = await workflowStepService.GetNextStepAsync(definition.WorkflowDefinitionId, 0, cancellationToken)
            ?? throw new WorkflowApproverResolutionException(
                definition.WorkflowDefinitionId, "No active steps found in the workflow definition.");

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
        await instanceRepository.AddAsync(instance, cancellationToken);

        TrackHistory(instance.Id, null, firstStep.Id,
            WorkflowActionType.Submit, null,
            null, WorkflowStatus.Pending, initiatorEmployeeId);

        await TrackTasksForStepAsync(instance, firstStep, cancellationToken);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, moduleCode, referenceTransactionId,
            WorkflowStatus.Pending, WorkflowActionType.Submit, initiatorEmployeeId, null, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit

        return instance;
    }

    // ── Approve ──────────────────────────────────────────────
    public async Task ProcessApproveAsync(
        Guid taskId, Guid actionBy, string? remarks,
        CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);
        var currentStep = await workflowStepService.GetByIdAsync(task.WorkflowStepId, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowStep", task.WorkflowStepId);

        TrackCompleteTask(task, WorkflowTaskStatus.Completed, actionBy, remarks);

        TrackHistory(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Approve, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.InProgress, actionBy);

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

        if (!allMandatoryDone)
        {
            await unitOfWork.SaveChangesAsync(cancellationToken); // ← commit partial approval
            return;
        }

        if (currentStep.IsFinalStep)
        {
            TrackTerminateInstance(instance, WorkflowStatus.Approved, actionBy);
            TrackHistory(instance.Id, null, currentStep.Id,
                WorkflowActionType.Approve, "Final step approved.",
                WorkflowStatus.InProgress, WorkflowStatus.Approved, actionBy);

            await outboxPublisher.PublishStatusChangedAsync(
                instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
                WorkflowStatus.Approved, WorkflowActionType.Approve, actionBy, remarks, cancellationToken);
        }
        else
        {
            var nextStep = await workflowStepService.GetNextStepAsync(
                instance.WorkflowDefinitionId, currentStep.StepNo, cancellationToken)
                ?? throw new WorkflowApproverResolutionException(currentStep.Id, "Could not find next step.");

            instance.CurrentWorkflowStepId = nextStep.Id;
            instance.WorkflowStatus = WorkflowStatus.InProgress;
            instance.LastUpdatedAt = DateTime.UtcNow;
            instanceRepository.Update(instance);

            await TrackTasksForStepAsync(instance, nextStep, cancellationToken);
        }

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit
    }

    // ── Reject ───────────────────────────────────────────────
    public async Task ProcessRejectAsync(
        Guid taskId, Guid actionBy, string? remarks,
        CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        TrackCompleteTask(task, WorkflowTaskStatus.Completed, actionBy, remarks);
        TrackCancelOpenTasks(await taskRepository.GetByInstanceIdAsync(instance.Id, cancellationToken), taskId);

        TrackHistory(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Reject, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.Rejected, actionBy);

        TrackTerminateInstance(instance, WorkflowStatus.Rejected, actionBy);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Rejected, WorkflowActionType.Reject, actionBy, remarks, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit
    }

    // ── Delegate ─────────────────────────────────────────────
    public async Task ProcessDelegateAsync(
        Guid taskId, Guid delegateToEmployeeId, Guid actionBy, string? remarks,
        CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        TrackCompleteTask(task, WorkflowTaskStatus.Delegated, actionBy, remarks);

        var dueAt = task.Step?.EscalationAfterHours is not null
            ? DateTime.UtcNow.AddHours(task.Step.EscalationAfterHours.Value)
            : (DateTime?)null;

        await taskRepository.AddAsync(new WorkflowTask
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
        }, cancellationToken);

        TrackHistory(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Delegate, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.InProgress, actionBy);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.InProgress, WorkflowActionType.Delegate, actionBy, remarks, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit
    }

    // ── Return for clarification ─────────────────────────────
    public async Task ProcessReturnAsync(
        Guid taskId, Guid actionBy, string? remarks,
        CancellationToken cancellationToken = default)
    {
        var task = await GetPendingTaskOrThrowAsync(taskId, actionBy, cancellationToken);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        TrackCompleteTask(task, WorkflowTaskStatus.Completed, actionBy, remarks);
        TrackCancelOpenTasks(await taskRepository.GetByInstanceIdAsync(instance.Id, cancellationToken), taskId);

        TrackHistory(instance.Id, taskId, task.WorkflowStepId,
            WorkflowActionType.Return, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.Pending, actionBy);

        var firstStep = await workflowStepService.GetNextStepAsync(instance.WorkflowDefinitionId, 0, cancellationToken);
        instance.CurrentWorkflowStepId = firstStep?.Id;
        instance.WorkflowStatus = WorkflowStatus.Pending;
        instance.LastUpdatedAt = DateTime.UtcNow;
        instanceRepository.Update(instance);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Pending, WorkflowActionType.Return, actionBy, remarks, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit
    }

    // ── Reassign ─────────────────────────────────────────────
    public async Task ProcessReassignAsync(
        Guid taskId, Guid reassignToEmployeeId, Guid actionBy, string? remarks,
        CancellationToken cancellationToken = default)
    {
        var task = await taskRepository.GetByIdWithDetailsAsync(taskId, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(taskId);
        var instance = await GetInstanceOrThrowAsync(task.WorkflowInstanceId, cancellationToken);

        if (task.TaskStatus != WorkflowTaskStatus.Pending)
            throw new WorkflowTaskAlreadyActionedException(taskId, task.TaskStatus);

        TrackCompleteTask(task, WorkflowTaskStatus.Cancelled, actionBy, remarks);

        await taskRepository.AddAsync(new WorkflowTask
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
        }, cancellationToken);

        TrackHistory(task.WorkflowInstanceId, taskId, task.WorkflowStepId,
            WorkflowActionType.Reassign, remarks,
            WorkflowStatus.InProgress, WorkflowStatus.InProgress, actionBy);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.InProgress, WorkflowActionType.Reassign, actionBy, remarks, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit
    }

    // ── Cancel ───────────────────────────────────────────────
    public async Task CancelAsync(
        Guid instanceId, Guid actionBy, string? remarks,
        CancellationToken cancellationToken = default)
    {
        var instance = await GetInstanceOrThrowAsync(instanceId, cancellationToken);

        if (instance.WorkflowStatus is WorkflowStatus.Approved
            or WorkflowStatus.Rejected
            or WorkflowStatus.Cancelled)
            throw new WorkflowInstanceNotCancellableException(instanceId, instance.WorkflowStatus);

        TrackCancelOpenTasks(await taskRepository.GetByInstanceIdAsync(instanceId, cancellationToken), null);

        TrackHistory(instanceId, null, null,
            WorkflowActionType.Cancel, remarks,
            instance.WorkflowStatus, WorkflowStatus.Cancelled, actionBy);

        TrackTerminateInstance(instance, WorkflowStatus.Cancelled, actionBy);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Cancelled, WorkflowActionType.Cancel, actionBy, remarks, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit
    }

    // ── Withdraw ─────────────────────────────────────────────
    public async Task WithdrawAsync(
        Guid instanceId, Guid actionBy, string? remarks,
        CancellationToken cancellationToken = default)
    {
        var instance = await GetInstanceOrThrowAsync(instanceId, cancellationToken);

        if (instance.WorkflowStatus != WorkflowStatus.Pending)
            throw new WorkflowInstanceNotWithdrawableException(instanceId, instance.WorkflowStatus);

        TrackCancelOpenTasks(await taskRepository.GetByInstanceIdAsync(instanceId, cancellationToken), null);

        TrackHistory(instanceId, null, null,
            WorkflowActionType.Withdraw, remarks,
            WorkflowStatus.Pending, WorkflowStatus.Withdrawn, actionBy);

        TrackTerminateInstance(instance, WorkflowStatus.Withdrawn, actionBy);

        await outboxPublisher.PublishStatusChangedAsync(
            instance.Id, instance.Module!.ModuleCode, instance.ReferenceTransactionId,
            WorkflowStatus.Withdrawn, WorkflowActionType.Withdraw, actionBy, remarks, cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken); // ← single commit
    }

    // ── Private helpers (Track only — no SaveChanges) ────────

    private async Task TrackTasksForStepAsync(
        WorkflowInstance instance, WorkflowStepResponse step,
        CancellationToken cancellationToken)
    {
        var approvers = await workflowStepApproverService.GetByStepIdAsync(step.Id, cancellationToken);
        var activeApprovers = approvers.Where(a => a.IsActive).ToList();

        if (!activeApprovers.Any())
            throw new WorkflowApproverResolutionException(step.Id,
                $"No active approver rules found for step '{step.StepName}'.");

        var dueAt = step.EscalationAfterHours.HasValue
            ? DateTime.UtcNow.AddHours(step.EscalationAfterHours.Value)
            : (DateTime?)null;

        Guid userId = instance.CreatedBy
            ?? throw new ArgumentNullException(nameof(instance.CreatedBy));

        var allResolved = await resolver.ResolveApproverAsync(step.Id, userId);
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
                continue;
            }

            foreach (var r in resolvedForRule)
            {
                await taskRepository.AddAsync(new WorkflowTask
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
                }, cancellationToken);
            }
        }
        // no SaveChanges — caller commits
    }

    private void TrackCompleteTask(
        WorkflowTask task, string newStatus, Guid actionBy, string? remarks)
    {
        task.TaskStatus = newStatus;
        task.Remarks = remarks;
        task.ActionAt = DateTime.UtcNow;
        task.ActionBy = actionBy;
        taskRepository.Update(task);
        // no SaveChanges — caller commits
    }

    private void TrackCancelOpenTasks(
        IEnumerable<WorkflowTask> tasks, Guid? exceptTaskId)
    {
        foreach (var t in tasks.Where(t =>
            t.TaskStatus == WorkflowTaskStatus.Pending && t.Id != exceptTaskId))
        {
            t.TaskStatus = WorkflowTaskStatus.Cancelled;
            t.ActionAt = DateTime.UtcNow;
            taskRepository.Update(t);
        }
        // no SaveChanges — caller commits
    }

    private void TrackTerminateInstance(
        WorkflowInstance instance, string finalStatus, Guid actionBy)
    {
        instance.WorkflowStatus = finalStatus;
        instance.CurrentWorkflowStepId = null;
        instance.CompletedAt = DateTime.UtcNow;
        instance.CompletedBy = actionBy;
        instance.LastUpdatedAt = DateTime.UtcNow;
        instanceRepository.Update(instance);
        // no SaveChanges — caller commits
    }

    private void TrackHistory(
        Guid instanceId, Guid? taskId, Guid? stepId,
        string actionType, string? remarks,
        string? fromStatus, string? toStatus, Guid actionBy)
    {
        historyRepository.AddAsync(new WorkflowActionHistory
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
        });
        // no SaveChanges — caller commits
    }

    private async Task<WorkflowTask> GetPendingTaskOrThrowAsync(
        Guid taskId, Guid actionBy, CancellationToken cancellationToken)
    {
        var task = await taskRepository.GetByIdWithDetailsAsync(taskId, cancellationToken)
            ?? throw new WorkflowTaskNotFoundException(taskId);

        if (task.AssignedToEmployeeId != actionBy)
            throw new WorkflowTaskNotAssignedToUserException(taskId, actionBy);

        if (task.TaskStatus != WorkflowTaskStatus.Pending)
            throw new WorkflowTaskAlreadyActionedException(taskId, task.TaskStatus);

        return task;
    }

    private async Task<WorkflowInstance> GetInstanceOrThrowAsync(
        Guid instanceId, CancellationToken cancellationToken)
        => await instanceRepository.GetByIdWithDetailsAsync(instanceId, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowInstance", instanceId);
}