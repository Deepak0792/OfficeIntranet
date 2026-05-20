using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Application.Security;
using SdxCore.Identity.Domain.DTOs;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace SdxCore.Identity.Tests.UnitTests;

public class TokenFactoryTests
{
    private readonly Mock<ILogger<TokenFactory>> _loggerMock;
    private readonly IConfiguration _configuration;

    public TokenFactoryTests()
    {
        _loggerMock = new Mock<ILogger<TokenFactory>>();
        
        // Create in-memory configuration for testing with HS256
        var configData = new Dictionary<string, string>
        {
            ["Authentication:Issuer"] = "https://test-issuer.com",
            ["Authentication:Audience"] = "test-audience",
            ["Authentication:TokenLifetime"] = "01:00:00",
            ["Authentication:SigningAlgorithm"] = "HS256",
            ["Authentication:SigningKey"] = "ThisIsATestSigningKeyThatIsLongEnoughForHS256Algorithm"
        };
        
        _configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configData!)
            .Build();
    }

    [Fact]
    public void IssueToken_WithValidClaims_ReturnsAuthToken()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, "user123"),
            new Claim(ClaimTypes.Name, "testuser"),
            new Claim(ClaimTypes.Email, "test@example.com")
        };

        // Act
        AuthToken token = tokenFactory.IssueToken(claims);

        // Assert
        Assert.NotNull(token);
        Assert.NotNull(token.AccessToken);
        Assert.NotEmpty(token.AccessToken);
        Assert.Equal("Bearer", token.TokenType);
        Assert.True(token.ExpiresAt > DateTime.UtcNow);
        Assert.True(token.ExpiresAt <= DateTime.UtcNow.AddHours(1).AddMinutes(1)); // Allow 1 minute tolerance
    }

    [Fact]
    public void IssueToken_IncludesStandardJwtClaims()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, "user123")
        };

        // Act
        AuthToken token = tokenFactory.IssueToken(claims);

        // Assert - Parse the token to verify claims
        var handler = new JwtSecurityTokenHandler();
        var jwtToken = handler.ReadJwtToken(token.AccessToken);
        
        Assert.Contains(jwtToken.Claims, c => c.Type == JwtRegisteredClaimNames.Jti);
        Assert.Contains(jwtToken.Claims, c => c.Type == JwtRegisteredClaimNames.Iat);
        Assert.NotNull(jwtToken.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti)?.Value);
    }

    [Fact]
    public void ValidateToken_WithValidToken_ReturnsClaimsPrincipal()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, "user123"),
            new Claim(ClaimTypes.Name, "testuser")
        };
        var token = tokenFactory.IssueToken(claims);

        // Act
        var principal = tokenFactory.ValidateToken(token.AccessToken);

        // Assert
        Assert.NotNull(principal);
        Assert.Contains(principal.Claims, c => c.Type == ClaimTypes.NameIdentifier && c.Value == "user123");
        Assert.Contains(principal.Claims, c => c.Type == ClaimTypes.Name && c.Value == "testuser");
    }

    [Fact]
    public void ValidateToken_WithNullToken_ReturnsNull()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);

        // Act
        var principal = tokenFactory.ValidateToken(null!);

        // Assert
        Assert.Null(principal);
    }

    [Fact]
    public void ValidateToken_WithEmptyToken_ReturnsNull()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);

        // Act
        var principal = tokenFactory.ValidateToken(string.Empty);

        // Assert
        Assert.Null(principal);
    }

    [Fact]
    public void ValidateToken_WithInvalidToken_ReturnsNull()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);

        // Act
        var principal = tokenFactory.ValidateToken("invalid.token.string");

        // Assert
        Assert.Null(principal);
    }

    [Fact]
    public void RevokeToken_ThenValidateToken_ReturnsNull()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, "user123")
        };
        var token = tokenFactory.IssueToken(claims);

        // Verify token is valid before revocation
        var principalBeforeRevoke = tokenFactory.ValidateToken(token.AccessToken);
        Assert.NotNull(principalBeforeRevoke);

        // Act - Revoke the token
        tokenFactory.RevokeToken(token.AccessToken);

        // Assert - Token should now be invalid
        var principalAfterRevoke = tokenFactory.ValidateToken(token.AccessToken);
        Assert.Null(principalAfterRevoke);
    }

    [Fact]
    public void RevokeToken_WithNullToken_ThrowsArgumentException()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);

        // Act & Assert
        Assert.Throws<ArgumentException>(() => tokenFactory.RevokeToken(null!));
    }

    [Fact]
    public void RevokeToken_WithEmptyToken_ThrowsArgumentException()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);

        // Act & Assert
        Assert.Throws<ArgumentException>(() => tokenFactory.RevokeToken(string.Empty));
    }

    [Fact]
    public void IssueToken_WithNullClaims_ThrowsArgumentException()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);

        // Act & Assert
        Assert.Throws<ArgumentException>(() => tokenFactory.IssueToken(null!));
    }

    [Fact]
    public void IssueToken_WithEmptyClaims_ThrowsArgumentException()
    {
        // Arrange
        var tokenFactory = new TokenFactory(_configuration, _loggerMock.Object);

        // Act & Assert
        Assert.Throws<ArgumentException>(() => tokenFactory.IssueToken(new List<Claim>()));
    }

    [Fact]
    public void Constructor_WithMissingIssuer_ThrowsInvalidOperationException()
    {
        // Arrange
        var configData = new Dictionary<string, string>
        {
            ["Authentication:Audience"] = "test-audience",
            ["Authentication:TokenLifetime"] = "01:00:00",
            ["Authentication:SigningAlgorithm"] = "HS256",
            ["Authentication:SigningKey"] = "ThisIsATestSigningKeyThatIsLongEnoughForHS256Algorithm"
        };
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(configData!)
            .Build();

        // Act & Assert
        Assert.Throws<InvalidOperationException>(() => new TokenFactory(config, _loggerMock.Object));
    }

    [Fact]
    public void Constructor_WithMissingAudience_ThrowsInvalidOperationException()
    {
        // Arrange
        var configData = new Dictionary<string, string>
        {
            ["Authentication:Issuer"] = "https://test-issuer.com",
            ["Authentication:TokenLifetime"] = "01:00:00",
            ["Authentication:SigningAlgorithm"] = "HS256",
            ["Authentication:SigningKey"] = "ThisIsATestSigningKeyThatIsLongEnoughForHS256Algorithm"
        };
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(configData!)
            .Build();

        // Act & Assert
        Assert.Throws<InvalidOperationException>(() => new TokenFactory(config, _loggerMock.Object));
    }
}
