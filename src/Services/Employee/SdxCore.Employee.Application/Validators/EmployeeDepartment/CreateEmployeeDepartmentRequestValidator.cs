using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeDepartment.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeDepartment;

public sealed class CreateEmployeeDepartmentRequestValidator : AbstractValidator<CreateEmployeeDepartmentRequest>
{
    public CreateEmployeeDepartmentRequestValidator()
    {
        RuleFor(x => x.DepartmentId).NotEmpty();
        RuleFor(x => x.AllocationPercentage)
            .InclusiveBetween(0, 100).When(x => x.AllocationPercentage.HasValue);
        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate)
            .When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}