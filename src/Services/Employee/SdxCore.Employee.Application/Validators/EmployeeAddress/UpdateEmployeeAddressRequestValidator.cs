using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeAddress.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeAddress;

public sealed class UpdateEmployeeAddressRequestValidator : AbstractValidator<UpdateEmployeeAddressRequest>
{
    public UpdateEmployeeAddressRequestValidator()
    {
        RuleFor(x => x.AddressLine1).NotEmpty().MaximumLength(500);
        RuleFor(x => x.AddressLine2).MaximumLength(500);
        RuleFor(x => x.Landmark).MaximumLength(200);
        RuleFor(x => x.City).NotEmpty().MaximumLength(100);
        RuleFor(x => x.StateProvince).MaximumLength(100);
        RuleFor(x => x.PostalCode).MaximumLength(20);
        RuleFor(x => x.CountryId).NotEmpty();
    }
}