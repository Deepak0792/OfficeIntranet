using System.Security.Claims;
using Microsoft.Extensions.Logging;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces.Providers;
using SdxCore.Identity.Domain.Interfaces.Security;

namespace SdxCore.Identity.Application.Providers;

/// <summary>
/// JWT bearer token authentication provider.
/// Validates JWT tokens provided in authentication requests.
/// </summary>
/// <remarks>
/// This provider validates JWT bearer tokens according to requirement 3.5:
/// - Validates the token signature using the configured signing key
/// - Validates token expiry
/// - Validates issuer claims
/// - Extracts user claims from the validated token
/// 
/// The provider uses ITokenFactory (injected via constructor) to perform token validation.
/// </remarks>
public sealed class JwtProvider : IAuthenticationProvider
{
    private readonly ITokenFactory _tokenFactory;
    private readonly ILogger<JwtProvider> _logger;

    /// <summary>
    /// Initializes a new instance of the <see cref="JwtProvider"/> class.
    /// </summary>
    /// <param name="tokenFactory">Token factory for JWT validation.</param>
    /// <param name="logger">Logger instance.</param>
    public JwtProvider(
        ITokenFactory tokenFactory,
        ILogger<JwtProvider> logger)
    {
        _tokenFactory = tokenFactory ?? throw new ArgumentNullException(nameof(tokenFactory));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <inheritdoc />
    public AuthProtocol Protocol => AuthProtocol.Jwt;

    /// <inheritdoc />
    public async Task<ProviderResult> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default)
    {
        // 1. Validate input (Requirement 7.6)
        if (string.IsNullOrWhiteSpace(request.BearerToken))
        {
            _logger.LogWarning("Authentication attempt with missing bearer token");
            return Fail("Bearer token is required.");
        }

        try
        {
            // 2. Validate the JWT token (Requirement 3.5)
            // This validates:
            // - Token signature using the configured signing key
            // - Token expiry
            // - Issuer claims
            // - Token is not revoked
            ClaimsPrincipal? principal = await Task.Run(() => _tokenFactory.ValidateToken(request.BearerToken), ct);

            if (principal == null)
            {
                _logger.LogWarning("JWT token validation failed");
                return Fail("Invalid or expired bearer token.");
            }

            // 3. Extract claims from the validated token (Requirement 3.5)
            var claims = principal.Claims.ToList();

            // Ensure we have at least a subject claim
            var subjectClaim = claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == "sub");
            if (subjectClaim == null)
            {
                _logger.LogWarning("JWT token does not contain a subject identifier");
                return Fail("Bearer token is missing required subject identifier.");
            }

            _logger.LogInformation("Successfully validated JWT bearer token for subject: {Subject}", subjectClaim.Value);

            return new ProviderResult { IsSuccess = true, Claims = claims };
        }
        catch (Exception ex)
        {
            // Requirement 9.3: Catch exceptions and return failure result
            _logger.LogError(ex, "Error processing JWT bearer token");
            return Fail($"JWT authentication failed: {ex.Message}");
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
}
