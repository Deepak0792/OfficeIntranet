// SdxCore.Messaging.BackgroundServices
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.SharedKernel.Constant;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using System.Text.Json;

namespace SdxCore.Messaging.BackgroundServices;

public sealed class OutboxProcessorBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<OutboxProcessorBackgroundService> _logger;
    private readonly int _batchSize;
    private readonly int _maxRetries;
    private readonly int _pollingIntervalSeconds;

    public OutboxProcessorBackgroundService(
        IServiceProvider serviceProvider,
        IConfiguration configuration,
        ILogger<OutboxProcessorBackgroundService> logger)
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
        _logger.LogInformation(
            "Outbox Processor started. BatchSize={BatchSize}, MaxRetries={MaxRetries}, PollingInterval={PollingIntervalSeconds}s",
            _batchSize, _maxRetries, _pollingIntervalSeconds);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessOutboxMessagesAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error while processing outbox messages.");
            }

            try
            {
                await Task.Delay(
                    TimeSpan.FromSeconds(_pollingIntervalSeconds),
                    stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }

        _logger.LogInformation("Outbox Processor stopped.");
    }

    private async Task ProcessOutboxMessagesAsync(CancellationToken cancellationToken)
    {
        await using var scope = _serviceProvider.CreateAsyncScope();

        var outboxRepository = scope.ServiceProvider
            .GetRequiredService<IOutboxRepository>();

        var unitOfWork = scope.ServiceProvider
            .GetRequiredService<IUnitOfWork>();

        var publisher = scope.ServiceProvider
            .GetRequiredService<IEventPublisher>();

        var messages = await outboxRepository.GetPendingAsync(_batchSize, cancellationToken);
        if (messages.Count == 0) return;

        foreach (var message in messages)
        {
            try
            {
                await PublishMessageAsync(publisher, message, cancellationToken);
                message.Status = OutboxStatus.Published;
                message.PublishedAt = DateTime.UtcNow;
                message.LastUpdatedAt = DateTime.UtcNow;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to publish outbox message {MessageId}.", message.Id);

                message.RetryCount++;
                message.ErrorMessage = ex.ToString();
                message.LastUpdatedAt = DateTime.UtcNow;

                if (message.RetryCount >= _maxRetries)
                    message.Status = OutboxStatus.Failed;
            }
        }

        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private async Task PublishMessageAsync(
        IEventPublisher publisher,
        OutboxMessage message,
        CancellationToken cancellationToken)
    {
        var eventType = Type.GetType(message.EventType)
            ?? throw new InvalidOperationException(
                $"Unable to resolve event type '{message.EventType}'.");

        var eventObject = JsonSerializer.Deserialize(message.Payload, eventType)
            ?? throw new InvalidOperationException(
                $"Unable to deserialize payload for '{message.EventType}'.");

        var headers = new Dictionary<string, object>
        {
            ["EventType"] = eventType.Name
        };

        await publisher.PublishAsync(eventObject, headers, cancellationToken);
    }
}