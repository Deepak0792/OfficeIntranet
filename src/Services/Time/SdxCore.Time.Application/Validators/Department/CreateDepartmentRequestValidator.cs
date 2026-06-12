using FluentValidation;
using SdxCore.Time.Application.DTOs.Department.Request;

namespace SdxCore.Time.Application.Validators.Department;

public sealed class CreateDepartmentRequestValidator : AbstractValidator<CreateDepartmentRequest>
{
    public CreateDepartmentRequestValidator()
    {
        RuleFor(x => x.DepartmentCode).NotEmpty().MaximumLength(50);
        RuleFor(x => x.DepartmentName).NotEmpty().MaximumLength(200);
    }
}
