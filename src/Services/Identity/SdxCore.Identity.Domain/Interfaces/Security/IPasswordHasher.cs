namespace SdxCore.Identity.Domain.Interfaces.Security;

/// <summary>
/// Password hasher interface for secure password hashing and verification.
/// Uses Argon2id algorithm with random salts for maximum security.
/// </summary>
public interface IPasswordHasher
{
    /// <summary>
    /// Hashes a plaintext password using Argon2id with a random salt.
    /// </summary>
    /// <param name="password">Plaintext password to hash.</param>
    /// <returns>Hashed password string containing salt and hash.</returns>
    string Hash(string password);

    /// <summary>
    /// Verifies a plaintext password against a stored hash using constant-time comparison.
    /// </summary>
    /// <param name="password">Plaintext password to verify.</param>
    /// <param name="hash">Stored password hash.</param>
    /// <returns>True if the password matches the hash; otherwise false.</returns>
    bool Verify(string password, string hash);
}
