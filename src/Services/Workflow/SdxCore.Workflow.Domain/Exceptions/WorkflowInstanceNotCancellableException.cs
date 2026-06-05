namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowInstanceNotCancellableException(int instanceId, string status)
    : Exception($"WorkflowInstance '{instanceId}' {status}")
{
}