using FluentValidation;
using SdxCore.Time.Application.DTOs.ScopeType.Request;

namespace SdxCore.Time.Application.Validators.ScopeType;

public sealed class CreateScopeTypeRequestValidator : AbstractValidator<CreateScopeTypeRequest>
{
    public CreateScopeTypeRequestValidator()
    {
        RuleFor(x => x.ScopeCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.ScopeName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.HierarchyLevel).GreaterThan((short)0);
    }
}
