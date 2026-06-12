using SdxCore.Identity.Application.Enums;

namespace SdxCore.Identity.Application.Abstractions.Providers;

/// <summary>
/// Provider registry interface for managing and resolving authentication providers.
/// Maintains the mapping between authentication protocols and their implementations.
/// </summary>
public interface IProviderRegistry
{
    /// <summary>
    /// Registers an authentication provider for a specific protocol.
    /// </summary>
    /// <param name="protocol">Authentication protocol.</param>
    /// <param name="provider">Provider implementation.</param>
    void Register(AuthProtocol protocol, IAuthenticationProvider provider);

    /// <summary>
    /// Resolves an authentication provider by protocol.
    /// </summary>
    /// <param name="protocol">Authentication protocol.</param>
    /// <returns>The registered provider for the specified protocol.</returns>
    /// <exception cref="Exceptions.ProviderNotFoundException">Thrown when no provider is registered for the protocol.</exception>
    IAuthenticationProvider Resolve(AuthProtocol protocol);

    /// <summary>
    /// Resolves an authentication provider based on configuration.
    /// Reads the protocol name from appsettings.json and returns the corresponding provider.
    /// </summary>
    /// <returns>The registered provider for the configured protocol.</returns>
    /// <exception cref="Exceptions.ConfigurationException">Thrown when protocol is not configured or invalid.</exception>
    /// <exception cref="Exceptions.ProviderNotFoundException">Thrown when the configured protocol is not registered.</exception>
    IAuthenticationProvider ResolveFromConfiguration();
}
