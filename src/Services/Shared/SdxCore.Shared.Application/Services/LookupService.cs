using SdxCore.Shared.Domain.Entities;
using SdxCore.Shared.Domain.Interfaces;

namespace SdxCore.Shared.Application.Services;

public interface ILookupService
{
    Task<IEnumerable<LookupItem>> GetLookupAsync(string code, string? parentId = null, CancellationToken cancellationToken = default);
}

public class LookupService : ILookupService
{
    private readonly ILookupRepository _repository;

    public LookupService(ILookupRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<LookupItem>> GetLookupAsync(string code, string? parentId = null, CancellationToken cancellationToken = default)
    {
        return await _repository.GetLookupAsync(code, parentId, cancellationToken);
    }
}
