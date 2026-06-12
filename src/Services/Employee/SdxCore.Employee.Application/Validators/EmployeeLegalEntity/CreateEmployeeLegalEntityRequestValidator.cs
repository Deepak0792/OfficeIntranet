using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeLegalEntity.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeLegalEntity;

public class CreateEmployeeLegalEntityRequestValidator : AbstractValidator<CreateEmployeeLegalEntityRequest>
{
    public CreateEmployeeLegalEntityRequestValidator()
    {
        RuleFor(x => x.LegalEntityId)
            .NotEmpty().WithMessage("Legal Entity ID must be valid.");

        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}
