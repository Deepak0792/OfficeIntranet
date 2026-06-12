using FluentValidation;
using SdxCore.Time.Application.DTOs.ScopeType.Request;

namespace SdxCore.Time.Application.Validators.ScopeType;

public sealed class UpdateScopeTypeRequestValidator : AbstractValidator<UpdateScopeTypeRequest>
{
    public UpdateScopeTypeRequestValidator()
    {
        RuleFor(x => x.ScopeName).NotEmpty().MaximumLength(200);
    }
}
