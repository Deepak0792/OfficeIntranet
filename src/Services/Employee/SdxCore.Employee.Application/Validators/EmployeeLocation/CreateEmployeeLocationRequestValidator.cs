using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeLocation.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeLocation;

public sealed class CreateEmployeeLocationRequestValidator : AbstractValidator<CreateEmployeeLocationRequest>
{
    public CreateEmployeeLocationRequestValidator()
    {
        RuleFor(x => x.LocationId).NotEmpty();
        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate)
            .When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End Date cannot be before Start Date.");
    }
}