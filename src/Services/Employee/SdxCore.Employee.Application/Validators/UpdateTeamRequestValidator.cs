using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class UpdateTeamRequestValidator : AbstractValidator<UpdateTeamRequest>
{
    public UpdateTeamRequestValidator()
    {
        RuleFor(x => x.TeamName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.TeamType).MaximumLength(100);
        RuleFor(x => x.Description).MaximumLength(1000);
    }
}
