using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class CreateSkillRequestValidator : AbstractValidator<CreateSkillRequest>
{
    public CreateSkillRequestValidator()
    {
        RuleFor(x => x.SkillName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.SkillCategory).MaximumLength(100);
        RuleFor(x => x.Description).MaximumLength(1000);
    }
}
