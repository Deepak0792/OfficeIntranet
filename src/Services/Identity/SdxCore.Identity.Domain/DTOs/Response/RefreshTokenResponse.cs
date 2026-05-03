namespace SdxCore.Identity.Domain.DTOs.Response;
public class RefreshTokenResponse
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string RawToken { get; set; } = default!;
    public string HashToken { get; set; } = default!;
    public DateTimeOffset ExpiresAt { get; set; }
}