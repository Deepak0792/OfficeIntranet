using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Contexts;
using SdxCore.Common.Interfaces.Contexts;
using Quartz;

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
    /// Extension method to register caching infrastructure (L1 Memory Cache, L2 Distributed Redis Cache)
    /// </summary>
    public static IServiceCollection AddSdxCoreCaching(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddMemoryCache();
        
        var redisConnectionString = configuration.GetConnectionString("Redis");
        if (!string.IsNullOrEmpty(redisConnectionString))
        {
            services.AddStackExchangeRedisCache(options =>
            {
                options.Configuration = redisConnectionString;
                options.InstanceName = "SdxCore_";
            });
        }
        else
        {
            // Fallback for local dev if Redis is not configured
            services.AddDistributedMemoryCache();
        }

        services.AddSingleton<SdxCore.Common.Caching.ICacheService, SdxCore.Common.Caching.CacheService>();

        return services;
    }

    /// <summary>
    /// Extension method to register Quartz and common Outbox jobs
    /// </summary>
    public static IServiceCollection AddSdxCoreQuartz(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddQuartz(q =>
        {
            var jobKey = new Quartz.JobKey("OutboxCleanupJob");
            q.AddJob<SdxCore.Common.Outbox.OutboxCleanupJob>(opts => opts.WithIdentity(jobKey));

            var cronSchedule = configuration.GetValue<string>("Quartz:OutboxCleanupCron") ?? "0 0 2 * * ?"; // Default 2 AM daily
            q.AddTrigger(opts => opts
                .ForJob(jobKey)
                .WithIdentity("OutboxCleanupJob-trigger")
                .WithCronSchedule(cronSchedule));
        });

        services.AddQuartzHostedService(q => q.WaitForJobsToComplete = true);

        return services;
    }
}
