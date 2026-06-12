using Microsoft.AspNetCore.Mvc;
using SdxCore.Common.Controllers;
using SdxCore.Common.Models;
using SdxCore.Common.Models.Auth;
using SdxCore.Common.Security.Attributes;
using SdxCore.Common.Security.Jwt;
using SdxCore.Identity.Application.Abstractions.Providers;
using SdxCore.Identity.Application.Abstractions.Services;
using SdxCore.Identity.Application.DTOs.Auth.Request;
using SdxCore.Identity.Application.DTOs.Auth.Response;
using SdxCore.Identity.Application.DTOs.Token.Request;
using SdxCore.Identity.Application.DTOs.User.Request;

namespace SdxCore.Identity.API.Controllers;

/// <summary>
/// Authentication controller providing login and token management endpoints.
/// All exception handling is centralized in GlobalExceptionMiddleware.
/// </summary>
[ApiController]
[Route("api/v1/auth")]
[GatewayOnly]
public sealed class AuthController : SdxControllerBase
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
        _authenticationService = authenticationService;
        _refreshTokenService = refreshTokenService;
        _providerRegistry = providerRegistry;
        _logger = logger;
    }

    /// <summary>Authenticates a user and issues a JWT token.</summary>
    [HttpPost("token")]
    public async Task<IActionResult> Token([FromBody] LoginRequest request, CancellationToken ct)
    {
        var validation = await ValidateAsync(request, ct);
        if (validation != null) return validation;

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

        var result = await _authenticationService.AuthenticateAsync(authRequest, ct);

        if (result.IsSuccess && result.Token is not null)
        {
            _logger.LogInformation("Authentication successful for user");
            return Ok(new ApiResponse<LoginResponse>(new LoginResponse
            {
                AccessToken = result.Token.AccessToken,
                TokenType = result.Token.TokenType,
                ExpiresAt = result.Token.ExpiresAt,
                RefreshToken = result.Token.RefreshToken,
                RefreshTokenExpiresAt = result.Token.RefreshTokenExpiresAt
            }, "Authentication successful"));
        }

        _logger.LogWarning("Authentication failed: {ErrorCode} - {ErrorMessage}", result.ErrorCode, result.ErrorMessage);
        return Unauthorized(new ErrorResponse
        {
            ErrorCode = result.ErrorCode ?? "AUTH_TOKEN_FAILED",
            ErrorMessage = result.ErrorMessage ?? "Authentication failed"
        });
    }

    /// <summary>Issues a new access token using a valid refresh token.</summary>
    [HttpPost("refresh-token")]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request, CancellationToken ct)
    {
        var validation = await ValidateAsync(request, ct);
        if (validation != null) return validation;

        var result = await _refreshTokenService.RefreshTokenAsync(request, ct);

        if (!result.IsSuccess)
        {
            _logger.LogWarning("Refresh token failed: {ErrorCode} - {ErrorMessage}", result.ErrorCode, result.ErrorMessage);
            return Unauthorized(new ErrorResponse
            {
                ErrorCode = result.ErrorCode ?? "INVALID_REFRESH_TOKEN",
                ErrorMessage = result.ErrorMessage ?? "Refresh token failed"
            });
        }

        _logger.LogInformation("Refresh token successful");
        return Ok(new ApiResponse<LoginResponse>(new LoginResponse
        {
            AccessToken = result.Token!.AccessToken,
            TokenType = result.Token.TokenType,
            ExpiresAt = result.Token.ExpiresAt,
            RefreshToken = result.Token.RefreshToken,
            RefreshTokenExpiresAt = result.Token.RefreshTokenExpiresAt
        }, "Refresh token successful"));
    }

    /// <summary>Revokes an access token and its associated refresh token.</summary>
    [HttpPost("revoke-token")]
    public async Task<IActionResult> RevokeToken([FromBody] RevokeTokenRequest request, CancellationToken ct)
    {
        var validation = await ValidateAsync(request, ct);
        if (validation != null) return validation;

        await _authenticationService.RevokeTokenAsync(request, ct);

        _logger.LogInformation("Token and refresh token revoked successfully");
        return Ok(new ApiResponse<bool>(true, "Token revoked successfully"));
    }

    /// <summary>
    /// Validates a JWT token. INTERNAL endpoint — accessible only by the Gateway via internal API key.
    /// </summary>
    [HttpPost("validate-token")]
    public async Task<IActionResult> ValidateToken(CancellationToken ct)
    {
        var authorizationHeader = Request.Headers.Authorization.FirstOrDefault();

        if (string.IsNullOrWhiteSpace(authorizationHeader))
        {
            _logger.LogWarning("No authorization header provided for token validation");
            return BadRequest(new ErrorResponse { ErrorCode = "MISSING_AUTHORIZATION_HEADER", ErrorMessage = "Authorization header is required" });
        }

        if (!authorizationHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogWarning("Invalid authorization header format for token validation");
            return BadRequest(new ErrorResponse { ErrorCode = "INVALID_AUTHORIZATION_FORMAT", ErrorMessage = "Authorization header must use Bearer scheme" });
        }

        var token = authorizationHeader["Bearer ".Length..].Trim();

        if (string.IsNullOrWhiteSpace(token))
        {
            _logger.LogWarning("Empty bearer token provided for validation");
            return BadRequest(new ErrorResponse { ErrorCode = "EMPTY_TOKEN", ErrorMessage = "Bearer token cannot be empty" });
        }

        var isValid = await _authenticationService.ValidateTokenAsync(token, ct);

        if (!isValid)
        {
            _logger.LogWarning("Token validation failed");
            return Unauthorized(new ErrorResponse { ErrorCode = "INVALID_TOKEN", ErrorMessage = "Token is invalid, expired, or revoked" });
        }

        var tokenClaims = JwtTokenUtilities.ExtractTokenClaims(token, _logger);

        _logger.LogInformation("Token validation successful for user: {UserId}", tokenClaims.UserId);
        return Ok(new ApiResponse<TokenValidationResponse>(new TokenValidationResponse
        {
            IsValid = true,
            UserId = tokenClaims.UserId,
            Username = tokenClaims.Username,
            Email = tokenClaims.Email,
            Roles = tokenClaims.Roles,
            Provider = tokenClaims.Provider,
            ExpiresAt = tokenClaims.ExpiresAt,
            ValidatedAt = DateTime.UtcNow
        }, "Token is valid"));
    }

    /// <summary>Test endpoint for verifying gateway header propagation.</summary>
    [HttpGet("test-protected")]
    public IActionResult TestProtected()
    {
        var userIdFromGateway = Request.Headers["X-User-Id"].FirstOrDefault();
        return Ok(new ApiResponse<object>(new
        {
            Message = "Token is valid",
            Timestamp = DateTime.UtcNow,
            UserIdFromGateway = userIdFromGateway,
            Note = userIdFromGateway != null
                ? "X-User-Id header was provided by Gateway"
                : "X-User-Id header not present (direct call to Identity service)"
        }, "Test protected endpoint successful"));
    }

    /// <summary>Creates a user in the InHouse authentication provider.</summary>
    [HttpPost("create-user")]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request, CancellationToken ct)
    {
        var validation = await ValidateAsync(request, ct);
        if (validation != null) return validation;

        var provider = _providerRegistry.ResolveFromConfiguration() as IInHouseProvider
            ?? throw new InvalidOperationException("InHouse provider is not configured");

        var user = await provider.CreateUserAsync(request, ct);

        _logger.LogInformation("Created user: {UserId}, Username: {Username}", user.EmployeeId, user.Username);
        return Created($"/api/auth/users/{user.Email}", new ApiResponse<object>(new
        {
            Id = user.EmployeeId,
            Username = user.Username,
            Email = user.Email,
            CreatedAt = user.CreatedAt
        }, "User created successfully"));
    }

    /// <summary>Changes the password for a user in the InHouse authentication provider.</summary>
    [HttpPost("change-password")]
    public async Task<IActionResult> UpdatePassword([FromBody] ChangePasswordRequest request, CancellationToken ct)
    {
        var validation = await ValidateAsync(request, ct);
        if (validation != null) return validation;

        var provider = _providerRegistry.ResolveFromConfiguration() as IInHouseProvider
            ?? throw new InvalidOperationException("InHouse provider is not configured");

        var status = await provider.ChangePasswordAsync(request, ct);

        if (!status)
        {
            return StatusCode(StatusCodes.Status401Unauthorized, new ErrorResponse
            {
                ErrorCode = "CHANGE_PASSWORD_ERROR",
                ErrorMessage = "Failed to change the password"
            });
        }

        _logger.LogInformation("Password changed for employee: {EmployeeId}", request.EmployeeId);
        return Ok(new ApiResponse<bool>(true, "Password changed successfully"));
    }

    /// <summary>Deactivates a user in the InHouse authentication provider.</summary>
    [HttpPost("deactivate-user")]
    public async Task<IActionResult> DeactivateUser([FromBody] DeactivateUserRequest request, CancellationToken ct)
    {
        var provider = _providerRegistry.ResolveFromConfiguration() as IInHouseProvider
            ?? throw new InvalidOperationException("InHouse provider is not configured");

        var status = await provider.DeactivateUserAsync(request.EmployeeId, ct);

        if (!status)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = "DEACTIVATE_USER_ERROR",
                ErrorMessage = "Failed to deactivate user"
            });
        }

        _logger.LogInformation("User deactivated successfully: {EmployeeId}", request.EmployeeId);
        return Ok(new ApiResponse<bool>(true, "User deactivated successfully"));
    }
}