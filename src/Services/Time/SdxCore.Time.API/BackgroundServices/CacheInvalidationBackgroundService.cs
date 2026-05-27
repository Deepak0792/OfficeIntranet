using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using SdxCore.Common.Caching;
using SdxCore.Common.Messaging;

namespace SdxCore.Time.API.BackgroundServices;

public class CacheInvalidationBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IConnection _connection;
    private readonly IRabbitMqTopologyConfigurator _topologyConfigurator;
    private readonly ILogger<CacheInvalidationBackgroundService> _logger;
    private IModel _channel;
    private readonly string _queueName = "cache.time.invalidate";

    public CacheInvalidationBackgroundService(
        IServiceProvider serviceProvider,
        IConnection connection,
        IRabbitMqTopologyConfigurator topologyConfigurator,
        ILogger<CacheInvalidationBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _connection = connection;
        _topologyConfigurator = topologyConfigurator;
        _logger = logger;
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // 1. Declare Queue Topology
        _topologyConfigurator.ConfigureTopology("time", new[] { _queueName });

        // 2. Setup Channel and Consumer
        _channel = _connection.CreateModel();
        _channel.BasicQos(prefetchSize: 0, prefetchCount: 10, global: false);

        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var payload = Encoding.UTF8.GetString(body);
            
            string eventType = null;
            if (ea.BasicProperties.Headers != null && ea.BasicProperties.Headers.TryGetValue("EventType", out var headerObj))
            {
                var bytes = headerObj as byte[];
                eventType = bytes != null ? Encoding.UTF8.GetString(bytes) : headerObj?.ToString();
            }

            try
            {
                await ProcessInvalidationAsync(eventType, payload, stoppingToken);
                _channel.BasicAck(ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing cache invalidation event: {EventType}", eventType);
                _channel.BasicNack(ea.DeliveryTag, multiple: false, requeue: false); // Will go to DLQ because we configured x-dead-letter-exchange
            }
        };

        _channel.BasicConsume(queue: _queueName, autoAck: false, consumer: consumer);

        return Task.CompletedTask;
    }

    private async Task ProcessInvalidationAsync(string eventType, string payload, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(eventType))
        {
            _logger.LogWarning("Received cache invalidation event with no EventType header.");
            return;
        }

        // Extract Entity Name by stripping the action suffixes
        var entityName = eventType
            .Replace("Created", "")
            .Replace("Updated", "")
            .Replace("SoftDeleted", "")
            .Replace("Deleted", "");

        using var scope = _serviceProvider.CreateScope();
        var cacheService = scope.ServiceProvider.GetRequiredService<ICacheService>();
        var cacheKeyBuilder = scope.ServiceProvider.GetRequiredService<ICacheKeyBuilder>();

        // Wildcard invalidation: "sdxcore:development:time:country:*"
        var pattern = cacheKeyBuilder.BuildPattern(entityName, "*");

        _logger.LogInformation("Invalidating cache for Entity: {EntityName} using Pattern: {Pattern}", entityName, pattern);
        
        await cacheService.RemoveByPatternAsync(pattern, cancellationToken);
    }

    public override void Dispose()
    {
        _channel?.Close();
        _channel?.Dispose();
        base.Dispose();
    }
}
