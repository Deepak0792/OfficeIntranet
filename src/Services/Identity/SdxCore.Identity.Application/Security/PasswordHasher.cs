using System.Security.Cryptography;
using System.Text;
using Konscious.Security.Cryptography;
using SdxCore.Identity.Domain.Interfaces.Security;

namespace SdxCore.Identity.Application.Security;

/// <summary>
/// Password hasher implementation using Argon2id algorithm.
/// Configured for 200-300ms hashing time with random salt generation.
/// </summary>
public sealed class PasswordHasher : IPasswordHasher
{
    // Argon2id parameters tuned for 200-300ms hashing time
    private const int SaltSize = 16; // 128 bits
    private const int HashSize = 32; // 256 bits
    private const int DegreeOfParallelism = 8;
    private const int Iterations = 4;
    private const int MemorySize = 128 * 1024; // 128 MB

    /// <summary>
    /// Hashes a plaintext password using Argon2id with a random salt.
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
        byte[] salt = GenerateSalt();

        // Hash the password with Argon2id
        byte[] hash = PasswordHash(password, salt);

        // Return salt and hash as base64 strings separated by a dot
        return $"{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }

    /// <summary>
    /// Verifies a plaintext password against a stored hash using constant-time comparison.
    /// </summary>
    /// <param name="password">Plaintext password to verify.</param>
    /// <param name="hash">Stored password hash in format "salt.hash".</param>
    /// <returns>True if the password matches the hash; otherwise false.</returns>
    public bool Verify(string password, string hash)
    {
        if (password is null || hash is null)
            return false;

        if (string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(hash))
            return false;

        try
        {
            // Parse the stored hash to extract salt and hash
            string[] parts = hash.Split('.');
            if (parts.Length != 2)
                return false;

            byte[] salt = Convert.FromBase64String(parts[0]);
            byte[] storedHash = Convert.FromBase64String(parts[1]);

            // Hash the provided password with the extracted salt
            byte[] computedHash = PasswordHash(password, salt);

            // Constant-time comparison to prevent timing attacks
            return CryptographicOperations.FixedTimeEquals(storedHash, computedHash);
        }
        catch
        {
            // Return false for any parsing or decoding errors
            return false;
        }
    }

    /// <summary>
    /// Generates a cryptographically secure random salt.
    /// </summary>
    /// <returns>Random salt bytes.</returns>
    private static byte[] GenerateSalt()
    {
        byte[] salt = new byte[SaltSize];
        RandomNumberGenerator.Fill(salt);
        return salt;
    }

    /// <summary>
    /// Hashes a password using Argon2id with the provided salt.
    /// </summary>
    /// <param name="password">Plaintext password.</param>
    /// <param name="salt">Salt bytes.</param>
    /// <returns>Hash bytes.</returns>
    private static byte[] PasswordHash(string password, byte[] salt)
    {
        using var argon2 = new Argon2id(Encoding.UTF8.GetBytes(password))
        {
            Salt = salt,
            DegreeOfParallelism = DegreeOfParallelism,
            Iterations = Iterations,
            MemorySize = MemorySize
        };

        return argon2.GetBytes(HashSize);
    }

    public string HashToken(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToBase64String(bytes);
    }

    // Secure compare
    public bool VerifyToken(string token, string storedHash)
    {
        var hash = HashToken(token);
        return CryptographicOperations.FixedTimeEquals(
            Convert.FromBase64String(hash),
            Convert.FromBase64String(storedHash)
        );
    }
}
