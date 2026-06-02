using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class CreateEmployeeLegalEntityRequestValidator : AbstractValidator<CreateEmployeeLegalEntityRequest>
{
    public CreateEmployeeLegalEntityRequestValidator()
    {
        RuleFor(x => x.LegalEntityId)
            .GreaterThan((short)0).WithMessage("Legal Entity ID must be valid.");

        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}
