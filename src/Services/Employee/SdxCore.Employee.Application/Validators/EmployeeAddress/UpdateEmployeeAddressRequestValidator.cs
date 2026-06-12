using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeAddress.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeAddress;
public class UpdateEmployeeAddressRequestValidator : AbstractValidator<UpdateEmployeeAddressRequest>
{
    public UpdateEmployeeAddressRequestValidator()
    {
        RuleFor(x => x.AddressLine1)
            .NotEmpty().WithMessage("Address Line 1 is required.");

        RuleFor(x => x.City)
            .NotEmpty().WithMessage("City is required.");

        RuleFor(x => x.CountryId)
            .NotEmpty().WithMessage("Country ID must be valid.");
    }
}