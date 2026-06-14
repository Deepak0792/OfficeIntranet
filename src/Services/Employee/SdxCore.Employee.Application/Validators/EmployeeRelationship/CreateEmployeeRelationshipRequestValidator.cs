using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeRelationship.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeRelationship;

public sealed class CreateEmployeeRelationshipRequestValidator : AbstractValidator<CreateEmployeeRelationshipRequest>
{
    public CreateEmployeeRelationshipRequestValidator()
    {
        RuleFor(x => x.ChildEmployeeId).NotEmpty();
        RuleFor(x => x.RelationshipType).NotEmpty().MaximumLength(50);
        RuleFor(x => x.EffectiveTo)
            .GreaterThanOrEqualTo(x => x.EffectiveFrom)
            .When(x => x.EffectiveFrom.HasValue && x.EffectiveTo.HasValue)
            .WithMessage("Effective To Date cannot be before Effective From Date.");
    }
}