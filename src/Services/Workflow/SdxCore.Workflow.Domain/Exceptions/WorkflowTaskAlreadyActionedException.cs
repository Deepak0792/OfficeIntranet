namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowTaskAlreadyActionedException(int taskId, string currentStatus)
    : Exception($"WorkflowTask '{taskId}' {currentStatus}")
{
}