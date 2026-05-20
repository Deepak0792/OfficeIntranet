namespace SdxCore.Time.Domain.DTOs;

public class ScopeTypeDto
{
    public long Id { get; set; }
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public int HierarchyLevel { get; set; }
    public bool IsActive { get; set; }
}

public class CreateScopeTypeDto
{
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public int HierarchyLevel { get; set; }
}

public class UpdateScopeTypeDto : CreateScopeTypeDto { }
