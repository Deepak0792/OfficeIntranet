using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Domain.Exceptions;
using SdxCore.Identity.Domain.Interfaces.Providers;
using SdxCore.Identity.Domain.Interfaces.Services;

namespace SdxCore.Identity.API.Controllers;

/// <summary>
/// Authentication controller providing login and token management endpoints.
/// </summary>
[ApiController]
[Route("api/auth")]
[GatewayOnly]
public sealed class AuthController : ControllerBase
{
    private readonly IAuthenticationService _authenticationService;
    private readonly IRefreshTokenService _refreshTokenService;
    private readonly IProviderRegistry _providerRegistry;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        IAuthenticationService authenticationService,
        IRefreshTokenService refreshTokenService,
        IProviderRegistry providerRegistry,
        ILogger<AuthController> logger)
    {
        _authenticationService = authenticationService ?? throw new ArgumentNullException(nameof(authenticationService));
        _refreshTokenService = refreshTokenService ?? throw new ArgumentNullException(nameof(refreshTokenService));
        _providerRegistry = providerRegistry ?? throw new ArgumentNullException(nameof(providerRegistry));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Authenticates a user and issues a JWT token.
    /// </summary>
    /// <param name="request">Login request containing credentials.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Authentication result with token on success, error details on failure.</returns>
    [HttpPost("token")]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Token([FromBody] LoginRequest request, CancellationToken ct)
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
                    RefreshToken = result.Token.RefreshToken,
                    RefreshTokenExpiresAt = result.Token.RefreshTokenExpiresAt
                });
            }

            // Authentication failed
            _logger.LogWarning("Authentication failed: {ErrorCode} - {ErrorMessage}", result.ErrorCode, result.ErrorMessage);
            return Unauthorized(new ErrorResponse
            {
                ErrorCode = result.ErrorCode ?? "AUTH_TOKEN_FAILED",
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
        catch (ArgumentNullException ex)
        {
            _logger.LogError(ex, "Unexpected error during authentication");
            return BadRequest(new ErrorResponse
            {
                ErrorCode = "AUTH_TOKEN_ERROR",
                ErrorMessage = ex.Message
            });
        }
        catch (Exception ex)
        {
            // Unexpected errors
            _logger.LogError(ex, "Unexpected error during authentication");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "AUTH_TOKEN_ERROR",
                ErrorMessage = "An unexpected error occurred"
            });
        }
    }

    /// <summary>
    /// Issues a new access token using a valid refresh token.
    /// </summary>
    /// <param name="request">Refresh token request.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>New JWT access token and rotated refresh token.</returns>
    [HttpPost("refresh-token")]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request, CancellationToken ct)
    {
        try
        {
            var result = await _refreshTokenService.RefreshTokenAsync(request, ct);

            if (!result.IsSuccess)
            {
                _logger.LogWarning(
                    "Refresh token failed: {ErrorCode} - {ErrorMessage}",
                    result.ErrorCode,
                    result.ErrorMessage);

                return Unauthorized(new ErrorResponse
                {
                    ErrorCode = result.ErrorCode ?? "INVALID_REFRESH_TOKEN",
                    ErrorMessage = result.ErrorMessage ?? "Refresh token failed"
                });
            }

            _logger.LogInformation("Refresh token successful");

            return Ok(new LoginResponse
            {
                AccessToken = result.Token!.AccessToken,
                TokenType = result.Token.TokenType,
                ExpiresAt = result.Token.ExpiresAt,
                RefreshToken = result.Token.RefreshToken,
                RefreshTokenExpiresAt = result.Token.RefreshTokenExpiresAt
            });
        }
        catch (RecordNotFoundException ex)
        {
            _logger.LogError(ex, "User not found during refresh token flow");

            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "REFRESH_TOKEN_NOT_FOUND",
                ErrorMessage = "User associated with refresh token does not exist"
            });
        }
        catch (ConfigurationException ex)
        {
            _logger.LogError(ex, "Configuration error during refresh token flow");

            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "CONFIGURATION_ERROR",
                ErrorMessage = "Authentication service is not properly configured"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during refresh token flow");

            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "REFRESH_TOKEN_ERROR",
                ErrorMessage = "An unexpected error occurred"
            });
        }
    }

    /// <summary>
    /// Revokes an access token and its associated refresh token before expiration.
    /// </summary>
    /// <param name="request">Token revocation request containing access and refresh tokens.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Success or error response.</returns>
    [HttpPost("revoke-token")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> RevokeToken([FromBody] RevokeTokenRequest request, CancellationToken ct)
    {
        try
        {
            await _authenticationService.RevokeTokenAsync(request, ct);

            _logger.LogInformation("Token and refresh token revoked successfully");

            return Ok(new
            {
                Message = "Token revoked successfully"
            });
        }
        catch (ArgumentNullException ex)
        {
            _logger.LogWarning(ex, "Token and refresh token are required");
            return BadRequest(new ErrorResponse
            {
                ErrorCode = "REVOKE_TOKEN_ERROR",
                ErrorMessage = "Token and refresh token are required"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during token revocation");

            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "REVOKE_TOKEN_ERROR",
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

        return Ok(new
        {
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

    /// <summary>
    /// TEMPORARY: Creates a test user for development purposes.
    /// This endpoint should be removed in production.
    /// </summary>
    /// <param name="request">User creation request.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Created user information.</returns>
    [HttpPost("create-user")]
    [ProducesResponseType(typeof(object), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request, CancellationToken ct)
    {
        try
        {
            // Get the InHouse provider from the registry
            var provider = _providerRegistry.ResolveFromConfiguration() as IInHouseProvider;

            if (provider == null)
            {
                return BadRequest(new ErrorResponse
                {
                    ErrorCode = "INVALID_PROVIDER",
                    ErrorMessage = "InHouse provider is not configured"
                });
            }

            // Create the user
            var user = await provider.CreateUserAsync(request, ct);

            _logger.LogInformation("Created test user: {UserId}, Username: {Username}", user.Id, user.Username);

            return Created($"/api/auth/users/{user.Id}", new
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                CreatedAt = user.CreatedAt
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
        catch (ArgumentNullException ex)
        {
            _logger.LogError(ex, "Error while deactivating user");
            return BadRequest(new ErrorResponse
            {
                ErrorCode = "CREATE_USER_ERROR",
                ErrorMessage = ex.Message
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating user");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "CREATE_USER_ERROR",
                ErrorMessage = "Error creating user"
            });
        }
    }

    /// <summary>
    /// TEMPORARY: Creates a test user for development purposes.
    /// This endpoint should be removed in production.
    /// </summary>
    /// <param name="request">User creation request.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Created user information.</returns>
    [HttpPost("change-password")]
    [ProducesResponseType(typeof(object), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> UpdatePassword([FromBody] ChangePasswordRequest request, CancellationToken ct)
    {
        try
        {
            // Get the InHouse provider from the registry
            var provider = _providerRegistry.ResolveFromConfiguration() as IInHouseProvider;

            if (provider == null)
            {
                return BadRequest(new ErrorResponse
                {
                    ErrorCode = "INVALID_PROVIDER",
                    ErrorMessage = "InHouse provider is not configured"
                });
            }

            // Chaneg the password
            var status = await provider.ChangePasswordAsync(request, ct);

            if (!status)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new
                {
                    ErrorCode = "CHANGE_PASSWORD_ERROR",
                    ErrorMessage = "Failed to change the password"
                });
            }
            _logger.LogInformation("Password Changed for: {UserId}, Username: {Username}", 2, 2);

            return Ok(new
            {
                Message = "Password changed successfully"
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
        catch (ArgumentNullException ex)
        {
            _logger.LogError(ex, "Error while changing password");
            return BadRequest(new ErrorResponse
            {
                ErrorCode = "CHANGE_PASSWORD_ERROR",
                ErrorMessage = ex.Message
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error while changing password");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "CHANGE_PASSWORD_ERROR",
                ErrorMessage = "Error while changing password"
            });
        }
    }

    /// <summary>
    /// TEMPORARY: Creates a test user for development purposes.
    /// This endpoint should be removed in production.
    /// </summary>
    /// <param name="request">User creation request.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Created user information.</returns>
    [HttpPost("deactivate-user")]
    [ProducesResponseType(typeof(object), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> DeactivatePassword([FromBody] string userId, CancellationToken ct)
    {
        try
        {
            // Get the InHouse provider from the registry
            var provider = _providerRegistry.ResolveFromConfiguration() as IInHouseProvider;

            if (provider == null)
            {
                return BadRequest(new ErrorResponse
                {
                    ErrorCode = "INVALID_PROVIDER",
                    ErrorMessage = "InHouse provider is not configured"
                });
            }

            // Deactivating user
            var status = await provider.DeactivateUserAsync(userId, ct);

            if (!status)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new
                {
                    ErrorCode = "DEACTIVATE_USER_ERROR",
                    ErrorMessage = "Failed to deactivate user"
                });
            }
            _logger.LogInformation($"User deactivate successfully {userId}");

            return Ok(new
            {
                Message = "User deactivate successfully"
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
        catch (ArgumentNullException ex)
        {
            _logger.LogError(ex, "Error while deactivating user");
            return BadRequest(new ErrorResponse
            {
                ErrorCode = "DEACTIVATE_USER_ERROR",
                ErrorMessage = ex.Message

            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error while deactivating user");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DEACTIVATE_USER_ERROR",
                ErrorMessage = "Error while deactivating user"
            });
        }
    }
}
