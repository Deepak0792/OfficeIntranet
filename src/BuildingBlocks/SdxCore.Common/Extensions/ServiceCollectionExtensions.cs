using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

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

        //services.AddScoped<IRequestContext, RequestContext>();

        return services;
    }  
}
