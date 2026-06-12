using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using SdxCore.Identity.Application.Abstractions.Providers;
using SdxCore.Identity.Application.Enums;
using SdxCore.Identity.Application.Exceptions;
using System.Collections.Concurrent;

namespace SdxCore.Identity.Application.Providers;

/// <summary>
/// Provider registry implementation that maintains and resolves authentication providers.
/// Uses ConcurrentDictionary for thread-safe provider lookups.
/// Configuration is mandatory - no fallback behavior.
/// </summary>
public sealed class ProviderRegistry : IProviderRegistry
{
    private readonly ConcurrentDictionary<AuthProtocol, IAuthenticationProvider> _providers;
    private readonly IConfiguration _configuration;
    private readonly ILogger<ProviderRegistry> _logger;
    private readonly IServiceProvider _serviceProvider;

    public ProviderRegistry(IConfiguration configuration, ILogger<ProviderRegistry> logger, IServiceProvider serviceProvider)
    {
        _providers = new ConcurrentDictionary<AuthProtocol, IAuthenticationProvider>();
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
    }

    /// <summary>
    /// Registers an authentication provider for a specific protocol.
    /// </summary>
    /// <param name="protocol">Authentication protocol.</param>
    /// <param name="provider">Provider implementation.</param>
    public void Register(AuthProtocol protocol, IAuthenticationProvider provider)
    {
        if (provider == null)
            throw new ArgumentNullException(nameof(provider));

        _providers[protocol] = provider;
        _logger.LogInformation("Registered authentication provider for protocol: {Protocol}", protocol);
    }

    /// <summary>
    /// Resolves an authentication provider by protocol.
    /// </summary>
    /// <param name="protocol">Authentication protocol.</param>
    /// <returns>The registered provider for the specified protocol.</returns>
    /// <exception cref="ProviderNotFoundException">Thrown when no provider is registered for the protocol.</exception>
    public IAuthenticationProvider Resolve(AuthProtocol protocol)
    {
        if (_providers.TryGetValue(protocol, out IAuthenticationProvider? provider))
        {
            return provider;
        }

        _logger.LogError("Provider for protocol '{Protocol}' is not registered", protocol);
        throw new ProviderNotFoundException($"Provider for protocol '{protocol}' is not registered. Please register the provider using the appropriate extension method.");
    }

    /// <summary>
    /// Resolves an authentication provider based on configuration.
    /// Reads the protocol name from appsettings.json and returns the corresponding provider.
    /// Configuration is mandatory - no fallback behavior.
    /// </summary>
    /// <returns>The registered provider for the configured protocol.</returns>
    /// <exception cref="ConfigurationException">Thrown when protocol is not configured or invalid.</exception>
    /// <exception cref="ProviderNotFoundException">Thrown when the configured protocol is not registered.</exception>
    public IAuthenticationProvider ResolveFromConfiguration()
    {
        // 1. Read protocol name from appsettings.json
        string? protocolName = _configuration["Authentication:Protocol"];

        // 2. No protocol configured → throw exception (mandatory configuration)
        if (string.IsNullOrWhiteSpace(protocolName))
        {
            _logger.LogError("Authentication protocol is not configured in appsettings.json. Please set 'Authentication:Protocol' to one of: InHouse, Saml, OAuth, Oidc, Jwt, Ldap");
            throw new ConfigurationException("Authentication protocol is not configured in appsettings.json. Please set 'Authentication:Protocol' to one of: InHouse, Saml, OAuth, Oidc, Jwt, Ldap");
        }

        // 3. Parse protocol name to enum
        if (!Enum.TryParse(protocolName, ignoreCase: true, out AuthProtocol protocol))
        {
            _logger.LogError("Invalid protocol name '{ProtocolName}' in configuration. Valid values are: InHouse, Saml, OAuth, Oidc, Jwt, Ldap", protocolName);
            throw new ConfigurationException($"Invalid protocol name '{protocolName}' in configuration. Valid values are: InHouse, Saml, OAuth, Oidc, Jwt, Ldap");
        }

        // 4. Protocol specified and registered as instance → return it
        if (_providers.TryGetValue(protocol, out IAuthenticationProvider? provider))
        {
            _logger.LogDebug("Resolved authentication provider for protocol: {Protocol}", protocol);
            return provider;
        }

        // 5. Try to resolve the provider directly from DI based on protocol
        try
        {
            IAuthenticationProvider resolvedProvider = protocol switch
            {
                AuthProtocol.InHouse => _serviceProvider.GetRequiredService<IInHouseProvider>(),
                AuthProtocol.Saml => _serviceProvider.GetRequiredService<IAuthenticationProvider>(),
                AuthProtocol.OAuth => _serviceProvider.GetRequiredService<IAuthenticationProvider>(),
                AuthProtocol.Oidc => _serviceProvider.GetRequiredService<IAuthenticationProvider>(),
                AuthProtocol.Jwt => _serviceProvider.GetRequiredService<IAuthenticationProvider>(),
                AuthProtocol.Ldap => _serviceProvider.GetRequiredService<IAuthenticationProvider>(),
                // Other providers are not implemented yet
                _ => throw new ProviderNotFoundException($"Provider for protocol '{protocol}' is not implemented yet.")
            };

            _logger.LogDebug("Resolved authentication provider from DI for protocol: {Protocol}", protocol);
            return resolvedProvider;
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogError(ex, "Failed to resolve provider from DI for protocol: {Protocol}", protocol);
            throw new ProviderNotFoundException($"Provider for protocol '{protocol}' is not registered. Please register the provider using the appropriate extension method (e.g., AddInHouseProvider, AddSamlProvider).");
        }
    }
}
