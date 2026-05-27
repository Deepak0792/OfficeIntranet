using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using SdxCore.Common.Caching;
using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.API.BackgroundServices;

public class CacheInvalidationConsumer : BackgroundService
{
    private readonly ICacheService _cacheService;
    private readonly ILogger<CacheInvalidationConsumer> _logger;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly string _queueName;

    public CacheInvalidationConsumer(ICacheService cacheService, IConfiguration configuration, ILogger<CacheInvalidationConsumer> logger)
    {
        _cacheService = cacheService;
        _logger = logger;

        var factory = new ConnectionFactory
        {
            Uri = new Uri(configuration.GetConnectionString("RabbitMQ") ?? "amqp://guest:guest@localhost:5672"),
            DispatchConsumersAsync = true
        };

        _connection = factory.CreateConnection();
        _channel = _connection.CreateModel();

        // Declare a topic exchange
        var exchangeName = "sdxcore-events";
        _channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Topic, durable: true);

        // Declare a unique, exclusive queue for this specific replica instance for L1 cache invalidation
        _queueName = _channel.QueueDeclare().QueueName;

        // Bind queue to all department events
        _channel.QueueBind(queue: _queueName, exchange: exchangeName, routingKey: "departmentcreatedevent");
        _channel.QueueBind(queue: _queueName, exchange: exchangeName, routingKey: "departmentupdatedevent");
        _channel.QueueBind(queue: _queueName, exchange: exchangeName, routingKey: "departmentdeletedevent");
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            var routingKey = ea.RoutingKey;
            _logger.LogInformation("Received cache invalidation event: {RoutingKey}", routingKey);

            try
            {
                // Invalidate local L1 cache (L2 is shared, but clearing L1 prevents stale reads)
                await _cacheService.RemoveByPrefixAsync("Department_", stoppingToken);
                _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to invalidate cache");
                _channel.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(queue: _queueName, autoAck: false, consumer: consumer);

        return Task.CompletedTask;
    }

    public override void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
        base.Dispose();
    }
}
