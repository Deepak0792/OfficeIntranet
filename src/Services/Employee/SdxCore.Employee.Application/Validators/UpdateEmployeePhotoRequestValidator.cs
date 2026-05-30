using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateEmployeePhotoRequestValidator : AbstractValidator<UpdateEmployeePhotoRequest>
{
    public UpdateEmployeePhotoRequestValidator()
    {
        RuleFor(x => x.ProfilePhotoUrl).NotEmpty().MaximumLength(2048);
    }
}
