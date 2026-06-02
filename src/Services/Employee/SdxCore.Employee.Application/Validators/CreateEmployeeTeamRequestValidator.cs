using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;

public class CreateEmployeeTeamRequestValidator : AbstractValidator<CreateEmployeeTeamRequest>
{
    public CreateEmployeeTeamRequestValidator()
    {
        RuleFor(x => x.TeamId).GreaterThan((short)0);
        RuleFor(x => x.RoleInTeam).MaximumLength(100);
        RuleFor(x => x.AllocationPercentage).InclusiveBetween(0, 100).When(x => x.AllocationPercentage.HasValue);
    }
}
