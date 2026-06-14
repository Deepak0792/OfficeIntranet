using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeDepartment.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeDepartment;

public sealed class UpdateEmployeeDepartmentRequestValidator : AbstractValidator<UpdateEmployeeDepartmentRequest>
{
    public UpdateEmployeeDepartmentRequestValidator()
    {
        RuleFor(x => x.AllocationPercentage)
            .InclusiveBetween(0, 100).When(x => x.AllocationPercentage.HasValue);
        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate)
            .When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}