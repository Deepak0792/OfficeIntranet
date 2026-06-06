using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class ScopeType : BaseAuditEntity<short>, IPublishableEntity
{
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
    public bool IsActive { get; set; } = true;
}