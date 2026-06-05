namespace SdxCore.Workflow.Domain.Exceptions;

public class DuplicateWorkflowModuleCodeException(string code)
    : Exception($"A WorkflowModule with code '{code}'")
{
}
