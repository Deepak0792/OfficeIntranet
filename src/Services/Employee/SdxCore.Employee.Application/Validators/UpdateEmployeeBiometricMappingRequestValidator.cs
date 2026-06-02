using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateEmployeeBiometricMappingRequestValidator : AbstractValidator<UpdateEmployeeBiometricMappingRequest>
{
    public UpdateEmployeeBiometricMappingRequestValidator()
    {
        RuleFor(x => x.DeviceEmployeeCode).NotEmpty().MaximumLength(100);
    }
}
