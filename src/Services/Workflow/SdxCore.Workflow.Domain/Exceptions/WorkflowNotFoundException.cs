namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowNotFoundException(string resource, object id)
    : Exception($"Workflow {resource}' {id}")
{
}