using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using SdxCore.Common.Models;

namespace SdxCore.Common.Outbox;

public class OutboxSaveChangesInterceptor : SaveChangesInterceptor
{
    public override async ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        var dbContext = eventData.Context;
        if (dbContext == null) return await base.SavingChangesAsync(eventData, result, cancellationToken);

        var domainEvents = dbContext.ChangeTracker.Entries<IHasDomainEvents>()
            .Select(x => x.Entity)
            .SelectMany(entity =>
            {
                var events = entity.GetDomainEvents().ToList();
                entity.ClearDomainEvents();
                return events;
            })
            .ToList();

        if (domainEvents.Any())
        {
            var outboxMessages = domainEvents.Select(domainEvent => new OutboxMessage
            {
                Id = Guid.NewGuid(),
                EventType = domainEvent.GetType().Name,
                Payload = JsonSerializer.Serialize(domainEvent, new JsonSerializerOptions { WriteIndented = true }),
                Exchange = "sdxcore-events",
                RoutingKey = domainEvent.GetType().Name.ToLower(),
                Status = "PENDING",
                StatusGroup = "OUTBOX_STATUS",
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                LastUpdatedAt = DateTime.UtcNow
            }).ToList();

            dbContext.AddRange(outboxMessages);
        }

        return await base.SavingChangesAsync(eventData, result, cancellationToken);
    }
}
