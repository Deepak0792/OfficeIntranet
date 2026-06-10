namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowTaskNotFoundException(Guid taskId)
    : Exception($"WorkflowTask '{taskId}'")
{
}