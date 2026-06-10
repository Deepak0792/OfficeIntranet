namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowTaskNotAssignedToUserException(Guid taskId, Guid employeeId)
    : Exception($"WorkflowTask '{taskId}' {employeeId}")
{
}