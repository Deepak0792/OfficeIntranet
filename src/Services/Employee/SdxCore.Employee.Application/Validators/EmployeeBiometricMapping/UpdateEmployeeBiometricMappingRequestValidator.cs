using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeBiometricMapping.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeBiometricMapping;

public sealed class UpdateEmployeeBiometricMappingRequestValidator : AbstractValidator<UpdateEmployeeBiometricMappingRequest>
{
    public UpdateEmployeeBiometricMappingRequestValidator()
    {
        RuleFor(x => x.DeviceEmployeeCode).NotEmpty().MaximumLength(100);
    }
}
