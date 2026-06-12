using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Definition.Request;

namespace SdxCore.Workflow.Application.Validators.Definition;

public sealed class UpdateWorkflowDefinitionRequestValidator : AbstractValidator<UpdateWorkflowDefinitionRequest>
{
    public UpdateWorkflowDefinitionRequestValidator()
    {
        RuleFor(x => x.WorkflowName).NotEmpty().MaximumLength(300);
        RuleFor(x => x.VersionNo).GreaterThan((short)0);
    }
}
