using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Persistence.Data;
using SdxCore.Identity.Persistence.Repositories;

namespace SdxCore.Identity.Persistence.Extensions;

/// <summary>
/// Extension methods for registering persistence layer services with dependency injection.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers the persistence layer services including DbContext and repositories.
    /// Reads the connection string from IConfiguration under "ConnectionStrings:DefaultConnection".
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <param name="configuration">The configuration instance containing connection string.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services or configuration is null.</exception>
    /// <exception cref="InvalidOperationException">Thrown when connection string is not configured.</exception>
    public static IServiceCollection AddSdxCorePersistence(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        if (configuration is null)
            throw new ArgumentNullException(nameof(configuration));

        // Read connection string from configuration
        var connectionString = configuration.GetConnectionString("DefaultConnection");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "Database connection string 'DefaultConnection' is not configured. " +
                "Please set 'ConnectionStrings:DefaultConnection' in appsettings.json");
        }

        // Register DbContext with SQL Server provider
        services.AddDbContext<IdentityDbContext>(options =>
            options.UseSqlServer(connectionString));

        // Register repository implementations
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
        services.AddScoped<IAuditRepository, AuditRepository>();

        return services;
    }
}
