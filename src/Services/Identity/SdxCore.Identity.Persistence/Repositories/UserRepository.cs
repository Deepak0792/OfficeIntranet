using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces;
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

        // Check if we need to lock the account
        // This logic should ideally be in the Application layer, but for simplicity we handle it here
        // The design document mentions MaxFailedAttempts and LockoutDuration from configuration
        // For now, we just increment the counter and let the Application layer handle locking

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
