namespace SdxCore.Time.Application.DTOs.ScopeType.Request;

public class CreateScopeTypeRequest
{
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
}

