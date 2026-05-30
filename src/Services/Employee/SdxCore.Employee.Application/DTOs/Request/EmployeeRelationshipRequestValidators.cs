using FluentValidation;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeRelationshipRequestValidator : AbstractValidator<AddEmployeeRelationshipRequest>
{
    public AddEmployeeRelationshipRequestValidator()
    {
        RuleFor(x => x.ChildEmployeeId)
            .GreaterThan(0).WithMessage("Child Employee ID must be valid.");
            
        RuleFor(x => x.RelationshipType)
            .NotEmpty().WithMessage("Relationship Type is required.");
        
        RuleFor(x => x.EffectiveTo)
            .GreaterThanOrEqualTo(x => x.EffectiveFrom).When(x => x.EffectiveFrom.HasValue && x.EffectiveTo.HasValue)
            .WithMessage("Effective To Date cannot be before Effective From Date.");
    }
}

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
