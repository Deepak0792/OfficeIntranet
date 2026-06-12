using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Resolution.Request;

namespace SdxCore.Workflow.Application.Validators.Resolution;

public sealed class PreviewApproversRequestValidator : AbstractValidator<PreviewApproversRequest>
{
    public PreviewApproversRequestValidator()
    {
        RuleFor(x => x.WorkflowStepId).NotEmpty();
        RuleFor(x => x.InitiatorEmployeeId).NotEmpty();
    }
}
