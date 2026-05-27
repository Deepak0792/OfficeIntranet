using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using RabbitMQ.Client;
using SdxCore.Common.Caching;
using SdxCore.Common.Contexts;
using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Common.Messaging;
using StackExchange.Redis;

namespace SdxCore.Common.Extensions;

/// <summary>
/// Extension methods for registering Common module services with dependency injection.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Extension methods for registering Common module services with dependency injection. 
    /// </summary>
    /// <param name="services"></param>
    /// <param name="configuration"></param>
    /// <returns></returns>
    /// <exception cref="ArgumentNullException"></exception>
    public static IServiceCollection AddSdxCoreCommon(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        if (services is null)
            throw new ArgumentNullException(nameof(services));

        if (configuration is null)
            throw new ArgumentNullException(nameof(configuration));

        services.AddScoped<IRequestContext, RequestContext>();

        return services;
    }

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

    /// <summary>
    /// Extension method to register RabbitMQ messaging services.
    /// </summary>
    public static IServiceCollection AddSdxMessaging(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.Configure<RabbitMqConfiguration>(configuration.GetSection("RabbitMQ"));
        
        var rabbitConfig = configuration.GetSection("RabbitMQ").Get<RabbitMqConfiguration>() ?? new RabbitMqConfiguration();

        services.AddSingleton<IConnection>(sp =>
        {
            var factory = new ConnectionFactory
            {
                HostName = rabbitConfig.Host,
                Port = rabbitConfig.Port,
                VirtualHost = rabbitConfig.VirtualHost,
                UserName = rabbitConfig.Username,
                Password = rabbitConfig.Password,
                DispatchConsumersAsync = true
            };
            return factory.CreateConnection();
        });

        services.AddSingleton<IRabbitMqTopologyConfigurator, RabbitMqTopologyConfigurator>();
        services.AddSingleton<IEventPublisher, RabbitMqEventPublisher>();

        return services;
    }
}
