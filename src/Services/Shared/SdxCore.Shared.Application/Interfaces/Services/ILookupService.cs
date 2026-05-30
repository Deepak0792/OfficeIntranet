using SdxCore.Shared.Domain.Entities;

namespace SdxCore.Shared.Application.Interfaces.Services;

public interface ILookupService
{
    Task<IEnumerable<LookupItem>> GetLookupAsync(string code, string? parentId = null, CancellationToken cancellationToken = default);
}
