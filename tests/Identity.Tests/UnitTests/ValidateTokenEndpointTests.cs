using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Moq;
using SdxCore.Common.Models;
using SdxCore.Identity.API.Controllers;
using SdxCore.Identity.Domain.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Xunit;

namespace SdxCore.Identity.Tests.UnitTests;

/// <summary>
/// Unit tests for the validate-token endpoint in AuthController.
/// Tests both token validation logic and internal API key security.
/// </summary>
public sealed class ValidateTokenEndpointTests
{
    private readonly Mock<IAuthenticationService> _authenticationServiceMock;
    private readonly Mock<ILogger<AuthController>> _loggerMock;
    private readonly AuthController _controller;

    public ValidateTokenEndpointTests()
    {
        _authenticationServiceMock = new Mock<IAuthenticationService>();
        _loggerMock = new Mock<ILogger<AuthController>>();
        _controller = new AuthController(_authenticationServiceMock.Object, _loggerMock.Object);
        
        // Setup HTTP context with headers
        _controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext()
        };
    }

    [Fact]
    public async Task ValidateToken_WithoutInternalApiKey_ReturnsForbidden()
    {
        // Arrange
        var token = CreateSampleJwtToken();
        _controller.Request.Headers["Authorization"] = $"Bearer {token}";
        
        // Mock configuration to return expected API key (but no header provided)
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var forbiddenResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status403Forbidden, forbiddenResult.StatusCode);
        
        var response = Assert.IsType<ErrorResponse>(forbiddenResult.Value);
        Assert.Equal("FORBIDDEN", response.ErrorCode);
        Assert.Equal("This endpoint is only accessible by the Gateway", response.ErrorMessage);
    }

    [Fact]
    public async Task ValidateToken_WithInvalidInternalApiKey_ReturnsForbidden()
    {
        // Arrange
        var token = CreateSampleJwtToken();
        _controller.Request.Headers["Authorization"] = $"Bearer {token}";
        _controller.Request.Headers["X-Internal-API-Key"] = "invalid-api-key";
        
        // Mock configuration to return expected API key
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var forbiddenResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status403Forbidden, forbiddenResult.StatusCode);
        
        var response = Assert.IsType<ErrorResponse>(forbiddenResult.Value);
        Assert.Equal("FORBIDDEN", response.ErrorCode);
        Assert.Equal("This endpoint is only accessible by the Gateway", response.ErrorMessage);
    }

    [Fact]
    public async Task ValidateToken_WithValidInternalApiKey_ProcessesRequest()
    {
        // Arrange
        var token = CreateSampleJwtToken();
        _controller.Request.Headers["Authorization"] = $"Bearer {token}";
        _controller.Request.Headers["X-Internal-API-Key"] = "correct-api-key";
        
        // Mock configuration to return expected API key
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;
        
        _authenticationServiceMock
            .Setup(s => s.ValidateTokenAsync(token, It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<TokenValidationResponse>(okResult.Value);
        
        Assert.True(response.IsValid);
        Assert.True(response.ValidatedAt > DateTimeOffset.MinValue);
        
        _authenticationServiceMock.Verify(
            s => s.ValidateTokenAsync(token, It.IsAny<CancellationToken>()), 
            Times.Once);
    }

    [Fact]
    public async Task ValidateToken_WithValidApiKeyButInvalidToken_ReturnsUnauthorized()
    {
        // Arrange
        var token = "invalid.token.here";
        _controller.Request.Headers["Authorization"] = $"Bearer {token}";
        _controller.Request.Headers["X-Internal-API-Key"] = "correct-api-key";
        
        // Mock configuration to return expected API key
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;
        
        _authenticationServiceMock
            .Setup(s => s.ValidateTokenAsync(token, It.IsAny<CancellationToken>()))
            .ReturnsAsync(false);

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var unauthorizedResult = Assert.IsType<UnauthorizedObjectResult>(result);
        var response = Assert.IsType<ErrorResponse>(unauthorizedResult.Value);
        
        Assert.Equal("INVALID_TOKEN", response.ErrorCode);
        Assert.Equal("Token is invalid, expired, or revoked", response.ErrorMessage);
    }

    [Fact]
    public async Task ValidateToken_WithValidApiKeyButMissingAuthorizationHeader_ReturnsBadRequest()
    {
        // Arrange
        _controller.Request.Headers["X-Internal-API-Key"] = "correct-api-key";
        
        // Mock configuration to return expected API key
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var response = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        
        Assert.Equal("MISSING_AUTHORIZATION_HEADER", response.ErrorCode);
        Assert.Equal("Authorization header is required", response.ErrorMessage);
    }

    [Fact]
    public async Task ValidateToken_WithValidApiKeyButInvalidAuthorizationFormat_ReturnsBadRequest()
    {
        // Arrange
        _controller.Request.Headers["Authorization"] = "Basic dXNlcjpwYXNz";
        _controller.Request.Headers["X-Internal-API-Key"] = "correct-api-key";
        
        // Mock configuration to return expected API key
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var response = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        
        Assert.Equal("INVALID_AUTHORIZATION_FORMAT", response.ErrorCode);
        Assert.Equal("Authorization header must use Bearer scheme", response.ErrorMessage);
    }

    [Fact]
    public async Task ValidateToken_WithValidApiKeyButEmptyToken_ReturnsBadRequest()
    {
        // Arrange
        _controller.Request.Headers["Authorization"] = "Bearer ";
        _controller.Request.Headers["X-Internal-API-Key"] = "correct-api-key";
        
        // Mock configuration to return expected API key
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var response = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        
        Assert.Equal("EMPTY_TOKEN", response.ErrorCode);
        Assert.Equal("Bearer token cannot be empty", response.ErrorMessage);
    }

    [Fact]
    public async Task ValidateToken_WithServiceException_ReturnsInternalServerError()
    {
        // Arrange
        var token = "some.token.here";
        _controller.Request.Headers["Authorization"] = $"Bearer {token}";
        _controller.Request.Headers["X-Internal-API-Key"] = "correct-api-key";
        
        // Mock configuration to return expected API key
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(c => c["Authentication:InternalApiKey"]).Returns("correct-api-key");
        
        var serviceProviderMock = new Mock<IServiceProvider>();
        serviceProviderMock.Setup(sp => sp.GetService(typeof(IConfiguration))).Returns(configMock.Object);
        _controller.HttpContext.RequestServices = serviceProviderMock.Object;
        
        _authenticationServiceMock
            .Setup(s => s.ValidateTokenAsync(token, It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("Service error"));

        // Act
        var result = await _controller.ValidateToken(CancellationToken.None);

        // Assert
        var serverErrorResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, serverErrorResult.StatusCode);
        
        var response = Assert.IsType<ErrorResponse>(serverErrorResult.Value);
        Assert.Equal("VALIDATION_ERROR", response.ErrorCode);
        Assert.Equal("An error occurred while validating the token", response.ErrorMessage);
    }

    /// <summary>
    /// Creates a sample JWT token for testing purposes.
    /// </summary>
    private static string CreateSampleJwtToken()
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, "user123"),
            new Claim(ClaimTypes.Name, "john.doe"),
            new Claim(ClaimTypes.Email, "john.doe@example.com"),
            new Claim(ClaimTypes.Role, "User"),
            new Claim(ClaimTypes.Role, "Admin"),
            new Claim("provider", "InHouse")
        };

        var key = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes("this-is-a-sample-key-for-testing-purposes-only-must-be-long-enough"));
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddHours(1),
            Issuer = "test-issuer",
            Audience = "test-audience",
            SigningCredentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256Signature)
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
}