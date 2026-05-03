namespace SdxCore.Identity.Domain.DTOs;
public sealed class RefreshTokenRequest
{
    public string RefreshToken { get; set; } = default!;
}
