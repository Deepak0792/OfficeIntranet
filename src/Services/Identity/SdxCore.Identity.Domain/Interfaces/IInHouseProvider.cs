using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces;

/// <summary>
/// Extended authentication provider interface for in-house credential management.
/// Provides user account management operations in addition to authentication.
/// </summary>
public interface IInHouseProvider : IAuthenticationProvider
{
    /// <summary>
    /// Creates a new user account with hashed password.
    /// </summary>
    /// <param name="request">User creation request containing username, password, and email.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>The created user record with assigned ID.</returns>
    Task<UserRecord> CreateUserAsync(CreateUserRequest request, CancellationToken ct = default);

    /// <summary>
    /// Changes a user's password.
    /// </summary>
    /// <param name="request">Password change request containing user ID and new password.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>True if the password was changed successfully; otherwise false.</returns>
    Task<bool> ChangePasswordAsync(ChangePasswordRequest request, CancellationToken ct = default);

    /// <summary>
    /// Deactivates a user account, preventing future authentication.
    /// </summary>
    /// <param name="userId">User ID to deactivate.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>True if the account was deactivated successfully; otherwise false.</returns>
    Task<bool> DeactivateUserAsync(string userId, CancellationToken ct = default);
}
