using FluentValidation;
using SdxCore.Time.Application.DTOs.LegalEntity.Request;

namespace SdxCore.Time.Application.Validators.LegalEntity;

public sealed class CreateLegalEntityRequestValidator : AbstractValidator<CreateLegalEntityRequest>
{
    public CreateLegalEntityRequestValidator()
    {
        RuleFor(x => x.EntityCode).NotEmpty().MaximumLength(50);
        RuleFor(x => x.EntityName).NotEmpty().MaximumLength(300);
        RuleFor(x => x.CountryId).NotEmpty();
    }
}
