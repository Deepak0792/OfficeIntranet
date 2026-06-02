using MassTransit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace SdxCore.Messaging.Extensions;

/// <summary>
/// Extension methods for registering Common module services with dependency injection.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers MassTransit with RabbitMQ.
    /// </summary>
    public static IServiceCollection AddSdxMessaging(
     this IServiceCollection services,
     IConfiguration configuration,
     Action<IBusRegistrationConfigurator>? configureConsumers = null)
    {
        var rabbitConfig =
            configuration.GetSection("RabbitMQ")
                .Get<RabbitMqConfiguration>()
            ?? new RabbitMqConfiguration();

        services.AddMassTransit(x =>
        {
            configureConsumers?.Invoke(x);

            x.SetKebabCaseEndpointNameFormatter();

            x.UsingRabbitMq((context, cfg) =>
            {
                cfg.Host(
                    new Uri(
                        $"rabbitmq://{rabbitConfig.Host}:{rabbitConfig.Port}/{rabbitConfig.VirtualHost.TrimStart('/')}"
                    ),
                    h =>
                    {
                        h.Username(rabbitConfig.Username);
                        h.Password(rabbitConfig.Password);
                    });

                cfg.ConfigureEndpoints(context);
            });
        });

        services.AddScoped<IEventPublisher, MassTransitEventPublisher>();

        return services;
    }
}
