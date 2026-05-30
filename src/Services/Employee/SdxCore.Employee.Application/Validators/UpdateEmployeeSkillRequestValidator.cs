using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateEmployeeSkillRequestValidator : AbstractValidator<UpdateEmployeeSkillRequest>
{
    public UpdateEmployeeSkillRequestValidator()
    {
        RuleFor(x => x.SkillLevel).MaximumLength(50);
        RuleFor(x => x.YearsOfExperience).GreaterThanOrEqualTo(0);
    }
}
