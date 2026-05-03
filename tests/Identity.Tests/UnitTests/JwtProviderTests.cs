using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Providers;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces.Security;
using System.Security.Claims;

namespace SdxCore.Identity.Tests.UnitTests;

/// <summary>
/// Unit tests for JwtProvider.
/// </summary>
public class JwtProviderTests
{
    private readonly Mock<ITokenFactory> _tokenFactoryMock;
    private readonly Mock<ILogger<JwtProvider>> _loggerMock;
    private readonly JwtProvider _provider;

    public JwtProviderTests()
    {
        _tokenFactoryMock = new Mock<ITokenFactory>();
        _loggerMock = new Mock<ILogger<JwtProvider>>();
        _provider = new JwtProvider(_tokenFactoryMock.Object, _loggerMock.Object);
    }

    [Fact]
    public void Protocol_ReturnsJwt()
    {
        // Act
        var protocol = _provider.Protocol;

        // Assert
        Assert.Equal(AuthProtocol.Jwt, protocol);
    }

    [Fact]
    public void Constructor_WithNullTokenFactory_ThrowsArgumentNullException()
    {
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new JwtProvider(null!, _loggerMock.Object));
    }

    [Fact]
    public void Constructor_WithNullLogger_ThrowsArgumentNullException()
    {
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new JwtProvider(_tokenFactoryMock.Object, null!));
    }

    [Fact]
    public async Task AuthenticateAsync_WithNullBearerToken_ReturnsFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = null
        };

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Bearer token is required.", result.FailureReason);
        Assert.Empty(result.Claims);
    }

    [Fact]
    public async Task AuthenticateAsync_WithEmptyBearerToken_ReturnsFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = ""
        };

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Bearer token is required.", result.FailureReason);
        Assert.Empty(result.Claims);
    }

    [Fact]
    public async Task AuthenticateAsync_WithWhitespaceBearerToken_ReturnsFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = "   "
        };

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Bearer token is required.", result.FailureReason);
        Assert.Empty(result.Claims);
    }

    [Fact]
    public async Task AuthenticateAsync_WithInvalidToken_ReturnsFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = "invalid.jwt.token"
        };

        _tokenFactoryMock
            .Setup(tf => tf.ValidateToken(request.BearerToken))
            .Returns((ClaimsPrincipal?)null);

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Invalid or expired bearer token.", result.FailureReason);
        Assert.Empty(result.Claims);
        _tokenFactoryMock.Verify(tf => tf.ValidateToken(request.BearerToken), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithValidTokenButNoSubject_ReturnsFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = "valid.jwt.token"
        };

        var claims = new List<Claim>
        {
            new ("email", "user@example.com"),
            new ("name", "Test User")
        };

        var principal = new ClaimsPrincipal(new ClaimsIdentity(claims));

        _tokenFactoryMock
            .Setup(tf => tf.ValidateToken(request.BearerToken))
            .Returns(principal);

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Bearer token is missing required subject identifier.", result.FailureReason);
        Assert.Empty(result.Claims);
        _tokenFactoryMock.Verify(tf => tf.ValidateToken(request.BearerToken), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithValidTokenAndSubject_ReturnsSuccess()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = "valid.jwt.token"
        };

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, "user123"),
            new("email", "user@example.com"),
            new("name", "Test User")
        };

        var principal = new ClaimsPrincipal(new ClaimsIdentity(claims));

        _tokenFactoryMock
            .Setup(tf => tf.ValidateToken(request.BearerToken))
            .Returns(principal);

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Null(result.FailureReason);
        Assert.Equal(3, result.Claims.Count);
        Assert.Contains(result.Claims, c => c.Type == ClaimTypes.NameIdentifier && c.Value == "user123");
        Assert.Contains(result.Claims, c => c.Type == "email" && c.Value == "user@example.com");
        Assert.Contains(result.Claims, c => c.Type == "name" && c.Value == "Test User");
        _tokenFactoryMock.Verify(tf => tf.ValidateToken(request.BearerToken), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithValidTokenAndSubClaim_ReturnsSuccess()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = "valid.jwt.token"
        };

        var claims = new List<Claim>
        {
            new ("sub", "user456"),
            new ("email", "user@example.com")
        };

        var principal = new ClaimsPrincipal(new ClaimsIdentity(claims));

        _tokenFactoryMock
            .Setup(tf => tf.ValidateToken(request.BearerToken))
            .Returns(principal);

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Null(result.FailureReason);
        Assert.Equal(2, result.Claims.Count);
        Assert.Contains(result.Claims, c => c.Type == "sub" && c.Value == "user456");
        _tokenFactoryMock.Verify(tf => tf.ValidateToken(request.BearerToken), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WhenTokenFactoryThrowsException_ReturnsFailure()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = "valid.jwt.token"
        };

        _tokenFactoryMock
            .Setup(tf => tf.ValidateToken(request.BearerToken))
            .Throws(new InvalidOperationException("Token validation error"));

        // Act
        var result = await _provider.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Contains("JWT authentication failed", result.FailureReason);
        Assert.Contains("Token validation error", result.FailureReason);
        Assert.Empty(result.Claims);
        _tokenFactoryMock.Verify(tf => tf.ValidateToken(request.BearerToken), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithCancellationToken_PassesCancellation()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = "valid.jwt.token"
        };

        var claims = new List<Claim>
        {
            new (ClaimTypes.NameIdentifier, "user123")
        };

        var principal = new ClaimsPrincipal(new ClaimsIdentity(claims));

        _tokenFactoryMock
            .Setup(tf => tf.ValidateToken(request.BearerToken))
            .Returns(principal);

        var cts = new CancellationTokenSource();

        // Act
        var result = await _provider.AuthenticateAsync(request, cts.Token);

        // Assert
        Assert.True(result.IsSuccess);
        _tokenFactoryMock.Verify(tf => tf.ValidateToken(request.BearerToken), Times.Once);
    }
}
