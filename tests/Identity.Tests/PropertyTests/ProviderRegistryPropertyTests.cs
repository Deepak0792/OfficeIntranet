using FsCheck;
using FsCheck.Xunit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.Exceptions;
using SdxCore.Identity.Domain.Interfaces.Providers;

namespace SdxCore.Identity.Tests.PropertyTests;

/// <summary>
/// Property-based tests for ProviderRegistry using FsCheck.
/// Validates universal correctness properties for configuration validation.
/// </summary>
public class ProviderRegistryPropertyTests
{
    /// <summary>
    /// Property 5: Configuration exception when protocol not configured
    /// **Validates: Requirements 1.2**
    /// When "Authentication:Protocol" is null or empty, ResolveFromConfiguration throws ConfigurationException
    /// </summary>
    [Fact]
    public void ConfigurationException_WhenProtocolIsNull_ThrowsConfigurationException()
    {
        // Arrange
        var configurationData = new Dictionary<string, string?>
        {
            { "Authentication:Protocol", null }
        };

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configurationData)
            .Build();

        var mockLogger = new Mock<ILogger<ProviderRegistry>>();
        var registry = new ProviderRegistry(configuration, mockLogger.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        
        // Verify the exception message matches the requirement
        Assert.Contains("Authentication protocol is not configured in appsettings.json", exception.Message);
    }

    /// <summary>
    /// Property 5: Configuration exception when protocol not configured
    /// **Validates: Requirements 1.2**
    /// When "Authentication:Protocol" is empty, ResolveFromConfiguration throws ConfigurationException
    /// </summary>
    [Fact]
    public void ConfigurationException_WhenProtocolIsEmpty_ThrowsConfigurationException()
    {
        // Arrange
        var configurationData = new Dictionary<string, string?>
        {
            { "Authentication:Protocol", string.Empty }
        };

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configurationData)
            .Build();

        var mockLogger = new Mock<ILogger<ProviderRegistry>>();
        var registry = new ProviderRegistry(configuration, mockLogger.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        
        // Verify the exception message matches the requirement
        Assert.Contains("Authentication protocol is not configured in appsettings.json", exception.Message);
    }

    /// <summary>
    /// Property 5: Configuration exception when protocol not configured
    /// **Validates: Requirements 1.2**
    /// When "Authentication:Protocol" is whitespace, ResolveFromConfiguration throws ConfigurationException
    /// </summary>
    [Theory]
    [InlineData("   ")]
    [InlineData("\t")]
    [InlineData("\n")]
    [InlineData("  \t  ")]
    public void ConfigurationException_WhenProtocolIsWhitespace_ThrowsConfigurationException(string whitespaceValue)
    {
        // Arrange
        var configurationData = new Dictionary<string, string?>
        {
            { "Authentication:Protocol", whitespaceValue }
        };

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configurationData)
            .Build();

        var mockLogger = new Mock<ILogger<ProviderRegistry>>();
        var registry = new ProviderRegistry(configuration, mockLogger.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        
        // Verify the exception message matches the requirement
        Assert.Contains("Authentication protocol is not configured in appsettings.json", exception.Message);
    }

    /// <summary>
    /// Property 6: Configuration exception for invalid protocol
    /// **Validates: Requirements 1.3**
    /// When "Authentication:Protocol" is invalid, ResolveFromConfiguration throws ConfigurationException
    /// </summary>
    [Theory]
    [InlineData("InvalidProtocol")]
    [InlineData("NotAProtocol")]
    [InlineData("Random123")]
    [InlineData("INVALID")]
    public void ConfigurationException_WhenProtocolIsInvalid_ThrowsConfigurationException(string invalidProtocol)
    {
        // Arrange
        var configurationData = new Dictionary<string, string?>
        {
            { "Authentication:Protocol", invalidProtocol }
        };

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configurationData)
            .Build();

        var mockLogger = new Mock<ILogger<ProviderRegistry>>();
        var registry = new ProviderRegistry(configuration, mockLogger.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        
        // Verify the exception message contains the invalid protocol name
        Assert.Contains("Invalid protocol name", exception.Message);
        Assert.Contains(invalidProtocol, exception.Message);
    }

    /// <summary>
    /// Property 7: Provider not found exception
    /// **Validates: Requirements 1.4**
    /// When configured protocol is not registered, ResolveFromConfiguration throws ProviderNotFoundException
    /// </summary>
    [Theory]
    [InlineData("InHouse")]
    [InlineData("Saml")]
    [InlineData("OAuth")]
    [InlineData("Oidc")]
    [InlineData("Jwt")]
    [InlineData("Ldap")]
    public void ProviderNotFoundException_WhenProtocolNotRegistered_ThrowsProviderNotFoundException(string validProtocol)
    {
        // Arrange - Configure a valid protocol but don't register any provider
        var configurationData = new Dictionary<string, string?>
        {
            { "Authentication:Protocol", validProtocol }
        };

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configurationData)
            .Build();

        var mockLogger = new Mock<ILogger<ProviderRegistry>>();
        var registry = new ProviderRegistry(configuration, mockLogger.Object);
        // Note: No provider is registered

        // Act & Assert
        var exception = Assert.Throws<ProviderNotFoundException>(() => registry.ResolveFromConfiguration());
        
        // Verify the exception message contains the protocol name
        Assert.Contains($"Provider for protocol '{validProtocol}' is not registered", exception.Message);
    }
}
