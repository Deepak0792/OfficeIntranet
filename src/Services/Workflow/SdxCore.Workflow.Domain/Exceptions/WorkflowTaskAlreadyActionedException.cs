namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowTaskAlreadyActionedException(Guid taskId, string currentStatus)
    : Exception($"WorkflowTask '{taskId}' {currentStatus}")
{
}