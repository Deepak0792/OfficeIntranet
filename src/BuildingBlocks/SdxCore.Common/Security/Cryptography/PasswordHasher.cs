using System.Security.Cryptography;
using System.Text;
using Konscious.Security.Cryptography;

namespace SdxCore.Common.Security.Cryptography;

/// <summary>
/// Provides static methods for password hashing, token hashing, and AES-GCM encryption.
/// </summary>
public static class PasswordHasher
{
    // Argon2id parameters tuned for 200-300ms hashing time
    private const int SaltSize = 16;           // 128 bits
    private const int HashSize = 32;           // 256 bits
    private const int DegreeOfParallelism = 8;
    private const int Iterations = 4;
    private const int MemorySize = 128 * 1024; // 128 MB

    private const int NonceSize = 12;
    private const int TagSize = 16;

    private const string EncryptionKey = "sdxcore-my-secret-key-encryption-key";
    private static readonly byte[] AesKey = DeriveAes256KeyFromString(EncryptionKey);

    /// <summary>
    /// Hashes a plaintext password using Argon2id with a random salt.
    /// </summary>
    public static string Hash(string password)
    {
        if (password is null)
            throw new ArgumentNullException(nameof(password));

        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password cannot be empty or whitespace.", nameof(password));

        byte[] salt = GenerateSalt();
        byte[] hash = ComputeArgon2idHash(password, salt);

        return $"{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }

    /// <summary>
    /// Verifies a plaintext password against a stored hash using constant-time comparison.
    /// </summary>
    public static bool Verify(string password, string hash)
    {
        if (password is null || hash is null)
            return false;

        if (string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(hash))
            return false;

        try
        {
            string[] parts = hash.Split('.');
            if (parts.Length != 2)
                return false;

            byte[] salt = Convert.FromBase64String(parts[0]);
            byte[] storedHash = Convert.FromBase64String(parts[1]);
            byte[] computed = ComputeArgon2idHash(password, salt);

            return CryptographicOperations.FixedTimeEquals(storedHash, computed);
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Hashes a token using SHA-256.
    /// </summary>
    public static string HashToken(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToBase64String(bytes);
    }

    /// <summary>
    /// Verifies a token against a stored SHA-256 hash using constant-time comparison.
    /// </summary>
    public static bool VerifyToken(string token, string storedHash)
    {
        var hash = HashToken(token);
        return CryptographicOperations.FixedTimeEquals(
            Convert.FromBase64String(hash),
            Convert.FromBase64String(storedHash)
        );
    }

    /// <summary>
    /// Encrypts plaintext using AES-GCM.
    /// </summary>
    public static string Encrypt(string plaintext)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(plaintext);

        byte[] nonce = RandomNumberGenerator.GetBytes(NonceSize);
        byte[] plaintextBytes = Encoding.UTF8.GetBytes(plaintext);
        byte[] ciphertext = new byte[plaintextBytes.Length];
        byte[] tag = new byte[TagSize];

        using var aes = new AesGcm(AesKey, TagSize);
        aes.Encrypt(nonce, plaintextBytes, ciphertext, tag);

        // Layout: [nonce | tag | ciphertext]
        return Convert.ToBase64String([.. nonce, .. tag, .. ciphertext]);
    }

    /// <summary>
    /// Decrypts AES-GCM encrypted data.
    /// </summary>
    public static string Decrypt(string encryptedData)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(encryptedData);

        byte[] fullCipher = Convert.FromBase64String(encryptedData);
        var span = fullCipher.AsSpan();

        var nonce = span[..NonceSize];
        var tag = span[NonceSize..(NonceSize + TagSize)];
        var ciphertext = span[(NonceSize + TagSize)..];

        byte[] plaintext = new byte[ciphertext.Length];

        using var aes = new AesGcm(AesKey, TagSize);
        aes.Decrypt(nonce, ciphertext, tag, plaintext);

        return Encoding.UTF8.GetString(plaintext);
    }

    private static byte[] GenerateSalt()
    {
        byte[] salt = new byte[SaltSize];
        RandomNumberGenerator.Fill(salt);
        return salt;
    }

    private static byte[] ComputeArgon2idHash(string password, byte[] salt)
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

    private static byte[] DeriveAes256KeyFromString(string key)
    {
        return SHA256.HashData(Encoding.UTF8.GetBytes(key));
    }
}
