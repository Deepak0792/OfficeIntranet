using FluentValidation;
using SdxCore.Time.Application.DTOs.Country.Request;

namespace SdxCore.Time.Application.Validators.Country;

public sealed class UpdateCountryRequestValidator : AbstractValidator<UpdateCountryRequest>
{
    public UpdateCountryRequestValidator()
    {
        RuleFor(x => x.CountryName).NotEmpty().MaximumLength(200);
    }
}
