using FluentValidation;
using SdxCore.Employee.Application.DTOs.Employee.Request;

namespace SdxCore.Employee.Application.Validators.Employee;

public sealed class UpdateEmployeePhotoRequestValidator : AbstractValidator<UpdateEmployeePhotoRequest>
{
    public UpdateEmployeePhotoRequestValidator()
    {
        RuleFor(x => x.ProfilePhotoUrl).NotEmpty().MaximumLength(2048);
    }
}
