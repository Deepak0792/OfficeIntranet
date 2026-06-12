using System;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace SdxCore.Caching;

public interface ICacheKeyBuilder
{
    string BuildKey(string entity, string identifier);
    string BuildPattern(string entity, string identifierPattern);
}

public class CacheKeyBuilder : ICacheKeyBuilder
{
    private readonly string _environment;
    private readonly string _serviceName;

    public CacheKeyBuilder(IHostEnvironment environment, IConfiguration configuration)
    {
        _environment = environment.EnvironmentName.ToLowerInvariant();
        // Assuming AppName or ServiceName is defined in appsettings
        _serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "unknown";        
    }

    public string BuildKey(string entity, string identifier)
    {
        if (string.IsNullOrWhiteSpace(entity)) throw new ArgumentNullException(nameof(entity));
        if (string.IsNullOrWhiteSpace(identifier)) throw new ArgumentNullException(nameof(identifier));

        return $"{_environment}:{entity.ToLowerInvariant()}:{identifier.ToLowerInvariant()}";
    }

    public string BuildPattern(string entity, string identifierPattern)
    {
        if (string.IsNullOrWhiteSpace(entity)) throw new ArgumentNullException(nameof(entity));
        if (string.IsNullOrWhiteSpace(identifierPattern)) throw new ArgumentNullException(nameof(identifierPattern));

        return $"{_environment}:{entity.ToLowerInvariant()}:{identifierPattern.ToLowerInvariant()}";
    }
}
