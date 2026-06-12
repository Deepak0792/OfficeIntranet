using FluentValidation;
using SdxCore.Identity.Application.DTOs.User.Request;

namespace SdxCore.Identity.Application.Validators.User;

public sealed class CreateUserRequestValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.Username).NotEmpty().MaximumLength(255);
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(255);
        RuleFor(x => x.Password).NotEmpty().MinimumLength(8).MaximumLength(128);
    }
}
