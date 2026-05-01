using System.Security.Claims;
using FsCheck;
using FsCheck.Xunit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.Interfaces.Security;

namespace SdxCore.Identity.Tests.PropertyTests;

/// <summary>
/// Property-based tests for TokenFactory using FsCheck.
/// Validates universal correctness properties for token issuance and validation.
/// </summary>
public class TokenFactoryPropertyTests
{
    private readonly ITokenFactory _tokenFactory;

    public TokenFactoryPropertyTests()
    {
        var loggerMock = new Mock<ILogger<TokenFactory>>();
        
        // Create in-memory configuration for testing with HS256
        var configData = new Dictionary<string, string>
        {
            ["Authentication:Issuer"] = "https://test-issuer.com",
            ["Authentication:Audience"] = "test-audience",
            ["Authentication:TokenLifetime"] = "01:00:00",
            ["Authentication:SigningAlgorithm"] = "HS256",
            ["Authentication:SigningKey"] = "ThisIsATestSigningKeyThatIsLongEnoughForHS256Algorithm"
        };
        
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configData!)
            .Build();

        _tokenFactory = new TokenFactory(configuration, loggerMock.Object);
    }

    /// <summary>
    /// Property 3: Token issuance and immediate validation
    /// **Validates: Requirements 4.1, 4.6, 4.7**
    /// For all claim sets, IssueToken followed by ValidateToken returns non-null ClaimsPrincipal
    /// </summary>
    [Property(MaxTest = 100)]
    public void TokenIssuanceAndValidation_ForAllClaimSets_ReturnsNonNullPrincipal(NonEmptyArray<NonEmptyString> claimValues)
    {
        // Arrange - Generate arbitrary claim sets
        // Create claims from the generated values
        var claims = claimValues.Get
            .Select((value, index) => new Claim($"claim_{index}", value.Get))
            .ToList();

        // Ensure we have at least one claim
        if (claims.Count == 0)
        {
            claims.Add(new Claim(ClaimTypes.NameIdentifier, "test-user"));
        }

        // Act - Issue token and immediately validate it
        var token = _tokenFactory.IssueToken(claims);
        var principal = _tokenFactory.ValidateToken(token.AccessToken);

        // Assert - Principal should be non-null
        Assert.NotNull(principal);
        
        // Verify that the principal contains the original claims
        foreach (var originalClaim in claims)
        {
            Assert.Contains(principal.Claims, c => c.Type == originalClaim.Type && c.Value == originalClaim.Value);
        }
        
        // Verify standard JWT claims are present
        Assert.Contains(principal.Claims, c => c.Type == "jti");
        Assert.Contains(principal.Claims, c => c.Type == "iat");
    }

    /// <summary>
    /// Property 4: Token revocation
    /// **Validates: Requirements 4.9, 4.10**
    /// For all tokens, RevokeToken followed by ValidateToken returns null
    /// </summary>
    [Property(MaxTest = 100)]
    public void TokenRevocation_ForAllTokens_ValidationReturnsNull(NonEmptyArray<NonEmptyString> claimValues)
    {
        // Arrange - Generate arbitrary claim sets
        var claims = claimValues.Get
            .Select((value, index) => new Claim($"claim_{index}", value.Get))
            .ToList();

        // Ensure we have at least one claim
        if (claims.Count == 0)
        {
            claims.Add(new Claim(ClaimTypes.NameIdentifier, "test-user"));
        }

        // Act - Issue token, verify it's valid, then revoke it
        var token = _tokenFactory.IssueToken(claims);
        
        // Verify token is valid before revocation
        var principalBeforeRevocation = _tokenFactory.ValidateToken(token.AccessToken);
        Assert.NotNull(principalBeforeRevocation);
        
        // Revoke the token
        _tokenFactory.RevokeToken(token.AccessToken);
        
        // Validate token after revocation
        var principalAfterRevocation = _tokenFactory.ValidateToken(token.AccessToken);

        // Assert - Principal should be null after revocation
        Assert.Null(principalAfterRevocation);
    }
}
