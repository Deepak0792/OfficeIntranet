using FluentValidation;
using SdxCore.Employee.Application.DTOs.Skill.Request;

namespace SdxCore.Employee.Application.Validators.Skill;

public class UpdateSkillRequestValidator : AbstractValidator<UpdateSkillRequest>
{
    public UpdateSkillRequestValidator()
    {
        RuleFor(x => x.SkillName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.SkillCategory).MaximumLength(100);
        RuleFor(x => x.Description).MaximumLength(1000);
    }
}
