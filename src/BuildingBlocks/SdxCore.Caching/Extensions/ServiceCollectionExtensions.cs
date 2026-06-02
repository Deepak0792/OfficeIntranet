using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StackExchange.Redis;

namespace SdxCore.Caching.Extensions;

/// <summary>
/// Extension methods for registering Common module services with dependency injection.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Extension method to register caching services (L1 + L2 Redis).
    /// </summary>
    public static IServiceCollection AddSdxCaching(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var redisConnectionString = configuration["Redis:ConnectionString"];
        if (string.IsNullOrEmpty(redisConnectionString))
            throw new ArgumentException("Redis:ConnectionString is missing in configuration.");

        // Register Memory Cache (L1)
        services.AddMemoryCache();

        // Register Distributed Cache (L2)
        services.AddStackExchangeRedisCache(options =>
        {
            options.Configuration = redisConnectionString;
            options.InstanceName = configuration["Redis:InstanceName"] ?? "sdxcore:";
        });

        // Register ConnectionMultiplexer for pattern deletion
        services.AddSingleton<IConnectionMultiplexer>(sp =>
            ConnectionMultiplexer.Connect(redisConnectionString));

        // Register CacheKeyBuilder
        services.AddSingleton<ICacheKeyBuilder, CacheKeyBuilder>();

        // Register CacheService
        services.AddSingleton<ICacheService, CacheService>();

        return services;
    }
}
