using SdxCore.SharedKernel.Entities;

namespace SdxCore.SharedKernel.Abstractions.Repositories;
public interface IOutboxRepository : IRepository<OutboxMessage, Guid>
{
    Task<List<OutboxMessage>> GetPendingAsync(
    int batchSize,
    CancellationToken cancellationToken);

    Task MarkPublishedAsync(
        Guid id,
        CancellationToken cancellationToken);

    Task MarkFailedAsync(
        Guid id,
        string error,
        CancellationToken cancellationToken);
}