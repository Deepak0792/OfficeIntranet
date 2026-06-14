using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeTeam.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeTeam;

public sealed class UpdateEmployeeTeamRequestValidator : AbstractValidator<UpdateEmployeeTeamRequest>
{
    public UpdateEmployeeTeamRequestValidator()
    {
        RuleFor(x => x.RoleInTeam).MaximumLength(100);
        RuleFor(x => x.AllocationPercentage)
            .InclusiveBetween(0, 100).When(x => x.AllocationPercentage.HasValue);
    }
}
