using FluentValidation;
using SdxCore.Time.Application.DTOs.Designation.Request;

namespace SdxCore.Time.Application.Validators.Designation;

public sealed class CreateDesignationRequestValidator : AbstractValidator<CreateDesignationRequest>
{
    public CreateDesignationRequestValidator()
    {
        RuleFor(x => x.DesignationCode).NotEmpty().MaximumLength(50);
        RuleFor(x => x.DesignationName).NotEmpty().MaximumLength(200);
    }
}
