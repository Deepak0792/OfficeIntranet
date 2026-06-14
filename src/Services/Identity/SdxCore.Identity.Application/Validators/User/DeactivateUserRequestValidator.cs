using FluentValidation;
using SdxCore.Identity.Application.DTOs.User.Request;

namespace SdxCore.Identity.Application.Validators.User;

public sealed class DeactivateUserRequestValidator : AbstractValidator<DeactivateUserRequest>
{
    public DeactivateUserRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
    }
}
