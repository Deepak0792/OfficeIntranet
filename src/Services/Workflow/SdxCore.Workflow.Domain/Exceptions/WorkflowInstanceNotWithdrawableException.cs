namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowInstanceNotWithdrawableException(Guid instanceId, string status)
    : Exception($"WorkflowInstance '{instanceId}' {status}")
{
}