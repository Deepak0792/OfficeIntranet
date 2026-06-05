namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowDefinitionNotFoundException(string moduleCode)
    : Exception($"No active WorkflowDefinition found for module '{moduleCode}'")
{
}
