namespace SdxCore.Time.Domain.Entities;
public class ScopeType : BaseEntity {
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public int HierarchyLevel { get; set; }
}
