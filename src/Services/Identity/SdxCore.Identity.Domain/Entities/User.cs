using SdxCore.SharedKernel.Entities;

namespace SdxCore.Identity.Domain.Entities;

/// <summary>
/// Domain entity representing a user account with credentials.
/// Stores user authentication information including hashed passwords and account status.
/// </summary>
public sealed class User : BaseAuditEntity<int>
{
    /// <summary>
    /// Unique identifier for the user account.
    /// </summary>
    public int EmployeeId { get; set; }

    /// <summary>
    /// Username for authentication. Must be unique across all users.
    /// </summary>
    public required string Username { get; set; }

    /// <summary>
    /// Argon2id hash of the user's password. Never stores plaintext passwords.
    /// </summary>
    public required string PasswordHash { get; set; }

    /// <summary>
    /// User's email address.
    /// </summary>
    public required string Email { get; set; }

    /// <summary>
    /// Counter for consecutive failed authentication attempts.
    /// Reset to zero on successful authentication.
    /// </summary>
    public int FailedAttempts { get; set; } = 0;

    /// <summary>
    /// Timestamp until which the account is locked due to excessive failed attempts.
    /// Null indicates the account is not locked.
    /// </summary>
    public DateTime? LockedUntil { get; set; }

    /// <summary>
    /// Timestamp of the user's last successful authentication.
    /// Null if the user has never logged in.
    /// </summary>
    public DateTime? LastLoginAt { get; set; }

    /// <summary>
    /// Indicates whether the account is active. Inactive accounts cannot authenticate.
    /// </summary>
    public bool IsActive { get; set; } = false;
}