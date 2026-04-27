using Microsoft.Extensions.DependencyInjection;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces;
using SdxCore.Identity.Application.Providers;

namespace SdxCore.Identity.Application.Extensions;

/// <summary>
/// Extension methods for registering authentication providers with dependency injection.
/// </summary>
public static class ProviderExtensions
{
    /// <summary>
    /// Registers the InHouse authentication provider with the provider registry.
    /// The InHouse provider handles username/password authentication backed by SQL Server.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services is null.</exception>
    public static IServiceCollection AddInHouseProvider(this IServiceCollection services)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        // Register InHouseProvider as a scoped service
        services.AddScoped<IInHouseProvider, InHouseProvider>();

        // Register the provider with the provider registry
        services.AddScoped<IAuthenticationProvider>(sp =>
        {
            var inHouseProvider = sp.GetRequiredService<IInHouseProvider>();
            var registry = sp.GetRequiredService<IProviderRegistry>();
            registry.Register(AuthProtocol.InHouse, inHouseProvider);
            return inHouseProvider;
        });

        return services;
    }
}
