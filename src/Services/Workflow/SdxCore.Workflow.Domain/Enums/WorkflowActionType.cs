namespace SdxCore.Workflow.Domain.Enums;

public static class WorkflowActionType
{
    public const string Submit = "SUBMIT";
    public const string Approve = "APPROVE";
    public const string Reject = "REJECT";
    public const string Delegate = "DELEGATE";
    public const string Escalate = "ESCALATE";
    public const string Cancel = "CANCEL";
    public const string Withdraw = "WITHDRAW";
    public const string Reassign = "REASSIGN";
    public const string Return = "RETURN_FOR_CLARIFICATION";
}
