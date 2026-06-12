using FluentValidation;
using SdxCore.Identity.Application.DTOs.User.Request;

namespace SdxCore.Identity.Application.Validators.User;

public sealed class ChangePasswordRequestValidator : AbstractValidator<ChangePasswordRequest>
{
    public ChangePasswordRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.CurrentPassword).NotEmpty();
        RuleFor(x => x.NewPassword).NotEmpty().MinimumLength(8).MaximumLength(128)
            .NotEqual(x => x.CurrentPassword).WithMessage("New password must differ from the current password.");
    }
}
