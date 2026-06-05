namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowTaskNotFoundException(int taskId)
    : Exception($"WorkflowTask '{taskId}'")
{
}