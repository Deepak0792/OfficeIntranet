using Microsoft.AspNetCore.Mvc;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Exceptions;
using SdxCore.Identity.Domain.Interfaces;

namespace SdxCore.Identity.API.Controllers;

/// <summary>
/// Authentication controller providing login and token management endpoints.
/// </summary>
[ApiController]
[Route("api/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly IAuthenticationService _authenticationService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        IAuthenticationService authenticationService,
        ILogger<AuthController> logger)
    {
        _authenticationService = authenticationService ?? throw new ArgumentNullException(nameof(authenticationService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Authenticates a user and issues a JWT token.
    /// </summary>
    /// <param name="request">Login request containing credentials.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Authentication result with token on success, error details on failure.</returns>
    [HttpPost("login")]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken ct)
    {
        try
        {
            // Map LoginRequest to AuthenticationRequest
            var authRequest = new AuthenticationRequest
            {
                Username = request.Username,
                Password = request.Password,
                SamlAssertion = request.SamlAssertion,
                OAuthCode = request.OAuthCode,
                IdToken = request.IdToken,
                BearerToken = request.BearerToken,
                ExtraParameters = request.ExtraParameters ?? new Dictionary<string, string>()
            };

            // Delegate to authentication service
            var result = await _authenticationService.AuthenticateAsync(authRequest, ct);

            // Return appropriate response based on result
            if (result.IsSuccess && result.Token is not null)
            {
                _logger.LogInformation("Authentication successful for user");
                return Ok(new LoginResponse
                {
                    AccessToken = result.Token.AccessToken,
                    TokenType = result.Token.TokenType,
                    ExpiresAt = result.Token.ExpiresAt,
                    RefreshToken = result.Token.RefreshToken
                });
            }

            // Authentication failed
            _logger.LogWarning("Authentication failed: {ErrorCode} - {ErrorMessage}", result.ErrorCode, result.ErrorMessage);
            return Unauthorized(new ErrorResponse
            {
                ErrorCode = result.ErrorCode ?? "AUTH_FAILED",
                ErrorMessage = result.ErrorMessage ?? "Authentication failed"
            });
        }
        catch (ConfigurationException ex)
        {
            // Configuration errors are server errors (HTTP 500)
            _logger.LogError(ex, "Configuration error during authentication");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "CONFIGURATION_ERROR",
                ErrorMessage = "Authentication service is not properly configured"
            });
        }
        catch (ProviderNotFoundException ex)
        {
            // Provider not found is a server error (HTTP 500)
            _logger.LogError(ex, "Provider not found during authentication");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "PROVIDER_NOT_FOUND",
                ErrorMessage = "Authentication provider is not available"
            });
        }
        catch (Exception ex)
        {
            // Unexpected errors
            _logger.LogError(ex, "Unexpected error during authentication");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "INTERNAL_ERROR",
                ErrorMessage = "An unexpected error occurred"
            });
        }
    }

    /// <summary>
    /// Test endpoint for validating token middleware functionality.
    /// This endpoint is protected by TokenValidationMiddleware.
    /// </summary>
    /// <returns>Success message if token is valid.</returns>
    [HttpGet("test-protected")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status401Unauthorized)]
    public IActionResult TestProtected()
    {
        return Ok(new { Message = "Token is valid", Timestamp = DateTimeOffset.UtcNow });
    }
}

/// <summary>
/// Login request model for the API endpoint.
/// </summary>
public sealed record LoginRequest
{
    /// <summary>
    /// Username for InHouse authentication.
    /// </summary>
    public string? Username { get; init; }

    /// <summary>
    /// Password for InHouse authentication.
    /// </summary>
    public string? Password { get; init; }

    /// <summary>
    /// SAML assertion for SAML authentication.
    /// </summary>
    public string? SamlAssertion { get; init; }

    /// <summary>
    /// OAuth authorization code.
    /// </summary>
    public string? OAuthCode { get; init; }

    /// <summary>
    /// OpenID Connect ID token.
    /// </summary>
    public string? IdToken { get; init; }

    /// <summary>
    /// JWT bearer token for JWT authentication.
    /// </summary>
    public string? BearerToken { get; init; }

    /// <summary>
    /// Additional protocol-specific parameters.
    /// </summary>
    public IDictionary<string, string>? ExtraParameters { get; init; }
}

/// <summary>
/// Login response model containing the issued token.
/// </summary>
public sealed record LoginResponse
{
    /// <summary>
    /// The issued JWT access token.
    /// </summary>
    public required string AccessToken { get; init; }

    /// <summary>
    /// Token type (typically "Bearer").
    /// </summary>
    public required string TokenType { get; init; }

    /// <summary>
    /// Token expiration timestamp.
    /// </summary>
    public required DateTimeOffset ExpiresAt { get; init; }

    /// <summary>
    /// Optional refresh token for token renewal.
    /// </summary>
    public string? RefreshToken { get; init; }
}

/// <summary>
/// Error response model for failed requests.
/// </summary>
public sealed record ErrorResponse
{
    /// <summary>
    /// Machine-readable error code.
    /// </summary>
    public required string ErrorCode { get; init; }

    /// <summary>
    /// Human-readable error message.
    /// </summary>
    public required string ErrorMessage { get; init; }
}
