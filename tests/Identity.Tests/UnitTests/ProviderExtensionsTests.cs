using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Identity.Application.Extensions;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces.Providers;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Domain.Interfaces.Security;
using System.Reflection.Metadata.Ecma335;

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

    [Fact]
    public void AddJwtProvider_RegistersJwtProviderSuccessfully()
    {
        // Arrange
        var services = new ServiceCollection();

        // Add required dependencies
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                { "Authentication:Protocol", "Jwt" }
            })
            .Build();

        services.AddSingleton<IConfiguration>(configuration);
        services.AddLogging();

        // Add mock dependencies
        services.AddScoped<ITokenFactory, MockTokenFactory>();
        services.AddSingleton<IProviderRegistry, MockProviderRegistry>();

        // Act
        services.AddJwtProvider();
        var serviceProvider = services.BuildServiceProvider();

        // Assert
        var providers = serviceProvider.GetServices<IAuthenticationProvider>().ToList();
        var jwtProvider = providers.FirstOrDefault(p => p.Protocol == AuthProtocol.Jwt);
        Assert.NotNull(jwtProvider);
        Assert.Equal(AuthProtocol.Jwt, jwtProvider.Protocol);
    }

    [Fact]
    public void AddJwtProvider_ThrowsArgumentNullException_WhenServicesIsNull()
    {
        // Arrange
        IServiceCollection? services = null;

        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => services!.AddJwtProvider());
    }

    // Mock implementations for testing
    private class MockUserRepository : IUserRepository
    {
        public Task<Domain.Entities.User?> GetByUsernameAsync(string username, CancellationToken ct = default)
            => Task.FromResult<Domain.Entities.User?>(null);
        public Task<Domain.Entities.User?> GetByIdAsync(Guid id, CancellationToken ct = default) => Task.FromResult<Domain.Entities.User?>(null);
        public Task<IEnumerable<Domain.Entities.User>> GetAllAsync(CancellationToken ct = default) => Task.FromResult<IEnumerable<Domain.Entities.User>>([]);
        public Task<(IEnumerable<Domain.Entities.User> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken ct = default) => Task.FromResult<(IEnumerable<Domain.Entities.User> Items, int TotalCount)>(([], 0));
        public Task<IEnumerable<Domain.Entities.User>> FindAsync(System.Linq.Expressions.Expression<Func<Domain.Entities.User, bool>> predicate, CancellationToken ct = default) => Task.FromResult<IEnumerable<Domain.Entities.User>>([]);
        public Task<Domain.Entities.User> AddAsync(Domain.Entities.User user, CancellationToken ct = default) => Task.FromResult(user);
        public Task AddRangeAsync(IEnumerable<Domain.Entities.User> entities, CancellationToken ct = default) => Task.CompletedTask;
        public void Update(Domain.Entities.User entity) { }
        public void Remove(Domain.Entities.User entity) { }
        public void RemoveRange(IEnumerable<Domain.Entities.User> entities) { }
        public Task<int> SaveChangesAsync(CancellationToken ct = default) => Task.FromResult(0);
        public Task IncrementFailedAttemptsAsync(Guid userId, CancellationToken ct = default)
            => Task.CompletedTask;
        public Task ResetFailedAttemptsAsync(Guid userId, CancellationToken ct = default)
            => Task.CompletedTask;
        public Task UpdateLastLoginAsync(Guid userId, DateTime loginTime, CancellationToken ct = default)
            => Task.CompletedTask;
        public Task DeactivateAsync(Guid userId, CancellationToken ct = default)
            => Task.CompletedTask;
        public Task LockAccountAsync(Guid userId, DateTime lockedUntil, CancellationToken ct = default)
            => Task.CompletedTask;

        public Task UpdatePasswordHashAsync(Guid userId, string newPasswordHash, CancellationToken ct = default)
            => Task.CompletedTask;
    }

    private class MockPasswordHasher : IPasswordHasher
    {
        public string Hash(string password) => "hashed_" + password;
        public bool Verify(string password, string hash) => hash == "hashed_" + password;

        public string HashToken(string token) => "hashed_" + token;

        public bool VerifyToken(string token, string storedHash) => storedHash.Equals("hashed_" + token);
    }

    private class MockProviderRegistry : IProviderRegistry
    {
        private readonly Dictionary<AuthProtocol, IAuthenticationProvider> _providers = [];

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

    private class MockTokenFactory : ITokenFactory
    {
        public Domain.DTOs.AuthToken IssueToken(IEnumerable<System.Security.Claims.Claim> claims)
        {
            return new Domain.DTOs.AuthToken
            {
                AccessToken = "mock.jwt.token",
                ExpiresAt = DateTime.UtcNow.AddHours(1),
                TokenType = "Bearer"
            };
        }

        public System.Security.Claims.ClaimsPrincipal? ValidateToken(string token)
        {
            return new System.Security.Claims.ClaimsPrincipal();
        }

        public void RevokeToken(string token)
        {
            // Mock implementation
        }
    }
}
