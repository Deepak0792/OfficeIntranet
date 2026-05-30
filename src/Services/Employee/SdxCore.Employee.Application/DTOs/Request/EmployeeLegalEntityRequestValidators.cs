using FluentValidation;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeLegalEntityRequestValidator : AbstractValidator<AddEmployeeLegalEntityRequest>
{
    public AddEmployeeLegalEntityRequestValidator()
    {
        RuleFor(x => x.LegalEntityId)
            .GreaterThan((short)0).WithMessage("Legal Entity ID must be valid.");
        
        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}

public class UpdateEmployeeLegalEntityRequestValidator : AbstractValidator<UpdateEmployeeLegalEntityRequest>
{
    public UpdateEmployeeLegalEntityRequestValidator()
    {
        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}
