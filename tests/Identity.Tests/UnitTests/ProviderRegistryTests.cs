using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Exceptions;
using SdxCore.Identity.Domain.Interfaces;
using Xunit;

namespace SdxCore.Identity.Tests.UnitTests;

public class ProviderRegistryTests
{
    private readonly Mock<ILogger<ProviderRegistry>> _loggerMock;
    private readonly Mock<IAuthenticationProvider> _mockProvider;

    public ProviderRegistryTests()
    {
        _loggerMock = new Mock<ILogger<ProviderRegistry>>();
        _mockProvider = new Mock<IAuthenticationProvider>();
    }

    private IConfiguration CreateConfiguration(string? protocolValue)
    {
        var configData = new Dictionary<string, string?>();
        if (protocolValue != null)
        {
            configData["Authentication:Protocol"] = protocolValue;
        }
        
        return new ConfigurationBuilder()
            .AddInMemoryCollection(configData!)
            .Build();
    }

    [Fact]
    public void Register_WithValidProvider_StoresProvider()
    {
        // Arrange
        var config = CreateConfiguration("InHouse");
        var registry = new ProviderRegistry(config, _loggerMock.Object);
        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);

        // Act
        registry.Register(AuthProtocol.InHouse, _mockProvider.Object);

        // Assert - Should not throw when resolving
        var resolved = registry.Resolve(AuthProtocol.InHouse);
        Assert.NotNull(resolved);
        Assert.Same(_mockProvider.Object, resolved);
    }

    [Fact]
    public void Register_WithNullProvider_ThrowsArgumentNullException()
    {
        // Arrange
        var config = CreateConfiguration("InHouse");
        var registry = new ProviderRegistry(config, _loggerMock.Object);

        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => registry.Register(AuthProtocol.InHouse, null!));
    }

    [Fact]
    public void Resolve_WithRegisteredProvider_ReturnsProvider()
    {
        // Arrange
        var config = CreateConfiguration("InHouse");
        var registry = new ProviderRegistry(config, _loggerMock.Object);
        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        registry.Register(AuthProtocol.InHouse, _mockProvider.Object);

        // Act
        var resolved = registry.Resolve(AuthProtocol.InHouse);

        // Assert
        Assert.NotNull(resolved);
        Assert.Same(_mockProvider.Object, resolved);
    }

    [Fact]
    public void Resolve_WithUnregisteredProvider_ThrowsProviderNotFoundException()
    {
        // Arrange
        var config = CreateConfiguration("InHouse");
        var registry = new ProviderRegistry(config, _loggerMock.Object);

        // Act & Assert
        var exception = Assert.Throws<ProviderNotFoundException>(() => registry.Resolve(AuthProtocol.Saml));
        Assert.Contains("Provider for protocol 'Saml' is not registered", exception.Message);
    }

    [Fact]
    public void ResolveFromConfiguration_WithValidProtocol_ReturnsProvider()
    {
        // Arrange
        var config = CreateConfiguration("InHouse");
        var registry = new ProviderRegistry(config, _loggerMock.Object);
        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        registry.Register(AuthProtocol.InHouse, _mockProvider.Object);

        // Act
        var resolved = registry.ResolveFromConfiguration();

        // Assert
        Assert.NotNull(resolved);
        Assert.Same(_mockProvider.Object, resolved);
    }

    [Fact]
    public void ResolveFromConfiguration_WithNullProtocol_ThrowsConfigurationException()
    {
        // Arrange
        var config = CreateConfiguration(null);
        var registry = new ProviderRegistry(config, _loggerMock.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        Assert.Contains("Authentication protocol is not configured in appsettings.json", exception.Message);
    }

    [Fact]
    public void ResolveFromConfiguration_WithEmptyProtocol_ThrowsConfigurationException()
    {
        // Arrange
        var config = CreateConfiguration("");
        var registry = new ProviderRegistry(config, _loggerMock.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        Assert.Contains("Authentication protocol is not configured in appsettings.json", exception.Message);
    }

    [Fact]
    public void ResolveFromConfiguration_WithWhitespaceProtocol_ThrowsConfigurationException()
    {
        // Arrange
        var config = CreateConfiguration("   ");
        var registry = new ProviderRegistry(config, _loggerMock.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        Assert.Contains("Authentication protocol is not configured in appsettings.json", exception.Message);
    }

    [Fact]
    public void ResolveFromConfiguration_WithInvalidProtocol_ThrowsConfigurationException()
    {
        // Arrange
        var config = CreateConfiguration("InvalidProtocol");
        var registry = new ProviderRegistry(config, _loggerMock.Object);

        // Act & Assert
        var exception = Assert.Throws<ConfigurationException>(() => registry.ResolveFromConfiguration());
        Assert.Contains("Invalid protocol name 'InvalidProtocol' in configuration", exception.Message);
    }

    [Fact]
    public void ResolveFromConfiguration_WithValidButUnregisteredProtocol_ThrowsProviderNotFoundException()
    {
        // Arrange
        var config = CreateConfiguration("Saml");
        var registry = new ProviderRegistry(config, _loggerMock.Object);

        // Act & Assert
        var exception = Assert.Throws<ProviderNotFoundException>(() => registry.ResolveFromConfiguration());
        Assert.Contains("Provider for protocol 'Saml' is not registered", exception.Message);
    }

    [Fact]
    public void ResolveFromConfiguration_IsCaseInsensitive()
    {
        // Arrange
        var config = CreateConfiguration("inhouse"); // lowercase
        var registry = new ProviderRegistry(config, _loggerMock.Object);
        _mockProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        registry.Register(AuthProtocol.InHouse, _mockProvider.Object);

        // Act
        var resolved = registry.ResolveFromConfiguration();

        // Assert
        Assert.NotNull(resolved);
        Assert.Same(_mockProvider.Object, resolved);
    }

    [Fact]
    public void Register_MultipleProviders_AllCanBeResolved()
    {
        // Arrange
        var config = CreateConfiguration("InHouse");
        var registry = new ProviderRegistry(config, _loggerMock.Object);
        
        var inHouseProvider = new Mock<IAuthenticationProvider>();
        inHouseProvider.Setup(p => p.Protocol).Returns(AuthProtocol.InHouse);
        
        var samlProvider = new Mock<IAuthenticationProvider>();
        samlProvider.Setup(p => p.Protocol).Returns(AuthProtocol.Saml);

        // Act
        registry.Register(AuthProtocol.InHouse, inHouseProvider.Object);
        registry.Register(AuthProtocol.Saml, samlProvider.Object);

        // Assert
        var resolvedInHouse = registry.Resolve(AuthProtocol.InHouse);
        var resolvedSaml = registry.Resolve(AuthProtocol.Saml);
        
        Assert.Same(inHouseProvider.Object, resolvedInHouse);
        Assert.Same(samlProvider.Object, resolvedSaml);
    }

    [Fact]
    public void Constructor_WithNullConfiguration_ThrowsArgumentNullException()
    {
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new ProviderRegistry(null!, _loggerMock.Object));
    }

    [Fact]
    public void Constructor_WithNullLogger_ThrowsArgumentNullException()
    {
        // Arrange
        var config = CreateConfiguration("InHouse");

        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => new ProviderRegistry(config, null!));
    }
}
