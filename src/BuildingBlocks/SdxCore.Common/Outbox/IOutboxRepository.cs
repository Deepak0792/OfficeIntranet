using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Common.Outbox;

public interface IOutboxRepository
{
    Task<IReadOnlyList<OutboxMessage>> GetPendingMessagesAsync(int batchSize, CancellationToken cancellationToken = default);
    Task UpdateMessageAsync(OutboxMessage message, CancellationToken cancellationToken = default);
    Task DeletePublishedMessagesAsync(DateTime olderThan, CancellationToken cancellationToken = default);
}
