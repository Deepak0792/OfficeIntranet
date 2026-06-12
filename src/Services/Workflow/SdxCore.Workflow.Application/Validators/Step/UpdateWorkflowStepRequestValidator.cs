using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Step.Request;

namespace SdxCore.Workflow.Application.Validators.Step;

public sealed class UpdateWorkflowStepRequestValidator : AbstractValidator<UpdateWorkflowStepRequest>
{
    public UpdateWorkflowStepRequestValidator()
    {
        RuleFor(x => x.StepName).NotEmpty().MaximumLength(200);
    }
}
