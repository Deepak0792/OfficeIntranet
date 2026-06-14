using FluentValidation;
using SdxCore.Identity.Application.Abstractions.Providers;
using SdxCore.Identity.Application.DTOs.Auth.Request;
using SdxCore.Identity.Application.Enums;

namespace SdxCore.Identity.Application.Validators.Auth;

/// <summary>
/// Validates <see cref="AuthenticationRequest"/> based on the resolved authentication protocol.
/// Replaces the private ValidateRequest() helper that was in AuthenticationService —
/// protocol-specific required field checks are declared here via FluentValidation.
/// </summary>
public sealed class AuthenticationRequestValidator : AbstractValidator<AuthenticationRequest>
{
    public AuthenticationRequestValidator(IProviderRegistry providerRegistry)
    {
        var protocol = providerRegistry.ResolveFromConfiguration().Protocol;

        When(_ => protocol == AuthProtocol.InHouse || protocol == AuthProtocol.Ldap, () =>
        {
            RuleFor(x => x.Username)
                .NotEmpty()
                .WithMessage($"Username is required for {protocol} authentication.");

            RuleFor(x => x.Password)
                .NotEmpty()
                .WithMessage($"Password is required for {protocol} authentication.");
        });

        When(_ => protocol == AuthProtocol.Saml, () =>
        {
            RuleFor(x => x.SamlAssertion)
                .NotEmpty()
                .WithMessage("SAML assertion is required for SAML authentication.");
        });

        When(_ => protocol == AuthProtocol.OAuth, () =>
        {
            RuleFor(x => x.OAuthCode)
                .NotEmpty()
                .WithMessage("OAuth code is required for OAuth authentication.");
        });

        When(_ => protocol == AuthProtocol.Oidc, () =>
        {
            RuleFor(x => x.IdToken)
                .NotEmpty()
                .WithMessage("ID token is required for OIDC authentication.");
        });

        When(_ => protocol == AuthProtocol.Jwt, () =>
        {
            RuleFor(x => x.BearerToken)
                .NotEmpty()
                .WithMessage("Bearer token is required for JWT authentication.");
        });
    }
}
