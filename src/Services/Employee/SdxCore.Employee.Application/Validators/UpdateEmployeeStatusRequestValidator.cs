using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateEmployeeStatusRequestValidator : AbstractValidator<UpdateEmployeeStatusRequest>
{
    public UpdateEmployeeStatusRequestValidator()
    {
        RuleFor(x => x.IsActive).NotNull();
    }
}
