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

    /// <summary>
    /// Registers the SAML authentication provider with the provider registry.
    /// The SAML provider validates SAML 2.0 assertions from external identity providers.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services is null.</exception>
    public static IServiceCollection AddSamlProvider(this IServiceCollection services)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        // Register SamlProvider as a scoped service
        services.AddScoped<SamlProvider>();

        // Register the provider with the provider registry
        services.AddScoped<IAuthenticationProvider>(sp =>
        {
            var samlProvider = sp.GetRequiredService<SamlProvider>();
            var registry = sp.GetRequiredService<IProviderRegistry>();
            registry.Register(AuthProtocol.Saml, samlProvider);
            return samlProvider;
        });

        return services;
    }

    /// <summary>
    /// Registers the OAuth authentication provider with the provider registry.
    /// The OAuth provider handles OAuth 2.0 authorization code exchange flows.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services is null.</exception>
    public static IServiceCollection AddOAuthProvider(this IServiceCollection services)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        // Register OAuthProvider as a scoped service
        services.AddScoped<OAuthProvider>();

        // Register the provider with the provider registry
        services.AddScoped<IAuthenticationProvider>(sp =>
        {
            var oauthProvider = sp.GetRequiredService<OAuthProvider>();
            var registry = sp.GetRequiredService<IProviderRegistry>();
            registry.Register(AuthProtocol.OAuth, oauthProvider);
            return oauthProvider;
        });

        return services;
    }

    /// <summary>
    /// Registers the OpenID Connect authentication provider with the provider registry.
    /// The OIDC provider validates ID tokens from OpenID Connect identity providers.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services is null.</exception>
    public static IServiceCollection AddOidcProvider(this IServiceCollection services)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        // Register OidcProvider as a scoped service
        services.AddScoped<OidcProvider>();

        // Register the provider with the provider registry
        services.AddScoped<IAuthenticationProvider>(sp =>
        {
            var oidcProvider = sp.GetRequiredService<OidcProvider>();
            var registry = sp.GetRequiredService<IProviderRegistry>();
            registry.Register(AuthProtocol.Oidc, oidcProvider);
            return oidcProvider;
        });

        return services;
    }

    /// <summary>
    /// Registers the JWT authentication provider with the provider registry.
    /// The JWT provider validates JWT bearer tokens provided in authentication requests.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services is null.</exception>
    public static IServiceCollection AddJwtProvider(this IServiceCollection services)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        // Register JwtProvider as a scoped service
        services.AddScoped<JwtProvider>();

        // Register the provider with the provider registry
        services.AddScoped<IAuthenticationProvider>(sp =>
        {
            var jwtProvider = sp.GetRequiredService<JwtProvider>();
            var registry = sp.GetRequiredService<IProviderRegistry>();
            registry.Register(AuthProtocol.Jwt, jwtProvider);
            return jwtProvider;
        });

        return services;
    }

    /// <summary>
    /// Registers the LDAP authentication provider with the provider registry.
    /// The LDAP provider performs bind operations against LDAP/Active Directory servers.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <exception cref="ArgumentNullException">Thrown when services is null.</exception>
    public static IServiceCollection AddLdapProvider(this IServiceCollection services)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        // Register LdapProvider as a scoped service
        services.AddScoped<LdapProvider>();

        // Register the provider with the provider registry
        services.AddScoped<IAuthenticationProvider>(sp =>
        {
            var ldapProvider = sp.GetRequiredService<LdapProvider>();
            var registry = sp.GetRequiredService<IProviderRegistry>();
            registry.Register(AuthProtocol.Ldap, ldapProvider);
            return ldapProvider;
        });

        return services;
    }
}
