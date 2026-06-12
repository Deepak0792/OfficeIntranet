using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Definition.Request;

namespace SdxCore.Workflow.Application.Validators.Definition;

public sealed class CreateWorkflowDefinitionRequestValidator : AbstractValidator<CreateWorkflowDefinitionRequest>
{
    public CreateWorkflowDefinitionRequestValidator()
    {
        RuleFor(x => x.WorkflowModuleId).NotEmpty();
        RuleFor(x => x.WorkflowCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.WorkflowName).NotEmpty().MaximumLength(300);
        RuleFor(x => x.VersionNo).GreaterThan((short)0);
    }
}
