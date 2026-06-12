using SdxCore.Shared.Application.Abstractions.Services;
using SdxCore.Shared.Domain.Abstractions.Repositories;
using SdxCore.Shared.Domain.Entities;

namespace SdxCore.Shared.Application.Services;

public class LookupService : ILookupService
{
    private readonly ILookupRepository _repository;

    public LookupService(ILookupRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<LookupItem>> GetLookupAsync(string code, Guid? parentId = null, CancellationToken cancellationToken = default)
    {
        return await _repository.GetLookupAsync(code, parentId, cancellationToken);
    }
}
