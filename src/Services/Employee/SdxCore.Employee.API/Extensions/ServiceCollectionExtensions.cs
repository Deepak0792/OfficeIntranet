using SdxCore.Messaging.Extensions;
using SdxCore.Employee.Application.Consumers;

namespace SdxCore.Time.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreEmployeeMessaging(this IServiceCollection services,
        IConfiguration configuration)
    {
        string serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "employee";

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
