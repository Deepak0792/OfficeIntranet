using FluentValidation;
using SdxCore.Time.Application.DTOs.Region.Request;

namespace SdxCore.Time.Application.Validators.Region;

public sealed class CreateRegionRequestValidator : AbstractValidator<CreateRegionRequest>
{
    public CreateRegionRequestValidator()
    {
        RuleFor(x => x.CountryId).NotEmpty();
        RuleFor(x => x.RegionName).NotEmpty().MaximumLength(200);
    }
}
