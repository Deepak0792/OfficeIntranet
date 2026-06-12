using FluentValidation;
using SdxCore.Time.Application.DTOs.OfficeLocation.Request;

namespace SdxCore.Time.Application.Validators.OfficeLocation;

public sealed class UpdateOfficeLocationRequestValidator : AbstractValidator<UpdateOfficeLocationRequest>
{
    public UpdateOfficeLocationRequestValidator()
    {
        RuleFor(x => x.LocationName).NotEmpty().MaximumLength(200);
    }
}
