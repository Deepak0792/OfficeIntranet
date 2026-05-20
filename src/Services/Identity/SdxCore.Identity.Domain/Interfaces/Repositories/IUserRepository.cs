using SdxCore.Common.Interfaces.Data;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Repositories;

/// <summary>
/// Repository interface for user account data access.
/// Provides methods for querying and managing user records in persistent storage.
/// </summary>
public interface IUserRepository : IRepository<User, int>
{
    /// <summary>
    /// Finds a user by username.
    /// </summary>
    /// <param name="username">Username to search for.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>User record if found; otherwise null.</returns>
    Task<User?> GetByUsernameAsync(string username, CancellationToken ct = default);

    /// <summary>
    /// Increments the failed authentication attempts counter for a user.
    /// </summary>
    /// <param name="employeeId">Employee ID.</param>
    /// <param name="ct">Cancellation token.</param>
    Task IncrementFailedAttemptsAsync(int employeeId, CancellationToken ct = default);

    /// <summary>
    /// Resets the failed authentication attempts counter to zero.
    /// </summary>
    /// <param name="employeeId">Employee ID.</param>
    /// <param name="ct">Cancellation token.</param>
    Task ResetFailedAttemptsAsync(int employeeId, CancellationToken ct = default);

    /// <summary>
    /// Updates the last login timestamp for a user.
    /// </summary>
    /// <param name="employeeId">Employee ID.</param>
    /// <param name="loginTime">Login timestamp.</param>
    /// <param name="ct">Cancellation token.</param>
    Task UpdateLastLoginAsync(int employeeId, DateTime loginTime, CancellationToken ct = default);

    /// <summary>
    /// Deactivates a user account.
    /// </summary>
    /// <param name="employeeId">Employee ID.</param>
    /// <param name="ct">Cancellation token.</param>
    Task DeactivateAsync(int employeeId, CancellationToken ct = default);

    /// <summary>
    /// Locks a user account until the specified timestamp.
    /// </summary>
    /// <param name="employeeId">Employee ID.</param>
    /// <param name="lockedUntil">Timestamp until which the account should be locked.</param>
    /// <param name="ct">Cancellation token.</param>
    Task LockAccountAsync(int employeeId, DateTime lockedUntil, CancellationToken ct = default);

    /// <summary>
    /// Updates a user's password hash.
    /// </summary>
    /// <param name="employeeId">Employee ID.</param>
    /// <param name="newPasswordHash">New password hash.</param>
    /// <param name="ct">Cancellation token.</param>
    Task UpdatePasswordHashAsync(int employeeId, string newPasswordHash, CancellationToken ct = default);
}

