using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeContact.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeContact;
public class UpdateEmployeeContactRequestValidator : AbstractValidator<UpdateEmployeeContactRequest>
{
    public UpdateEmployeeContactRequestValidator()
    {
        RuleFor(x => x.ContactValue)
            .NotEmpty().WithMessage("Contact Value is required.");
    }
}