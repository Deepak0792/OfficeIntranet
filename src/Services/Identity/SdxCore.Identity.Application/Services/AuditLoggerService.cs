using System.Threading.Channels;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.Identity.Application.Contracts.Services;
using SdxCore.Identity.Domain;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Repositories;

namespace SdxCore.Identity.Application.Providers;

public sealed class AuditBackgroundService : BackgroundService, IAuditLoggerService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<AuditBackgroundService> _logger;

    private readonly Channel<AuditEvent> _channel;

    public AuditBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<AuditBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;

        var options = new BoundedChannelOptions(1000)
        {
            FullMode = BoundedChannelFullMode.DropOldest,
            SingleReader = true,
            SingleWriter = false
        };

        _channel = Channel.CreateBounded<AuditEvent>(options);

        _logger.LogInformation("AuditBackgroundService initialized.");
    }

    // ---------------------------
    // Public API (enqueue only)
    // ---------------------------
    public Task LogAsync(AuditEventRequest request, CancellationToken ct = default)
    {
        try
        {
            var auditEvent = new AuditEvent
            {
                Id = Guid.NewGuid(),
                EventType = request.EventType,
                Username = request.Username,
                EmployeeId = request.EmployeeId,
                Protocol = request.Protocol.ToString(),
                IpAddress = request.IpAddress,
                CreatedAt = DateTime.UtcNow
            };

            if (!_channel.Writer.TryWrite(auditEvent))
            {
                _logger.LogWarning(
                    "Audit queue full. Dropping event {EventType} for {Username}",
                    auditEvent.EventType,
                    auditEvent.Username ?? "unknown");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to enqueue audit event");
        }

        return Task.CompletedTask;
    }

    // ---------------------------
    // Background consumer loop
    // ---------------------------
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Audit background processor started.");

        await foreach (var auditEvent in _channel.Reader.ReadAllAsync(stoppingToken))
        {
            try
            {
                await using var scope = _scopeFactory.CreateAsyncScope();

                var repo = scope.ServiceProvider.GetRequiredService<IAuditRepository>();
                var uow = scope.ServiceProvider.GetRequiredService<IIdentityUnitOfWork>();

                await repo.AddAsync(auditEvent, stoppingToken);
                await uow.SaveChangesAsync(stoppingToken);

                _logger.LogDebug(
                    "Audit persisted: {EventType} - {Username}",
                    auditEvent.EventType,
                    auditEvent.Username ?? "unknown");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to persist audit event {EventType}",
                    auditEvent.EventType);
            }
        }

        _logger.LogInformation("Audit background processor stopping.");
    }
}