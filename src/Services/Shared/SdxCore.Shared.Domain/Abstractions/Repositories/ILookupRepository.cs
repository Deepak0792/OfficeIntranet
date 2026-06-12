using SdxCore.Shared.Domain.Entities;

namespace SdxCore.Shared.Domain.Abstractions.Repositories;

public interface ILookupRepository
{
    Task<IEnumerable<LookupItem>> GetLookupAsync(string code, Guid? parentId = null, CancellationToken cancellationToken = default);
}

