using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeContact.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeContact;

public sealed class UpdateEmployeeContactRequestValidator : AbstractValidator<UpdateEmployeeContactRequest>
{
    public UpdateEmployeeContactRequestValidator()
    {
        RuleFor(x => x.ContactType).NotEmpty().MaximumLength(50);
        RuleFor(x => x.ContactValue).NotEmpty().MaximumLength(200);
    }
}