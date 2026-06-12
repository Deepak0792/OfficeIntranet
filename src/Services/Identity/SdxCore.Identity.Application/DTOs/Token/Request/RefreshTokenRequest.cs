namespace SdxCore.Identity.Application.DTOs.Token.Request;
public sealed class RefreshTokenRequest
{
    public string RefreshToken { get; set; } = default!;
}
