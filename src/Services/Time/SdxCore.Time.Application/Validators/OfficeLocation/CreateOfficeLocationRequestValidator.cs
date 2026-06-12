using FluentValidation;
using SdxCore.Time.Application.DTOs.OfficeLocation.Request;

namespace SdxCore.Time.Application.Validators.OfficeLocation;

public sealed class CreateOfficeLocationRequestValidator : AbstractValidator<CreateOfficeLocationRequest>
{
    public CreateOfficeLocationRequestValidator()
    {
        RuleFor(x => x.LegalEntityId).NotEmpty();
        RuleFor(x => x.CountryId).NotEmpty();
        RuleFor(x => x.LocationCode).NotEmpty().MaximumLength(50);
        RuleFor(x => x.LocationName).NotEmpty().MaximumLength(200);
    }
}
