using FluentValidation;
using SdxCore.Time.Application.DTOs.BiometricDevice.Request;

namespace SdxCore.Time.Application.Validators.BiometricDevice;

public sealed class CreateBiometricDeviceRequestValidator : AbstractValidator<CreateBiometricDeviceRequest>
{
    public CreateBiometricDeviceRequestValidator()
    {
        RuleFor(x => x.DeviceCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.DeviceName).NotEmpty().MaximumLength(200);
    }
}
