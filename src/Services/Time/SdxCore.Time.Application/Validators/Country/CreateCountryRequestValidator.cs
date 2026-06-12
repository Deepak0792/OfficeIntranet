using FluentValidation;
using SdxCore.Time.Application.DTOs.Country.Request;

namespace SdxCore.Time.Application.Validators.Country;

public sealed class CreateCountryRequestValidator : AbstractValidator<CreateCountryRequest>
{
    public CreateCountryRequestValidator()
    {
        RuleFor(x => x.CountryCode).NotEmpty().MaximumLength(10);
        RuleFor(x => x.CountryName).NotEmpty().MaximumLength(200);
    }
}
