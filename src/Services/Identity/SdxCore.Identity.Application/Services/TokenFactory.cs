using System.Collections.Concurrent;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Interfaces.Security;

namespace SdxCore.Identity.Application.Services;

/// <summary>
/// Token factory implementation for JWT token operations.
/// Handles token issuance, validation, and revocation.
/// </summary>
public sealed class TokenFactory : ITokenFactory
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<TokenFactory> _logger;
    private readonly SigningCredentials _signingCredentials;
    private readonly TokenValidationParameters _validationParameters;
    private readonly TimeSpan _tokenLifetime;
    private readonly string _issuer;
    private readonly string _audience;
    private readonly ConcurrentDictionary<string, DateTimeOffset> _revokedTokens;
    private readonly JwtSecurityTokenHandler _tokenHandler;

    public TokenFactory(IConfiguration configuration, ILogger<TokenFactory> logger)
    {
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        
        // Read configuration values
        _issuer = _configuration["Authentication:Issuer"] 
            ?? throw new InvalidOperationException("Authentication:Issuer is not configured");
        _audience = _configuration["Authentication:Audience"] 
            ?? throw new InvalidOperationException("Authentication:Audience is not configured");
        
        var tokenLifetimeStr = _configuration["Authentication:TokenLifetime"];
        _tokenLifetime = string.IsNullOrWhiteSpace(tokenLifetimeStr) 
            ? TimeSpan.FromHours(1) 
            : TimeSpan.Parse(tokenLifetimeStr);

        // Initialize revocation list
        _revokedTokens = new ConcurrentDictionary<string, DateTimeOffset>();
        _tokenHandler = new JwtSecurityTokenHandler();

        // Load signing credentials
        _signingCredentials = LoadSigningCredentials();
        _validationParameters = CreateValidationParameters();
    }

    /// <summary>
    /// Issues a signed JWT token containing the provided claims.
    /// </summary>
    /// <param name="claims">Claims to embed in the token.</param>
    /// <returns>Signed JWT token with expiration and metadata.</returns>
    public AuthToken IssueToken(IEnumerable<Claim> claims)
    {
        if (claims == null || !claims.Any())
        {
            throw new ArgumentException("Claims cannot be null or empty", nameof(claims));
        }

        var now = DateTimeOffset.UtcNow;
        var expiry = now.Add(_tokenLifetime);
        var jti = Guid.NewGuid().ToString();

        // Build complete claims list with standard JWT claims
        var allClaims = new List<Claim>(claims)
        {
            new Claim(JwtRegisteredClaimNames.Jti, jti),
            new Claim(JwtRegisteredClaimNames.Iat, now.ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64)
        };

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(allClaims),
            Expires = expiry.UtcDateTime,
            Issuer = _issuer,
            Audience = _audience,
            SigningCredentials = _signingCredentials
        };

        var token = _tokenHandler.CreateToken(tokenDescriptor);
        var accessToken = _tokenHandler.WriteToken(token);

        _logger.LogInformation("Issued JWT token with jti={Jti}, expires at {ExpiresAt}", jti, expiry);

        return new AuthToken
        {
            AccessToken = accessToken,
            ExpiresAt = expiry,
            TokenType = "Bearer"
        };
    }

    /// <summary>
    /// Validates a JWT token and extracts claims.
    /// </summary>
    /// <param name="token">JWT token to validate.</param>
    /// <returns>ClaimsPrincipal if valid; otherwise null.</returns>
    public ClaimsPrincipal? ValidateToken(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            _logger.LogWarning("Token validation failed: token is null or empty");
            return null;
        }

        try
        {
            var principal = _tokenHandler.ValidateToken(token, _validationParameters, out var validatedToken);

            // Extract jti claim to check revocation list
            var jtiClaim = principal.FindFirst(JwtRegisteredClaimNames.Jti);
            if (jtiClaim == null)
            {
                _logger.LogWarning("Token validation failed: jti claim is missing");
                return null;
            }

            // Check if token is revoked
            if (_revokedTokens.ContainsKey(jtiClaim.Value))
            {
                _logger.LogWarning("Token validation failed: token with jti={Jti} is revoked", jtiClaim.Value);
                return null;
            }

            _logger.LogDebug("Token validated successfully with jti={Jti}", jtiClaim.Value);
            return principal;
        }
        catch (SecurityTokenExpiredException ex)
        {
            _logger.LogWarning(ex, "Token validation failed: token is expired");
            return null;
        }
        catch (SecurityTokenInvalidSignatureException ex)
        {
            _logger.LogWarning(ex, "Token validation failed: invalid signature");
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Token validation failed with unexpected error");
            return null;
        }
    }

    /// <summary>
    /// Revokes a JWT token by adding it to the revocation list.
    /// </summary>
    /// <param name="token">JWT token to revoke.</param>
    public void RevokeToken(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            throw new ArgumentException("Token cannot be null or empty", nameof(token));
        }

        try
        {
            // Parse token without validation to extract jti
            var jwtToken = _tokenHandler.ReadJwtToken(token);
            var jtiClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti);

            if (jtiClaim == null)
            {
                _logger.LogWarning("Cannot revoke token: jti claim is missing");
                throw new InvalidOperationException("Token does not contain a jti claim");
            }

            var expiry = jwtToken.ValidTo;
            _revokedTokens.TryAdd(jtiClaim.Value, new DateTimeOffset(expiry, TimeSpan.Zero));

            _logger.LogInformation("Revoked token with jti={Jti}", jtiClaim.Value);
        }
        catch (Exception ex) when (ex is not InvalidOperationException)
        {
            _logger.LogError(ex, "Failed to revoke token");
            throw new InvalidOperationException("Failed to revoke token", ex);
        }
    }

    /// <summary>
    /// Loads signing credentials from configuration.
    /// Supports both symmetric (HS256) and asymmetric (RS256) signing.
    /// </summary>
    private SigningCredentials LoadSigningCredentials()
    {
        var signingKeyPath = _configuration["Authentication:SigningKeyPath"];
        var signingAlgorithm = _configuration["Authentication:SigningAlgorithm"] ?? "HS256";

        if (signingAlgorithm.Equals("RS256", StringComparison.OrdinalIgnoreCase))
        {
            // Asymmetric signing with RSA
            if (string.IsNullOrWhiteSpace(signingKeyPath))
            {
                throw new InvalidOperationException("Authentication:SigningKeyPath is required for RS256 algorithm");
            }

            if (!File.Exists(signingKeyPath))
            {
                throw new FileNotFoundException($"Signing key file not found at path: {signingKeyPath}");
            }

            var privateKeyPem = File.ReadAllText(signingKeyPath);
            var rsa = System.Security.Cryptography.RSA.Create();
            rsa.ImportFromPem(privateKeyPem);

            var securityKey = new RsaSecurityKey(rsa);
            _logger.LogInformation("Loaded RS256 signing credentials from {Path}", signingKeyPath);
            return new SigningCredentials(securityKey, SecurityAlgorithms.RsaSha256);
        }
        else if (signingAlgorithm.Equals("HS256", StringComparison.OrdinalIgnoreCase))
        {
            // Symmetric signing with HMAC
            var signingKey = _configuration["Authentication:SigningKey"];
            
            if (string.IsNullOrWhiteSpace(signingKey))
            {
                // Try to load from file if path is provided
                if (!string.IsNullOrWhiteSpace(signingKeyPath) && File.Exists(signingKeyPath))
                {
                    signingKey = File.ReadAllText(signingKeyPath).Trim();
                }
                else
                {
                    throw new InvalidOperationException("Authentication:SigningKey or Authentication:SigningKeyPath is required for HS256 algorithm");
                }
            }

            var keyBytes = System.Text.Encoding.UTF8.GetBytes(signingKey);
            var securityKey = new SymmetricSecurityKey(keyBytes);
            _logger.LogInformation("Loaded HS256 signing credentials");
            return new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
        }
        else
        {
            throw new InvalidOperationException($"Unsupported signing algorithm: {signingAlgorithm}. Supported algorithms: RS256, HS256");
        }
    }

    /// <summary>
    /// Creates token validation parameters for JWT validation.
    /// </summary>
    private TokenValidationParameters CreateValidationParameters()
    {
        return new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = _issuer,
            ValidateAudience = true,
            ValidAudience = _audience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = _signingCredentials.Key,
            ClockSkew = TimeSpan.FromMinutes(5) // Allow 5 minutes clock skew
        };
    }
}
