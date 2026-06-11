namespace SdxCore.SharedKernel.Persistence.Repositories.Contracts
{
    public interface IUnitOfWork : IAsyncDisposable
    {
        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    }
}
