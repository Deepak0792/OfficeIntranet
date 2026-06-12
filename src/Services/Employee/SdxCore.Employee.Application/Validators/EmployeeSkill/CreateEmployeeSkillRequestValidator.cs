using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeSkill.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeSkill;

public class CreateEmployeeSkillRequestValidator : AbstractValidator<CreateEmployeeSkillRequest>
{
    public CreateEmployeeSkillRequestValidator()
    {
        RuleFor(x => x.SkillId).NotEmpty();
        RuleFor(x => x.SkillLevel).MaximumLength(50);
        RuleFor(x => x.YearsOfExperience).GreaterThanOrEqualTo(0);
    }
}
