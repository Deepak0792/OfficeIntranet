using FluentValidation;
using SdxCore.Identity.Application.DTOs.Auth.Request;

namespace SdxCore.Identity.Application.Validators.Auth;

public sealed class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        // At least one auth credential must be present — protocol-specific logic handled by service
        RuleFor(x => x).Must(r =>
            !string.IsNullOrWhiteSpace(r.Username) ||
            !string.IsNullOrWhiteSpace(r.SamlAssertion) ||
            !string.IsNullOrWhiteSpace(r.OAuthCode) ||
            !string.IsNullOrWhiteSpace(r.IdToken) ||
            !string.IsNullOrWhiteSpace(r.BearerToken))
            .WithMessage("At least one authentication credential must be provided.");
    }
}
