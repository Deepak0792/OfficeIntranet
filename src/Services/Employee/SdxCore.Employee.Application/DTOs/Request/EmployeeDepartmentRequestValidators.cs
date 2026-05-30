using FluentValidation;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeDepartmentRequestValidator : AbstractValidator<AddEmployeeDepartmentRequest>
{
    public AddEmployeeDepartmentRequestValidator()
    {
        RuleFor(x => x.DepartmentId)
            .GreaterThan((short)0).WithMessage("Department ID must be valid.");
        
        RuleFor(x => x.AllocationPercentage)
            .InclusiveBetween(0, 100).When(x => x.AllocationPercentage.HasValue)
            .WithMessage("Allocation percentage must be between 0 and 100.");

        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}

public class UpdateEmployeeDepartmentRequestValidator : AbstractValidator<UpdateEmployeeDepartmentRequest>
{
    public UpdateEmployeeDepartmentRequestValidator()
    {
        RuleFor(x => x.AllocationPercentage)
            .InclusiveBetween(0, 100).When(x => x.AllocationPercentage.HasValue)
            .WithMessage("Allocation percentage must be between 0 and 100.");

        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}
