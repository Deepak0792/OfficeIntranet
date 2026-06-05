namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowTaskNotAssignedToUserException(int taskId, int employeeId)
    : Exception($"WorkflowTask '{taskId}' {employeeId}")
{
}