using System.Security.Claims;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Exceptions;
using SdxCore.Identity.Domain.Interfaces.Providers;
using SdxCore.Identity.Domain.Interfaces.Security;
using SdxCore.Identity.Domain.Interfaces.Services;
using Xunit;

namespace SdxCore.Identity.Tests.UnitTests;

public class AuthenticationServiceTests
{
    private readonly Mock<IProviderRegistry> _providerRegistryMock;
    private readonly Mock<ITokenFactory> _tokenFactoryMock;
    private readonly Mock<IAuditLogger> _auditLoggerMock;
    private readonly Mock<ILogger<AuthenticationService>> _loggerMock;
    private readonly Mock<IAuthenticationProvider> _mockProvider;
    private readonly AuthenticationService _authenticationService;

    public AuthenticationServiceTests()
    {
        _providerRegistryMock = new Mock<IProviderRegistry>();
        _tokenFactoryMock = new Mock<ITokenFactory>();
        _auditLoggerMock = new Mock<IAuditLogger>();
        _loggerMock = new Mock<ILogger<AuthenticationService>>();
        _mockProvider = new Mock<IAuthenticationProvider>();

        _authenticationService = new AuthenticationService(
            _providerRegistryMock.Object,
            _tokenFactoryMock.Object,
            _auditLoggerMock.Object,
            _loggerMock.Object);
    }

    [Fact]
    public async Task AuthenticateAsync_WithSuccessfulAuthentication_ReturnsSuccessResult()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "password123"
        };

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, "user-123"),
            new Claim(ClaimTypes.Name, "testuser")
        };

        var providerResult = new ProviderResult
        {
            IsSuccess = true,
            Claims = claims
        };

        var authToken = new AuthToken
        {
            AccessToken = "test-token",
            ExpiresAt = DateTimeOffset.UtcNow.AddHours(1),
            TokenType = "Bearer"
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        _mockProvider.Setup(p => p.AuthenticateAsync(request, It.IsAny<CancellationToken>()))
            .ReturnsAsync(providerResult);

        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _tokenFactoryMock.Setup(t => t.IssueToken(It.IsAny<IEnumerable<Claim>>()))
            .Returns(authToken);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.NotNull(result.Token);
        Assert.Equal("test-token", result.Token.AccessToken);
        Assert.Equal(claims.Count, result.Claims.Count);

        _providerRegistryMock.Verify(r => r.ResolveFromConfiguration(), Times.Once);
        _mockProvider.Verify(p => p.AuthenticateAsync(request, It.IsAny<CancellationToken>()), Times.Once);
        _tokenFactoryMock.Verify(t => t.IssueToken(It.IsAny<IEnumerable<Claim>>()), Times.Once);
        _auditLoggerMock.Verify(a => a.LogAsync(
            It.Is<AuditEvent>(e => e.EventType == "LOGIN_SUCCESS"),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithFailedAuthentication_ReturnsFailureResult()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "wrongpassword"
        };

        var providerResult = new ProviderResult
        {
            IsSuccess = false,
            FailureReason = "Invalid credentials"
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        _mockProvider.Setup(p => p.AuthenticateAsync(request, It.IsAny<CancellationToken>()))
            .ReturnsAsync(providerResult);

        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Null(result.Token);
        Assert.Equal("AUTH_FAILED", result.ErrorCode);
        Assert.Equal("Invalid credentials", result.ErrorMessage);

        _providerRegistryMock.Verify(r => r.ResolveFromConfiguration(), Times.Once);
        _mockProvider.Verify(p => p.AuthenticateAsync(request, It.IsAny<CancellationToken>()), Times.Once);
        _tokenFactoryMock.Verify(t => t.IssueToken(It.IsAny<IEnumerable<Claim>>()), Times.Never);
        _auditLoggerMock.Verify(a => a.LogAsync(
            It.Is<AuditEvent>(e => e.EventType == "LOGIN_FAILURE"),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithConfigurationException_ReturnsConfigurationError()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "password123"
        };

        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Throws(new ConfigurationException("Authentication protocol is not configured"));

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("CONFIGURATION_ERROR", result.ErrorCode);
        Assert.Equal("Authentication service is not properly configured", result.ErrorMessage);

        _auditLoggerMock.Verify(a => a.LogAsync(
            It.Is<AuditEvent>(e => e.EventType == "LOGIN_FAILURE" && e.FailureReason == "Configuration error"),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithProviderNotFoundException_ReturnsProviderNotFoundError()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "password123"
        };

        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Throws(new ProviderNotFoundException("Provider for protocol 'Saml' is not registered"));

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("PROVIDER_NOT_FOUND", result.ErrorCode);
        Assert.Equal("Authentication provider is not available", result.ErrorMessage);

        _auditLoggerMock.Verify(a => a.LogAsync(
            It.Is<AuditEvent>(e => e.EventType == "LOGIN_FAILURE" && e.FailureReason == "Provider not found"),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AuthenticateAsync_WithNullRequest_ThrowsArgumentNullException()
    {
        // Act & Assert
        await Assert.ThrowsAsync<ArgumentNullException>(() =>
            _authenticationService.AuthenticateAsync(null!));
    }

    [Fact]
    public async Task ValidateTokenAsync_WithValidToken_ReturnsTrue()
    {
        // Arrange
        var token = "valid-token";
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new[]
        {
            new Claim(ClaimTypes.NameIdentifier, "user-123")
        }));

        _tokenFactoryMock.Setup(t => t.ValidateToken(token))
            .Returns(claimsPrincipal);

        // Act
        var result = await _authenticationService.ValidateTokenAsync(token);

        // Assert
        Assert.True(result);
        _tokenFactoryMock.Verify(t => t.ValidateToken(token), Times.Once);
    }

    [Fact]
    public async Task ValidateTokenAsync_WithInvalidToken_ReturnsFalse()
    {
        // Arrange
        var token = "invalid-token";

        _tokenFactoryMock.Setup(t => t.ValidateToken(token))
            .Returns((ClaimsPrincipal?)null);

        // Act
        var result = await _authenticationService.ValidateTokenAsync(token);

        // Assert
        Assert.False(result);
        _tokenFactoryMock.Verify(t => t.ValidateToken(token), Times.Once);
    }

    [Fact]
    public async Task ValidateTokenAsync_WithNullToken_ReturnsFalse()
    {
        // Act
        var result = await _authenticationService.ValidateTokenAsync(null!);

        // Assert
        Assert.False(result);
        _tokenFactoryMock.Verify(t => t.ValidateToken(It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task ValidateTokenAsync_WithEmptyToken_ReturnsFalse()
    {
        // Act
        var result = await _authenticationService.ValidateTokenAsync("");

        // Assert
        Assert.False(result);
        _tokenFactoryMock.Verify(t => t.ValidateToken(It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task RevokeTokenAsync_WithValidToken_CompletesSuccessfully()
    {
        // Arrange
        var token = "valid-token";

        _tokenFactoryMock.Setup(t => t.RevokeToken(token));

        // Act
        await _authenticationService.RevokeTokenAsync(token);

        // Assert
        _tokenFactoryMock.Verify(t => t.RevokeToken(token), Times.Once);
    }

    [Fact]
    public async Task RevokeTokenAsync_WithNullToken_ThrowsArgumentException()
    {
        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(() =>
            _authenticationService.RevokeTokenAsync(null!));
    }

    [Fact]
    public async Task RevokeTokenAsync_WithEmptyToken_ThrowsArgumentException()
    {
        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(() =>
            _authenticationService.RevokeTokenAsync(""));
    }

    [Fact]
    public void Constructor_WithNullProviderRegistry_ThrowsArgumentNullException()
    {
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new AuthenticationService(
            null!,
            _tokenFactoryMock.Object,
            _auditLoggerMock.Object,
            _loggerMock.Object));
    }

    [Fact]
    public void Constructor_WithNullTokenFactory_ThrowsArgumentNullException()
    {
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new AuthenticationService(
            _providerRegistryMock.Object,
            null!,
            _auditLoggerMock.Object,
            _loggerMock.Object));
    }

    [Fact]
    public void Constructor_WithNullAuditLogger_ThrowsArgumentNullException()
    {
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new AuthenticationService(
            _providerRegistryMock.Object,
            _tokenFactoryMock.Object,
            null!,
            _loggerMock.Object));
    }

    [Fact]
    public void Constructor_WithNullLogger_ThrowsArgumentNullException()
    {
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new AuthenticationService(
            _providerRegistryMock.Object,
            _tokenFactoryMock.Object,
            _auditLoggerMock.Object,
            null!));
    }

    [Fact]
    public async Task AuthenticateAsync_WithInHouseProtocol_ValidatesUsernameAndPassword()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = "password123"
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("INTERNAL_ERROR", result.ErrorCode);
    }

    [Fact]
    public async Task AuthenticateAsync_WithSamlProtocol_ValidatesSamlAssertion()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            SamlAssertion = null
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.Saml);
        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("INTERNAL_ERROR", result.ErrorCode);
    }

    [Fact]
    public async Task AuthenticateAsync_WithOAuthProtocol_ValidatesOAuthCode()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            OAuthCode = null
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.OAuth);
        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("INTERNAL_ERROR", result.ErrorCode);
    }

    [Fact]
    public async Task AuthenticateAsync_WithOidcProtocol_ValidatesIdToken()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            IdToken = null
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.Oidc);
        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("INTERNAL_ERROR", result.ErrorCode);
    }

    [Fact]
    public async Task AuthenticateAsync_WithJwtProtocol_ValidatesBearerToken()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = null,
            Password = null,
            BearerToken = null
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.Jwt);
        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("INTERNAL_ERROR", result.ErrorCode);
    }

    [Fact]
    public async Task AuthenticateAsync_WithLdapProtocol_ValidatesUsernameAndPassword()
    {
        // Arrange
        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = null
        };

        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.Ldap);
        _providerRegistryMock.Setup(r => r.ResolveFromConfiguration())
            .Returns(_mockProvider.Object);

        _auditLoggerMock.Setup(a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authenticationService.AuthenticateAsync(request);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("INTERNAL_ERROR", result.ErrorCode);
    }
}
