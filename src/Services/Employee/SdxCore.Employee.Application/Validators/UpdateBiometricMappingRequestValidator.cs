using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateBiometricMappingRequestValidator : AbstractValidator<UpdateBiometricMappingRequest>
{
    public UpdateBiometricMappingRequestValidator()
    {
        RuleFor(x => x.DeviceEmployeeCode).NotEmpty().MaximumLength(100);
    }
}
