using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Repositories;

/// <summary>
/// Repository interface for user account data access.
/// Provides methods for querying and managing user records in persistent storage.
/// </summary>
public interface IUserRepository
{
    /// <summary>
    /// Finds a user by username.
    /// </summary>
    /// <param name="username">Username to search for.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>User record if found; otherwise null.</returns>
    Task<User?> FindByUsernameAsync(string username, CancellationToken ct = default);

    /// <summary>
    /// Creates a new user record.
    /// </summary>
    /// <param name="user">User record to create.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>The created user record with assigned ID.</returns>
    Task<User> CreateAsync(User user, CancellationToken ct = default);

    /// <summary>
    /// Increments the failed authentication attempts counter for a user.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="ct">Cancellation token.</param>
    Task IncrementFailedAttemptsAsync(Guid userId, CancellationToken ct = default);

    /// <summary>
    /// Resets the failed authentication attempts counter to zero.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="ct">Cancellation token.</param>
    Task ResetFailedAttemptsAsync(Guid userId, CancellationToken ct = default);

    /// <summary>
    /// Updates the last login timestamp for a user.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="loginTime">Login timestamp.</param>
    /// <param name="ct">Cancellation token.</param>
    Task UpdateLastLoginAsync(Guid userId, DateTimeOffset loginTime, CancellationToken ct = default);

    /// <summary>
    /// Deactivates a user account.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="ct">Cancellation token.</param>
    Task DeactivateAsync(Guid userId, CancellationToken ct = default);

    /// <summary>
    /// Locks a user account until the specified timestamp.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="lockedUntil">Timestamp until which the account should be locked.</param>
    /// <param name="ct">Cancellation token.</param>
    Task LockAccountAsync(Guid userId, DateTimeOffset lockedUntil, CancellationToken ct = default);

    /// <summary>
    /// Finds a user by their unique identifier.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>User record if found; otherwise null.</returns>
    Task<User?> FindByIdAsync(Guid userId, CancellationToken ct = default);

    /// <summary>
    /// Updates a user's password hash.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="newPasswordHash">New password hash.</param>
    /// <param name="ct">Cancellation token.</param>
    Task UpdatePasswordHashAsync(Guid userId, string newPasswordHash, CancellationToken ct = default);
}
