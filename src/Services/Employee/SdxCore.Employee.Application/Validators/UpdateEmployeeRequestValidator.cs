using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateEmployeeRequestValidator : AbstractValidator<UpdateEmployeeRequest>
{
    public UpdateEmployeeRequestValidator()
    {
        RuleFor(x => x.FirstName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.LastName).MaximumLength(100);
        RuleFor(x => x.DisplayName).MaximumLength(200);
        RuleFor(x => x.MobileNumber).MaximumLength(30);
        RuleFor(x => x.PreferredLanguage).MaximumLength(20);
        RuleFor(x => x.EmploymentType).NotEmpty().MaximumLength(50);
    }
}
