using FluentValidation;
using SdxCore.Identity.Application.DTOs.Auth.Request;

namespace SdxCore.Identity.Application.Validators.Auth;

/// <summary>
/// Validates <see cref="LoginRequest"/> for presence of at least one credential field.
/// Protocol-specific field requirements are validated in <see cref="AuthenticationRequestValidator"/>.
/// </summary>
public sealed class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x).Must(r =>
            !string.IsNullOrWhiteSpace(r.Username) ||
            !string.IsNullOrWhiteSpace(r.SamlAssertion) ||
            !string.IsNullOrWhiteSpace(r.OAuthCode) ||
            !string.IsNullOrWhiteSpace(r.IdToken) ||
            !string.IsNullOrWhiteSpace(r.BearerToken))
            .WithMessage("At least one authentication credential must be provided.");
    }
}
