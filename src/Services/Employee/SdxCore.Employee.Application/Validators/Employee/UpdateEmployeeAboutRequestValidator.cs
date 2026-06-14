using FluentValidation;
using SdxCore.Employee.Application.DTOs.Employee.Request;

namespace SdxCore.Employee.Application.Validators.Employee;

public sealed class UpdateEmployeeAboutRequestValidator : AbstractValidator<UpdateEmployeeAboutRequest>
{
    public UpdateEmployeeAboutRequestValidator()
    {
        RuleFor(x => x.AboutMe).NotEmpty().MaximumLength(1000);
    }
}
