using FluentValidation;
using SdxCore.Time.Application.DTOs.DocumentType.Request;

namespace SdxCore.Time.Application.Validators.DocumentType;

public sealed class UpdateDocumentTypeRequestValidator : AbstractValidator<UpdateDocumentTypeRequest>
{
    public UpdateDocumentTypeRequestValidator()
    {
        RuleFor(x => x.DocumentTypeName).NotEmpty().MaximumLength(200);
    }
}
