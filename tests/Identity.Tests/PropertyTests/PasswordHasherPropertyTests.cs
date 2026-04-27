using FsCheck;
using FsCheck.Xunit;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.Interfaces;

namespace SdxCore.Identity.Tests.PropertyTests;

/// <summary>
/// Property-based tests for PasswordHasher using FsCheck.
/// Validates universal correctness properties across all possible inputs.
/// </summary>
public class PasswordHasherPropertyTests
{
    private readonly IPasswordHasher _passwordHasher;

    public PasswordHasherPropertyTests()
    {
        _passwordHasher = new PasswordHasher();
    }

    /// <summary>
    /// Property 1: Hash verification consistency
    /// **Validates: Requirements 8.1, 8.2, 8.3**
    /// For all passwords, Verify(password, Hash(password)) returns true
    /// </summary>
    [Property(MaxTest = 100)]
    public void HashVerificationConsistency_ForAllPasswords_VerifyReturnsTrue(NonEmptyString password)
    {
        // Arrange
        string pwd = password.Get;

        // Act
        string hash = _passwordHasher.Hash(pwd);
        bool isValid = _passwordHasher.Verify(pwd, hash);

        // Assert
        Assert.True(isValid, $"Verify(password, Hash(password)) should return true for password: {pwd.Substring(0, Math.Min(10, pwd.Length))}...");
    }

    /// <summary>
    /// Property 2: Salt randomization
    /// **Validates: Requirements 8.5**
    /// For all passwords, Hash(password) called twice produces different outputs
    /// </summary>
    [Property(MaxTest = 100)]
    public void SaltRandomization_ForAllPasswords_ProducesDifferentHashes(NonEmptyString password)
    {
        // Arrange
        string pwd = password.Get;

        // Act
        string hash1 = _passwordHasher.Hash(pwd);
        string hash2 = _passwordHasher.Hash(pwd);

        // Assert
        Assert.NotEqual(hash1, hash2);
    }
}
