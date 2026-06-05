namespace SdxCore.Workflow.Domain.Exceptions;

public class DuplicateWorkflowCodeException(string code)
    : Exception($"A WorkflowDefinition with code '{code}'")
{
}
