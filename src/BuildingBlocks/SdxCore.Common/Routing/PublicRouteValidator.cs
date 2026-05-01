using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace SdxCore.Common.Routing;

/// <summary>
/// Utility class for validating public routes that don't require authentication.
/// Provides consistent route matching logic across Gateway and other services.
/// </summary>
public class PublicRouteValidator
{
    private readonly HashSet<string> _publicRoutes;
    private readonly ILogger<PublicRouteValidator>? _logger;

    /// <summary>
    /// Initializes a new instance of the PublicRouteValidator.
    /// </summary>
    /// <param name="configuration">Configuration service to load public routes from.</param>
    /// <param name="logger">Optional logger for debugging route matching.</param>
    public PublicRouteValidator(IConfiguration configuration, ILogger<PublicRouteValidator>? logger = null)
    {
        _logger = logger;
        _publicRoutes = LoadPublicRoutes(configuration);
    }

    /// <summary>
    /// Checks if the given path is a public route that doesn't require authentication.
    /// </summary>
    /// <param name="path">The request path to check.</param>
    /// <returns>True if the path is public, false if authentication is required.</returns>
    public bool IsPublicRoute(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return false;
        }

        var normalizedPath = path.ToLowerInvariant();

        // Check exact matches first
        if (_publicRoutes.Contains(normalizedPath))
        {
            _logger?.LogDebug("Path {Path} matched exact public route", path);
            return true;
        }

        // Check wildcard patterns (routes ending with /*)
        foreach (var publicRoute in _publicRoutes)
        {
            if (publicRoute.EndsWith("/*"))
            {
                var prefix = publicRoute.Substring(0, publicRoute.Length - 2);
                if (normalizedPath.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                {
                    _logger?.LogDebug("Path {Path} matched wildcard public route {Route}", path, publicRoute);
                    return true;
                }
            }
        }

        _logger?.LogDebug("Path {Path} is not a public route", path);
        return false;
    }

    /// <summary>
    /// Gets all configured public routes.
    /// </summary>
    /// <returns>A read-only collection of public routes.</returns>
    public IReadOnlyCollection<string> GetPublicRoutes()
    {
        return _publicRoutes.ToList().AsReadOnly();
    }

    /// <summary>
    /// Loads public routes from configuration.
    /// </summary>
    /// <param name="configuration">Configuration service.</param>
    /// <returns>A set of normalized public routes.</returns>
    private HashSet<string> LoadPublicRoutes(IConfiguration configuration)
    {
        var publicRoutes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        
        // Load from configuration
        var configSection = configuration.GetSection("Authentication:PublicRoutes");
        var configRoutes = configSection.Exists() ? configSection.Get<string[]>() : null;
        if (configRoutes != null)
        {
            foreach (var route in configRoutes)
            {
                if (!string.IsNullOrWhiteSpace(route))
                {
                    publicRoutes.Add(route.ToLowerInvariant());
                }
            }
        }

        // Always allow common health and authentication endpoints
        var defaultPublicRoutes = new[]
        {
            "/health",
            "/health/*",
            "/api/auth/login",
            "/swagger",
            "/swagger/*",
            "/swagger-ui/*"
        };

        foreach (var route in defaultPublicRoutes)
        {
            publicRoutes.Add(route);
        }

        _logger?.LogInformation("Loaded {Count} public routes: {Routes}", 
            publicRoutes.Count, string.Join(", ", publicRoutes));

        return publicRoutes;
    }
}

/// <summary>
/// Static utility methods for public route validation without dependency injection.
/// </summary>
public static class PublicRouteUtilities
{
    /// <summary>
    /// Creates a simple public route validator from configuration.
    /// </summary>
    /// <param name="configuration">Configuration service.</param>
    /// <param name="logger">Optional logger.</param>
    /// <returns>A configured PublicRouteValidator instance.</returns>
    public static PublicRouteValidator CreateValidator(IConfiguration configuration, ILogger<PublicRouteValidator>? logger = null)
    {
        return new PublicRouteValidator(configuration, logger);
    }

    /// <summary>
    /// Quick check if a path matches common public route patterns.
    /// This is a lightweight alternative when full configuration loading isn't needed.
    /// </summary>
    /// <param name="path">The path to check.</param>
    /// <returns>True if the path matches common public patterns.</returns>
    public static bool IsCommonPublicRoute(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return false;
        }

        var normalizedPath = path.ToLowerInvariant();

        var commonPublicPaths = new[]
        {
            "/health",
            "/api/auth/login",
            "/swagger",
            "/swagger-ui"
        };

        // Check exact matches
        if (commonPublicPaths.Contains(normalizedPath))
        {
            return true;
        }

        // Check common prefixes
        var commonPublicPrefixes = new[]
        {
            "/health/",
            "/swagger/",
            "/swagger-ui/"
        };

        return commonPublicPrefixes.Any(prefix => normalizedPath.StartsWith(prefix));
    }
}