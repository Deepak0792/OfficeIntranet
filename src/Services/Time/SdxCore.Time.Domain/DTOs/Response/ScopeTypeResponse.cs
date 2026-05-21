namespace SdxCore.Time.Domain.DTOs.Response;

public class ScopeTypeResponse
{
    public short Id { get; set; }
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
    public bool IsActive { get; set; }
}

