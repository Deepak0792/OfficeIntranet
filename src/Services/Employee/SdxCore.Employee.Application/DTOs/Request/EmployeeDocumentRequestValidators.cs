using FluentValidation;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeDocumentRequestValidator : AbstractValidator<AddEmployeeDocumentRequest>
{
    public AddEmployeeDocumentRequestValidator()
    {
        RuleFor(x => x.DocumentTypeId)
            .GreaterThan((short)0).WithMessage("Document Type ID must be valid.");

        RuleFor(x => x.ExpiryDate)
            .GreaterThanOrEqualTo(x => x.IssuedDate).When(x => x.IssuedDate.HasValue && x.ExpiryDate.HasValue)
            .WithMessage("Expiry Date cannot be before Issued Date.");
    }
}

public class UpdateEmployeeDocumentRequestValidator : AbstractValidator<UpdateEmployeeDocumentRequest>
{
    public UpdateEmployeeDocumentRequestValidator()
    {
        RuleFor(x => x.ExpiryDate)
            .GreaterThanOrEqualTo(x => x.IssuedDate).When(x => x.IssuedDate.HasValue && x.ExpiryDate.HasValue)
            .WithMessage("Expiry Date cannot be before Issued Date.");
    }
}
