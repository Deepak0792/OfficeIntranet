using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Instance.Request;

namespace SdxCore.Workflow.Application.Validators.Instance;

public sealed class SubmitWorkflowInstanceRequestValidator : AbstractValidator<SubmitWorkflowInstanceRequest>
{
    public SubmitWorkflowInstanceRequestValidator()
    {
        RuleFor(x => x.ModuleCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.WorkflowCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.ReferenceTransactionId).NotEmpty();
        RuleFor(x => x.InitiatedByEmployeeId).NotEmpty();
    }
}
