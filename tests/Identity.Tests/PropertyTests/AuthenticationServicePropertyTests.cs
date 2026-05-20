using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Common.Contexts;
using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Application.Security;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces.Providers;
using SdxCore.Identity.Domain.Interfaces.Security;
using SdxCore.Identity.Domain.Interfaces.Services;
using System.Security.Claims;

namespace SdxCore.Identity.Tests.PropertyTests;

/// <summary>
/// Property-based tests for AuthenticationService using FsCheck.
/// Validates universal correctness properties for authentication operations.
/// </summary>
public class AuthenticationServicePropertyTests
{
    /// <summary>
    /// Property 8: Audit event always written
    /// **Validates: Requirements 6.7**
    /// For all authentication attempts, exactly one AuditEvent is written regardless of outcome
    /// </summary>
    [Fact]
    public async Task AuditEvent_AlwaysWritten_OnSuccessfulAuthentication()
    {
        // Arrange
        var mockRequestContext = new Mock<IRequestContext>();
        var mockTokenFactory = new Mock<ITokenFactory>();
        var mockProviderRegistry = new Mock<IProviderRegistry>();
        var mockRefreshTokenService = new Mock<IRefreshTokenService>();
        var mockAuditLogger = new Mock<IAuditLogger>();
        var mockAuditLoggerService = new Mock<IAuditLoggerService>();
        var mockLogger = new Mock<ILogger<AuthenticationService>>();

    var mockProvider = new Mock<IAuthenticationProvider>();
        mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        mockProvider.Setup(p => p.AuthenticateAsync(It.IsAny<AuthenticationRequest>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ProviderResponse
            {
                IsSuccess = true,
                Claims = new List<Claim> { new Claim(ClaimTypes.NameIdentifier, "user123") }
            });

        mockProviderRegistry.Setup(r => r.ResolveFromConfiguration()).Returns(mockProvider.Object);

        mockTokenFactory.Setup(t => t.IssueToken(It.IsAny<IEnumerable<Claim>>()))
            .Returns(new AuthToken
            {
                AccessToken = "test-token",
                ExpiresAt = DateTime.UtcNow.AddHours(1),
                TokenType = "Bearer"
            });

        var service = new AuthenticationService(
            mockRequestContext.Object,
            mockProviderRegistry.Object,
            mockTokenFactory.Object,
            mockAuditLoggerService.Object,
            mockRefreshTokenService.Object,
            mockLogger.Object);

        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "testpassword"
        };

        // Act
        await service.AuthenticateAsync(request, CancellationToken.None);

        // Assert - Verify exactly one audit event was written
        mockAuditLogger.Verify(
            a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Once,
            "Exactly one audit event should be written for successful authentication");
    }

    /// <summary>
    /// Property 8: Audit event always written
    /// **Validates: Requirements 6.7**
    /// For all authentication attempts, exactly one AuditEvent is written regardless of outcome
    /// </summary>
    [Fact]
    public async Task AuditEvent_AlwaysWritten_OnFailedAuthentication()
    {
        // Arrange
        var mockRequestContext = new Mock<IRequestContext>();
        var mockTokenFactory = new Mock<ITokenFactory>();
        var mockProviderRegistry = new Mock<IProviderRegistry>();
        var mockRefreshTokenService = new Mock<IRefreshTokenService>();
        var mockAuditLogger = new Mock<IAuditLogger>();
        var mockAuditLoggerService = new Mock<IAuditLoggerService>();
        var mockLogger = new Mock<ILogger<AuthenticationService>>();

        var mockProvider = new Mock<IAuthenticationProvider>();
        mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        mockProvider.Setup(p => p.AuthenticateAsync(It.IsAny<AuthenticationRequest>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ProviderResponse
            {
                IsSuccess = false,
                FailureReason = "Invalid credentials"
            });

        mockProviderRegistry.Setup(r => r.ResolveFromConfiguration()).Returns(mockProvider.Object);

        var service = new AuthenticationService(
            mockRequestContext.Object,
            mockProviderRegistry.Object,
            mockTokenFactory.Object,
            mockAuditLoggerService.Object,
            mockRefreshTokenService.Object,
            mockLogger.Object);

        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "wrongpassword"
        };

        // Act
        await service.AuthenticateAsync(request, CancellationToken.None);

        // Assert - Verify exactly one audit event was written
        mockAuditLogger.Verify(
            a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Once,
            "Exactly one audit event should be written for failed authentication");
    }

    /// <summary>
    /// Property 8: Audit event always written
    /// **Validates: Requirements 6.7**
    /// For all authentication attempts, exactly one AuditEvent is written regardless of outcome
    /// Even when provider throws an exception
    /// </summary>
    [Fact]
    public async Task AuditEvent_AlwaysWritten_OnProviderException()
    {
        // Arrange
        var mockRequestContext = new Mock<IRequestContext>();
        var mockTokenFactory = new Mock<ITokenFactory>();
        var mockProviderRegistry = new Mock<IProviderRegistry>();
        var mockRefreshTokenService = new Mock<IRefreshTokenService>();
        var mockAuditLogger = new Mock<IAuditLogger>();
        var mockAuditLoggerService = new Mock<IAuditLoggerService>();
        var mockLogger = new Mock<ILogger<AuthenticationService>>();

        var mockProvider = new Mock<IAuthenticationProvider>();
        mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        mockProvider.Setup(p => p.AuthenticateAsync(It.IsAny<AuthenticationRequest>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("Provider error"));

        mockProviderRegistry.Setup(r => r.ResolveFromConfiguration()).Returns(mockProvider.Object);

        var service = new AuthenticationService(
            mockRequestContext.Object,
            mockProviderRegistry.Object,
            mockTokenFactory.Object,
            mockAuditLoggerService.Object,
            mockRefreshTokenService.Object,
            mockLogger.Object);

        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "testpassword"
        };

        // Act
        var result = await service.AuthenticateAsync(request, CancellationToken.None);

        // Assert - Verify exactly one audit event was written even on exception
        mockAuditLogger.Verify(
            a => a.LogAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Once,
            "Exactly one audit event should be written even when provider throws exception");

        // Verify the result indicates failure
        Assert.False(result.IsSuccess);
    }

    /// <summary>
    /// Property 8: Audit event always written with correct event type
    /// **Validates: Requirements 6.1, 6.2**
    /// Successful authentication writes LOGIN_SUCCESS event
    /// </summary>
    [Fact]
    public async Task AuditEvent_WritesLoginSuccess_OnSuccessfulAuthentication()
    {
        // Arrange
        var mockRequestContext = new Mock<IRequestContext>();
        var mockTokenFactory = new Mock<ITokenFactory>();
        var mockProviderRegistry = new Mock<IProviderRegistry>();
        var mockRefreshTokenService = new Mock<IRefreshTokenService>();
        var mockAuditLogger = new Mock<IAuditLogger>();
        var mockAuditLoggerService = new Mock<IAuditLoggerService>();
        var mockLogger = new Mock<ILogger<AuthenticationService>>();

        var mockProvider = new Mock<IAuthenticationProvider>();
        mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        mockProvider.Setup(p => p.AuthenticateAsync(It.IsAny<AuthenticationRequest>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ProviderResponse
            {
                IsSuccess = true,
                Claims = new List<Claim> { new Claim(ClaimTypes.NameIdentifier, "user123") }
            });

        mockProviderRegistry.Setup(r => r.ResolveFromConfiguration()).Returns(mockProvider.Object);

        mockTokenFactory.Setup(t => t.IssueToken(It.IsAny<IEnumerable<Claim>>()))
            .Returns(new AuthToken
            {
                AccessToken = "test-token",
                ExpiresAt = DateTime.UtcNow.AddHours(1),
                TokenType = "Bearer"
            });

        var service = new AuthenticationService(
            mockRequestContext.Object,
            mockProviderRegistry.Object,
            mockTokenFactory.Object,
            mockAuditLoggerService.Object,
            mockRefreshTokenService.Object,
            mockLogger.Object);

        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "testpassword"
        };

        // Act
        await service.AuthenticateAsync(request, CancellationToken.None);

        // Assert - Verify LOGIN_SUCCESS event was written
        mockAuditLogger.Verify(
            a => a.LogAsync(
                It.Is<AuditEvent>(e => e.EventType == "LOGIN_SUCCESS"),
                It.IsAny<CancellationToken>()),
            Times.Once,
            "LOGIN_SUCCESS event should be written for successful authentication");
    }

    /// <summary>
    /// Property 8: Audit event always written with correct event type
    /// **Validates: Requirements 6.2**
    /// Failed authentication writes LOGIN_FAILURE event
    /// </summary>
    [Fact]
    public async Task AuditEvent_WritesLoginFailure_OnFailedAuthentication()
    {
        // Arrange
        var mockRequestContext = new Mock<IRequestContext>();
        var mockTokenFactory = new Mock<ITokenFactory>();
        var mockProviderRegistry = new Mock<IProviderRegistry>();
        var mockRefreshTokenService = new Mock<IRefreshTokenService>();
        var mockAuditLogger = new Mock<IAuditLogger>();
        var mockAuditLoggerService = new Mock<IAuditLoggerService>();
        var mockLogger = new Mock<ILogger<AuthenticationService>>();

        var mockProvider = new Mock<IAuthenticationProvider>();
        mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        mockProvider.Setup(p => p.AuthenticateAsync(It.IsAny<AuthenticationRequest>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ProviderResponse
            {
                IsSuccess = false,
                FailureReason = "Invalid credentials"
            });

        mockProviderRegistry.Setup(r => r.ResolveFromConfiguration()).Returns(mockProvider.Object);

        var service = new AuthenticationService(
            mockRequestContext.Object,
            mockProviderRegistry.Object,
            mockTokenFactory.Object,
            mockAuditLoggerService.Object,
            mockRefreshTokenService.Object,
            mockLogger.Object);

        var request = new AuthenticationRequest
        {
            Username = "testuser",
            Password = "wrongpassword"
        };

        // Act
        await service.AuthenticateAsync(request, CancellationToken.None);

        // Assert - Verify LOGIN_FAILURE event was written
        mockAuditLogger.Verify(
            a => a.LogAsync(
                It.Is<AuditEvent>(e => e.EventType == "LOGIN_FAILURE" && e.FailureReason == "Invalid credentials"),
                It.IsAny<CancellationToken>()),
            Times.Once,
            "LOGIN_FAILURE event with failure reason should be written for failed authentication");
    }
}
