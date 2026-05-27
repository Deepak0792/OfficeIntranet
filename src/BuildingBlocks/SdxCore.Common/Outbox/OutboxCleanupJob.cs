using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Quartz;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Common.Outbox;

[DisallowConcurrentExecution]
public class OutboxCleanupJob : IJob
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<OutboxCleanupJob> _logger;

    public OutboxCleanupJob(IServiceProvider serviceProvider, ILogger<OutboxCleanupJob> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    public async Task Execute(IJobExecutionContext context)
    {
        _logger.LogInformation("Outbox Cleanup Job starting execution at {Time}", DateTime.UtcNow);

        try
        {
            using var scope = _serviceProvider.CreateScope();
            var outboxRepository = scope.ServiceProvider.GetRequiredService<IOutboxRepository>();
            
            var olderThan = DateTime.UtcNow.AddDays(-30);
            
            await outboxRepository.DeletePublishedMessagesAsync(olderThan, context.CancellationToken);
            
            _logger.LogInformation("Outbox Cleanup Job completed successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred during Outbox Cleanup Job execution.");
            throw new JobExecutionException(ex);
        }
    }
}
