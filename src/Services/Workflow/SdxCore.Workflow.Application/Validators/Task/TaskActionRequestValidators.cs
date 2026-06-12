using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Task.Request;

namespace SdxCore.Workflow.Application.Validators.Task;

public sealed class ApproveTaskRequestValidator : AbstractValidator<ApproveTaskRequest>
{
    public ApproveTaskRequestValidator()
    {
        RuleFor(x => x.Remarks).MaximumLength(2000);
    }
}

public sealed class RejectTaskRequestValidator : AbstractValidator<RejectTaskRequest>
{
    public RejectTaskRequestValidator()
    {
        RuleFor(x => x.Remarks).MaximumLength(2000);
    }
}

public sealed class ReturnTaskRequestValidator : AbstractValidator<ReturnTaskRequest>
{
    public ReturnTaskRequestValidator()
    {
        RuleFor(x => x.Remarks).MaximumLength(2000);
    }
}

public sealed class DelegateTaskRequestValidator : AbstractValidator<DelegateTaskRequest>
{
    public DelegateTaskRequestValidator()
    {
        RuleFor(x => x.DelegateToEmployeeId).NotEmpty();
        RuleFor(x => x.Remarks).MaximumLength(2000);
    }
}

public sealed class ReassignTaskRequestValidator : AbstractValidator<ReassignTaskRequest>
{
    public ReassignTaskRequestValidator()
    {
        RuleFor(x => x.ReassignToEmployeeId).NotEmpty();
        RuleFor(x => x.Remarks).MaximumLength(2000);
    }
}
