using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Assignment.Request;

namespace SdxCore.Workflow.Application.Validators.Assignment;

public sealed class CreateWorkflowAssignmentRequestValidator : AbstractValidator<CreateWorkflowAssignmentRequest>
{
    public CreateWorkflowAssignmentRequestValidator()
    {
        RuleFor(x => x.WorkflowDefinitionId).NotEmpty();
        RuleFor(x => x.ScopeTypeId).NotEmpty();
        RuleFor(x => x.ScopeReferenceId).NotEmpty();
        RuleFor(x => x.PriorityOrder).GreaterThan((short)0);
    }
}
