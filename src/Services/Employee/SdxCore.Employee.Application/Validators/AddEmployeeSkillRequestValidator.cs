using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class AddEmployeeSkillRequestValidator : AbstractValidator<AddEmployeeSkillRequest>
{
    public AddEmployeeSkillRequestValidator()
    {
        RuleFor(x => x.SkillId).GreaterThan((short)0);
        RuleFor(x => x.SkillLevel).MaximumLength(50);
        RuleFor(x => x.YearsOfExperience).GreaterThanOrEqualTo(0);
    }
}
