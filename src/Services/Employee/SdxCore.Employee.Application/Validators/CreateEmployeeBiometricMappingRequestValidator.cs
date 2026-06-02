using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class CreateEmployeeBiometricMappingRequestValidator : AbstractValidator<CreateEmployeeBiometricMappingRequest>
{
    public CreateEmployeeBiometricMappingRequestValidator()
    {
        RuleFor(x => x.BiometricDeviceId).GreaterThan(0);
        RuleFor(x => x.DeviceEmployeeCode).NotEmpty().MaximumLength(100);
    }
}
