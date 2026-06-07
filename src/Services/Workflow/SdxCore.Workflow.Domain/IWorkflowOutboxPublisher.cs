namespace SdxCore.Workflow.Domain
{
    public interface IWorkflowOutboxPublisher
    {
        Task PublishStatusChangedAsync(
       int workflowInstanceId,
       string moduleCode,
       int referenceTransactionId,
       string newStatus,
       string actionType,
       int actionBy,
       string? remarks,
       CancellationToken cancellationToken = default);
    }
}
