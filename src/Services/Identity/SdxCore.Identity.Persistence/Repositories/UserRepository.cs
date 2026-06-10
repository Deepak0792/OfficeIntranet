using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Repositories;
using SdxCore.Identity.Persistence.Data;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Identity.Persistence.Repositories;

/// <summary>
/// Repository implementation for user account data access.
/// Uses Entity Framework Core to manage User entities in SQL Server.
/// </summary>
public class UserRepository : BaseRepository<User, Guid, IdentityDbContext>, IUserRepository
{
    /// <summary>
    /// Initializes a new instance of the <see cref="UserRepository"/> class.
    /// </summary>
    /// <param name="context">The database context.</param>
    public UserRepository(IdentityDbContext dbContext, IUserContext requestContext) : base(dbContext, requestContext) { }


    /// <inheritdoc />
    public async Task<User?> GetByUsernameAsync(string username, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(username))
            throw new ArgumentException("Username cannot be null or empty.", nameof(username));

        return await _dbContext.Users
            .SingleOrDefaultAsync(u => u.Username == username, ct);
    }

    /// <inheritdoc />
    public async Task IncrementFailedAttemptsAsync(Guid employeeId, CancellationToken ct = default)
    {
        var user = await GetByEmployeeIdAsync(employeeId, ct);
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
    public async Task LockAccountAsync(Guid employeeId, DateTime lockedUntil, CancellationToken ct = default)
    {
        var user = await GetByEmployeeIdAsync(employeeId, ct);
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
    public async Task UpdatePasswordHashAsync(Guid employeeId, string newPasswordHash, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(newPasswordHash))
            throw new ArgumentException("Password hash cannot be null or empty.", nameof(newPasswordHash));

        var user = await GetByEmployeeIdAsync(employeeId, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.PasswordHash = newPasswordHash;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task ResetFailedAttemptsAsync(Guid employeeId, CancellationToken ct = default)
    {
        var user = await GetByEmployeeIdAsync(employeeId, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.FailedAttempts = 0;
        user.LockedUntil = null;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task UpdateLastLoginAsync(Guid employeeId, DateTime loginTime, CancellationToken ct = default)
    {
        var user = await GetByEmployeeIdAsync(employeeId, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");
        user.LastLoginAt = loginTime;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    /// <inheritdoc />
    public async Task DeactivateAsync(Guid employeeId, CancellationToken ct = default)
    {
        var user = await GetByEmployeeIdAsync(employeeId, ct);
        if (user is null)
            throw new InvalidOperationException($"Employee with ID {employeeId} not found.");

        user.IsActive = false;
        Update(user);
        await _dbContext.SaveChangesAsync(ct);
    }

    private Task<User?> GetByEmployeeIdAsync(Guid employeeId, CancellationToken ct)
    {
        return _dbContext.Users
            .SingleOrDefaultAsync(u => u.EmployeeId == employeeId, ct);
    }
}


