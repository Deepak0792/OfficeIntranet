using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Common.Outbox;

public class OutboxProcessorJob : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<OutboxProcessorJob> _logger;
    private readonly int _batchSize = 20;

    public OutboxProcessorJob(IServiceProvider serviceProvider, ILogger<OutboxProcessorJob> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Outbox Processor Job started.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessOutboxMessagesAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while processing outbox messages.");
            }

            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }

    private async Task ProcessOutboxMessagesAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var outboxRepository = scope.ServiceProvider.GetRequiredService<IOutboxRepository>();
        var eventPublisher = scope.ServiceProvider.GetRequiredService<IEventPublisher>();

        var messages = await outboxRepository.GetPendingMessagesAsync(_batchSize, cancellationToken);

        foreach (var message in messages)
        {
            try
            {
                await eventPublisher.PublishAsync(message.Exchange, message.RoutingKey, message.Payload, cancellationToken);
                
                message.Status = "PUBLISHED";
                message.PublishedAt = DateTime.UtcNow;
                message.LastUpdatedAt = DateTime.UtcNow;
                message.ErrorMessage = null;
                
                await outboxRepository.UpdateMessageAsync(message, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to publish outbox message {MessageId}", message.Id);
                
                message.RetryCount++;
                message.ErrorMessage = ex.Message;
                message.LastUpdatedAt = DateTime.UtcNow;
                
                if (message.RetryCount >= 5)
                {
                    message.Status = "DEAD_LETTERED";
                }
                else
                {
                    message.Status = "RETRYING";
                }
                
                await outboxRepository.UpdateMessageAsync(message, cancellationToken);
            }
        }
    }
}
