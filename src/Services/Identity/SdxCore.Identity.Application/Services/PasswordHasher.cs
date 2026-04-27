using System.Security.Cryptography;
using System.Text;
using Konscious.Security.Cryptography;
using SdxCore.Identity.Domain.Interfaces;

namespace SdxCore.Identity.Application.Services;

/// <summary>
/// Password hasher implementation using Argon2id algorithm.
/// Provides secure password hashing with random salts and constant-time verification.
/// Configured for 200-300ms hashing time for optimal security/performance balance.
/// </summary>
public sealed class PasswordHasher : IPasswordHasher
{
    // Argon2id parameters tuned for 200-300ms hashing time
    private const int SaltSize = 16; // 128 bits
    private const int HashSize = 32; // 256 bits
    private const int Iterations = 3;
    private const int MemorySize = 49152; // 48 MB
    private const int DegreeOfParallelism = 1;

    /// <summary>
    /// Hashes a plaintext password using Argon2id with a random salt.
    /// Each invocation generates a new random salt, ensuring different outputs for the same password.
    /// </summary>
    /// <param name="password">Plaintext password to hash.</param>
    /// <returns>Base64-encoded string containing salt and hash separated by a dot.</returns>
    /// <exception cref="ArgumentNullException">Thrown when password is null.</exception>
    /// <exception cref="ArgumentException">Thrown when password is empty or whitespace.</exception>
    public string Hash(string password)
    {
        if (password is null)
            throw new ArgumentNullException(nameof(password));

        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password cannot be empty or whitespace.", nameof(password));

        // Generate random salt
        byte[] salt = GenerateRandomSalt();

        // Hash password with Argon2id
        byte[] hash = HashPassword(password, salt);

        // Return salt and hash as base64 string: "salt.hash"
        return $"{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }

    /// <summary>
    /// Verifies a plaintext password against a stored hash using constant-time comparison.
    /// </summary>
    /// <param name="password">Plaintext password to verify.</param>
    /// <param name="hash">Stored password hash in format "salt.hash".</param>
    /// <returns>True if the password matches the hash; otherwise false.</returns>
    /// <exception cref="ArgumentNullException">Thrown when password or hash is null.</exception>
    public bool Verify(string password, string hash)
    {
        if (password is null)
            throw new ArgumentNullException(nameof(password));

        if (hash is null)
            throw new ArgumentNullException(nameof(hash));

        try
        {
            // Parse stored hash to extract salt and hash
            string[] parts = hash.Split('.');
            if (parts.Length != 2)
                return false;

            byte[] salt = Convert.FromBase64String(parts[0]);
            byte[] storedHash = Convert.FromBase64String(parts[1]);

            // Hash the provided password with the extracted salt
            byte[] computedHash = HashPassword(password, salt);

            // Constant-time comparison to prevent timing attacks
            return CryptographicOperations.FixedTimeEquals(storedHash, computedHash);
        }
        catch
        {
            // If parsing or hashing fails, return false
            return false;
        }
    }

    /// <summary>
    /// Generates a cryptographically secure random salt.
    /// </summary>
    /// <returns>Random byte array of length SaltSize.</returns>
    private static byte[] GenerateRandomSalt()
    {
        byte[] salt = new byte[SaltSize];
        RandomNumberGenerator.Fill(salt);
        return salt;
    }

    /// <summary>
    /// Hashes a password using Argon2id with the specified salt.
    /// </summary>
    /// <param name="password">Plaintext password.</param>
    /// <param name="salt">Salt bytes.</param>
    /// <returns>Hash bytes.</returns>
    private static byte[] HashPassword(string password, byte[] salt)
    {
        using var argon2 = new Argon2id(Encoding.UTF8.GetBytes(password))
        {
            Salt = salt,
            DegreeOfParallelism = DegreeOfParallelism,
            MemorySize = MemorySize,
            Iterations = Iterations
        };

        return argon2.GetBytes(HashSize);
    }
}
