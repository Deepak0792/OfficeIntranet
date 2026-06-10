using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class CreateEmployeeDepartmentRequestValidator : AbstractValidator<CreateEmployeeDepartmentRequest>
{
    public CreateEmployeeDepartmentRequestValidator()
    {
        RuleFor(x => x.DepartmentId)
            .NotEmpty().WithMessage("Department ID must be valid.");

        RuleFor(x => x.AllocationPercentage)
            .InclusiveBetween(0, 100).When(x => x.AllocationPercentage.HasValue)
            .WithMessage("Allocation percentage must be between 0 and 100.");

        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}