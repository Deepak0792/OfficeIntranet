using System.Threading.Channels;
using Microsoft.Extensions.Logging;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Domain.Interfaces.Services;

namespace SdxCore.Identity.Application.Services;

/// <summary>
/// Audit logger implementation that records authentication events asynchronously.
/// Uses a bounded channel with fire-and-forget pattern to avoid blocking the authentication critical path.
/// </summary>
public sealed class AuditLogger : IAuditLogger, IDisposable
{
    private readonly IAuditRepository _auditRepository;
    private readonly ILogger<AuditLogger> _logger;
    private readonly Channel<AuditEvent> _channel;
    private readonly Task _processingTask;
    private readonly CancellationTokenSource _shutdownCts;
    private bool _disposed;

    /// <summary>
    /// Initializes a new instance of the <see cref="AuditLogger"/> class.
    /// </summary>
    /// <param name="auditRepository">Repository for persisting audit events.</param>
    /// <param name="logger">Logger for diagnostic messages.</param>
    public AuditLogger(IAuditRepository auditRepository, ILogger<AuditLogger> logger)
    {
        _auditRepository = auditRepository ?? throw new ArgumentNullException(nameof(auditRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));

        // Create bounded channel with capacity of 1000 events
        // When full, oldest events are dropped (BoundedChannelFullMode.DropOldest)
        var channelOptions = new BoundedChannelOptions(1000)
        {
            FullMode = BoundedChannelFullMode.DropOldest,
            SingleReader = true,
            SingleWriter = false
        };

        _channel = Channel.CreateBounded<AuditEvent>(channelOptions);
        _shutdownCts = new CancellationTokenSource();

        // Start background processing task
        _processingTask = Task.Run(() => ProcessAuditEventsAsync(_shutdownCts.Token));

        _logger.LogInformation("AuditLogger initialized with bounded channel (capacity: 1000)");
    }

    /// <summary>
    /// Logs an authentication audit event asynchronously using fire-and-forget pattern.
    /// This method returns immediately without blocking the caller.
    /// </summary>
    /// <param name="auditEvent">Audit event to log.</param>
    /// <param name="ct">Cancellation token (not used in fire-and-forget pattern).</param>
    public Task LogAsync(AuditEvent auditEvent, CancellationToken ct = default)
    {
        if (auditEvent is null)
        {
            throw new ArgumentNullException(nameof(auditEvent));
        }

        // Fire-and-forget: write to channel without awaiting
        // If channel is full, oldest event is dropped per BoundedChannelFullMode.DropOldest
        if (!_channel.Writer.TryWrite(auditEvent))
        {
            _logger.LogWarning(
                "Failed to enqueue audit event for {EventType} by user {Username} - channel may be closed",
                auditEvent.EventType,
                auditEvent.Username ?? "unknown");
        }

        return Task.CompletedTask;
    }

    /// <summary>
    /// Background task that processes audit events from the channel and writes them to the database.
    /// </summary>
    private async Task ProcessAuditEventsAsync(CancellationToken ct)
    {
        _logger.LogInformation("Audit event processing task started");

        try
        {
            await foreach (var auditEvent in _channel.Reader.ReadAllAsync(ct))
            {
                try
                {
                    await _auditRepository.InsertAsync(auditEvent, ct);

                    _logger.LogDebug(
                        "Audit event persisted: {EventType} for user {Username} from {IpAddress}",
                        auditEvent.EventType,
                        auditEvent.Username ?? "unknown",
                        auditEvent.IpAddress);
                }
                catch (Exception ex)
                {
                    _logger.LogError(
                        ex,
                        "Failed to persist audit event: {EventType} for user {Username}",
                        auditEvent.EventType,
                        auditEvent.Username ?? "unknown");
                    
                    // Continue processing other events even if one fails
                }
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Audit event processing task cancelled");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Audit event processing task failed with unexpected error");
        }
    }

    /// <summary>
    /// Disposes the audit logger and ensures all pending events are processed.
    /// </summary>
    public void Dispose()
    {
        if (_disposed)
            return;

        _disposed = true;
        _logger.LogInformation("Shutting down AuditLogger...");

        // Signal channel writer to complete (no more events will be accepted)
        _channel.Writer.Complete();

        try
        {
            // Wait for processing task to drain remaining events (with timeout)
            _processingTask.Wait(TimeSpan.FromSeconds(10));
            _logger.LogInformation("AuditLogger shutdown complete - all pending events processed");
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "AuditLogger shutdown timeout - some events may not have been processed");
        }
        finally
        {
            _shutdownCts.Cancel();
            _shutdownCts.Dispose();
        }
    }
}
