using SdxCore.Common.Interfaces.Contexts;
using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Persistence.Data;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace SdxCore.Identity.Persistence.Repositories;

/// <summary>
/// Repository implementation for user account data access.
/// Uses Entity Framework Core to manage User entities in SQL Server.
/// </summary>
public class UserRepository : BaseRepository<User>, IUserRepository
{
    /// <summary>
    /// Initializes a new instance of the <see cref="UserRepository"/> class.
    /// </summary>
    /// <param name="context">The database context.</param>
    public UserRepository(IdentityDbContext context, IRequestContext requestContext) : base(context, requestContext)
    {
    }

    /// <inheritdoc />
    public async Task<User?> GetByUsernameAsync(string username, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(username))
            throw new ArgumentException("Username cannot be null or empty.", nameof(username));

        return await _dbContext.Users
            .FirstOrDefaultAsync(u => u.Username == username, ct);
    }

    /// <inheritdoc />
    public async Task IncrementFailedAttemptsAsync(int employeeId, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FindAsync(new object[] { employeeId }, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.FailedAttempts++;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Locks a user account until the specified timestamp.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="lockedUntil">Timestamp until which the account should be locked.</param>
    /// <param name="ct">Cancellation token.</param>
    public async Task LockAccountAsync(int employeeId, DateTime lockedUntil, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FindAsync(new object[] { employeeId }, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.LockedUntil = lockedUntil;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Updates a user's password hash.
    /// </summary>
    /// <param name="userId">User ID.</param>
    /// <param name="newPasswordHash">New password hash.</param>
    /// <param name="ct">Cancellation token.</param>
    public async Task UpdatePasswordHashAsync(int employeeId, string newPasswordHash, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(newPasswordHash))
            throw new ArgumentException("Password hash cannot be null or empty.", nameof(newPasswordHash));

        var user = await _dbContext.Users.FindAsync(new object[] { employeeId }, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.PasswordHash = newPasswordHash;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task ResetFailedAttemptsAsync(int employeeId, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FindAsync(new object[] { employeeId }, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.FailedAttempts = 0;
        user.LockedUntil = null;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task UpdateLastLoginAsync(int employeeId, DateTime loginTime, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FindAsync(new object[] { employeeId }, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");
        user.LastLoginAt = loginTime;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task DeactivateAsync(int employeeId, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FindAsync(new object[] { employeeId }, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.IsActive = false;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }
}


