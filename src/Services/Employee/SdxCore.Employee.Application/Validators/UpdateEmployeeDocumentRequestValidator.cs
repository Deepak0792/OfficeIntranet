using FluentValidation;
using SdxCore.Employee.Application.DTOs.Request;

namespace SdxCore.Employee.Application.Validators;
public class UpdateEmployeeDocumentRequestValidator : AbstractValidator<UpdateEmployeeDocumentRequest>
{
    public UpdateEmployeeDocumentRequestValidator()
    {
        RuleFor(x => x.ExpiryDate)
            .GreaterThanOrEqualTo(x => x.IssuedDate).When(x => x.IssuedDate.HasValue && x.ExpiryDate.HasValue)
            .WithMessage("Expiry Date cannot be before Issued Date.");
    }
}
