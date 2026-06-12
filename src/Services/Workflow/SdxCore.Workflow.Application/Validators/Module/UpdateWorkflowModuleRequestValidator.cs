using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Module.Request;

namespace SdxCore.Workflow.Application.Validators.Module;

public sealed class UpdateWorkflowModuleRequestValidator : AbstractValidator<UpdateWorkflowModuleRequest>
{
    public UpdateWorkflowModuleRequestValidator()
    {
        RuleFor(x => x.ModuleName).NotEmpty().MaximumLength(200);
    }
}
