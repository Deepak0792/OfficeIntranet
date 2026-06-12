using FluentValidation;
using SdxCore.Time.Application.DTOs.Designation.Request;

namespace SdxCore.Time.Application.Validators.Designation;

public sealed class UpdateDesignationRequestValidator : AbstractValidator<UpdateDesignationRequest>
{
    public UpdateDesignationRequestValidator()
    {
        RuleFor(x => x.DesignationName).NotEmpty().MaximumLength(200);
    }
}
