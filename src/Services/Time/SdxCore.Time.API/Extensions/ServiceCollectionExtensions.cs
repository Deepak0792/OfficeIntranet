using SdxCore.Messaging.Extensions;
using SdxCore.Time.Application.Consumers;

namespace SdxCore.Time.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreTimeMessaging(this IServiceCollection services,
        IConfiguration configuration)
    {
        string serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "time";

        services.AddSdxMessaging(
            configuration,
            endpointPrefix: serviceName,
            configureBus =>
            {
                configureBus.AddConsumer<EntityChangedEventConsumer>();
            });

        return services;
    }
}
