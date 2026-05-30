using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class AddBiometricMappingRequestValidator : AbstractValidator<AddBiometricMappingRequest>
{
    public AddBiometricMappingRequestValidator()
    {
        RuleFor(x => x.BiometricDeviceId).GreaterThan(0);
        RuleFor(x => x.DeviceEmployeeCode).NotEmpty().MaximumLength(100);
    }
}
