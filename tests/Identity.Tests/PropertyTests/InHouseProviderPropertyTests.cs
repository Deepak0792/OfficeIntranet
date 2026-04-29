using FsCheck;
using FsCheck.Xunit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Providers;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces;

namespace SdxCore.Identity.Tests.PropertyTests;

/// <summary>
/// Property-based tests for InHouseProvider using FsCheck.
/// Validates universal correctness properties for password storage and authentication.
/// </summary>
public class InHouseProviderPropertyTests
{
    /// <summary>
    /// Property 9: Password never stored in plaintext
    /// **Validates: Requirements 5.6**
    /// For all CreateUserAsync calls, UserRecord.PasswordHash never equals the plaintext password
    /// </summary>
    [Property(MaxTest = 100)]
    public async Task PasswordNeverStoredInPlaintext_ForAllPasswords_HashNeverEqualsPlaintext(
        NonEmptyString username,
        NonEmptyString password,
        NonEmptyString email)
    {
        // Filter out whitespace-only strings
        if (string.IsNullOrWhiteSpace(username.Get) || 
            string.IsNullOrWhiteSpace(password.Get) || 
            string.IsNullOrWhiteSpace(email.Get))
            return;

        // Arrange - Create real PasswordHasher and mock dependencies
        var passwordHasher = new PasswordHasher();
        var userRepositoryMock = new Mock<IUserRepository>();
        var loggerMock = new Mock<ILogger<InHouseProvider>>();
        
        // Create minimal configuration
        var configData = new Dictionary<string, string>
        {
            ["Authentication:MaxFailedAttempts"] = "5",
            ["Authentication:LockoutDuration"] = "00:15:00"
        };
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configData!)
            .Build();

        // Mock FindByUsernameAsync to return null (username doesn't exist)
        userRepositoryMock
            .Setup(repo => repo.FindByUsernameAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((UserRecord?)null);

        // Capture the UserRecord that gets created
        UserRecord? capturedUser = null;
        userRepositoryMock
            .Setup(repo => repo.CreateAsync(It.IsAny<UserRecord>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((UserRecord user, CancellationToken ct) =>
            {
                capturedUser = user;
                return user;
            });

        var provider = new InHouseProvider(
            userRepositoryMock.Object,
            passwordHasher,
            configuration,
            loggerMock.Object);

        var request = new CreateUserRequest
        {
            Username = username.Get,
            Password = password.Get,
            Email = email.Get
        };

        // Act - Create user
        var createdUser = await provider.CreateUserAsync(request, CancellationToken.None);

        // Assert - Password hash must NEVER equal the plaintext password
        Assert.NotNull(createdUser);
        Assert.NotNull(createdUser.PasswordHash);
        Assert.NotEqual(password.Get, createdUser.PasswordHash);
        
        // Also verify the captured user (double-check)
        Assert.NotNull(capturedUser);
        Assert.NotEqual(password.Get, capturedUser.PasswordHash);
        
        // Verify the hash is not empty
        Assert.False(string.IsNullOrWhiteSpace(createdUser.PasswordHash));
    }

    /// <summary>
    /// Property 10: Failed attempts monotonically increase
    /// **Validates: Requirements 2.6**
    /// For all failed authentication attempts, FailedAttempts is monotonically non-decreasing until reset
    /// </summary>
    [Property(MaxTest = 100)]
    public async Task FailedAttemptsMonotonicallyIncrease_ForAllFailedAttempts_CounterNeverDecreases(
        NonEmptyString username,
        NonEmptyString correctPassword,
        NonEmptyString wrongPassword,
        PositiveInt attemptCount)
    {
        // Filter out whitespace-only strings
        if (string.IsNullOrWhiteSpace(username.Get) || 
            string.IsNullOrWhiteSpace(correctPassword.Get) || 
            string.IsNullOrWhiteSpace(wrongPassword.Get))
            return;

        // Ensure wrong password is different from correct password
        if (correctPassword.Get == wrongPassword.Get)
            return;

        // Limit attempts to a reasonable number (1-10)
        int numAttempts = Math.Min(attemptCount.Get, 10);
        if (numAttempts < 1)
            return;

        // Arrange - Create real PasswordHasher and mock dependencies
        var passwordHasher = new PasswordHasher();
        var userRepositoryMock = new Mock<IUserRepository>();
        var loggerMock = new Mock<ILogger<InHouseProvider>>();
        
        // Create minimal configuration with high threshold to avoid lockout during test
        var configData = new Dictionary<string, string>
        {
            ["Authentication:MaxFailedAttempts"] = "100",
            ["Authentication:LockoutDuration"] = "00:15:00"
        };
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configData!)
            .Build();

        // Create a user with correct password hash
        var user = new UserRecord
        {
            Id = Guid.NewGuid(),
            Username = username.Get,
            PasswordHash = passwordHasher.Hash(correctPassword.Get),
            Email = "test@example.com",
            IsActive = true,
            FailedAttempts = 0,
            LockedUntil = null,
            CreatedAt = DateTimeOffset.UtcNow,
            LastLoginAt = null
        };

        // Track FailedAttempts changes
        var failedAttemptsHistory = new List<int> { user.FailedAttempts };

        // Mock FindByUsernameAsync to return the user
        userRepositoryMock
            .Setup(repo => repo.FindByUsernameAsync(username.Get, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        // Mock IncrementFailedAttemptsAsync to simulate incrementing the counter
        userRepositoryMock
            .Setup(repo => repo.IncrementFailedAttemptsAsync(user.Id, It.IsAny<CancellationToken>()))
            .Callback<Guid, CancellationToken>((userId, ct) =>
            {
                user.FailedAttempts++;
                failedAttemptsHistory.Add(user.FailedAttempts);
            })
            .Returns(Task.CompletedTask);

        // Mock LockAccountAsync (should not be called with high threshold)
        userRepositoryMock
            .Setup(repo => repo.LockAccountAsync(It.IsAny<Guid>(), It.IsAny<DateTimeOffset>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        var provider = new InHouseProvider(
            userRepositoryMock.Object,
            passwordHasher,
            configuration,
            loggerMock.Object);

        // Act - Perform multiple failed authentication attempts
        for (int i = 0; i < numAttempts; i++)
        {
            var request = new AuthenticationRequest
            {
                Username = username.Get,
                Password = wrongPassword.Get
            };

            var result = await provider.AuthenticateAsync(request, CancellationToken.None);

            // Verify each attempt fails
            Assert.False(result.IsSuccess);
        }

        // Assert - Verify monotonic property: for all i, FailedAttempts[i+1] >= FailedAttempts[i]
        for (int i = 0; i < failedAttemptsHistory.Count - 1; i++)
        {
            Assert.True(
                failedAttemptsHistory[i + 1] >= failedAttemptsHistory[i],
                $"FailedAttempts decreased from {failedAttemptsHistory[i]} to {failedAttemptsHistory[i + 1]} at index {i}");
        }

        // Verify that IncrementFailedAttemptsAsync was called exactly numAttempts times
        userRepositoryMock.Verify(
            repo => repo.IncrementFailedAttemptsAsync(user.Id, It.IsAny<CancellationToken>()),
            Times.Exactly(numAttempts));

        // Verify final count equals initial + numAttempts
        Assert.Equal(numAttempts, user.FailedAttempts);
    }
}
