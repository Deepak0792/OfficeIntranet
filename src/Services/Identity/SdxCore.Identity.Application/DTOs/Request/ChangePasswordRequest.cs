namespace SdxCore.Identity.Domain.DTOs.Request;

/// <summary>
/// Represents a request to change a user's password in the InHouse provider.
/// </summary>
public sealed record ChangePasswordRequest
{
    public required Guid EmployeeId { get; set; }

    /// <summary>
    /// The current password for verification.
    /// </summary>
    public required string CurrentPassword { get; init; }

    /// <summary>
    /// The new password. Will be hashed using Argon2id before storage.
    /// </summary>
    public required string NewPassword { get; init; }
}
