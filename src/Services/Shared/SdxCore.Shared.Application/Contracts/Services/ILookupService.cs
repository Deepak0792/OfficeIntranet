using SdxCore.Shared.Domain.Entities;

namespace SdxCore.Shared.Application.Contracts.Services;

public interface ILookupService
{
    Task<IEnumerable<LookupItem>> GetLookupAsync(string code, Guid? parentId = null, CancellationToken cancellationToken = default);
}
