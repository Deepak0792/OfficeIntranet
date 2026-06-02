using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Diagnostics;
using SdxCore.SharedKernel.Constant;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Events;
using System.Text.Json;

namespace SdxCore.SharedKernel.Persistence;

public sealed class OutboxSaveChangesInterceptor : SaveChangesInterceptor
{
    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        var context = eventData.Context;

        if (context is null)
            return base.SavingChangesAsync(eventData, result, cancellationToken);

        var outboxMessages = BuildOutboxMessages(context);

        if (outboxMessages.Count > 0)
        {
            context.Set<OutboxMessage>().AddRange(outboxMessages);
        }

        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    private static List<OutboxMessage> BuildOutboxMessages(DbContext context)
    {
        var outboxMessages = new List<OutboxMessage>();

        var trackedEntries = context.ChangeTracker
            .Entries()
            .Where(e =>
                e.Entity is IPublishableEntity &&
                e.Entity is not OutboxMessage &&
                (
                    e.State == EntityState.Added ||
                    e.State == EntityState.Modified ||
                    e.State == EntityState.Deleted
                ))
            .ToList();

        foreach (var entry in trackedEntries)
        {
            var entity = entry.Entity;

            var idProperty = entity.GetType().GetProperty("Id");
            var entityId = idProperty?.GetValue(entity);

            if (entityId is null)
                continue;

            var integrationEvent = new EntityChangedEvent(
                Id: entityId.ToString()!,
                EntityName: entity.GetType().Name,
                Operation: GetOperation(entry),
                OccurredOnUtc: DateTime.UtcNow);

            outboxMessages.Add(new OutboxMessage
            {
                Id = Guid.NewGuid(),

                EventType = typeof(EntityChangedEvent)
                    .AssemblyQualifiedName!,

                Payload = JsonSerializer.Serialize(integrationEvent),

                Status = "PENDING",
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

    private static string GetOperation(EntityEntry entry)
    {
        return entry.State switch
        {
            EntityState.Added => "Created",

            EntityState.Modified =>
                IsSoftDeleted(entry) ? "SoftDeleted" : "Updated",

            EntityState.Deleted => "Deleted",

            _ => throw new InvalidOperationException(
                $"Unsupported entity state {entry.State}")
        };
    }

    private static bool IsSoftDeleted(EntityEntry entry)
    {
        var property = entry.Properties
            .FirstOrDefault(p => p.Metadata.Name == "IsActive");

        if (property is null)
            return false;

        return property.IsModified &&
               property.OriginalValue is true &&
               property.CurrentValue is false;
    }
}