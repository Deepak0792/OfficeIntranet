using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;
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