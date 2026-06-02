using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;
public class UpdateEmployeeContactRequestValidator : AbstractValidator<UpdateEmployeeContactRequest>
{
    public UpdateEmployeeContactRequestValidator()
    {
        RuleFor(x => x.ContactValue)
            .NotEmpty().WithMessage("Contact Value is required.");
    }
}