namespace SdxCore.Identity.Application.DTOs.Token.Request;
public class RevokeTokenRequest
{
    public string Token { get; set; } = default!;
    public string RefreshToken { get; set; } = default!;
}