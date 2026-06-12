using FluentValidation;
using SdxCore.Identity.Application.DTOs.Token.Request;

namespace SdxCore.Identity.Application.Validators.Token;

public sealed class RefreshTokenRequestValidator : AbstractValidator<RefreshTokenRequest>
{
    public RefreshTokenRequestValidator()
    {
        RuleFor(x => x.RefreshToken).NotEmpty();
    }
}

public sealed class RevokeTokenRequestValidator : AbstractValidator<RevokeTokenRequest>
{
    public RevokeTokenRequestValidator()
    {
        RuleFor(x => x.Token).NotEmpty();
        RuleFor(x => x.RefreshToken).NotEmpty();
    }
}
