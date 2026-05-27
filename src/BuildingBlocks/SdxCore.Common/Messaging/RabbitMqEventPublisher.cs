using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

namespace SdxCore.Common.Messaging;

public class RabbitMqEventPublisher : IEventPublisher
{
    private readonly IConnection _connection;
    private readonly RabbitMqConfiguration _config;

    public RabbitMqEventPublisher(IConnection connection, IOptions<RabbitMqConfiguration> options)
    {
        _connection = connection;
        _config = options.Value;
    }

    public Task PublishAsync<T>(T @event, string routingKey, IDictionary<string, object> headers = null, CancellationToken cancellationToken = default) where T : class
    {
        var payload = JsonSerializer.Serialize(@event);
        return PublishRawAsync(payload, routingKey, headers, cancellationToken);
    }

    public Task PublishRawAsync(string payload, string routingKey, IDictionary<string, object> headers = null, CancellationToken cancellationToken = default)
    {
        var body = Encoding.UTF8.GetBytes(payload);

        using var channel = _connection.CreateModel();
        var properties = channel.CreateBasicProperties();
        properties.Persistent = true;

        if (headers != null)
        {
            properties.Headers = headers;
        }

        channel.BasicPublish(
            exchange: _config.ExchangeName,
            routingKey: routingKey,
            basicProperties: properties,
            body: body);

        return Task.CompletedTask;
    }
}
