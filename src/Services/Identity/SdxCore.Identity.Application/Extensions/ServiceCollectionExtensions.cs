using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Contexts;
using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Application.Security;
using SdxCore.Identity.Domain.Interfaces.Providers;
using SdxCore.Identity.Domain.Interfaces.Security;
using SdxCore.Identity.Domain.Interfaces.Services;

namespace SdxCore.Identity.Application.Extensions;

/// <summary>
/// Extension methods for registering authentication module services with dependency injection.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers the SdxCore authentication module services with the dependency injection container.
    /// This includes the authentication service, provider registry, token factory, audit logger, and password hasher.
    /// All configuration values are read from IConfiguration.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <param name="configuration">The configuration instance containing authentication settings.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services or configuration is null.</exception>
    /// <remarks>
    /// This method registers the following services:
    /// - IAuthenticationService (scoped) - Central orchestrator for authentication operations
    /// - IProviderRegistry (singleton) - Maintains and resolves authentication providers
    /// - ITokenFactory (singleton) - Issues and validates JWT tokens
    /// - IAuditLogger (scoped) - Records authentication events to SQL Server
    /// - IPasswordHasher (singleton) - Hashes and verifies passwords using Argon2id
    /// 
    /// After calling this method, you must register at least one authentication provider
    /// using the provider extension methods (e.g., AddInHouseProvider, AddSamlProvider).
    /// 
    /// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5
    /// </remarks>
    public static IServiceCollection AddSdxCoreAuthentication(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        // Register IAuthenticationService as scoped (per-request lifetime)
        // Requirement 12.2: IAuthenticationService registered as scoped service             
        services.AddScoped<IAuditLoggerService, AuditLoggerService>();
        services.AddScoped<IRefreshTokenService, RefreshTokenService>();
        services.AddScoped<IAuthenticationService, AuthenticationService>();


        // Register IProviderRegistry as scoped (can resolve scoped services)
        // Changed from singleton to scoped to allow resolving scoped providers
        services.AddScoped<IProviderRegistry, ProviderRegistry>();

        // Register ITokenFactory as singleton (shared signing credentials)
        // Requirement 12.4: ITokenFactory registered as singleton
        services.AddSingleton<ITokenFactory, TokenFactory>();

        // Register IAuditLogger as scoped (per-request lifetime)
        // Requirement 12.5: IAuditLogger registered as scoped service
        services.AddScoped<IAuditLogger, AuditLogger>();

        // Register IPasswordHasher as singleton (stateless service)
        // Requirement 12.5: IPasswordHasher registered
        services.AddSingleton<IPasswordHasher, PasswordHasher>();

        return services;
    }
}
