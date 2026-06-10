namespace SdxCore.Workflow.Application.DTOs.Response;

public class ScopeTypeResponse
{
    public Guid Id { get; set; }
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public Guid HierarchyLevel { get; set; }
    public bool IsActive { get; set; }
}