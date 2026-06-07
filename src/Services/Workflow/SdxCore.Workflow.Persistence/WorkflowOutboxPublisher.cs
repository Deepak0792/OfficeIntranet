using SdxCore.SharedKernel.Constant;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Events;
using SdxCore.Workflow.Domain;
using SdxCore.Workflow.Persistence.Repositories;
using System.Text.Json;

namespace SdxCore.Workflow.Persistence;

public class WorkflowOutboxPublisher(OutboxRepository outboxRepository)
    : IWorkflowOutboxPublisher
{
    public async Task PublishStatusChangedAsync(
        int workflowInstanceId,
        string moduleCode,
        int referenceTransactionId,
        string newStatus,
        string actionType,
        int actionBy,
        string? remarks,
        CancellationToken cancellationToken = default)
    {
        var evt = new WorkflowInstanceStatusChangedEvent(
            WorkflowInstanceId: workflowInstanceId,
            ModuleCode: moduleCode,
            ReferenceTransactionId: referenceTransactionId,
            NewStatus: newStatus,
            ActionType: actionType,
            ActionBy: actionBy,
            Remarks: remarks,
            OccurredOnUtc: DateTime.UtcNow);

        var message = new OutboxMessage
        {
            Id = Guid.NewGuid(),
            EventType = typeof(WorkflowInstanceStatusChangedEvent).AssemblyQualifiedName!,
            Payload = JsonSerializer.Serialize(evt),
            Exchange = "sdxcore.events",
            RoutingKey = $"sdxcore.events.workflow.{newStatus.ToLower()}",
            Status = OutboxStatus.Pending,
            StatusGroup = "OUTBOX_STATUS",
            IsActive = true,
            RetryCount = 0,
            CreatedAt = DateTime.UtcNow,
            CreatedBy = SystemUser.SystemUserId,
            LastUpdatedAt = DateTime.UtcNow,
            LastUpdatedBy = SystemUser.SystemUserId
        };

        await outboxRepository.AddAsync(message, cancellationToken);
    }
}