using SdxCore.Shared.Domain.Entities;

namespace SdxCore.Shared.Domain.Interfaces.Repositories;

public interface ILookupRepository
{
    Task<IEnumerable<LookupItem>> GetLookupAsync(string code, string? parentId = null, CancellationToken cancellationToken = default);
}

