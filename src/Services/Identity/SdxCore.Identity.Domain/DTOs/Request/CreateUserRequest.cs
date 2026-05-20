namespace SdxCore.Identity.Domain.DTOs.Request;

/// <summary>
/// Represents a request to create a new user in the InHouse provider.
/// </summary>
public sealed record CreateUserRequest
{
    public int EmployeeId { get; set; }
    /// <summary>
    /// The unique username for the new user. Must be non-null, non-empty, and unique.
    /// </summary>
    public required string Username { get; init; }

    /// <summary>
    /// The plaintext password for the new user. Will be hashed using Argon2id before storage.
    /// </summary>
    public required string Password { get; init; }

    /// <summary>
    /// The email address for the new user. Must be a valid email address.
    /// </summary>
    public required string Email { get; init; }
}
