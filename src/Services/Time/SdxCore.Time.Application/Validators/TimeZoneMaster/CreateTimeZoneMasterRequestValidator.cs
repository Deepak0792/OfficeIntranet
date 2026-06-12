using FluentValidation;
using SdxCore.Time.Application.DTOs.TimeZoneMaster.Request;

namespace SdxCore.Time.Application.Validators.TimeZoneMaster;

public sealed class CreateTimeZoneMasterRequestValidator : AbstractValidator<CreateTimeZoneMasterRequest>
{
    public CreateTimeZoneMasterRequestValidator()
    {
        RuleFor(x => x.TimeZoneCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.TimeZoneName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.UtcOffset).NotEmpty().MaximumLength(10);
        RuleFor(x => x.OffsetMinutes).InclusiveBetween((short)-840, (short)840);
    }
}
