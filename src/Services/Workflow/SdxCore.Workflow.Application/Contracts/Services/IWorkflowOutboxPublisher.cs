using SdxCore.SharedKernel.Events;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowOutboxPublisher
{
    Task PublishAsync(WorkflowChangedEvent evt, CancellationToken cancellationToken = default);
}
