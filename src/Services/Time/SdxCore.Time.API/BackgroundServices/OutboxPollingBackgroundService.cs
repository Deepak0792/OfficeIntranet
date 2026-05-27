using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Messaging;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.API.BackgroundServices;

public class OutboxPollingBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<OutboxPollingBackgroundService> _logger;
    private readonly int _batchSize;
    private readonly int _maxRetries;
    private readonly int _pollingIntervalSeconds;

    public OutboxPollingBackgroundService(IServiceProvider serviceProvider, IConfiguration configuration, ILogger<OutboxPollingBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;

        var section = configuration.GetSection("OutboxSettings");
        _batchSize = section.GetValue<int>("BatchSize", 50);
        _maxRetries = section.GetValue<int>("MaxRetries", 3);
        _pollingIntervalSeconds = section.GetValue<int>("PollingIntervalSeconds", 5);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Outbox Polling Background Service started.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessOutboxMessagesAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while polling the outbox.");
            }

            // Poll at configured interval
            await Task.Delay(TimeSpan.FromSeconds(_pollingIntervalSeconds), stoppingToken);
        }
    }

    private async Task ProcessOutboxMessagesAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<TimeDbContext>();
        var eventPublisher = scope.ServiceProvider.GetRequiredService<IEventPublisher>();

        var messages = await dbContext.OutboxMessages
            .Where(m => m.Status == "PENDING" && m.RetryCount < _maxRetries)
            .OrderBy(m => m.CreatedAt)
            .Take(_batchSize)
            .ToListAsync(cancellationToken);

        if (!messages.Any())
        {
            return;
        }

        foreach (var message in messages)
        {
            try
            {
                var headers = new Dictionary<string, object>
                {
                    { "EventType", message.EventType }
                };

                await eventPublisher.PublishRawAsync(message.Payload, message.RoutingKey, headers, cancellationToken);
                
                message.Status = "PUBLISHED";
                message.PublishedAt = DateTime.UtcNow;
                message.LastUpdatedAt = DateTime.UtcNow;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to publish outbox message {MessageId}", message.Id);
                
                message.RetryCount++;
                message.ErrorMessage = ex.Message;
                message.LastUpdatedAt = DateTime.UtcNow;

                if (message.RetryCount >= _maxRetries)
                {
                    message.Status = "FAILED";
                }
            }
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
