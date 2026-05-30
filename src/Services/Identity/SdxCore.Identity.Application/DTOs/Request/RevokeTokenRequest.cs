namespace SdxCore.Identity.Domain.DTOs.Request;
public class RevokeTokenRequest
{
    public string Token { get; set; } = default!;
    public string RefreshToken { get; set; } = default!;
}