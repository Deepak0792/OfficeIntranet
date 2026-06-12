using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Step.Request;

namespace SdxCore.Workflow.Application.Validators.Step;

public sealed class CreateWorkflowStepRequestValidator : AbstractValidator<CreateWorkflowStepRequest>
{
    public CreateWorkflowStepRequestValidator()
    {
        RuleFor(x => x.StepNo).GreaterThan((short)0);
        RuleFor(x => x.StepName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.WorkflowStepType).NotEmpty().MaximumLength(50);
    }
}
