using MassTransit;
using SdxCore.Messaging.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Messaging.Infrastructure;

public sealed class MassTransitEventPublisher : IEventPublisher
{
    private readonly IPublishEndpoint _publishEndpoint;

    public MassTransitEventPublisher(IPublishEndpoint publishEndpoint)
    {
        _publishEndpoint = publishEndpoint;
    }

    public async Task PublishAsync<T>(
        T @event,
        IDictionary<string, object>? headers = null,
        CancellationToken cancellationToken = default)
        where T : class
    {
        await PublishAsync((object)@event, headers, cancellationToken);
    }

    public async Task PublishAsync(
        object @event,
        IDictionary<string, object>? headers = null,
        CancellationToken cancellationToken = default)
    {
        await _publishEndpoint.Publish(
            @event,
            context =>
            {
                if (headers == null)
                    return;

                foreach (var header in headers)
                    context.Headers.Set(header.Key, header.Value);
            },
            cancellationToken);
    }

    public async Task PublishRawAsync(
        string payload,
        string messageType,
        IDictionary<string, object>? headers = null,
        CancellationToken cancellationToken = default)
    {
        await _publishEndpoint.Publish(
            new RawMessage
            {
                MessageType = messageType,
                Payload = payload
            },
            context =>
            {
                if (headers is null)
                    return;

                foreach (var header in headers)
                    context.Headers.Set(header.Key, header.Value);
            },
            cancellationToken);
    }
}
