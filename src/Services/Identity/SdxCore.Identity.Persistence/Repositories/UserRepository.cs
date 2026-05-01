using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Persistence.Data;

namespace SdxCore.Identity.Persistence.Repositories;

/// <summary>
/// Repository implementation for user account data access.
/// Uses Entity Framework Core to manage UserRecord entities in SQL Server.
/// </summary>
public class UserRepository : IUserRepository
{
    private readonly IdentityDbContext _context;

    /// <summary>
    /// Initializes a new instance of the <see cref="UserRepository"/> class.
    /// </summary>
    /// <param name="context">The database context.</param>
    public UserRepository(IdentityDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    /// <inheritdoc />
    public async Task<UserRecord?> FindByUsernameAsync(string username, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(username))
            throw new ArgumentException("Username cannot be null or empty.", nameof(username));

        return await _context.UserRecords
            .FirstOrDefaultAsync(u => u.Username == username, ct);
    }

    /// <inheritdoc />
    public async Task<UserRecord> CreateAsync(UserRecord user, CancellationToken ct = default)
    {
        if (user is null)
            throw new ArgumentNullException(nameof(user));

        _context.UserRecords.Add(user);
        await _context.SaveChangesAsync(ct);
        return user;
    }

    /// <inheritdoc />
    public async Task IncrementFailedAttemptsAsync(Guid userId, CancellationToken ct = default)
    {
        var user = await _context.UserRecords.FindAsync(new object[] { userId }, ct);
        if (user is null)
            throw new InvalidOperationException($"User with ID {userId} not found.");

        user.FailedAttempts++;

        await _context.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Locks a user account until the specified timestamp.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="lockedUntil">Timestamp until which the account should be locked.</param>
    /// <param name="ct">Cancellation token.</param>
    public async Task LockAccountAsync(Guid userId, DateTimeOffset lockedUntil, CancellationToken ct = default)
    {
        var user = await _context.UserRecords.FindAsync(new object[] { userId }, ct);
        if (user is null)
            throw new InvalidOperationException($"User with ID {userId} not found.");

        user.LockedUntil = lockedUntil;

        await _context.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Finds a user by their unique identifier.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>User record if found; otherwise null.</returns>
    public async Task<UserRecord?> FindByIdAsync(Guid userId, CancellationToken ct = default)
    {
        return await _context.UserRecords.FindAsync(new object[] { userId }, ct);
    }

    /// <summary>
    /// Updates a user's password hash.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="newPasswordHash">New password hash.</param>
    /// <param name="ct">Cancellation token.</param>
    public async Task UpdatePasswordHashAsync(Guid userId, string newPasswordHash, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(newPasswordHash))
            throw new ArgumentException("Password hash cannot be null or empty.", nameof(newPasswordHash));

        var user = await _context.UserRecords.FindAsync(new object[] { userId }, ct);
        if (user is null)
            throw new InvalidOperationException($"User with ID {userId} not found.");

        user.PasswordHash = newPasswordHash;

        await _context.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task ResetFailedAttemptsAsync(Guid userId, CancellationToken ct = default)
    {
        var user = await _context.UserRecords.FindAsync(new object[] { userId }, ct);
        if (user is null)
            throw new InvalidOperationException($"User with ID {userId} not found.");

        user.FailedAttempts = 0;
        user.LockedUntil = null;

        await _context.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task UpdateLastLoginAsync(Guid userId, DateTimeOffset loginTime, CancellationToken ct = default)
    {
        var user = await _context.UserRecords.FindAsync(new object[] { userId }, ct);
        if (user is null)
            throw new InvalidOperationException($"User with ID {userId} not found.");

        user.LastLoginAt = loginTime;

        await _context.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task DeactivateAsync(Guid userId, CancellationToken ct = default)
    {
        var user = await _context.UserRecords.FindAsync(new object[] { userId }, ct);
        if (user is null)
            throw new InvalidOperationException($"User with ID {userId} not found.");

        user.IsActive = false;

        await _context.SaveChangesAsync(ct);
    }
}
