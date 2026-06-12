using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Security.Cryptography;
using SdxCore.Identity.Application.Abstractions.Providers;
using SdxCore.Identity.Application.DTOs.Auth.Request;
using SdxCore.Identity.Application.DTOs.Auth.Response;
using SdxCore.Identity.Application.DTOs.User.Request;
using SdxCore.Identity.Application.Enums;
using SdxCore.Identity.Domain.Abstractions;
using SdxCore.Identity.Domain.Abstractions.Repositories;
using SdxCore.Identity.Domain.Entities;
using System.Security.Claims;

namespace SdxCore.Identity.Application.Providers;

/// <summary>
/// Built-in authentication provider backed by SQL Server credential storage.
/// Handles username/password authentication with account lockout protection.
///
/// Commit ownership inside AuthenticateAsync:
///   - Failed attempt tracking + optional lockout - single commit (must persist
///     regardless of what happens next in the auth flow)
///   - Successful login (reset attempts + last login) - single commit
///
/// All other operations (CreateUserAsync, ChangePasswordAsync, DeactivateUserAsync)
/// are standalone admin operations that each own their own commit.
/// </summary>
public sealed class InHouseProvider : IInHouseProvider
{
    private readonly IUserRepository _userRepository;
    private readonly IConfiguration _configuration;
    private readonly IIdentityUnitOfWork _unitOfWork;
    private readonly ILogger<InHouseProvider> _logger;

    private const string MaxFailedAttemptsKey = "Authentication:MaxFailedAttempts";
    private const string LockoutDurationKey = "Authentication:LockoutDuration";
    private const int DefaultMaxFailedAttempts = 5;
    private static readonly TimeSpan DefaultLockoutDuration = TimeSpan.FromMinutes(15);

    public InHouseProvider(
        IUserRepository userRepository,
        IConfiguration configuration,
        ILogger<InHouseProvider> logger,
        IIdentityUnitOfWork unitOfWork)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
    }

    public AuthProtocol Protocol => AuthProtocol.InHouse;

    // -- AuthenticateAsync ------------------------------------
    // Two possible commits:
    //   A) Password wrong: stage failed-attempt increment + optional lockout - commit
    //   B) Password correct: stage reset + last-login update - commit
    // These are intentionally separate from the refresh token commit in
    // AuthenticationService — they must persist regardless of token issuance.
    public async Task<ProviderResponse> AuthenticateAsync(
        AuthenticationRequest request,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(request.Username) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            _logger.LogWarning("Authentication attempt with missing username or password.");
            return Fail("Username and password are required.");
        }

        var user = await _userRepository.GetByUsernameAsync(request.Username, ct);
        if (user is null)
        {
            _logger.LogWarning("Authentication attempt for non-existent user.");
            return Fail("Invalid credentials.");
        }

        if (!user.IsActive)
        {
            _logger.LogWarning("Authentication attempt for inactive account: {EmployeeId}.", user.EmployeeId);
            return Fail("Account is inactive.");
        }

        if (user.LockedUntil.HasValue && user.LockedUntil > DateTime.UtcNow)
        {
            _logger.LogWarning(
                "Authentication attempt for locked account: {EmployeeId}, locked until {LockedUntil}.",
                user.EmployeeId, user.LockedUntil);
            return Fail("Account is temporarily locked.");
        }

        bool passwordValid = PasswordHasher.Verify(request.Password, user.PasswordHash);

        if (!passwordValid)
        {
            _logger.LogWarning("Failed password attempt for employee: {EmployeeId}.", user.EmployeeId);

            int maxAttempts = _configuration.GetValue(MaxFailedAttemptsKey, DefaultMaxFailedAttempts);
            int newAttempts = user.FailedAttempts + 1;

            // Stage: increment failed attempts
            await _userRepository.IncrementFailedAttemptsAsync(user.EmployeeId, ct);

            if (newAttempts >= maxAttempts)
            {
                var lockoutDuration = _configuration.GetValue(LockoutDurationKey, DefaultLockoutDuration);
                var lockedUntil = DateTime.UtcNow.Add(lockoutDuration);

                // Stage: lock account
                await _userRepository.LockAccountAsync(user.EmployeeId, lockedUntil, ct);

                _logger.LogWarning(
                    "Account {EmployeeId} locked until {LockedUntil} after {Attempts} failed attempts.",
                    user.EmployeeId, lockedUntil, newAttempts);
            }

            // -- Commit A: failed attempt tracking ------------
            await _unitOfWork.SaveChangesAsync(ct);

            return Fail("Invalid credentials.");
        }

        // Stage: reset failed attempts + record last login
        await _userRepository.ResetFailedAttemptsAsync(user.EmployeeId, ct);
        await _userRepository.UpdateLastLoginAsync(user.EmployeeId, DateTime.UtcNow, ct);

        // -- Commit B: successful login updates ----------------
        await _unitOfWork.SaveChangesAsync(ct);

        _logger.LogInformation("Successful authentication for employee: {EmployeeId}.", user.EmployeeId);

        return new ProviderResponse { IsSuccess = true, Claims = BuildClaims(user) };
    }

    // -- CreateUserAsync --------------------------------------
    // Standalone admin operation — owns its own commit.
    public async Task<User> CreateUserAsync(
        CreateUserRequest request,
        CancellationToken ct = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        if (request.EmployeeId == Guid.Empty)
            throw new ArgumentException("EmployeeId cannot be empty.", nameof(request));
        if (string.IsNullOrWhiteSpace(request.Username))
            throw new ArgumentException("Username cannot be null or empty.", nameof(request));
        if (string.IsNullOrWhiteSpace(request.Password))
            throw new ArgumentException("Password cannot be null or empty.", nameof(request));
        if (string.IsNullOrWhiteSpace(request.Email))
            throw new ArgumentException("Email cannot be null or empty.", nameof(request));

        var existing = await _userRepository.GetByUsernameAsync(request.Username, ct);
        if (existing is not null)
        {
            _logger.LogWarning("Attempt to create user with duplicate username: {Username}.", request.Username);
            throw new InvalidOperationException($"Username '{request.Username}' is already taken.");
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            EmployeeId = request.EmployeeId,
            Username = request.Username,
            PasswordHash = PasswordHasher.Hash(request.Password),
            Email = request.Email,
            IsActive = true,
            FailedAttempts = 0
        };

        var created = await _userRepository.AddAsync(user, ct);

        // Standalone — owns commit
        await _unitOfWork.SaveChangesAsync(ct);

        _logger.LogInformation(
            "Created user: {EmployeeId}, Username: {Username}.",
            created.EmployeeId, created.Username);

        return created;
    }

    // -- ChangePasswordAsync ----------------------------------
    // Standalone admin operation — owns its own commit.
    public async Task<bool> ChangePasswordAsync(
        ChangePasswordRequest request,
        CancellationToken ct = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        if (request.EmployeeId == Guid.Empty)
            throw new ArgumentException("EmployeeId cannot be empty.", nameof(request));
        if (string.IsNullOrWhiteSpace(request.CurrentPassword))
            throw new ArgumentException("CurrentPassword cannot be null or empty.", nameof(request));
        if (string.IsNullOrWhiteSpace(request.NewPassword))
            throw new ArgumentException("NewPassword cannot be null or empty.", nameof(request));

        var user = await _userRepository.GetByEmployeeIdAsync(request.EmployeeId, ct);
        if (user is null)
        {
            _logger.LogWarning("Employee not found: {EmployeeId}.", request.EmployeeId);
            return false;
        }

        if (!PasswordHasher.Verify(request.CurrentPassword, user.PasswordHash))
        {
            _logger.LogWarning("Invalid current password for employee: {EmployeeId}.", request.EmployeeId);
            return false;
        }

        var newHash = PasswordHasher.Hash(request.NewPassword);
        await _userRepository.UpdatePasswordHashAsync(request.EmployeeId, newHash, ct);

        // Standalone — owns commit
        await _unitOfWork.SaveChangesAsync(ct);

        _logger.LogInformation("Password changed for employee: {EmployeeId}.", request.EmployeeId);
        return true;
    }

    // -- DeactivateUserAsync ----------------------------------
    // Standalone admin operation — owns its own commit.
    public async Task<bool> DeactivateUserAsync(
        Guid employeeId,
        CancellationToken ct = default)
    {
        if (employeeId == Guid.Empty)
            throw new ArgumentException("EmployeeId cannot be empty.", nameof(employeeId));

        try
        {
            await _userRepository.DeactivateAsync(employeeId, ct);

            // Standalone — owns commit
            await _unitOfWork.SaveChangesAsync(ct);

            _logger.LogInformation("Deactivated employee: {EmployeeId}.", employeeId);
            return true;
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Failed to deactivate employee: {EmployeeId}.", employeeId);
            return false;
        }
    }

    private static ProviderResponse Fail(string reason) =>
        new() { IsSuccess = false, FailureReason = reason };

    private static IReadOnlyList<Claim> BuildClaims(User user) =>
    [
        new("sub",      user.EmployeeId.ToString()),
        new("username", user.Username),
        new("email",    user.Email)
    ];
}