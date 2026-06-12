using FluentValidation;
using SdxCore.Time.Application.DTOs.DocumentType.Request;

namespace SdxCore.Time.Application.Validators.DocumentType;

public sealed class CreateDocumentTypeRequestValidator : AbstractValidator<CreateDocumentTypeRequest>
{
    public CreateDocumentTypeRequestValidator()
    {
        RuleFor(x => x.DocumentTypeCode).NotEmpty().MaximumLength(50);
        RuleFor(x => x.DocumentTypeName).NotEmpty().MaximumLength(200);
    }
}
