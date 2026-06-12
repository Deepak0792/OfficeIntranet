using FluentValidation;
using SdxCore.Time.Application.DTOs.GeoFence.Request;

namespace SdxCore.Time.Application.Validators.GeoFence;

public sealed class UpdateGeoFenceRequestValidator : AbstractValidator<UpdateGeoFenceRequest>
{
    public UpdateGeoFenceRequestValidator()
    {
        RuleFor(x => x.GeoFenceName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.RadiusMeters).GreaterThan(0);
    }
}
