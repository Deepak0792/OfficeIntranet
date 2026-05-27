using System.Collections.Generic;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

namespace SdxCore.Common.Messaging;

public class RabbitMqTopologyConfigurator : IRabbitMqTopologyConfigurator
{
    private readonly IConnection _connection;
    private readonly RabbitMqConfiguration _config;

    public RabbitMqTopologyConfigurator(IConnection connection, IOptions<RabbitMqConfiguration> options)
    {
        _connection = connection;
        _config = options.Value;
    }

    public void ConfigureTopology(string serviceName, IEnumerable<string> queueNames)
    {
        using var channel = _connection.CreateModel();

        // 1. Declare Main Exchange (Topic)
        channel.ExchangeDeclare(_config.ExchangeName, ExchangeType.Topic, durable: true);

        // 2. Declare DLX Exchange (Fanout)
        channel.ExchangeDeclare(_config.DeadLetterExchange, ExchangeType.Fanout, durable: true);

        // 3. Declare DLQ
        var dlqName = $"sdxcore.{serviceName.ToLowerInvariant()}.dlq";
        channel.QueueDeclare(dlqName, durable: true, exclusive: false, autoDelete: false);
        channel.QueueBind(dlqName, _config.DeadLetterExchange, routingKey: "");

        // 4. Declare specific service queues
        var args = new Dictionary<string, object>
        {
            { "x-dead-letter-exchange", _config.DeadLetterExchange }
        };

        foreach (var queueName in queueNames)
        {
            channel.QueueDeclare(queueName, durable: true, exclusive: false, autoDelete: false, arguments: args);
            // Binding is usually explicitly done for topics by the consumer, but we set a default exact match binding
            channel.QueueBind(queueName, _config.ExchangeName, routingKey: queueName);
        }
    }
}
