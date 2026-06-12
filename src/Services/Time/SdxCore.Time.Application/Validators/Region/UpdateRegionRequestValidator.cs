using FluentValidation;
using SdxCore.Time.Application.DTOs.Region.Request;

namespace SdxCore.Time.Application.Validators.Region;

public sealed class UpdateRegionRequestValidator : AbstractValidator<UpdateRegionRequest>
{
    public UpdateRegionRequestValidator()
    {
        RuleFor(x => x.RegionName).NotEmpty().MaximumLength(200);
    }
}
