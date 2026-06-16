// SdxCore.SharedKernel.Persistence
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Diagnostics;
using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Constant;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Events;
using System.Collections.Concurrent;
using System.Text.Json;

namespace SdxCore.SharedKernel.Persistence.Interceptors;

public sealed class OutboxSaveChangesInterceptor : SaveChangesInterceptor
{
    // Keyed by context instance — safe for singleton interceptor with multiple scoped contexts
    private readonly ConcurrentDictionary<DbContext, List<(EntityEntry Entry, string Operation)>>
        _pendingEntries = new();

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        var context = eventData.Context;
        if (context is null)
            return base.SavingChangesAsync(eventData, result, cancellationToken);

        var entries = context.ChangeTracker
            .Entries()
            .Where(e =>
                e.Entity is IPublishableEntity &&
                e.Entity is not OutboxMessage &&
                e.State is EntityState.Added or EntityState.Modified or EntityState.Deleted)
            .Select(e => (e, GetOperation(e)))
            .ToList();

        _pendingEntries[context] = entries;

        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    public override async ValueTask<int> SavedChangesAsync(
        SaveChangesCompletedEventData eventData,
        int result,
        CancellationToken cancellationToken = default)
    {
        var context = eventData.Context;
        if (context is null || !_pendingEntries.TryRemove(context, out var pending) || pending.Count == 0)
            return await base.SavedChangesAsync(eventData, result, cancellationToken);

        var outboxMessages = BuildOutboxMessages(pending);

        if (outboxMessages.Count > 0)
        {
            context.Set<OutboxMessage>().AddRange(outboxMessages);
            await context.SaveChangesAsync(cancellationToken);
        }

        return await base.SavedChangesAsync(eventData, result, cancellationToken);
    }

    private static List<OutboxMessage> BuildOutboxMessages(
        List<(EntityEntry Entry, string Operation)> pendingEntries)
    {
        var outboxMessages = new List<OutboxMessage>();

        foreach (var (entry, operation) in pendingEntries)
        {
            var entity = entry.Entity;
            var entityId = entity.GetType().GetProperty("Id")?.GetValue(entity);

            if (entityId is null)
                continue;

            var integrationEvent = new EntityChangedEvent(
                Id: entityId.ToString()!,
                EntityName: entity.GetType().Name,
                Operation: operation,
                CreatedAt: DateTime.UtcNow);

            outboxMessages.Add(new OutboxMessage
            {
                Id = Guid.NewGuid(),
                EventType = typeof(EntityChangedEvent).AssemblyQualifiedName!,
                Payload = JsonSerializer.Serialize(integrationEvent),
                Exchange = "sdxcore.events",
                RoutingKey = $"sdxcore.events.{entity.GetType().Name.ToLower()}",
                Status = OutboxStatus.Pending,
                StatusGroup = "OUTBOX_STATUS",

                IsActive = true,
                RetryCount = 0,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = SystemUser.SystemUserId,
                LastUpdatedAt = DateTime.UtcNow,
                LastUpdatedBy = SystemUser.SystemUserId
            });
        }

        return outboxMessages;
    }

    private static string GetOperation(EntityEntry entry) => entry.State switch
    {
        EntityState.Added => "Created",
        EntityState.Modified => IsSoftDeleted(entry) ? "SoftDeleted" : "Updated",
        EntityState.Deleted => "Deleted",
        _ => throw new InvalidOperationException($"Unsupported entity state {entry.State}")
    };

    private static bool IsSoftDeleted(EntityEntry entry)
    {
        var property = entry.Properties.FirstOrDefault(p => p.Metadata.Name == "IsActive");
        return property is not null &&
               property.IsModified &&
               property.OriginalValue is true &&
               property.CurrentValue is false;
    }
}
