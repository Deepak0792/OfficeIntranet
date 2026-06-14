namespace SdxCore.Identity.Application.DTOs.Token.Response;

public class RefreshTokenResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }

    /// <summary>The raw token value returned to the client (never stored plaintext).</summary>
    public string RawToken { get; set; } = default!;

    /// <summary>The stored hashed token value.</summary>
    public string HashToken { get; set; } = default!;

    public DateTime ExpiresAt { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string? RevokedByIp { get; set; }
    public string? Device { get; set; }
    public string? UserAgent { get; set; }
    public bool IsActive { get; set; }
}