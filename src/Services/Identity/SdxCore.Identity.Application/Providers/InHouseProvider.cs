using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Security;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Application.Interfaces;
using SdxCore.Identity.Application.Interfaces.Providers;
using System.Security.Claims;
using SdxCore.Identity.Domain.Repositories;

namespace SdxCore.Identity.Application.Providers;

/// <summary>
/// Built-in authentication provider backed by SQL Server credential storage.
/// Handles username/password authentication with account lockout protection.
/// </summary>
public sealed class InHouseProvider : IInHouseProvider
{
    private readonly IUserRepository _userRepository;
    private readonly IConfiguration _configuration;

    private readonly ILogger<InHouseProvider> _logger;

    // Configuration keys
    private const string MaxFailedAttemptsKey = "Authentication:MaxFailedAttempts";
    private const string LockoutDurationKey = "Authentication:LockoutDuration";

    // Default values
    private const int DefaultMaxFailedAttempts = 5;
    private static readonly TimeSpan DefaultLockoutDuration = TimeSpan.FromMinutes(15);

    /// <summary>
    /// Initializes a new instance of the <see cref="InHouseProvider"/> class.
    /// </summary>
    /// <param name="userRepository">Repository for user data access.</param>
    /// <param name="passwordHasher">Service for password hashing and verification.</param>
    /// <param name="configuration">Application configuration.</param>
    /// <param name="logger">Logger instance.</param>
    public InHouseProvider(
        IUserRepository userRepository,
        IConfiguration configuration,
        ILogger<InHouseProvider> logger)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <inheritdoc />
    public AuthProtocol Protocol => AuthProtocol.InHouse;

    /// <inheritdoc />
    public async Task<ProviderResponse> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default)
    {
        // 1. Validate inputs
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
        {
            _logger.LogWarning("Authentication attempt with missing username or password");
            return Fail("Username and password are required.");
        }

        // 2. Load user from SQL Server
        User? user = await _userRepository.GetByUsernameAsync(request.Username, ct);
        if (user is null)
        {
            _logger.LogWarning("Authentication attempt for non-existent employee");
            // Use generic error message to prevent user enumeration
            return Fail("Invalid credentials.");
        }

        // 3. Check account status
        if (!user.IsActive)
        {
            _logger.LogWarning("Authentication attempt for inactive account: {EmployeeId}", user.EmployeeId);
            return Fail("Account is inactive.");
        }

        if (user.LockedUntil.HasValue && user.LockedUntil > DateTime.UtcNow)
        {
            _logger.LogWarning("Authentication attempt for locked account: {EmployeeId}, locked until {LockedUntil}",
                user.EmployeeId, user.LockedUntil);
            return Fail("Account is temporarily locked.");
        }

        // 4. Verify password hash (Argon2id)
        bool passwordValid = PasswordHasher.Verify(request.Password, user.PasswordHash);

        if (!passwordValid)
        {
            _logger.LogWarning("Failed authentication attempt for employee: {EmployeeId}", user.EmployeeId);

            // Check if we need to lock the account after incrementing
            int maxFailedAttempts = _configuration.GetValue<int>(MaxFailedAttemptsKey, DefaultMaxFailedAttempts);
            int newFailedAttempts = user.FailedAttempts + 1;

            // Increment failed attempts
            await _userRepository.IncrementFailedAttemptsAsync(user.EmployeeId, ct);

            // Lock account if threshold reached
            if (newFailedAttempts >= maxFailedAttempts)
            {
                TimeSpan lockoutDuration = _configuration.GetValue<TimeSpan>(LockoutDurationKey, DefaultLockoutDuration);
                DateTime lockedUntil = DateTime.UtcNow.Add(lockoutDuration);
                await _userRepository.LockAccountAsync(user.EmployeeId, lockedUntil, ct);

                _logger.LogWarning("Account {EmployeeId} locked until {LockedUntil} after {FailedAttempts} failed attempts",
                    user.EmployeeId, lockedUntil, newFailedAttempts);
            }

            // Use generic error message to prevent user enumeration
            return Fail("Invalid credentials.");
        }

        // 5. Reset failed attempts on success
        await _userRepository.ResetFailedAttemptsAsync(user.EmployeeId, ct);
        await _userRepository.UpdateLastLoginAsync(user.EmployeeId, DateTime.UtcNow, ct);

        _logger.LogInformation("Successful authentication for employee: {EmployeeId}", user.EmployeeId);

        // 6. Build claims
        IReadOnlyList<Claim> claims = BuildClaims(user);

        return new ProviderResponse { IsSuccess = true, Claims = claims };
    }

    /// <inheritdoc />
    public async Task<User> CreateUserAsync(CreateUserRequest request, CancellationToken ct = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        if (request.EmployeeId == 0)
            throw new ArgumentException("EmployeeId cannot be null or 0.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.Username))
            throw new ArgumentException("Username cannot be null or empty.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.Password))
            throw new ArgumentException("Password cannot be null or empty.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.Email))
            throw new ArgumentException("Email cannot be null or empty.", nameof(request));

        // Validate uniqueness
        User? existingUser = await _userRepository.GetByUsernameAsync(request.Username, ct);
        if (existingUser is not null)
        {
            _logger.LogWarning("Attempt to create user with duplicate username: {Username}", request.Username);
            throw new InvalidOperationException($"Username '{request.Username}' is already taken.");
        }

        // Hash password
        string passwordHash = PasswordHasher.Hash(request.Password);

        // Create User with defaults
        var user = new User
        {
            EmployeeId = request.EmployeeId,
            Username = request.Username,
            PasswordHash = passwordHash,
            Email = request.Email,
            IsActive = true,
            FailedAttempts = 0
        };

        User createdUser = await _userRepository.AddAsync(user, ct);
        await _userRepository.SaveChangesAsync(ct);

        _logger.LogInformation("Created new employee: {EmployeeId}, Username: {Username}", createdUser.EmployeeId, createdUser.Username);

        return createdUser;
    }

    /// <inheritdoc />
    public async Task<bool> ChangePasswordAsync(ChangePasswordRequest request, CancellationToken ct = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        if (request.EmployeeId == 0)
            throw new ArgumentException("EmployeeId cannot be null or 0.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.CurrentPassword))
            throw new ArgumentException("CurrentPassword cannot be null or empty.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.NewPassword))
            throw new ArgumentException("NewPassword cannot be null or empty.", nameof(request));

        // Load user
        User? user = await _userRepository.GetByIdAsync(request.EmployeeId, ct);
        if (user is null)
        {
            _logger.LogWarning("Employee not found: {EmployeeId}", request.EmployeeId);
            return false;
        }

        // Verify current password
        bool currentPasswordValid = PasswordHasher.Verify(request.CurrentPassword, user.PasswordHash);
        if (!currentPasswordValid)
        {
            _logger.LogWarning("Invalid current password for employee: {EmployeeId}", request.EmployeeId);
            return false;
        }

        // Hash new password
        string newPasswordHash = PasswordHasher.Hash(request.NewPassword);

        // Update password in database
        await _userRepository.UpdatePasswordHashAsync(request.EmployeeId, newPasswordHash, ct);

        _logger.LogInformation("Password changed successfully for employee: {EmployeeId}", request.EmployeeId);

        return true;
    }

    /// <inheritdoc />
    public async Task<bool> DeactivateUserAsync(int employeeId, CancellationToken ct = default)
    {
        if (employeeId == 0)
            throw new ArgumentNullException("EmployeeId cannot be null or empty.", nameof(employeeId));

        try
        {
            await _userRepository.DeactivateAsync(employeeId, ct);
            _logger.LogInformation("Deactivated employee: {EmployeeId}", employeeId);
            return true;
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Failed to deactivate employee: {EmployeeId}", employeeId);
            return false;
        }
    }

    /// <summary>
    /// Builds a failure result with the specified reason.
    /// </summary>
    /// <param name="reason">Failure reason.</param>
    /// <returns>Provider result indicating failure.</returns>
    private static ProviderResponse Fail(string reason)
    {
        return new ProviderResponse
        {
            IsSuccess = false,
            FailureReason = reason
        };
    }

    /// <summary>
    /// Builds standard claims from a user record.
    /// </summary>
    /// <param name="user">User record.</param>
    /// <returns>List of claims.</returns>
    private static IReadOnlyList<Claim> BuildClaims(User user)
    {
        return new List<Claim>
        {
            new ("sub", user.EmployeeId.ToString()),
            new ("username", user.Username),
            new ("email", user.Email)
        };
    }
}
