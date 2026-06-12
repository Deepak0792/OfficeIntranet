using FluentValidation;
using SdxCore.Employee.Application.DTOs.Employee.Request;

namespace SdxCore.Employee.Application.Validators.Employee;

public class UpdateEmployeeStatusRequestValidator : AbstractValidator<UpdateEmployeeStatusRequest>
{
    public UpdateEmployeeStatusRequestValidator()
    {
        RuleFor(x => x.IsActive).NotNull();
    }
}
