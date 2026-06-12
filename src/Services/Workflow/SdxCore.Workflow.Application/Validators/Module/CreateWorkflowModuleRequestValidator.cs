using FluentValidation;
using SdxCore.Workflow.Application.DTOs.Module.Request;

namespace SdxCore.Workflow.Application.Validators.Module;

public sealed class CreateWorkflowModuleRequestValidator : AbstractValidator<CreateWorkflowModuleRequest>
{
    public CreateWorkflowModuleRequestValidator()
    {
        RuleFor(x => x.ModuleCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.ModuleName).NotEmpty().MaximumLength(200);
    }
}
