namespace SdxCore.Workflow.Domain
{
    public interface IWorkflowOutboxPublisher
    {
        Task PublishStatusChangedAsync(
       Guid workflowInstanceId,
       string moduleCode,
       Guid referenceTransactionId,
       string newStatus,
       string actionType,
       Guid actionBy,
       string? remarks,
       CancellationToken cancellationToken = default);
    }
}
