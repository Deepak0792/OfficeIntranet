using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Module.Request;

namespace SdxCore.Workflow.Application.Validators.Module;

public sealed class UpdateWorkflowModuleRequestValidator : AbstractValidator<UpdateWorkflowModuleRequest>
{
    public UpdateWorkflowModuleRequestValidator()
    {
        RuleFor(x => x.ModuleName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Schema).NotEmpty().MaximumLength(50);
        RuleFor(x => x.EntityName).NotEmpty().MaximumLength(100);
    }
}
