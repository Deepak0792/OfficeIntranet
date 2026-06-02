using SdxCore.Shared.Application.Interfaces.Services;
using SdxCore.Shared.Domain.Entities;
using SdxCore.Shared.Domain.Repositories;

namespace SdxCore.Shared.Application.Services;

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
