namespace SdxCore.Time.Domain.Entities;
public class ScopeType : BaseEntity
{
    public short Id { get; set; }
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
}
