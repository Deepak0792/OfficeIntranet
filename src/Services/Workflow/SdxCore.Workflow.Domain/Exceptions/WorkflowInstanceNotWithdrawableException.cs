namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowInstanceNotWithdrawableException(int instanceId, string status)
    : Exception($"WorkflowInstance '{instanceId}' {status}")
{
}