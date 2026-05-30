using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateEmployeeAboutRequestValidator : AbstractValidator<UpdateEmployeeAboutRequest>
{
    public UpdateEmployeeAboutRequestValidator()
    {
        RuleFor(x => x.AboutMe).NotEmpty().MaximumLength(1000);
    }
}
