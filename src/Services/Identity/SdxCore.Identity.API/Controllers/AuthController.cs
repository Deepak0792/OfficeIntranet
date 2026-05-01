using Microsoft.AspNetCore.Mvc;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Exceptions;
using SdxCore.Identity.Domain.Interfaces;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Common.Http;

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
    /// Validates a JWT token for all supported authentication providers.
    /// This endpoint is ONLY accessible by the Gateway middleware via internal API key.
    /// NOT exposed publicly - only login endpoint is public.
    /// </summary>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Token validation result with user information if valid.</returns>
    [HttpPost("validate-token")]
    [ProducesResponseType(typeof(TokenValidationResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> ValidateToken(CancellationToken ct)
    {
        try
        {
            // SECURITY: Verify this is an internal call from Gateway middleware
            if (!IsInternalGatewayCall())
            {
                _logger.LogWarning("Unauthorized access attempt to validate-token endpoint from {RemoteIpAddress}", 
                    Request.HttpContext.Connection.RemoteIpAddress);
                return StatusCode(StatusCodes.Status403Forbidden, new ErrorResponse
                {
                    ErrorCode = "FORBIDDEN",
                    ErrorMessage = "This endpoint is only accessible by the Gateway"
                });
            }

            // Extract bearer token from Authorization header
            var authorizationHeader = Request.Headers.Authorization.FirstOrDefault();
            
            if (string.IsNullOrWhiteSpace(authorizationHeader))
            {
                _logger.LogWarning("No authorization header provided for token validation");
                return BadRequest(new ErrorResponse
                {
                    ErrorCode = "MISSING_AUTHORIZATION_HEADER",
                    ErrorMessage = "Authorization header is required"
                });
            }

            // Check if it's a Bearer token
            if (!authorizationHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogWarning("Invalid authorization header format for token validation");
                return BadRequest(new ErrorResponse
                {
                    ErrorCode = "INVALID_AUTHORIZATION_FORMAT",
                    ErrorMessage = "Authorization header must use Bearer scheme"
                });
            }

            // Extract the token
            var token = authorizationHeader.Substring("Bearer ".Length).Trim();

            if (string.IsNullOrWhiteSpace(token))
            {
                _logger.LogWarning("Empty bearer token provided for validation");
                return BadRequest(new ErrorResponse
                {
                    ErrorCode = "EMPTY_TOKEN",
                    ErrorMessage = "Bearer token cannot be empty"
                });
            }

            // Validate the token using the authentication service
            var isValid = await _authenticationService.ValidateTokenAsync(token, ct);

            if (!isValid)
            {
                _logger.LogWarning("Token validation failed");
                return Unauthorized(new ErrorResponse
                {
                    ErrorCode = "INVALID_TOKEN",
                    ErrorMessage = "Token is invalid, expired, or revoked"
                });
            }

            // Extract claims from the token for additional context
            var tokenClaims = ExtractTokenClaims(token);

            _logger.LogInformation("Token validation successful for user: {UserId}", tokenClaims.UserId);
            return Ok(new TokenValidationResponse
            {
                IsValid = true,
                UserId = tokenClaims.UserId,
                Username = tokenClaims.Username,
                Email = tokenClaims.Email,
                Roles = tokenClaims.Roles,
                Provider = tokenClaims.Provider,
                ExpiresAt = tokenClaims.ExpiresAt,
                ValidatedAt = DateTimeOffset.UtcNow
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during token validation");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "VALIDATION_ERROR",
                ErrorMessage = "An error occurred while validating the token"
            });
        }
    }

    /// <summary>
    /// Verifies that the request is coming from the Gateway middleware.
    /// Uses internal API key authentication to restrict access.
    /// </summary>
    /// <returns>True if the request is from Gateway, false otherwise.</returns>
    private bool IsInternalGatewayCall()
    {
        return InternalApiKeyValidator.IsInternalGatewayCall(Request, 
            HttpContext.RequestServices.GetRequiredService<IConfiguration>(), 
            _logger);
    }

    /// <summary>
    /// Test endpoint for validating token middleware functionality.
    /// This endpoint is protected by TokenValidationMiddleware and shows user context.
    /// </summary>
    /// <returns>Success message if token is valid, including user context from Gateway.</returns>
    [HttpGet("test-protected")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status401Unauthorized)]
    public IActionResult TestProtected()
    {
        // Check if X-User-Id header was added by the Gateway
        var userIdFromGateway = Request.Headers["X-User-Id"].FirstOrDefault();
        
        return Ok(new { 
            Message = "Token is valid", 
            Timestamp = DateTimeOffset.UtcNow,
            UserIdFromGateway = userIdFromGateway,
            Note = userIdFromGateway != null 
                ? "X-User-Id header was provided by Gateway" 
                : "X-User-Id header not present (direct call to Identity service)"
        });
    }

    /// <summary>
    /// Extracts claims from a JWT token without validation.
    /// This method assumes the token has already been validated.
    /// </summary>
    /// <param name="token">The JWT token to extract claims from.</param>
    /// <returns>Token claims information.</returns>
    private TokenClaims ExtractTokenClaims(string token)
    {
        return JwtTokenUtilities.ExtractTokenClaims(token, _logger);
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
