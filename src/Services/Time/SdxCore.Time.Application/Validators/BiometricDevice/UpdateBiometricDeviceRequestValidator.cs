using FluentValidation;
using SdxCore.Time.Application.DTOs.BiometricDevice.Request;

namespace SdxCore.Time.Application.Validators.BiometricDevice;

public sealed class UpdateBiometricDeviceRequestValidator : AbstractValidator<UpdateBiometricDeviceRequest>
{
    public UpdateBiometricDeviceRequestValidator()
    {
        RuleFor(x => x.DeviceName).NotEmpty().MaximumLength(200);
    }
}
