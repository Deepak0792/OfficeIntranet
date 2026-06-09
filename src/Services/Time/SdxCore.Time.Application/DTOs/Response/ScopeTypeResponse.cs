namespace SdxCore.Time.Application.DTOs.Response;

public class ScopeTypeResponse
{
    public Guid Id { get; set; }
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
    public bool IsActive { get; set; }
}

