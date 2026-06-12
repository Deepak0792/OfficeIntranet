using FluentValidation;
using SdxCore.Time.Application.DTOs.Department.Request;

namespace SdxCore.Time.Application.Validators.Department;

public sealed class UpdateDepartmentRequestValidator : AbstractValidator<UpdateDepartmentRequest>
{
    public UpdateDepartmentRequestValidator()
    {
        RuleFor(x => x.DepartmentName).NotEmpty().MaximumLength(200);
    }
}
