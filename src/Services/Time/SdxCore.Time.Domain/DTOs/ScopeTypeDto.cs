namespace SdxCore.Time.Domain.DTOs;

public class ScopeTypeDto
{
    public short Id { get; set; }
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
    public bool IsActive { get; set; }
}

public class CreateScopeTypeDto
{
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public short HierarchyLevel { get; set; }
}

public class UpdateScopeTypeDto : CreateScopeTypeDto { }
