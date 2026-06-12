using FluentValidation;
using SdxCore.Time.Application.DTOs.TimeZoneMaster.Request;

namespace SdxCore.Time.Application.Validators.TimeZoneMaster;

public sealed class UpdateTimeZoneMasterRequestValidator : AbstractValidator<UpdateTimeZoneMasterRequest>
{
    public UpdateTimeZoneMasterRequestValidator()
    {
        RuleFor(x => x.TimeZoneName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.UtcOffset).NotEmpty().MaximumLength(10);
    }
}
