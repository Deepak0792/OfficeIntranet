using Microsoft.Extensions.Logging;
using SdxCore.Common.Helpers;
using SdxCore.Identity.Application.Interfaces.Services;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Repositories;
using SdxCore.SharedKernel.Contracts;
using System.Threading.Channels;

namespace SdxCore.Identity.Application.Providers;

public sealed class AuditLoggerService : IAuditLoggerService, IDisposable
{
    private readonly IAuditRepository _auditRepository;
    private readonly IRequestContext _requestContext;
    private readonly ILogger<AuditLoggerService> _logger;

    private readonly Channel<AuditEvent> _channel;
    private readonly CancellationTokenSource _shutdownCts;
    private readonly Task _processingTask;

    private bool _disposed;

    public AuditLoggerService(
        IAuditRepository auditRepository,
        IRequestContext requestContext,
        ILogger<AuditLoggerService> logger)
    {
        _auditRepository = auditRepository ?? throw new ArgumentNullException(nameof(auditRepository));
        _requestContext = requestContext ?? throw new ArgumentNullException(nameof(requestContext));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));

        var channelOptions = new BoundedChannelOptions(1000)
        {
            FullMode = BoundedChannelFullMode.DropOldest,
            SingleReader = true,
            SingleWriter = false
        };

        _channel = Channel.CreateBounded<AuditEvent>(channelOptions);

        _shutdownCts = new CancellationTokenSource();

        _processingTask = Task.Run(() => ProcessAuditEventsAsync(_shutdownCts.Token));

        _logger.LogInformation(
            "AuditLoggerService initialized with bounded channel (capacity: {Capacity})",
            1000);
    }

    public Task LogAsync(
        AuditEventRequest auditEventRequest,
        CancellationToken ct = default)
    {
        try
        {
            var auditEvent = PropertyMapper.Map<AuditEventRequest, AuditEvent>(auditEventRequest);
            auditEvent.Protocol = auditEventRequest.Protocol.ToString();

            if (!_channel.Writer.TryWrite(auditEvent))
            {
                _logger.LogWarning(
                    "Failed to enqueue audit event {EventType} for user {Username}",
                    auditEvent.EventType,
                    auditEvent.Username ?? "unknown");
            }
        }
        catch (Exception ex)
        {
            // Never break authentication flow because of audit failures.
            _logger.LogError(
                ex,
                "Failed to enqueue audit event: {EventType}",
                auditEventRequest.EventType);
        }

        return Task.CompletedTask;
    }

    private async Task ProcessAuditEventsAsync(CancellationToken ct)
    {
        _logger.LogInformation("Audit event processor started");

        try
        {
            await foreach (AuditEvent auditEvent in _channel.Reader.ReadAllAsync(ct))
            {
                try
                {
                    await _auditRepository.AddAsync(auditEvent, ct);
                    await _auditRepository.SaveChangesAsync(ct);

                    _logger.LogDebug(
                        "Audit event persisted: {EventType}, User: {Username}",
                        auditEvent.EventType,
                        auditEvent.Username ?? "unknown");
                }
                catch (Exception ex)
                {
                    _logger.LogError(
                        ex,
                        "Failed to persist audit event: {EventType}, User: {Username}",
                        auditEvent.EventType,
                        auditEvent.Username ?? "unknown");
                }
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Audit event processor cancelled");
        }
        catch (Exception ex)
        {
            _logger.LogCritical(
                ex,
                "Audit event processor terminated unexpectedly");
        }
    }

    public void Dispose()
    {
        if (_disposed)
        {
            return;
        }

        _disposed = true;

        _logger.LogInformation("Shutting down AuditLoggerService");

        _channel.Writer.Complete();

        try
        {
            _processingTask.Wait(TimeSpan.FromSeconds(10));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(
                ex,
                "AuditLoggerService shutdown timed out");
        }
        finally
        {
            _shutdownCts.Cancel();
            _shutdownCts.Dispose();
        }
    }
}