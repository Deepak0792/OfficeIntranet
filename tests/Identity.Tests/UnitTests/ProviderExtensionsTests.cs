using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using SdxCore.Identity.Application.Extensions;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces;
using Xunit;

namespace SdxCore.Identity.Tests.UnitTests;

/// <summary>
/// Unit tests for provider registration extension methods.
/// </summary>
public class ProviderExtensionsTests
{
    [Fact]
    public void AddInHouseProvider_RegistersInHouseProviderSuccessfully()
    {
        // Arrange
        var services = new ServiceCollection();
        
        // Add required dependencies
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                { "Authentication:Protocol", "InHouse" },
                { "Authentication:MaxFailedAttempts", "5" },
                { "Authentication:LockoutDuration", "00:15:00" }
            })
            .Build();
        
        services.AddSingleton<IConfiguration>(configuration);
        services.AddLogging();
        
        // Add mock repositories
        services.AddScoped<IUserRepository, MockUserRepository>();
        services.AddScoped<IPasswordHasher, MockPasswordHasher>();
        services.AddSingleton<IProviderRegistry, MockProviderRegistry>();
        
        // Act
        services.AddInHouseProvider();
        var serviceProvider = services.BuildServiceProvider();
        
        // Assert
        var inHouseProvider = serviceProvider.GetService<IInHouseProvider>();
        Assert.NotNull(inHouseProvider);
        Assert.Equal(AuthProtocol.InHouse, inHouseProvider.Protocol);
    }
    
    [Fact]
    public void AddInHouseProvider_ThrowsArgumentNullException_WhenServicesIsNull()
    {
        // Arrange
        IServiceCollection? services = null;
        
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => services!.AddInHouseProvider());
    }
    
    // Mock implementations for testing
    private class MockUserRepository : IUserRepository
    {
        public Task<Domain.Entities.UserRecord?> FindByUsernameAsync(string username, CancellationToken ct = default) 
            => Task.FromResult<Domain.Entities.UserRecord?>(null);
        public Task<Domain.Entities.UserRecord> CreateAsync(Domain.Entities.UserRecord user, CancellationToken ct = default) 
            => Task.FromResult(user);
        public Task IncrementFailedAttemptsAsync(Guid userId, CancellationToken ct = default) 
            => Task.CompletedTask;
        public Task ResetFailedAttemptsAsync(Guid userId, CancellationToken ct = default) 
            => Task.CompletedTask;
        public Task UpdateLastLoginAsync(Guid userId, DateTimeOffset loginTime, CancellationToken ct = default) 
            => Task.CompletedTask;
        public Task DeactivateAsync(Guid userId, CancellationToken ct = default) 
            => Task.CompletedTask;
        public Task LockAccountAsync(Guid userId, DateTimeOffset lockedUntil, CancellationToken ct = default) 
            => Task.CompletedTask;
        public Task<Domain.Entities.UserRecord?> FindByIdAsync(Guid userId, CancellationToken ct = default) 
            => Task.FromResult<Domain.Entities.UserRecord?>(null);
        public Task UpdatePasswordHashAsync(Guid userId, string newPasswordHash, CancellationToken ct = default) 
            => Task.CompletedTask;
    }
    
    private class MockPasswordHasher : IPasswordHasher
    {
        public string Hash(string password) => "hashed_" + password;
        public bool Verify(string password, string hash) => hash == "hashed_" + password;
    }
    
    private class MockProviderRegistry : IProviderRegistry
    {
        private readonly Dictionary<AuthProtocol, IAuthenticationProvider> _providers = new();
        
        public void Register(AuthProtocol protocol, IAuthenticationProvider provider)
        {
            _providers[protocol] = provider;
        }
        
        public IAuthenticationProvider Resolve(AuthProtocol protocol)
        {
            return _providers[protocol];
        }
        
        public IAuthenticationProvider ResolveFromConfiguration()
        {
            return _providers[AuthProtocol.InHouse];
        }
    }
}
