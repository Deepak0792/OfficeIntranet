using MassTransit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Messaging.Abstractions;
using SdxCore.Messaging.Infrastructure;
using SdxCore.Messaging.Options;

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
        string? endpointPrefix = null,
        Action<IBusRegistrationConfigurator>? configureConsumers = null)
    {
        var rabbitConfig =
            configuration.GetSection("RabbitMQ")
                .Get<RabbitMqConfiguration>()
            ?? new RabbitMqConfiguration();

        services.AddMassTransit(x =>
        {
            configureConsumers?.Invoke(x);

            if (!string.IsNullOrWhiteSpace(endpointPrefix))
            {
                x.SetEndpointNameFormatter(
                    new KebabCaseEndpointNameFormatter(
                        endpointPrefix,
                        includeNamespace: false));
            }
            else
            {
                x.SetKebabCaseEndpointNameFormatter();
            }

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