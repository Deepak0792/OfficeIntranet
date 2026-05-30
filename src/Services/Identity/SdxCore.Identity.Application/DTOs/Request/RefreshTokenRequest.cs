namespace SdxCore.Identity.Domain.DTOs.Request;
public sealed class RefreshTokenRequest
{
    public string RefreshToken { get; set; } = default!;
}
