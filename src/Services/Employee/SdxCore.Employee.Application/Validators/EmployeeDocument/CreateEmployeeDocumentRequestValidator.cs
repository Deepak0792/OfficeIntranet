using FluentValidation;
using SdxCore.Employee.Application.DTOs.EmployeeDocument.Request;

namespace SdxCore.Employee.Application.Validators.EmployeeDocument;

public class CreateEmployeeDocumentRequestValidator : AbstractValidator<CreateEmployeeDocumentRequest>
{
    public CreateEmployeeDocumentRequestValidator()
    {
        RuleFor(x => x.DocumentTypeId)
            .NotEmpty().WithMessage("Document Type ID must be valid.");

        RuleFor(x => x.ExpiryDate)
            .GreaterThanOrEqualTo(x => x.IssuedDate).When(x => x.IssuedDate.HasValue && x.ExpiryDate.HasValue)
            .WithMessage("Expiry Date cannot be before Issued Date.");
    }
}