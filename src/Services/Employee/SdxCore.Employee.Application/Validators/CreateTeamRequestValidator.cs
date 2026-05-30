using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class CreateTeamRequestValidator : AbstractValidator<CreateTeamRequest>
{
    public CreateTeamRequestValidator()
    {
        RuleFor(x => x.TeamCode).NotEmpty().MaximumLength(50);
        RuleFor(x => x.TeamName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.TeamType).MaximumLength(100);
        RuleFor(x => x.Description).MaximumLength(1000);
    }
}
