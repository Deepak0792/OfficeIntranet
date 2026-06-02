using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class ScopeType : BaseAuditEntity<short>
{
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
}
