using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeSkill.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeSkill;

public sealed class UpdateEmployeeSkillRequestValidator : AbstractValidator<UpdateEmployeeSkillRequest>
{
    public UpdateEmployeeSkillRequestValidator()
    {
        RuleFor(x => x.SkillLevel).MaximumLength(50);
        RuleFor(x => x.YearsOfExperience).GreaterThanOrEqualTo(0);
    }
}
