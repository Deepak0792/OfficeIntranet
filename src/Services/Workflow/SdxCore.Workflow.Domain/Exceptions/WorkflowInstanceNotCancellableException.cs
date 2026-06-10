namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowInstanceNotCancellableException(Guid instanceId, string status)
    : Exception($"WorkflowInstance '{instanceId}' {status}")
{
}