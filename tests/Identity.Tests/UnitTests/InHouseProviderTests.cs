using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Providers;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces.Providers;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Domain.Interfaces.Security;
using Xunit;

namespace Identity.Tests.UnitTests;

/// <summary>
/// Unit tests for InHouseProvider authentication logic.
/// Tests cover successful authentication, invalid credentials, account status checks,
/// failed attempt tracking, and account lockout behavior.
/// </summary>
public sealed class InHouseProviderTests
{
    private readonly Mock<IUserRepository> _mockUserRepository;
    private readonly Mock<IPasswordHasher> _mockPasswordHasher;
    private readonly Mock<IConfiguration> _mockConfiguration;
    private readonly Mock<ILogger<InHouseProvider>> _mockLogger;
    private readonly InHouseProvider _provider;

    public InHouseProviderTests()
    {
        _mockUserRepository = new Mock<IUserRepository>();
        _mockPasswordHasher = new Mock<IPasswordHasher>();
        _mockConfiguration = new Mock<IConfiguration>();
        _mockLogger = new Mock<ILogger<InHouseProvider>>();

        // Setup default configuration values using IConfigurationSection
        var maxFailedAttemptsSection = new Mock<IConfigurationSection>();
        maxFailedAttemptsSection.Setup(s => s.Value).Returns("5");
        _mockConfiguration.Setup(c => c.GetSection("Authentication:MaxFailedAttempts")).Returns(maxFailedAttemptsSection.Object);

        var lockoutDurationSection = new Mock<IConfigurationSection>();
        lockoutDurationSection.Setup(s => s.Value).Returns("00:15:00");
        _mockConfiguration.Setup(c => c.GetSection("Authentication:LockoutDuration")).Returns(lockoutDurationSection.Object);

        _provider = new InHouseProvider(
            _mockUserRepository.Object,
            _mockPasswordHasher.Object,
            _mockConfiguration.Object,
            _mockLogger.Object);
    }

    [Fact]
    public void Protocol_ShouldReturnInHouse()
    {
        // Act
        AuthProtocol protocol = _provider.Protocol;

        // Assert
        Assert.Equal(AuthProtocol.InHouse, protocol);
    }

    [Fact]
    public async Task AuthenticateAsync_WithValidCredentials_ShouldReturnSuccess()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var password = "SecurePassword123!";
        var email = "test@example.com";
        var passwordHash = "hashed_password";

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = passwordHash,
            Email = email,
            IsActive = true,
            FailedAttempts = 0,
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = password
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _mockPasswordHasher
            .Setup(h => h.Verify(password, passwordHash))
            .Returns(true);

        _mockUserRepository
            .Setup(r => r.ResetFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _mockUserRepository
            .Setup(r => r.UpdateLastLoginAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.NotNull(result.Claims);
        Assert.Equal(3, result.Claims.Count);
        Assert.Contains(result.Claims, c => c.Type == "sub" && c.Value == userId.ToString());
        Assert.Contains(result.Claims, c => c.Type == "username" && c.Value == username);
        Assert.Contains(result.Claims, c => c.Type == "email" && c.Value == email);
        Assert.Null(result.FailureReason);

        // Verify repository interactions
        _mockUserRepository.Verify(r => r.ResetFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
        _mockUserRepository.Verify(r => r.UpdateLastLoginAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithNullUsername_ShouldReturnFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = "password"
        };

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Username and password are required.", result.FailureReason);
        Assert.Empty(result.Claims);
    }

    [Fact]
    public async Task AuthenticateAsync_WithEmptyPassword_ShouldReturnFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = ""
        };

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Username and password are required.", result.FailureReason);
        Assert.Empty(result.Claims);
    }

    [Fact]
    public async Task AuthenticateAsync_WithNonExistentUsername_ShouldReturnGenericError()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = "nonexistent",
            Password = "password"
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync("nonexistent", It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Invalid credentials.", result.FailureReason);
        Assert.Empty(result.Claims);
    }

    [Fact]
    public async Task AuthenticateAsync_WithWrongPassword_ShouldReturnGenericError()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var wrongPassword = "WrongPassword";
        var passwordHash = "hashed_password";

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = passwordHash,
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 2,
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = wrongPassword
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _mockPasswordHasher
            .Setup(h => h.Verify(wrongPassword, passwordHash))
            .Returns(false);

        _mockUserRepository
            .Setup(r => r.IncrementFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Invalid credentials.", result.FailureReason);
        Assert.Empty(result.Claims);

        // Verify failed attempts were incremented
        _mockUserRepository.Verify(r => r.IncrementFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithInactiveAccount_ShouldReturnFailure()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var password = "password";

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = "hashed_password",
            Email = "test@example.com",
            IsActive = false, // Account is inactive
            FailedAttempts = 0,
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = password
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Account is inactive.", result.FailureReason);
        Assert.Empty(result.Claims);

        // Verify password was never checked
        _mockPasswordHasher.Verify(h => h.Verify(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task AuthenticateAsync_WithLockedAccount_ShouldReturnFailure()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var password = "password";
        var lockedUntil = DateTimeOffset.UtcNow.AddMinutes(10); // Locked for 10 more minutes

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = "hashed_password",
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 5,
            LockedUntil = lockedUntil, // Account is locked
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = password
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Account is temporarily locked.", result.FailureReason);
        Assert.Empty(result.Claims);

        // Verify password was never checked
        _mockPasswordHasher.Verify(h => h.Verify(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task AuthenticateAsync_WithExpiredLock_ShouldAllowAuthentication()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var password = "password";
        var passwordHash = "hashed_password";
        var lockedUntil = DateTimeOffset.UtcNow.AddMinutes(-5); // Lock expired 5 minutes ago

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = passwordHash,
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 5,
            LockedUntil = lockedUntil, // Lock has expired
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = password
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _mockPasswordHasher
            .Setup(h => h.Verify(password, passwordHash))
            .Returns(true);

        _mockUserRepository
            .Setup(r => r.ResetFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _mockUserRepository
            .Setup(r => r.UpdateLastLoginAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.NotNull(result.Claims);
        Assert.Equal(3, result.Claims.Count);
    }

    [Fact]
    public async Task AuthenticateAsync_WithFailedAttempt_ShouldIncrementCounter()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var wrongPassword = "WrongPassword";
        var passwordHash = "hashed_password";

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = passwordHash,
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 2, // Currently at 2 failed attempts
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = wrongPassword
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _mockPasswordHasher
            .Setup(h => h.Verify(wrongPassword, passwordHash))
            .Returns(false);

        _mockUserRepository
            .Setup(r => r.IncrementFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        _mockUserRepository.Verify(r => r.IncrementFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithMaxFailedAttempts_ShouldLockAccount()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var wrongPassword = "WrongPassword";
        var passwordHash = "hashed_password";

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = passwordHash,
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 4, // One more attempt will reach the threshold of 5
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = wrongPassword
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _mockPasswordHasher
            .Setup(h => h.Verify(wrongPassword, passwordHash))
            .Returns(false);

        _mockUserRepository
            .Setup(r => r.IncrementFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _mockUserRepository
            .Setup(r => r.LockAccountAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Invalid credentials.", result.FailureReason);

        // Verify account was locked
        _mockUserRepository.Verify(r => r.IncrementFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
        _mockUserRepository.Verify(r => r.LockAccountAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithSuccessfulLogin_ShouldResetFailedAttempts()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var password = "password";
        var passwordHash = "hashed_password";

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = passwordHash,
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 3, // Had previous failed attempts
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = password
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _mockPasswordHasher
            .Setup(h => h.Verify(password, passwordHash))
            .Returns(true);

        _mockUserRepository
            .Setup(r => r.ResetFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _mockUserRepository
            .Setup(r => r.UpdateLastLoginAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.True(result.IsSuccess);

        // Verify failed attempts were reset
        _mockUserRepository.Verify(r => r.ResetFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
        _mockUserRepository.Verify(r => r.UpdateLastLoginAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithCustomMaxFailedAttempts_ShouldRespectConfiguration()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var username = "testuser";
        var wrongPassword = "WrongPassword";
        var passwordHash = "hashed_password";

        // Configure custom max failed attempts (3 instead of default 5)
        var customMaxAttemptsSection = new Mock<IConfigurationSection>();
        customMaxAttemptsSection.Setup(s => s.Value).Returns("3");
        _mockConfiguration.Setup(c => c.GetSection("Authentication:MaxFailedAttempts")).Returns(customMaxAttemptsSection.Object);

        var user = new User
        {
            Id = userId,
            Username = username,
            PasswordHash = passwordHash,
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 2, // One more will reach threshold of 3
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        var request = new AuthenticationRequest
        {
            Username = username,
            Password = wrongPassword
        };

        _mockUserRepository
            .Setup(r => r.FindByUsernameAsync(username, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _mockPasswordHasher
            .Setup(h => h.Verify(wrongPassword, passwordHash))
            .Returns(false);

        _mockUserRepository
            .Setup(r => r.IncrementFailedAttemptsAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _mockUserRepository
            .Setup(r => r.LockAccountAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        ProviderResult result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);

        // Verify account was locked with custom threshold
        _mockUserRepository.Verify(r => r.LockAccountAsync(userId, It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()), Times.Once);
    }
}
