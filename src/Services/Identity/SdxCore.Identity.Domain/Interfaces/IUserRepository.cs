using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces;

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
    Task<UserRecord?> FindByUsernameAsync(string username, CancellationToken ct = default);

    /// <summary>
    /// Creates a new user record.
    /// </summary>
    /// <param name="user">User record to create.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>The created user record with assigned ID.</returns>
    Task<UserRecord> CreateAsync(UserRecord user, CancellationToken ct = default);

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
}
