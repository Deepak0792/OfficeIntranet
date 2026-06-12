using FluentValidation;
using SdxCore.Workflow.Application.DTOs.StepApprover.Request;

namespace SdxCore.Workflow.Application.Validators.StepApprover;

public sealed class CreateWorkflowStepApproverRequestValidator : AbstractValidator<CreateWorkflowStepApproverRequest>
{
    public CreateWorkflowStepApproverRequestValidator()
    {
        RuleFor(x => x.WorkflowApproverType).NotEmpty().MaximumLength(50);
        RuleFor(x => x.PriorityOrder).GreaterThan((short)0);
    }
}
