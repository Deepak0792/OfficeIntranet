using FluentValidation;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeAddressRequestValidator : AbstractValidator<AddEmployeeAddressRequest>
{
    public AddEmployeeAddressRequestValidator()
    {
        RuleFor(x => x.AddressType)
            .NotEmpty().WithMessage("Address Type is required.");
            
        RuleFor(x => x.AddressLine1)
            .NotEmpty().WithMessage("Address Line 1 is required.");
            
        RuleFor(x => x.City)
            .NotEmpty().WithMessage("City is required.");
            
        RuleFor(x => x.CountryId)
            .GreaterThan((short)0).WithMessage("Country ID must be valid.");
    }
}

public class UpdateEmployeeAddressRequestValidator : AbstractValidator<UpdateEmployeeAddressRequest>
{
    public UpdateEmployeeAddressRequestValidator()
    {
        RuleFor(x => x.AddressLine1)
            .NotEmpty().WithMessage("Address Line 1 is required.");
            
        RuleFor(x => x.City)
            .NotEmpty().WithMessage("City is required.");
            
        RuleFor(x => x.CountryId)
            .GreaterThan((short)0).WithMessage("Country ID must be valid.");
    }
}
