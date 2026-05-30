using FluentValidation;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeLocationRequestValidator : AbstractValidator<AddEmployeeLocationRequest>
{
    public AddEmployeeLocationRequestValidator()
    {
        RuleFor(x => x.LocationId)
            .GreaterThan((short)0).WithMessage("Location ID must be valid.");
        
        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}

public class UpdateEmployeeLocationRequestValidator : AbstractValidator<UpdateEmployeeLocationRequest>
{
    public UpdateEmployeeLocationRequestValidator()
    {
        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}
