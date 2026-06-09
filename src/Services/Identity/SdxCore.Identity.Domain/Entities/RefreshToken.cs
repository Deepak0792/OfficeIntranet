using SdxCore.SharedKernel.Entities;

namespace SdxCore.Identity.Domain.Entities;

public class RefreshToken : BaseAuditEntity<Guid>
{
    /// <summary>
    /// Identifier of the employee this refresh token belongs to.
    /// </summary>
    public Guid EmployeeId { get; set; }

    /// <summary>
    /// Hashed value of the refresh token. Never stores plaintext tokens.
    /// </summary>
    public required string HashToken { get; set; }

    /// <summary>
    /// Timestamp when the refresh token expires.
    /// </summary>
    public DateTime ExpiresAt { get; set; }

    /// <summary>
    /// Timestamp when the refresh token was revoked.
    /// Null indicates the token has not been revoked.
    /// </summary>
    public DateTime? RevokedAt { get; set; }

    /// <summary>
    /// IP address of the client that revoked the token.
    /// Null if the token has not been revoked.
    /// </summary>
    public string? RevokedByIp { get; set; }

    /// <summary>
    /// Hash of the new token that replaced this one during rotation.
    /// Null if the token has not been rotated.
    /// </summary>
    public string? ReplacedByHashToken { get; set; }

    /// <summary>
    /// User agent string of the client that created the token.
    /// </summary>
    public string? UserAgent { get; set; }

    /// <summary>
    /// Device identifier or description of the client that created the token.
    /// </summary>
    public string? Device { get; set; }

    /// <summary>
    /// Indicates whether the refresh token is currently active.
    /// Inactive tokens cannot be used for authentication.
    /// </summary>
    public bool IsActive { get; set; } = false;

    /// <summary>
    /// IP address of the client that created the token.
    /// </summary>
    public string? CreatedByIp { get; set; }
}