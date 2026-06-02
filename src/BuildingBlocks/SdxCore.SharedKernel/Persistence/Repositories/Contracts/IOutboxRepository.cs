using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.SharedKernel.Persistence.Repositories.Contracts;
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