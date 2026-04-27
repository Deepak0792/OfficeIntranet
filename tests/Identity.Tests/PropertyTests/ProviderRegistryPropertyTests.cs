using FsCheck;
using FsCheck.Xunit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.Exceptions;
using SdxCore.Identity.Domain.Interfaces;

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
}
