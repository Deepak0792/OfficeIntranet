using FluentValidation;
using SdxCore.Time.Application.DTOs.GeoFence.Request;

namespace SdxCore.Time.Application.Validators.GeoFence;

public sealed class CreateGeoFenceRequestValidator : AbstractValidator<CreateGeoFenceRequest>
{
    public CreateGeoFenceRequestValidator()
    {
        RuleFor(x => x.GeoFenceCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.GeoFenceName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.RadiusMeters).GreaterThan(0);
    }
}
