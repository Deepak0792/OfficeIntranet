using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class CreateEmployeeContactRequestValidator : AbstractValidator<CreateEmployeeContactRequest>
{
    public CreateEmployeeContactRequestValidator()
    {
        RuleFor(x => x.ContactType)
            .NotEmpty().WithMessage("Contact Type is required.");

        RuleFor(x => x.ContactValue)
            .NotEmpty().WithMessage("Contact Value is required.");
    }
}