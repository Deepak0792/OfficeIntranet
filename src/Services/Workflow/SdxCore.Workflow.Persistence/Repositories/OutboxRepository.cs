using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Outbox;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class OutboxRepository : IOutboxRepository
{
    private readonly WorkflowDbContext _context;

    public OutboxRepository(WorkflowDbContext context)
    {
        _context = context;
    }

    public async Task<IReadOnlyList<OutboxMessage>> GetPendingMessagesAsync(int batchSize, CancellationToken cancellationToken = default)
    {
        return await _context.OutboxMessages
            .Where(m => m.Status == "PENDING" || m.Status == "RETRYING")
            .OrderBy(m => m.CreatedAt)
            .Take(batchSize)
            .ToListAsync(cancellationToken);
    }

    public async Task UpdateMessageAsync(OutboxMessage message, CancellationToken cancellationToken = default)
    {
        _context.OutboxMessages.Update(message);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeletePublishedMessagesAsync(DateTime olderThan, CancellationToken cancellationToken = default)
    {
        var messagesToDelete = await _context.OutboxMessages
            .Where(m => (m.Status == "PUBLISHED" || m.Status == "DEAD_LETTERED") && m.LastUpdatedAt < olderThan)
            .ToListAsync(cancellationToken);

        if (messagesToDelete.Any())
        {
            _context.OutboxMessages.RemoveRange(messagesToDelete);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}

