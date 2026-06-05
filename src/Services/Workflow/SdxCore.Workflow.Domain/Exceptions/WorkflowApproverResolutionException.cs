namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowApproverResolutionException(short stepId, string reason)
    : Exception($"Could not resolve approvers for WorkflowStep '{stepId}, {reason}'")
{
}
