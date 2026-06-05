using SdxCore.Workflow.Application.Services;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowOutboxPublisher
{
    Task PublishAsync(WorkflowEvent evt, CancellationToken cancellationToken = default);
}
