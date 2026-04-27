using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces;

namespace SdxCore.Identity.Application.Providers;

/// <summary>
/// Built-in authentication provider backed by SQL Server credential storage.
/// Handles username/password authentication with account lockout protection.
/// </summary>
public sealed class InHouseProvider : IInHouseProvider
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
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
        IPasswordHasher passwordHasher,
        IConfiguration configuration,
        ILogger<InHouseProvider> logger)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _passwordHasher = passwordHasher ?? throw new ArgumentNullException(nameof(passwordHasher));
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <inheritdoc />
    public AuthProtocol Protocol => AuthProtocol.InHouse;

    /// <inheritdoc />
    public async Task<ProviderResult> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default)
    {
        // 1. Validate inputs
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
        {
            _logger.LogWarning("Authentication attempt with missing username or password");
            return Fail("Username and password are required.");
        }

        // 2. Load user from SQL Server
        UserRecord? user = await _userRepository.FindByUsernameAsync(request.Username, ct);
        if (user is null)
        {
            _logger.LogWarning("Authentication attempt for non-existent user");
            // Use generic error message to prevent user enumeration
            return Fail("Invalid credentials.");
        }

        // 3. Check account status
        if (!user.IsActive)
        {
            _logger.LogWarning("Authentication attempt for inactive account: {UserId}", user.Id);
            return Fail("Account is inactive.");
        }

        if (user.LockedUntil.HasValue && user.LockedUntil > DateTimeOffset.UtcNow)
        {
            _logger.LogWarning("Authentication attempt for locked account: {UserId}, locked until {LockedUntil}", 
                user.Id, user.LockedUntil);
            return Fail("Account is temporarily locked.");
        }

        // 4. Verify password hash (Argon2id)
        bool passwordValid = _passwordHasher.Verify(request.Password, user.PasswordHash);

        if (!passwordValid)
        {
            _logger.LogWarning("Failed authentication attempt for user: {UserId}", user.Id);
            
            // Check if we need to lock the account after incrementing
            int maxFailedAttempts = _configuration.GetValue<int>(MaxFailedAttemptsKey, DefaultMaxFailedAttempts);
            int newFailedAttempts = user.FailedAttempts + 1;
            
            // Increment failed attempts
            await _userRepository.IncrementFailedAttemptsAsync(user.Id, ct);
            
            // Lock account if threshold reached
            if (newFailedAttempts >= maxFailedAttempts)
            {
                TimeSpan lockoutDuration = _configuration.GetValue<TimeSpan>(LockoutDurationKey, DefaultLockoutDuration);
                DateTimeOffset lockedUntil = DateTimeOffset.UtcNow.Add(lockoutDuration);
                await _userRepository.LockAccountAsync(user.Id, lockedUntil, ct);
                
                _logger.LogWarning("Account {UserId} locked until {LockedUntil} after {FailedAttempts} failed attempts", 
                    user.Id, lockedUntil, newFailedAttempts);
            }
            
            // Use generic error message to prevent user enumeration
            return Fail("Invalid credentials.");
        }

        // 5. Reset failed attempts on success
        await _userRepository.ResetFailedAttemptsAsync(user.Id, ct);
        await _userRepository.UpdateLastLoginAsync(user.Id, DateTimeOffset.UtcNow, ct);

        _logger.LogInformation("Successful authentication for user: {UserId}", user.Id);

        // 6. Build claims
        IReadOnlyList<Claim> claims = BuildClaims(user);

        return new ProviderResult { IsSuccess = true, Claims = claims };
    }

    /// <inheritdoc />
    public async Task<UserRecord> CreateUserAsync(CreateUserRequest request, CancellationToken ct = default)
    {
        if (request is null)
            throw new ArgumentNullException(nameof(request));

        if (string.IsNullOrWhiteSpace(request.Username))
            throw new ArgumentException("Username cannot be null or empty.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.Password))
            throw new ArgumentException("Password cannot be null or empty.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.Email))
            throw new ArgumentException("Email cannot be null or empty.", nameof(request));

        // Validate uniqueness
        UserRecord? existingUser = await _userRepository.FindByUsernameAsync(request.Username, ct);
        if (existingUser is not null)
        {
            _logger.LogWarning("Attempt to create user with duplicate username: {Username}", request.Username);
            throw new InvalidOperationException($"Username '{request.Username}' is already taken.");
        }

        // Hash password
        string passwordHash = _passwordHasher.Hash(request.Password);

        // Create UserRecord with defaults
        var user = new UserRecord
        {
            Id = Guid.NewGuid(),
            Username = request.Username,
            PasswordHash = passwordHash,
            Email = request.Email,
            IsActive = true,
            FailedAttempts = 0,
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        UserRecord createdUser = await _userRepository.CreateAsync(user, ct);
        
        _logger.LogInformation("Created new user: {UserId}, Username: {Username}", createdUser.Id, createdUser.Username);

        return createdUser;
    }

    /// <inheritdoc />
    public async Task<bool> ChangePasswordAsync(ChangePasswordRequest request, CancellationToken ct = default)
    {
        if (request is null)
            throw new ArgumentNullException(nameof(request));

        if (string.IsNullOrWhiteSpace(request.UserId))
            throw new ArgumentException("UserId cannot be null or empty.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.CurrentPassword))
            throw new ArgumentException("CurrentPassword cannot be null or empty.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.NewPassword))
            throw new ArgumentException("NewPassword cannot be null or empty.", nameof(request));

        // Parse user ID
        if (!Guid.TryParse(request.UserId, out Guid userId))
        {
            _logger.LogWarning("Invalid UserId format: {UserId}", request.UserId);
            return false;
        }

        // Load user
        UserRecord? user = await _userRepository.FindByIdAsync(userId, ct);
        if (user is null)
        {
            _logger.LogWarning("User not found: {UserId}", userId);
            return false;
        }

        // Verify current password
        bool currentPasswordValid = _passwordHasher.Verify(request.CurrentPassword, user.PasswordHash);
        if (!currentPasswordValid)
        {
            _logger.LogWarning("Invalid current password for user: {UserId}", userId);
            return false;
        }

        // Hash new password
        string newPasswordHash = _passwordHasher.Hash(request.NewPassword);

        // Update password in database
        await _userRepository.UpdatePasswordHashAsync(userId, newPasswordHash, ct);

        _logger.LogInformation("Password changed successfully for user: {UserId}", userId);

        return true;
    }

    /// <inheritdoc />
    public async Task<bool> DeactivateUserAsync(string userId, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(userId))
            throw new ArgumentException("UserId cannot be null or empty.", nameof(userId));

        // Parse user ID
        if (!Guid.TryParse(userId, out Guid userGuid))
        {
            _logger.LogWarning("Invalid UserId format: {UserId}", userId);
            return false;
        }

        try
        {
            await _userRepository.DeactivateAsync(userGuid, ct);
            _logger.LogInformation("Deactivated user: {UserId}", userGuid);
            return true;
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Failed to deactivate user: {UserId}", userGuid);
            return false;
        }
    }

    /// <summary>
    /// Builds a failure result with the specified reason.
    /// </summary>
    /// <param name="reason">Failure reason.</param>
    /// <returns>Provider result indicating failure.</returns>
    private static ProviderResult Fail(string reason)
    {
        return new ProviderResult
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
    private static IReadOnlyList<Claim> BuildClaims(UserRecord user)
    {
        return new List<Claim>
        {
            new Claim("sub", user.Id.ToString()),
            new Claim("username", user.Username),
            new Claim("email", user.Email)
        };
    }
}
