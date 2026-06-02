using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;
public class UpdateEmployeeRelationshipRequestValidator : AbstractValidator<UpdateEmployeeRelationshipRequest>
{
    public UpdateEmployeeRelationshipRequestValidator()
    {
        RuleFor(x => x.RelationshipType)
            .NotEmpty().WithMessage("Relationship Type is required.");

        RuleFor(x => x.EffectiveTo)
            .GreaterThanOrEqualTo(x => x.EffectiveFrom).When(x => x.EffectiveFrom.HasValue && x.EffectiveTo.HasValue)
            .WithMessage("Effective To Date cannot be before Effective From Date.");
    }
}
