using FluentValidation;
using SdxCore.Time.Application.DTOs.LegalEntity.Request;

namespace SdxCore.Time.Application.Validators.LegalEntity;

public sealed class UpdateLegalEntityRequestValidator : AbstractValidator<UpdateLegalEntityRequest>
{
    public UpdateLegalEntityRequestValidator()
    {
        RuleFor(x => x.EntityName).NotEmpty().MaximumLength(300);
    }
}
