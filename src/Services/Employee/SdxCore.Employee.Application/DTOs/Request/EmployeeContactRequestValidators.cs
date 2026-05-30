using FluentValidation;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeContactRequestValidator : AbstractValidator<AddEmployeeContactRequest>
{
    public AddEmployeeContactRequestValidator()
    {
        RuleFor(x => x.ContactType)
            .NotEmpty().WithMessage("Contact Type is required.");
        
        RuleFor(x => x.ContactValue)
            .NotEmpty().WithMessage("Contact Value is required.");
    }
}

public class UpdateEmployeeContactRequestValidator : AbstractValidator<UpdateEmployeeContactRequest>
{
    public UpdateEmployeeContactRequestValidator()
    {
        RuleFor(x => x.ContactValue)
            .NotEmpty().WithMessage("Contact Value is required.");
    }
}
